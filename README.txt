findsj 3.2.4 -- Resubmission software and reproducibility files
22 July 2026

TITLE

  findsj: Interactive search and citation management for Stata Journal
  articles

DESCRIPTION

  findsj searches Stata Journal (SJ) and Stata Technical Bulletin (STB)
  records by keyword, title, or author. Searches use the bundled findsj.dta
  database first and fall back to the official Stata Journal website when
  the database is unavailable. Author searches use complete name-token AND
  matching. The bundled database contains 1,269 records; some early records
  have incomplete metadata fields.

REQUIREMENTS

  Stata 16 or later.

  Core local search does not require an internet connection. Online fallback,
  DOI-based citation generation, external links, BibTeX/RIS downloads, and
  database refreshes require connectivity. Automatic clipboard copying is
  supported on Windows and macOS; Linux batch exports are saved to files
  without automatic clipboard copying.

FILES FOR THE STATA PACKAGE

  findsj.ado              Main command, version 3.2.4
  findsj.sthlp            Help file
  findsj.dta              Bundled article metadata (1,269 records)
  findsj_version.dta      Database-version metadata
  getiref.ado             Bundled DOI citation component
  getiref.sthlp           Help file for getiref
  findsj.pkg              Package manifest
  stata.toc               Package index
  findsj_examples.do      Reproduces article examples and regression tests
  findsj_examples.log     Plain-text log produced by the example do-file

MAINTENANCE FILES

  auto_update.py                    Regenerates the metadata files
  .github/workflows/auto-update.yml Monthly GitHub Actions workflow

REPRODUCTION

  1. Place the submitted files in one directory.
  2. Start Stata 16 or later and change to that directory.
  3. Run:

       . do findsj_examples.do

  The do-file adds the submission directory to adopath, so the submitted ado
  files are used instead of an older installed copy. It sets linesize to 80,
  replaces findsj_examples.log, and runs the manuscript examples.

  The author-search section displays all results for Jenkins, Lian, and Baum
  and verifies programmatically that every returned record satisfies complete
  name-token matching. It also tests a multiword author query, the principal
  search scopes, DOI display, batch export, BibTeX/RIS downloads, the update-
  source menu, and download-path configuration.

  The do-file does not replace the installed database. The command for a
  manual database refresh is printed but not executed. Temporary citation
  exports, downloaded BibTeX/RIS test files, and the temporary path directory
  are removed before the do-file finishes.

  DOI citation generation and BibTeX/RIS download examples require an internet
  connection. The supplied findsj_examples.log is the audit log from the
  completed reproduction run used for this resubmission.

INSTALLATION

  From SSC, install the program and ancillary database with:

       . ssc install findsj, all replace

  Canonical repository:
  https://github.com/BlueDayDreeaming/findsj

AUTHORS

  Yujun Lian
  Lingnan College, Sun Yat-sen University, Guangzhou, China
  Email: arlionn@163.com

  Chucheng Wan
  Lingnan College, Sun Yat-sen University, Guangzhou, China
  Email: chucheng.wan@outlook.com
