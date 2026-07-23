findsj 3.2.5 -- Resubmission software and reproducibility files
23 July 2026

TITLE

  findsj: Interactive search and citation management for Stata Journal
  articles

DESCRIPTION

  findsj searches Stata Journal (SJ) records by keyword, title, or author.
  Searches use the bundled findsj.dta
  database first and fall back to the official Stata Journal website when
  the database is unavailable. The online option selects the website even
  when the local database is available. Local author searches use complete
  name-token AND matching. In all online modes, findsj displays or exports the
  website-supplied matches without applying an additional query-term
  post-filter. The bundled database contains 1,269 records; some early records
  have incomplete metadata fields.

REQUIREMENTS

  Stata 16 or later.

  Core local search does not require an internet connection. Explicit online
  search, online fallback, DOI-based citation generation, external links,
  BibTeX/RIS downloads, and database refreshes require connectivity.
  Automatic clipboard copying is supported on Windows and macOS; Linux batch
  exports are saved to files without automatic clipboard copying.

FILES FOR THE STATA PACKAGE

  findsj.ado              Main command, version 3.2.5
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

  The author-search section displays local results for Jenkins, Lian, and Baum
  and verifies programmatically that every local record satisfies complete
  name-token matching. It also explicitly runs website searches for those
  names. Website-supplied matches are not tested against the local matching
  rule. The do-file additionally tests a multiword local
  author query, the principal search scopes, DOI display, batch export,
  BibTeX/RIS downloads, the update-source menu, and download-path
  configuration.

  The do-file does not replace the installed database. The command for a
  manual database refresh is printed but not executed. Temporary citation
  exports, downloaded BibTeX/RIS test files, and temporary directories are
  created in a unique workspace and removed before the do-file finishes. The
  caller's working directory, persistent download-path configuration, and
  in-session download-path global are restored after the file-writing examples.

  Online searches, DOI citation generation, and BibTeX/RIS download examples
  require an internet connection. The supplied findsj_examples.log is the
  audit log from the completed reproduction run used for this resubmission.

STORED RESULTS

  After a regular search, r(search_source) reports "local" or "online".

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
