NOTE:  readme.txt template -- do not remove empty entries, but you may
                              add entries for additional authors
------------------------------------------------------------------------------

Package name:   findsj

DOI:  

Title: findsj - Search and cite Stata Journal articles with interactive buttons

Version: 1.4.0 (2025/12/08)

Author 1 name: Yujun Lian
Author 1 from: Lingnan College, Sun Yat-sen University, Guangzhou, China
Author 1 email: arlionn@163.com

Author 2 name: Chucheng Wan
Author 2 from: Lingnan College, Sun Yat-sen University, Guangzhou, China
Author 2 email: chucheng.wan@outlook.com

Author 3 name:  
Author 3 from:  
Author 3 email: 

Author 4 name:  
Author 4 from:  
Author 4 email: 

Author 5 name:  
Author 5 from:  
Author 5 email: 

Help keywords: findsj, Stata Journal, search, citation, bibliography, BibTeX, RIS, interactive buttons, getiref

File list: findsj.ado findsj.sthlp findsj.dta findsj_version.dta findsj_examples.do getiref.ado stata.toc

Notes: 

findsj searches for articles from the Stata Journal (SJ) and Stata 
Technical Bulletin (STB) by keywords, author names, or article titles. 
Articles are searched using a local database (findsj.dta) for fast, 
offline access. The database is automatically updated via GitHub Actions
and includes 1260+ articles with full metadata.

Key Features:
- Fast local database search with 1260+ Stata Journal articles
- Interactive clickable buttons for each article:
  * Article - Open article page
  * PDF - Direct PDF download link
  * Google - Search on Google Scholar
  * Install - One-click package installation
  * Ref - Show citation format buttons (.md/.latex/.txt)
  * BibTeX - Download BibTeX citation file
  * RIS - Download RIS citation file
- Citation generation via getiref integration (Markdown, LaTeX, plain text)
- Automatic database update checking (monthly reminders)
- Database updates from GitHub or Gitee (with auto-fallback)
- Cross-platform support (Windows, Mac, Linux)
- Automatic clipboard copying for citations
- Configurable download path (persistent across sessions)
- DOI information for PDF links and citations

Version 1.4.0 Changes:
- Added automatic database update checking (monthly reminders)
- Improved update system with clickable download options
- Enhanced database management with version tracking
- Fixed HTML entity display in author names (supports international characters)
- Streamlined examples file with 17 focused sections

Version 1.3.0 Changes:
- Direct getiref integration for citation generation
- Click .md/.latex/.txt buttons to generate formatted citations
- Automatic DOI fetching when using ref option

Version 1.2.0 Changes:
- Added "Ref" button for each article
- Three clickable citation format buttons (.md/.latex/.txt)
- Integrated with getiref for professional citation formatting

Version 1.1.0 Changes:
- Transitioned from online fetching to local database system
- Added findsj.dta for fast offline search
- Improved Mac/Unix download support with proper shell scripts
- Added download path configuration (setpath, querypath, resetpath)
- Fixed BibTeX/RIS download with Referer header spoofing
- Enhanced display format (title first, configurable results)

System Requirements:
- Stata 16.0 or higher
- Internet connection (for database updates and downloads)
- Operating System: Windows, macOS, or Linux
- Tools:
  - Windows: PowerShell (built-in)
  - Mac/Linux: curl and bash (pre-installed)
- Required packages: getiref (auto-installed if missing)

Installation: 
net install findsj, from(https://raw.githubusercontent.com/BlueDayDreeaming/findsj/main/) replace
net install findsj, from(https://gitee.com/ChuChengWan/findsj/raw/main/) replace

Quick Start:
findsj regression                          // Basic search
findsj panel data, n(10)                   // Show 10 results
findsj Baum, author                        // Search by author
findsj synthetic control, ref              // Show citation buttons
findsj propensity score, markdown          // Export in Markdown
findsj, update source(github)              // Update database
findsj, setpath(/your/path)                // Set download path
findsj, querypath                          // Check current path

GitHub: https://github.com/BlueDayDreeaming/findsj
Gitee: https://gitee.com/ChuChengWan/findsj

Contact: arlionn@163.com, chucheng.wan@outlook.com

