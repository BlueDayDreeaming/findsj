# findsj

**Search, read, and cite Stata Journal articles from Stata**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stata](https://img.shields.io/badge/Stata-16%2B-blue)](https://www.stata.com/)
[![Version](https://img.shields.io/badge/version-3.2.5-brightgreen)](https://github.com/BlueDayDreeaming/findsj)

[English](README.md) | [中文文档](README_CN.md)

Current release: **3.2.5 (23Jul2026)**.

`findsj` searches Stata Journal (SJ) articles by keyword, author, or title.
Each result includes clickable links for
the article page, a DOI-based publisher PDF link (when available), Google Scholar, package search,
citation generation, and BibTeX/RIS download.

The bundled database currently contains **1,269 records**. Searches use the
local database first for fast, offline access and fall back to the official
Stata Journal website when the database is unavailable. The `online` option
can explicitly select the website even when the local database is present.
`findsj` displays or exports the website-supplied matches without applying an
additional query-term post-filter; `n()` and `allresults` still control how many
records are displayed or exported. DOI lookup also uses the local database
first and then attempts an online lookup when necessary.

## Key features

- Local-first keyword, author, and title search
- Complete-token author matching in local searches: all query tokens must match
- Explicit `online` mode that preserves the Stata Journal website's matches
- Clickable article, PDF, Google Scholar, and package-search links
- Citation buttons in Markdown, LaTeX, and plain-text formats by default
- Batch citation export in Markdown, LaTeX, or plain text
- Direct BibTeX and RIS download by article ID
- Persistent download-path configuration
- Monthly database checks through GitHub Actions

## Requirements

- Stata 16 or later
- Internet access for online fallback, database updates, and external links
- Windows, macOS, or Linux

Batch exports are copied automatically to the clipboard on **Windows and
macOS**. Automatic clipboard copying is **not supported on Linux**; the export
file is still created normally.

## Installation

### SSC

Install the program and its ancillary database together:

```stata
ssc install findsj, all replace
```

The `all` option installs `findsj.dta` together with the program files. Without
the database, `findsj` can still use its online fallback, but searches and DOI
lookups may be slower.

### GitHub

The canonical repository is
[BlueDayDreeaming/findsj](https://github.com/BlueDayDreeaming/findsj).

```stata
net install findsj, from(https://raw.githubusercontent.com/BlueDayDreeaming/findsj/main/) all replace
findsj, updatesource source(github)
```

For users who prefer the Gitee mirror:

```stata
net install findsj, from(https://gitee.com/ChuChengWan/findsj/raw/main/) all replace
findsj, updatesource source(gitee)
```

## Quick start

Keyword search is the default:

```stata
findsj did, n(3)
findsj panel data, n(3)
```

Search by author:

```stata
findsj cox, author
findsj "Christopher F. Baum", author allresults
```

In local-database searches, author queries are case-insensitive and match
complete name tokens. A search for `lian` therefore does not match names such
as `Iliana`. In a multiword query, all tokens are required: `Christopher F.
Baum` requires the complete tokens `Christopher`, `F`, and `Baum` to occur in
the author field.

Explicitly query the Stata Journal website:

```stata
findsj lian, author online allresults
```

The website controls matching in `online` mode. `findsj` does not apply an
additional query-term post-filter, including its local complete-token author
rule, so local and online result sets may differ. Use `n()` or `allresults` to
control how many website records are displayed.

Search within article titles:

```stata
findsj panel data, title
```

Display all matches:

```stata
findsj regression, allresults
```

## Citation tools

When a DOI is available, every standard search result already contains `.md`,
`.latex`, and `.txt` citation buttons. The `ref` option is not required to show
these buttons; on a regular search it adds DOI information to the output:

```stata
findsj did, ref n(1)
```

When an article ID is supplied, `ref` displays the citation formats for that
specific article:

```stata
findsj st0001, ref
```

Export a batch of results:

```stata
findsj causal inference, md n(2)
findsj panel data, latex
findsj regression, text noclip
```

Supported aliases are:

- Markdown: `md`, `markdown`
- LaTeX: `latex`, `tex`
- Plain text: `plain`, `text`, `txt`

The `noclip` option prevents automatic clipboard copying. On Linux, clipboard
copying is skipped regardless, while the export file is still saved.

## BibTeX and RIS downloads

Download a reference file directly when the article ID is known:

```stata
findsj st0377, bib
findsj dm0065, ris
```

The same actions are available through the **BibTeX** and **RIS** buttons in
search results.

Configure where these files are saved:

```stata
findsj, setpath(D:/References)
findsj, querypath
findsj, resetpath
```

## Syntax and options

```stata
findsj [keywords] [, options]
findsj article_id, ref
findsj article_id, bib
findsj article_id, ris
findsj, update
findsj, updatesource [source(github|gitee|both)]
findsj, setpath(path)
findsj, querypath
findsj, resetpath
```

### Search scope

- `author` — search the author field; local searches use complete name tokens
  and AND logic, while online searches preserve website matching
- `title` — search article titles
- `keyword` — search by keyword (default)

### Search source

- `online` — bypass the local database and query the Stata Journal website;
  display or export the website-supplied matches without an additional
  `findsj` query-term post-filter

### Display

- `n(#)` — maximum number of results to display; default is 10
- `allresults` — display all matching results

### Citation and export

- `ref` — display DOI information for search results; with an article ID, show
  its citation formats
- `getdoi` — display DOI information
- `md`, `markdown` — export results in Markdown format
- `latex`, `tex` — export results in LaTeX format
- `plain`, `text`, `txt` — export results in plain-text format
- `noclip` — do not copy a batch export to the clipboard
- `bib` — download a BibTeX file for the specified article ID
- `ris` — download a RIS file for the specified article ID

### Download path

- `setpath(path)` — set the persistent BibTeX/RIS download directory
- `querypath` — show the current download directory
- `resetpath` — reset the download directory to the current working directory

### Database management

- `update` — update using the language-dependent two-source fallback in `source(both)`
- `updatesource` — without `source()`, display a clickable source menu
- `updatesource source(github)` — update from GitHub only
- `updatesource source(gitee)` — update from Gitee only
- `updatesource source(both)` — try Gitee first in a Chinese locale and GitHub first otherwise, then use the alternate source if needed

In particular, `findsj, update` is equivalent to:

```stata
findsj, updatesource source(both)
```

After a regular search, `r(search_source)` identifies the path used as `local`
or `online`.

## Database coverage and maintenance

- Stata Journal: 2001–present
- Bundled records: 1,269 as of July 2026
- Repository database check: monthly through GitHub Actions

You can refresh an installed database at any time with:

```stata
findsj, update
```

## Citation

If you use `findsj` in research, please cite the accompanying Stata Journal
article after publication.

## Contact and links

- Yujun Lian: [arlionn@163.com](mailto:arlionn@163.com)
- Chucheng Wan: [chucheng.wan@outlook.com](mailto:chucheng.wan@outlook.com)
- Repository: [BlueDayDreeaming/findsj](https://github.com/BlueDayDreeaming/findsj)
- Issues: [GitHub Issues](https://github.com/BlueDayDreeaming/findsj/issues)
- Gitee mirror: [ChuChengWan/findsj](https://gitee.com/ChuChengWan/findsj)

## License

This project is released under the MIT License. See [LICENSE](LICENSE).
