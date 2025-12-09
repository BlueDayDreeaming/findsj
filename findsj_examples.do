*===============================================================================
* findsj - Examples and Demonstrations
* Version 1.4.0
* Last updated: 2025/12/08
*
* Authors: Yujun Lian 
*          Chucheng Wan
*
* This file demonstrates all features and use cases of findsj command
*===============================================================================

* Start logging
capture log close
log using "findsj_examples.log", replace text

clear all
set more off


*===============================================================================
* SECTION 1: Basic Search Examples
*===============================================================================

* Example 1.1: Simple keyword search (default)
* Search for articles containing "panel data" in keyword field
findsj panel data

* Example 1.2: Limit number of results displayed
* Show only top 5 results instead of default 10
findsj panel data, n(5)

* Example 1.3: Show all search results
* Display all matching articles (no limit)
findsj panel data, allresults


*===============================================================================
* SECTION 2: Search by Different Fields
*===============================================================================

* Example 2.1: Search by author name
* Find all articles by "Nicholas J. Cox"
findsj Cox, author

* Example 2.2: Search by article title
* Search for "causal inference" in article titles only
findsj causal inference, title

* Example 2.3: Search by keyword (explicit)
* Same as default, but explicitly specified
findsj regression, keyword


*===============================================================================
* SECTION 3: Interactive Buttons - Search Results
*===============================================================================

* When you run a search, each article displays 7 clickable buttons:
* [Article] - Opens article webpage in browser
* [PDF]     - Opens full-text PDF in browser (requires DOI)
* [Google]  - Searches Google Scholar for the article
* [Install] - Searches for related Stata packages to install
* [Ref]     - Displays citation format buttons (.md/.latex/.txt)
* [BibTeX]  - Downloads BibTeX citation file
* [RIS]     - Downloads RIS citation file (for reference managers)

* Example 3.1: Basic search with all buttons visible
findsj synthetic control, n(3)

* Example 3.2: Hide PDF button (when DOI not needed)
findsj regression, nopdf

* Example 3.3: Hide package search button
findsj fixed effects, nopkg

* Example 3.4: Disable all browser links (text-only mode)
findsj causal inference, nobrowser


*===============================================================================
* SECTION 4: Citation Generation - Individual Article
*===============================================================================

* The [Ref] button shows three citation format buttons for each article:
* [.md]    - Markdown format (for Markdown documents)
* [.latex] - LaTeX format (for LaTeX/TeX documents)
* [.txt]   - Plain text format (for plain text documents)

* Example 4.1: Display citation buttons for search results
* Click the [Ref] button to see .md/.latex/.txt buttons
findsj propensity score matching, ref n(5)

* Example 4.2: Show citation buttons for specific article
* Use article ID (e.g., "st0001") to show citation buttons directly
findsj st0547, ref


*===============================================================================
* SECTION 5: Batch Citation Export
*===============================================================================

* Export all search results as formatted citations to file
* Citations are automatically copied to clipboard (unless noclip specified)
* Four access buttons appear: [View] [Open_Mac] [Open_Win] [dir]

* Example 5.1: Export to Markdown format
* File: _findsj_temp_out_.md in current directory
findsj instrumental variable, md

* Example 5.2: Export to LaTeX format
* File: _findsj_temp_out_.txt (LaTeX code)
findsj causal inference, latex

* Example 5.3: Export to plain text format
* File: _findsj_temp_out_.txt (plain text)
findsj panel data, plain

* Example 5.4: Export with markdown option (alias)
* Both "md" and "markdown" options work the same
findsj causal inference, markdown

* Example 5.5: Export with tex option (alias for latex)
* Both "latex" and "tex" options work the same
findsj time series, tex

* Example 5.6: Export without copying to clipboard
* Use noclip to skip automatic clipboard copy
findsj regression, md noclip

* Example 5.7: Combine with other options
* Export limited results without PDF links
findsj fixed effects, latex nopdf n(5)


*===============================================================================
* SECTION 6: File Access Buttons (After Export)
*===============================================================================

* After exporting citations, four buttons appear to access the output file:
* [View]     - Opens file in Stata's viewer window
* [Open_Mac] - Opens file with default Mac application
* [Open_Win] - Opens file with default Windows application
* [dir]      - Opens the containing directory in file explorer

* The buttons are clickable after running any export command (md/latex/plain)

* Example 6.1: Export and use file access buttons
findsj synthetic control, md n(3)
* Now click [View] to see file in Stata viewer
* Or click [Open_Win] on Windows / [Open_Mac] on Mac to open in default app
* Or click [dir] to open the folder containing the file


*===============================================================================
* SECTION 7: Download Citation Files (BibTeX and RIS)
*===============================================================================

* Each article has [BibTeX] and [RIS] buttons for downloading citation files
* Files are saved to current directory (or custom path, see Section 13)

* Example 7.1: Search and download BibTeX file
* Click [BibTeX] button for desired article after running:
findsj instrumental variable, n(3)

* Example 7.2: Search and download RIS file  
* Click [RIS] button for desired article after running:
findsj panel data, n(3)

* Example 7.3: Direct download using article ID
* Download BibTeX file for specific article
findsj st0547, type(bib)

* Example 7.4: Direct download RIS file for specific article
findsj st0547, type(ris)


*===============================================================================
* SECTION 8: Database Management - Update
*===============================================================================

* The findsj database contains DOI and page information for all articles
* Database is automatically checked for updates (monthly)
* Manual update options available via three sources

* Example 8.1: Show update options
* Display clickable update source buttons
findsj, update

* Example 8.2: Update from GitHub (international users)
* Recommended for users outside China
findsj, update source(github)

* Example 8.3: Update from Gitee (China users)
* Faster for users in China
findsj, update source(gitee)

* Example 8.4: Update with auto-fallback
* Try GitHub first, then Gitee if GitHub fails
findsj, update source(both)


*===============================================================================
* SECTION 9: Database Management - Automatic Update Check
*===============================================================================

* findsj automatically checks database age once per day
* If database is >120 days old, update reminder appears
* No action needed - just run any findsj command normally

* Example 9.1: Normal search triggers automatic check
findsj regression
* If database is old, you'll see an update reminder with clickable links

* Note: Update reminder uses GitHub Actions to monitor Stata Journal website
*       Database is updated monthly to include new articles


*===============================================================================
* SECTION 10: Download Path Configuration
*===============================================================================

* Configure where BibTeX/RIS files are downloaded
* Default: current working directory
* Settings persist across Stata sessions

* Example 10.1: Query current download path
findsj, querypath

* Example 10.2: Set custom download path
* Change download location (must be valid directory)
* Note: Command commented out - adjust path to your actual directory before running
* findsj, setpath("D:\\References\\Stata")

* Example 10.3: Reset to default path
* Clear custom path, return to using current directory
* findsj, resetpath


*===============================================================================
* SECTION 11: Advanced Features - DOI Information
*===============================================================================

* DOI (Digital Object Identifier) enables PDF links and citations
* DOIs are fetched automatically from local database or online

* Example 11.1: Basic search with DOI lookup
* DOIs fetched automatically when available
findsj synthetic control, ref

* Example 11.2: Explicit DOI retrieval
* Force DOI lookup even without ref option
findsj panel data, getdoi

* Example 11.3: Search without local database
* If findsj.dta not found, DOIs fetched online (slower)
* One-time notice shown with database update instructions
findsj instrumental variable, ref


*===============================================================================
* SECTION 12: Combining Options
*===============================================================================

* Multiple options can be combined for customized searches

* Example 12.1: Author search with limited results and Markdown export
findsj Cox, author md n(5)

* Example 12.2: Title search with LaTeX export, no PDF, no clipboard
findsj matching, title latex nopdf noclip

* Example 12.3: Keyword search with all results and plain text export
findsj causal inference, keyword plain allresults

* Example 12.4: Search with package button hidden and citations shown
findsj fixed effects, nopkg ref n(3)

* Example 12.5: Complete customization
findsj regression, author markdown nopdf nopkg n(10)


*===============================================================================
* SECTION 13: Understanding Return Values
*===============================================================================

* findsj stores search information in r() results
* Useful for programming and automation

* Example 13.1: Display return values after search
findsj panel data, n(3)
return list

* Return values include:
* r(keywords)   - Search keywords used
* r(scope)      - Search scope (author/title/keyword)
* r(url)        - Full search URL on Stata Journal website
* r(n_results)  - Total number of articles found
* r(art_id_1)   - Article ID of first result
* r(title_1)    - Title of first result  
* r(author_1)   - Author of first result
* r(doi_1)      - DOI of first result (if available)
* r(url_1)      - Article URL of first result

* Example 13.2: Use return values in programming
findsj instrumental variable, n(1)
display "Found `r(n_results)' articles"
display "First article: `r(title_1)'"
display "By: `r(author_1)'"


*===============================================================================
* SECTION 14: Working with Article IDs
*===============================================================================

* Each article has unique ID (format: st0001, dm0065, etc.)
* Article IDs can be used directly for various operations

* Example 14.1: Show citation buttons for specific article
* Using article ID instead of keyword search
findsj st0547, ref

* Example 14.2: Download specific article's BibTeX file
findsj st0547, type(bib)

* Example 14.3: Download specific article's RIS file
findsj st0547, type(ris)

* Note: Article IDs shown in search results can be used directly
*       Format: letters followed by numbers (e.g., st0547, dm0065)


*===============================================================================
* SECTION 15: Workflow Examples
*===============================================================================

* Example 15.1: Research Literature Review Workflow
* Step 1: Search for relevant articles
findsj causal inference, n(10)

* Step 2: Click [Article] buttons to read abstracts online
* Step 3: Click [PDF] buttons to read full papers
* Step 4: Click [Google] buttons to find citations and related work
* Step 5: Export citations in preferred format
findsj causal inference, markdown n(10)

* Step 6: Click [View] to review exported citations
* Step 7: Copy-paste from clipboard into your document


* Example 15.2: Package Installation Workflow
* Step 1: Find articles about specific method
findsj propensity score matching, n(5)

* Step 2: Click [Install] buttons to find related packages
* Step 3: Install packages from search results


* Example 15.3: Reference Management Workflow
* Step 1: Search for articles
findsj instrumental variable, n(5)

* Step 2: Click [BibTeX] or [RIS] buttons to download citation files
* Step 3: Import downloaded files into reference manager (Zotero, EndNote, Mendeley)


* Example 15.4: Writing Paper Workflow
* Step 1: Set custom download path for project (adjust path as needed)
* findsj, setpath("D:\\Projects\\MyPaper\\References")

* Step 2: Search and download citations
findsj synthetic control, n(5)

* Step 3: Click [BibTeX] buttons to download citation files
* Step 4: Export formatted citations for manuscript
findsj synthetic control, latex n(5)

* Step 5: Click [View] to see formatted citations
* Step 6: Use clipboard content in LaTeX document


*===============================================================================
* SECTION 16: Tips and Best Practices
*===============================================================================

* Tip 1: Use specific keywords for better results
* Instead of: findsj data
* Better:     findsj panel data fixed effects

* Tip 2: Use author search for finding all papers by researcher
findsj Cox, author

* Tip 3: Use title search for finding specific paper
findsj Flexible parametric survival analysis, title

* Tip 4: Update database regularly for newest articles
findsj, update source(both)

* Tip 5: Set download path once for project
* findsj, setpath("D:\\CurrentProject\\References")

* Tip 6: Use markdown export for README files and wikis
findsj regression, markdown n(5)

* Tip 7: Use latex export for academic papers
findsj instrumental variable, latex n(10)

* Tip 8: Use plain text for simple documentation
findsj fixed effects, plain n(5)

* Tip 9: Use ref option to see citation buttons without exporting
findsj causal inference, ref n(3)

* Tip 10: Combine nopdf and nopkg to reduce clutter
findsj panel data, nopdf nopkg n(5)


*===============================================================================
* SECTION 17: Troubleshooting
*===============================================================================

* Problem 1: "No articles found"
* Solution: Try different keywords or search scope
findsj panel, keyword
findsj panel, title
findsj panel, author

* Problem 2: PDF button not working
* Solution: Article might not have DOI. Update database:
findsj, update source(both)

* Problem 3: Slow search performance
* Solution: Update local database for faster DOI lookups:
findsj, update source(github)

* Problem 4: Download path not working
* Solution: Verify directory exists and reset if needed:
findsj, querypath
* findsj, resetpath

* Problem 5: Citation format buttons not showing
* Solution: Make sure to use ref option:
findsj panel data, ref

* Problem 6: Clipboard not working
* Solution: Use noclip to skip clipboard and access file directly:
findsj panel data, md noclip


*===============================================================================
* SECTION 18: Platform-Specific Notes
*===============================================================================

* Windows Users:
* - File access: Use [Open_Win] button to open exported files
* - Clipboard: Uses PowerShell, automatically available
* - Download path: Use Windows path format (e.g., "D:\References")

* Example for Windows:
findsj instrumental variable, md
* Click [Open_Win] to open file in default application

* Mac Users:
* - File access: Use [Open_Mac] button to open exported files  
* - Clipboard: Uses pbcopy, automatically available
* - Download path: Use Unix path format (e.g., "/Users/name/References")

* Example for Mac:
findsj instrumental variable, md
* Click [Open_Mac] to open file in default application

* Universal:
* - [View] button works on all platforms (opens in Stata viewer)
* - [dir] button opens containing directory on all platforms


*===============================================================================
* SECTION 19: Integration with getiref
*===============================================================================

* findsj integrates with getiref command for citation generation
* Citation format buttons (.md/.latex/.txt) call getiref internally

* Example 19.1: findsj search with citation buttons
findsj synthetic control, ref n(3)
* Click .md/.latex/.txt buttons to generate citations via getiref

* Example 19.2: Verify getiref integration
* After clicking a citation button, check if getiref executed:
return list

* Note: getiref must be installed for citation buttons to work
* Install getiref if needed:
ssc install getiref, replace


*===============================================================================
* SECTION 20: Advanced Programming Examples
*===============================================================================

* Example 20.1: Loop through search results
findsj panel data, n(5)
local n_found = r(n_results)
display "Total articles found: `n_found'"

* Example 20.2: Extract first result information
findsj instrumental variable, n(1)
local first_title = r(title_1)
local first_author = r(author_1)
local first_id = r(art_id_1)
display "Article: `first_title'"
display "Author: `first_author'"
display "ID: `first_id'"

* Example 20.3: Conditional search based on results
findsj regression, n(1)
if r(n_results) > 0 {
    display "Articles found. Title: `r(title_1)'"
}
else {
    display "No articles found. Try different keywords."
}

* Example 20.4: Build search URL for external use
findsj causal inference, n(1)
local search_url = r(url)
display "Full search results: `search_url'"

* Example 20.5: Automate multiple searches
foreach topic in "panel data" "instrumental variable" "fixed effects" {
    display _n "Searching: `topic'"
    findsj `topic', n(3)
    display "Found `r(n_results)' articles"
}


*===============================================================================
* SECTION 21: Citation Format Comparison
*===============================================================================

* Same search, three different export formats for comparison

* Example 21.1: Markdown format
findsj synthetic control, markdown n(3)
* Output: [Link](url), [PDF](url), [Google](<url>)
* Best for: GitHub README, Markdown documents, wikis

* Example 21.2: LaTeX format
findsj synthetic control, latex n(3)
* Output: \href{url}{Link}, \href{url}{PDF}, \href{url}{Google}
* Best for: Academic papers, LaTeX documents, dissertations

* Example 21.3: Plain text format
findsj synthetic control, plain n(3)
* Output: Link: url, PDF: url, Google: url
* Best for: Plain text documents, emails, simple notes


*===============================================================================
* SECTION 22: Database Version Check
*===============================================================================

* findsj automatically checks database age and notifies if update needed
* Checks run once per day, non-intrusive

* Example 22.1: Trigger automatic check
* Any findsj command triggers the check
findsj regression

* Example 22.2: Manual database information
* Check when database was last updated (if file exists)
findsj, update
* Shows update options and current database status


*===============================================================================
* SECTION 23: Complete Real-World Example
*===============================================================================

* Scenario: Writing a paper on causal inference methods
* Need to cite key Stata Journal articles

* Step 1: Set up download path for project (adjust paths as needed)
* cd "D:\\Projects\\Causal_Paper"
* findsj, setpath("D:\\Projects\\Causal_Paper\\References")

* Step 2: Search for relevant articles
findsj causal inference, allresults

* Step 3: Review articles by clicking [Article] and [PDF] buttons
* (Interactive: click buttons in Stata results window)

* Step 4: Download BibTeX files for reference manager
* (Interactive: click [BibTeX] buttons for selected articles)

* Step 5: Export formatted citations for manuscript
findsj causal inference, latex n(10)

* Step 6: View exported citations
* (Interactive: click [View] button)

* Step 7: Paste from clipboard into LaTeX document
* Press Ctrl+V (Windows) or Command+V (Mac)

* Step 8: Search for related packages
findsj causal inference, n(5)
* (Interactive: click [Install] buttons)

* Step 9: Check Google Scholar for additional citations
* (Interactive: click [Google] buttons)

* Step 10: Save article IDs for future reference
* Note article IDs (e.g., st0547) for direct access later


*===============================================================================
* SECTION 24: Quick Reference
*===============================================================================

* Basic Syntax:
* findsj keywords [, options]

* Search Scope Options:
*   author     - Search in author field
*   title      - Search in title field  
*   keyword    - Search in keyword field (default)

* Display Options:
*   n(#)       - Number of results to show (default 10)
*   allresults - Show all results
*   nobrowser  - Hide all clickable links
*   nopdf      - Hide PDF links
*   nopkg      - Hide package search links

* Citation Options:
*   ref        - Show citation format buttons
*   md         - Export to Markdown format
*   markdown   - Export to Markdown format (alias)
*   latex      - Export to LaTeX format
*   tex        - Export to LaTeX format (alias)
*   plain      - Export to plain text format
*   noclip     - Don't copy to clipboard

* Download Options:
*   type(bib)  - Download BibTeX file
*   type(ris)  - Download RIS file

* Database Options:
*   update     - Show update options
*   source(github) - Update from GitHub
*   source(gitee)  - Update from Gitee
*   source(both)   - Update with auto-fallback

* Path Options:
*   setpath(path)  - Set download directory
*   querypath      - Show current download directory
*   resetpath      - Reset to default directory

* Other Options:
*   getdoi     - Force DOI lookup
*   clear      - Clear data
*   debug      - Enable debug mode


*===============================================================================
* END OF EXAMPLES
*===============================================================================

* For more information:
*   help findsj
*   
* Online resources:
*   GitHub:  https://github.com/BlueDayDreeaming/findsj
*   Gitee:   https://gitee.com/ChuChengWan/findsj
*
* Contact:
*   Yujun Lian:    arlionn@163.com
*   Chucheng Wan:  chucheng.wan@outlook.com
*===============================================================================

* Close log file
log close
