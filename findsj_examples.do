*! version 1.4.5  Reproducing examples for "findsj: Interactive search and citation management"
*! Authors: Yujun Lian and Chucheng Wan
*! Date: 2026-08-02

version 16
clear all
set more off
set linesize 80
capture log close _all

* Run the submitted package files in this directory, not an older SSC copy.
local package_root = subinstr("`c(pwd)'", "\", "/", .)
adopath ++ "`package_root'"
discard

log using "findsj_examples.log", text replace

* Record the submitted program versions without printing machine-specific paths.
quietly findfile findsj.ado
local findsj_file `"`r(fn)'"'
tempname findsj_handle
file open `findsj_handle' using `"`findsj_file'"', read text
file read `findsj_handle' findsj_version
file close `findsj_handle'
display as text "`findsj_version'"

* Locate the bundled runtime database through adopath. This works both when
* reproducing a submission directory and after net/SSC installation into PLUS.
quietly findfile findsj.dta
local findsj_data_file `"`r(fn)'"'

quietly findfile _getiref.ado
local getiref_file `"`r(fn)'"'
tempname getiref_handle
file open `getiref_handle' using `"`getiref_file'"', read text
file read `getiref_handle' getiref_version
file close `getiref_handle'
display as text "`getiref_version'"

* Verify that an author command returns exactly the records whose author field
* contains every query term as a complete name token.
capture program drop verify_author_count
program define verify_author_count
    version 16
    syntax, Query(string) Returned(integer) Datafile(string)

    preserve
    quietly use `"`datafile'"', clear
    capture confirm variable authors
    if !_rc rename authors author

    tempvar author_tokens matched
    quietly gen strL `author_tokens' = ustrlower(author)
    quietly replace `author_tokens' = ///
        ustrregexra(`author_tokens', "[^\p{L}\p{N}_]+", " ")
    quietly replace `author_tokens' = ///
        " " + strtrim(stritrim(`author_tokens')) + " "

    local query_clean = ///
        ustrlower(ustrregexra(`"`query'"', "[^\p{L}\p{N}_]+", " "))
    local query_clean = strtrim(stritrim(`"`query_clean'"'))
    local n_words = wordcount(`"`query_clean'"')

    quietly gen byte `matched' = 1
    forvalues i = 1/`n_words' {
        local query_word = word(`"`query_clean'"', `i')
        quietly replace `matched' = 0 if ///
            strpos(`author_tokens', " `query_word' ") == 0
    }

    quietly count if `matched'
    local expected = r(N)
    restore

    if `returned' != `expected' {
        display as error "Author-search regression test failed for: `query'"
        display as error "Command returned `returned'; expected `expected'."
        exit 9
    }
    display as result ///
        "PASS: `query' returned all `returned' complete-token matches."
end

* Inspect a batch export as raw text, rather than importing it as delimited
* data. This catches unwanted CSV quoting and format-specific escaping errors.
capture program drop verify_export_file
program define verify_export_file
    version 16
    syntax using/, Format(string) Expected(integer) ///
        [Firstid(string) Contains(string) Excludes(string)]

    local format = lower(`"`format'"')
    if !inlist(`"`format'"', "markdown", "latex", "plain") {
        display as error "Unknown export format in regression test: `format'"
        exit 198
    }

    tempname export_handle
    capture file open `export_handle' using `"`using'"', read text
    if _rc {
        display as error "Could not open export file: `using'"
        exit _rc
    }

    local n_lines 0
    local outer_quotes 0
    local missing_marker 0
    local doubled_href 0
    local unescaped_percent 0
    local first_identity_mismatch 0
    local required_text_found = (`"`contains'"' == "")
    local excluded_text_found 0

    file read `export_handle' export_line
    while r(eof) == 0 {
        if strtrim(`"`export_line'"') != "" {
            local n_lines = `n_lines' + 1

            if `n_lines' == 1 & `"`firstid'"' != "" {
                if strpos(`"`export_line'"', `"`firstid'"') == 0 {
                    local first_identity_mismatch 1
                }
            }

            if `"`contains'"' != "" & ///
               strpos(`"`export_line'"', `"`contains'"') > 0 {
                local required_text_found 1
            }
            if `"`excludes'"' != "" & ///
               strpos(`"`export_line'"', `"`excludes'"') > 0 {
                local excluded_text_found 1
            }

            if substr(`"`export_line'"', 1, 1) == char(34) | ///
               substr(`"`export_line'"', -1, 1) == char(34) {
                local outer_quotes = `outer_quotes' + 1
            }

            if `"`format'"' == "markdown" {
                if strpos(`"`export_line'"', "[Link](") == 0 {
                    local missing_marker = `missing_marker' + 1
                }
            }
            else if `"`format'"' == "latex" {
                if strpos(`"`export_line'"', "\href{") == 0 {
                    local missing_marker = `missing_marker' + 1
                }
                if strpos(`"`export_line'"', "\\href{") > 0 {
                    local doubled_href = `doubled_href' + 1
                }
                local percent_check = ///
                    subinstr(`"`export_line'"', "\%", "", .)
                if strpos(`"`percent_check'"', "%") > 0 {
                    local unescaped_percent = `unescaped_percent' + 1
                }
            }
            else if `"`format'"' == "plain" {
                if strpos(`"`export_line'"', "Link: https://") == 0 {
                    local missing_marker = `missing_marker' + 1
                }
            }
        }
        file read `export_handle' export_line
    }
    file close `export_handle'

    if `n_lines' != `expected' {
        display as error ///
            "`format' export contained `n_lines' records; expected `expected'."
        exit 9
    }
    if `outer_quotes' {
        display as error ///
            "`format' export wrapped one or more records in CSV quotes."
        exit 9
    }
    if `missing_marker' {
        display as error ///
            "`format' export omitted its expected link syntax."
        exit 9
    }
    if `doubled_href' {
        display as error ///
            "LaTeX export used a doubled backslash before href."
        exit 9
    }
    if `unescaped_percent' {
        display as error ///
            "LaTeX export contained an unescaped percent sign."
        exit 9
    }
    if `first_identity_mismatch' {
        display as error ///
            "The first export record did not match returned art_id_1."
        exit 9
    }
    if !`required_text_found' {
        display as error ///
            "`format' export omitted required citation text: `contains'"
        exit 9
    }
    if `excluded_text_found' {
        display as error ///
            "`format' export retained excluded citation text: `excludes'"
        exit 9
    }

    display as result ///
        "PASS: `format' export has `expected' raw, correctly formatted records."
end


*-------------------------------------------------------------------------------
* Section 1: Basic search functionality
* Manuscript: Introduction and Syntax and usage
*-------------------------------------------------------------------------------

display as result "--- Example 1: Basic keyword search ---"
findsj did, n(3)

display as result "--- Example 2: Search by author ---"
findsj cox, author

display as result "--- Example 3: Multiword title search ---"
findsj panel data, title

display as result "--- Example 4: Limiting displayed results ---"
findsj panel data, n(3)


*-------------------------------------------------------------------------------
* Section 2: Targeted local author-search regression tests
* Manuscript: How findsj resolves a query
*-------------------------------------------------------------------------------

display as result "--- Example 5: Local Jenkins author search ---"
findsj jenkins, author allresults
local source_jenkins_local `"`r(search_source)'"'
local n_jenkins_local = r(n_results)
if `"`source_jenkins_local'"' != "local" {
    display as error "Expected the local search path for Jenkins."
    exit 9
}
verify_author_count, query("jenkins") returned(`n_jenkins_local') ///
    datafile(`"`findsj_data_file'"')

display as result "--- Example 6: Local Lian author search ---"
findsj lian, author allresults
local source_lian_local `"`r(search_source)'"'
local n_lian_local = r(n_results)
if `"`source_lian_local'"' != "local" {
    display as error "Expected the local search path for Lian."
    exit 9
}
verify_author_count, query("lian") returned(`n_lian_local') ///
    datafile(`"`findsj_data_file'"')

display as result "--- Example 7: Local Baum author search ---"
findsj baum, author allresults
local source_baum_local `"`r(search_source)'"'
local n_baum_local = r(n_results)
if `"`source_baum_local'"' != "local" {
    display as error "Expected the local search path for Baum."
    exit 9
}
verify_author_count, query("baum") returned(`n_baum_local') ///
    datafile(`"`findsj_data_file'"')

display as result "--- Example 8: Local multiword author search ---"
findsj "Christopher F. Baum", author allresults
local source_fullname_local `"`r(search_source)'"'
local n_fullname_local = r(n_results)
if `"`source_fullname_local'"' != "local" {
    display as error "Expected the local search path for the multiword query."
    exit 9
}
verify_author_count, query("Christopher F. Baum") ///
    returned(`n_fullname_local') datafile(`"`findsj_data_file'"')


*-------------------------------------------------------------------------------
* Section 3: Stata Journal website-supplied results
* Manuscript: Local and online search semantics
*-------------------------------------------------------------------------------

display as result "--- Example 9: Online Jenkins author search ---"
findsj jenkins, author online allresults
local source_jenkins_online `"`r(search_source)'"'
local n_jenkins_online = r(n_results)
if `"`source_jenkins_online'"' != "online" {
    display as error "Expected the online search path for Jenkins."
    exit 9
}
display as result ///
    "PASS: Jenkins used the online search source."
display as text "Local complete-token count: `n_jenkins_local'; " ///
    "website count: `n_jenkins_online'."

display as result "--- Example 10: Online Lian author search ---"
findsj lian, author online allresults
local source_lian_online `"`r(search_source)'"'
local n_lian_online = r(n_results)
if `"`source_lian_online'"' != "online" {
    display as error "Expected the online search path for Lian."
    exit 9
}
display as result ///
    "PASS: Lian used the online search source."
display as text "Local complete-token count: `n_lian_local'; " ///
    "website count: `n_lian_online'."

display as result "--- Example 11: Online Baum author search ---"
findsj baum, author online allresults
local source_baum_online `"`r(search_source)'"'
local n_baum_online = r(n_results)
if `"`source_baum_online'"' != "online" {
    display as error "Expected the online search path for Baum."
    exit 9
}
display as result ///
    "PASS: Baum used the online search source."
display as text "Local complete-token count: `n_baum_local'; " ///
    "website count: `n_baum_online'."

* All remaining examples that write files or settings run in a unique temporary
* workspace. The caller's directory and path configuration are restored below,
* including after a captured error.
local original_personal "`c(sysdir_personal)'"
local saved_download_global `"$findsj_download_path"'
tempfile workspace_stub
local example_workspace "`workspace_stub'_workspace"
local isolated_personal "`example_workspace'/personal"
local demo_path "`isolated_personal'/downloads"
capture mkdir "`example_workspace'"
capture mkdir "`isolated_personal'"
capture mkdir "`demo_path'"
cd "`example_workspace'"
sysdir set PERSONAL "`isolated_personal'/"
global findsj_download_path ""

capture noisily {
    *---------------------------------------------------------------------------
    * Section 4: Raw batch-export regression tests
    * Manuscript: Citation management
    *---------------------------------------------------------------------------

    display as result "--- Example 12: Local Markdown export ---"
    findsj did, md n(2) noclip
    local export_source `"`r(search_source)'"'
    local export_total = r(n_results)
    if `"`export_source'"' != "local" | `export_total' < 2 {
        display as error "Local Markdown export returned unexpected results."
        exit 9
    }
    verify_export_file using "_findsj_temp_out_.md", ///
        format(markdown) expected(2) ///
        contains("Clarke, D., Pailañir, D., Athey, S., & Imbens, G. (2024).") ///
        excludes("Clarke, Damian;")
    capture erase "_findsj_temp_out_.md"

    display as result "--- Example 13: Local LaTeX export ---"
    findsj did, latex n(2) noclip
    local export_source `"`r(search_source)'"'
    local export_total = r(n_results)
    if `"`export_source'"' != "local" | `export_total' < 2 {
        display as error "Local LaTeX export returned unexpected results."
        exit 9
    }
    verify_export_file using "_findsj_temp_out_.tex", ///
        format(latex) expected(2) ///
        contains("Clarke, D.") excludes("Clarke, Damian;")
    capture erase "_findsj_temp_out_.tex"

    display as result "--- Example 14: Local plain-text export ---"
    findsj did, plain n(2) noclip
    local export_source `"`r(search_source)'"'
    local export_total = r(n_results)
    if `"`export_source'"' != "local" | `export_total' < 2 {
        display as error "Local plain-text export returned unexpected results."
        exit 9
    }
    verify_export_file using "_findsj_temp_out_.txt", ///
        format(plain) expected(2) ///
        contains("Clarke, D., Pailañir, D., Athey, S., & Imbens, G. (2024).") ///
        excludes("Clarke, Damian;")
    capture erase "_findsj_temp_out_.txt"

    display as result "--- Example 15: Online Markdown alias export ---"
    findsj lian, author online markdown n(2) noclip
    local export_source `"`r(search_source)'"'
    local export_total = r(n_results)
    local export_first_id `"`r(art_id_1)'"'
    if `"`export_source'"' != "online" | ///
       `export_total' != `n_lian_online' | ///
       `"`export_first_id'"' == "" {
        display as error "Online Markdown export returned unexpected results."
        exit 9
    }
    verify_export_file using "_findsj_temp_out_.md", ///
        format(markdown) expected(2) firstid(`"`export_first_id'"')
    capture erase "_findsj_temp_out_.md"
    display as result ///
        "PASS: Online display and export preserved the website result count."

    display as result "--- Example 16: Online LaTeX alias export ---"
    findsj lian, author online tex n(2) noclip
    local export_source `"`r(search_source)'"'
    local export_total = r(n_results)
    local export_first_id `"`r(art_id_1)'"'
    if `"`export_source'"' != "online" | `export_total' < 2 | ///
       `"`export_first_id'"' == "" {
        display as error "Online LaTeX export returned unexpected results."
        exit 9
    }
    verify_export_file using "_findsj_temp_out_.tex", ///
        format(latex) expected(2) firstid(`"`export_first_id'"')
    capture erase "_findsj_temp_out_.tex"

    display as result "--- Example 17: Online plain-text alias export ---"
    findsj lian, author online txt n(2) noclip
    local export_source `"`r(search_source)'"'
    local export_total = r(n_results)
    local export_first_id `"`r(art_id_1)'"'
    if `"`export_source'"' != "online" | `export_total' < 2 | ///
       `"`export_first_id'"' == "" {
        display as error "Online plain-text export returned unexpected results."
        exit 9
    }
    verify_export_file using "_findsj_temp_out_.txt", ///
        format(plain) expected(2) firstid(`"`export_first_id'"')
    capture erase "_findsj_temp_out_.txt"

    *---------------------------------------------------------------------------
    * Section 5: Returned-results and input-validation regression tests
    * Manuscript: Syntax and usage
    *---------------------------------------------------------------------------

    display as result "--- Example 18: Local zero-result return contract ---"
    findsj zzzxqvnonexistentfindsjtest, n(1)
    local zero_source `"`r(search_source)'"'
    local zero_results = r(n_results)
    if `"`zero_source'"' != "local" | `zero_results' != 0 {
        display as error ///
            "Local zero-result search did not return n_results=0/source=local."
        exit 9
    }
    display as result ///
        "PASS: Local zero-result search returned n_results=0 and source=local."

    display as result "--- Example 19: Online zero-result return contract ---"
    findsj zzzxqvnonexistentfindsjtest, online n(1)
    local zero_source `"`r(search_source)'"'
    local zero_results = r(n_results)
    if `"`zero_source'"' != "online" | `zero_results' != 0 {
        display as error ///
            "Online zero-result search did not return n_results=0/source=online."
        exit 9
    }
    display as result ///
        "PASS: Online zero-result search returned n_results=0 and source=online."

    display as result "--- Example 20: Reject nonpositive n() ---"
    capture noisily findsj did, n(0)
    local invalid_n_rc = _rc
    if `invalid_n_rc' != 198 {
        display as error "n(0) returned error `invalid_n_rc'; expected 198."
        exit 9
    }
    display as result "PASS: n(0) was rejected with error 198."

    *---------------------------------------------------------------------------
    * Section 6: Citation management
    * Manuscript: Citation management and worked ten-article example
    *---------------------------------------------------------------------------

    display as result "--- Example 21: DOI display and reference links ---"
    findsj did, ref n(1)
    local did_doi `"`r(doi_1)'"'
    if lower(`"`did_doi'"') != "10.1177/1536867x241297914" {
        display as error ///
            "The first DID result returned an unexpected DOI: `did_doi'"
        exit 9
    }
    display as result ///
        "PASS: The displayed DID result and citation DOI are identical."

    display as result "--- Example 22: Markdown citation from a DOI ---"
    _getiref 10.1177/1536867x241297914, md
    local getiref_body = strtrim(`"`r(refbody)'"')

    preserve
    quietly use `"`findsj_data_file'"', clear
    quietly keep if lower(doi) == "10.1177/1536867x241297914"
    if _N != 1 {
        display as error ///
            "Expected one cached citation for the displayed DID article."
        exit 9
    }
    local cached_body = strtrim(citation_apa[1])
    restore

    if `"`getiref_body'"' != `"`cached_body'"' {
        display as error ///
            "Per-article and cached batch citation bodies do not agree."
        exit 9
    }
    display as result ///
        "PASS: Per-article and batch citation bodies use the same APA text."

    display as result "--- Example 23: Batch Markdown export ---"
    findsj causal inference, md n(2) noclip
    capture erase "_findsj_temp_out_.md"

    display as result "--- Example 24: Ten-article plain-text export ---"
    timer clear 1
    timer on 1
    findsj causal inference, txt n(10) noclip
    timer off 1
    timer list 1
    capture erase "_findsj_temp_out_.txt"

    *---------------------------------------------------------------------------
    * Section 7: Database-update command
    * Manuscript: Database structure and updates
    *---------------------------------------------------------------------------

    display as result "--- Example 25: Database-update command ---"
    display as text "Run: findsj, update"
    display as text "The command is not executed here because it replaces the installed database."


    *---------------------------------------------------------------------------
    * Section 8: Isolated download and path-management tests
    * Manuscript: Download path management
    *---------------------------------------------------------------------------

    display as result "--- Example 26: Managing download paths ---"
    findsj, querypath
    findsj, setpath("`demo_path'")
    findsj, querypath

    display as result "--- Example 27: BibTeX and RIS downloads ---"
    findsj st0377, bib
    confirm file "`demo_path'/st0377.bib"
    findsj dm0065, ris
    confirm file "`demo_path'/dm0065.ris"

    findsj, resetpath
    findsj, querypath

    if c(linesize) != 80 {
        display as error "Regression test failed: findsj changed linesize."
        exit 9
    }
}
local isolated_examples_rc = _rc

* Restore caller state before evaluating the captured return code.
cd "`package_root'"
sysdir set PERSONAL "`original_personal'"
global findsj_download_path `"`saved_download_global'"'

* Remove only files and directories created inside the unique workspace.
capture erase "`example_workspace'/_findsj_temp_out_.md"
capture erase "`example_workspace'/_findsj_temp_out_.txt"
capture erase "`example_workspace'/_findsj_temp_out_.tex"
capture erase "`demo_path'/st0377.bib"
capture erase "`demo_path'/dm0065.ris"
capture erase "`isolated_personal'/findsj_config.txt"
capture rmdir "`example_workspace'/_temp_getref_"
capture rmdir "`demo_path'"
capture rmdir "`isolated_personal'"
capture rmdir "`example_workspace'"

if `isolated_examples_rc' {
    display as error "Isolated file-writing examples failed."
    capture program drop verify_author_count
    capture program drop verify_export_file
    log close
    exit `isolated_examples_rc'
}
display as result "PASS: caller working directory and path configuration restored."
display as result "PASS: caller linesize remains 80."

capture program drop verify_author_count
capture program drop verify_export_file
display as result "--- All examples and regression checks completed ---"
log close
