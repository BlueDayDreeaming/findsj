*! version 1.2.0  Reproducing examples for "findsj: Interactive search and citation management"
*! Authors: Yujun Lian and Chucheng Wan
*! Date: 2026-07-22

version 16
clear all
set more off
set linesize 80
capture log close _all

* Run the submitted package files in this directory, not an older SSC copy.
adopath ++ "`c(pwd)'"
discard

log using "findsj_examples.log", text replace
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
* Section 2: Targeted author-search regression tests
* Manuscript: How findsj resolves a query
*-------------------------------------------------------------------------------

display as result "--- Example 5: Jenkins author search ---"
findsj jenkins, author allresults
local n_jenkins = r(n_results)
verify_author_count, query("jenkins") returned(`n_jenkins')

display as result "--- Example 6: Lian author search ---"
findsj lian, author allresults
local n_lian = r(n_results)
verify_author_count, query("lian") returned(`n_lian')

display as result "--- Example 7: Baum author search ---"
findsj baum, author allresults
local n_baum = r(n_results)
verify_author_count, query("baum") returned(`n_baum')

display as result "--- Example 8: Multiword author search ---"
findsj "Christopher F. Baum", author allresults
local n_fullname = r(n_results)
verify_author_count, query("Christopher F. Baum") returned(`n_fullname')


*-------------------------------------------------------------------------------
* Section 3: Citation management
* Manuscript: Citation management and worked ten-article example
*-------------------------------------------------------------------------------

display as result "--- Example 9: DOI display and reference links ---"
findsj did, ref n(1)

display as result "--- Example 10: Markdown citation from a DOI ---"
getiref 10.1177/1536867x241233676, md

display as result "--- Example 11: Batch Markdown export ---"
findsj causal inference, md n(2) noclip
capture erase "_findsj_temp_out_.md"

display as result "--- Example 12: Ten-article plain-text export ---"
timer clear 1
timer on 1
findsj causal inference, txt n(10) noclip
timer off 1
timer list 1
capture erase "_findsj_temp_out_.txt"

display as result "--- Example 13: BibTeX and RIS downloads ---"
findsj st0377, bib
confirm file "st0377.bib"
findsj dm0065, ris
confirm file "dm0065.ris"
capture erase "st0377.bib"
capture erase "dm0065.ris"


*-------------------------------------------------------------------------------
* Section 4: Database-source display
* Manuscript: Database structure and updates
*-------------------------------------------------------------------------------

display as result "--- Example 14: Update-source menu ---"
findsj, updatesource

display as text "To update the database manually, run: findsj, update"


*-------------------------------------------------------------------------------
* Section 5: Download-path management
* Manuscript: Download path management
*-------------------------------------------------------------------------------

display as result "--- Example 15: Managing download paths ---"
findsj, querypath

local demo_root = subinstr("`c(tmpdir)'", "\", "/", .)
if substr("`demo_root'", -1, 1) != "/" local demo_root "`demo_root'/"
local demo_path "`demo_root'findsj_demo_references"
capture mkdir "`demo_path'"
findsj, setpath("`demo_path'")
findsj, querypath
findsj, resetpath
findsj, querypath
capture rmdir "`demo_path'"

if c(linesize) != 80 {
    display as error "Regression test failed: findsj changed linesize."
    exit 9
}
display as result "PASS: caller linesize remains 80."

capture program drop verify_author_count
display as result "--- All examples and regression checks completed ---"
log close
