*! version 1.1.0  Reproducing examples for "findsj: Interactive search and citation management"
*! Authors: Yujun Lian and Chucheng Wan
*! Date: 2026-07-21

version 16
clear all
set more off
capture log close _all

* Run the submitted package files in this directory, not an older SSC copy.
adopath ++ "`c(pwd)'"
discard

log using "findsj_examples.log", text replace
which findsj
which getiref

*-------------------------------------------------------------------------------
* Section 1: Basic Search Functionality
* Reference: Page 2 (Figure 1) and Page 4 (Section 2.2)
*-------------------------------------------------------------------------------

display as result "--- Example 1: Basic keyword search (Figure 1) ---"
// Searches for "did" (difference-in-differences) in titles, abstracts, and keywords
findsj did

display as result "--- Example 2: Search by Author (Section 2.2) ---"
// Restrict search to author names containing "cox"
findsj cox, author

display as result "--- Example 3: Search by Title (Section 2.2) ---"
// Restrict search to titles containing "panel data"
findsj panel data, title

display as result "--- Example 4: Limiting Results (Section 2.2) ---"
// Show only the first 3 matches for "panel data"
findsj panel data, n(3)

display as result "--- Example 5: Show All Results (Section 2.2) ---"
// Show all matches for "regression" (overriding the default limit of 10)
// Note: This may produce a long output list
findsj regression, allresults


*-------------------------------------------------------------------------------
* Section 2: Targeted Author-search Regression Tests
* Reference: Editor's comments on Jenkins, Lian, and Baum searches
*-------------------------------------------------------------------------------

display as result "--- Example 6: Jenkins Author Search ---"
// Every displayed author list should contain Jenkins as a complete name token
findsj jenkins, author

display as result "--- Example 7: Lian Author Search ---"
// This must not return substring matches such as Iliana, Julian, or Galiani
findsj lian, author

display as result "--- Example 8: Baum Author Search ---"
// Every displayed author list should contain Baum as a complete name token
findsj baum, author


*-------------------------------------------------------------------------------
* Section 3: Citation Management
* Reference: Page 5 (Figure 2 & 3) and Page 6 (Figure 4)
*-------------------------------------------------------------------------------

display as result "--- Example 9: Reference Links (Figure 2) ---"
// Search for "wwwhelp" and include specific reference format links (md, latex, txt)
findsj wwwhelp, ref

display as result "--- Example 10: Generating Markdown Citation via DOI (Figure 3) ---"
// This uses the helper command `getiref` directly, which findsj invokes internally
// Note: This requires an internet connection
getiref 10.1177/1536867x241233676, md

display as result "--- Example 11: Batch Export to Markdown (Figure 4) ---"
// Search "causal inference", limit to 2 results, and export citations to Markdown
// This copies the result to the clipboard and saves a temp file
findsj causal inference, md n(2)


*-------------------------------------------------------------------------------
* Section 4: Database Updates
* Reference: Page 3 (Syntax) and Page 7 (Figure 6)
*-------------------------------------------------------------------------------

display as result "--- Example 12: Update Source Menu (Figure 6) ---"
// Displays interactive menu to choose download source (GitHub/Gitee)
// Note: This command is interactive.
findsj, updatesource

display as result "--- Example 13: Quick Update ---"
// The following command updates the installed database in place. It is shown
// for reproducibility but is not executed while generating this audit log.
// findsj, update
display as text "To update the database, run: findsj, update"


*-------------------------------------------------------------------------------
* Section 5: Download Path Management
* Reference: Page 9 (Section 4.2)
*-------------------------------------------------------------------------------

display as result "--- Example 14: Managing Download Paths ---"

// 1. Check current path
findsj, querypath

// 2. Set a cross-platform temporary path for demonstration purposes
local demo_path "`c(tmpdir)'findsj_demo_references"
capture mkdir "`demo_path'"
findsj, setpath("`demo_path'")

// Verify the new path
findsj, querypath

// 3. Reset to default (current working directory)
findsj, resetpath

// Verify reset
findsj, querypath

// Cleanup demo folder
capture rmdir "`demo_path'"

display as result "--- End of Examples ---"
log close
