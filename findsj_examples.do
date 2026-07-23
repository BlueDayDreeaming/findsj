*! version 1.3.0  Reproducing examples for "findsj: Interactive search and citation management"
*! Authors: Yujun Lian and Chucheng Wan
*! Date: 2026-07-23

version 16
clear all
set more off
set linesize 80
capture log close _all

* Run the submitted package files in this directory, not an older SSC copy.
local package_root = subinstr("`c(pwd)'", "\", "/", .)
adopath ++ "`package_root'"
discard

log using "`package_root'/findsj_examples.log", text replace
which findsj
which getiref

* Verify that an author command returns exactly the records whose author field
* contains every query term as a complete name token.
capture program drop verify_author_count
program define verify_author_count
    version 16
    syntax, Query(string) Returned(integer)

    preserve
    quietly use "findsj.dta", clear
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
verify_author_count, query("jenkins") returned(`n_jenkins_local')

display as result "--- Example 6: Local Lian author search ---"
findsj lian, author allresults
local source_lian_local `"`r(search_source)'"'
local n_lian_local = r(n_results)
if `"`source_lian_local'"' != "local" {
    display as error "Expected the local search path for Lian."
    exit 9
}
verify_author_count, query("lian") returned(`n_lian_local')

display as result "--- Example 7: Local Baum author search ---"
findsj baum, author allresults
local source_baum_local `"`r(search_source)'"'
local n_baum_local = r(n_results)
if `"`source_baum_local'"' != "local" {
    display as error "Expected the local search path for Baum."
    exit 9
}
verify_author_count, query("baum") returned(`n_baum_local')

display as result "--- Example 8: Local multiword author search ---"
findsj "Christopher F. Baum", author allresults
local source_fullname_local `"`r(search_source)'"'
local n_fullname_local = r(n_results)
if `"`source_fullname_local'"' != "local" {
    display as error "Expected the local search path for the multiword query."
    exit 9
}
verify_author_count, query("Christopher F. Baum") ///
    returned(`n_fullname_local')


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
    display as result "--- Example 12: Online batch export ---"
    findsj lian, author online txt allresults noclip
    local source_lian_export `"`r(search_source)'"'
    local n_lian_export = r(n_results)
    if `"`source_lian_export'"' != "online" {
        display as error "Expected the online export path for Lian."
        exit 9
    }
    if `n_lian_export' != `n_lian_online' {
        display as error "Online display and export returned different counts."
        exit 9
    }
    confirm file "_findsj_temp_out_.txt"
    preserve
    quietly import delimited using "_findsj_temp_out_.txt", clear ///
        varnames(nonames) stringcols(_all)
    local n_lian_exported_rows = _N
    restore
    if `n_lian_exported_rows' != `n_lian_online' {
        display as error "Online export omitted website result rows."
        exit 9
    }
    capture erase "_findsj_temp_out_.txt"
    display as result ///
        "PASS: Online display and export preserved the same website result count."

    *---------------------------------------------------------------------------
    * Section 4: Citation management
    * Manuscript: Citation management and worked ten-article example
    *---------------------------------------------------------------------------

    display as result "--- Example 13: DOI display and reference links ---"
    findsj did, ref n(1)

    display as result "--- Example 14: Markdown citation from a DOI ---"
    getiref 10.1177/1536867x241233676, md

    display as result "--- Example 15: Batch Markdown export ---"
    findsj causal inference, md n(2) noclip
    capture erase "_findsj_temp_out_.md"

    display as result "--- Example 16: Ten-article plain-text export ---"
    timer clear 1
    timer on 1
    findsj causal inference, txt n(10) noclip
    timer off 1
    timer list 1
    capture erase "_findsj_temp_out_.txt"

    *---------------------------------------------------------------------------
    * Section 5: Database-source display
    * Manuscript: Database structure and updates
    *---------------------------------------------------------------------------

    display as result "--- Example 17: Update-source menu ---"
    findsj, updatesource

    display as text "To update the database manually, run: findsj, update"


    *---------------------------------------------------------------------------
    * Section 6: Isolated download and path-management tests
    * Manuscript: Download path management
    *---------------------------------------------------------------------------

    display as result "--- Example 18: Managing download paths ---"
    findsj, querypath
    findsj, setpath("`demo_path'")
    findsj, querypath

    display as result "--- Example 19: BibTeX and RIS downloads ---"
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
    log close
    exit `isolated_examples_rc'
}
display as result "PASS: caller working directory and path configuration restored."
display as result "PASS: caller linesize remains 80."

capture program drop verify_author_count
display as result "--- All examples and regression checks completed ---"
log close
