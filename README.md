# findsj

**One-click access to Stata Journal articles and their companion packages**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stata](https://img.shields.io/badge/Stata-14%2B-blue)](https://www.stata.com/)
[![Version](https://img.shields.io/badge/version-1.4.0-brightgreen)](https://github.com/BlueDayDreeaming/findsj)

[English](README.md) | [中文文档](README_CN.md)

---

## 🎯 Problem Solved

**The Pain Point:**  
The Stata Journal website **does not provide direct download links** to companion software packages (ado files or Stata programs) alongside published articles. Researchers must:
1. Read the article to find the package name
2. Manually search for the package using `findit` or `ssc`
3. Hope the package is still available and properly indexed

**Our Solution:**  
`findsj` provides **instant, clickable access** to both articles AND their companion packages from a single search, saving you time and frustration.

---

## ✨ Key Features

- 🔍 **Unified Search**: Search 1,200+ Stata Journal articles by keyword, author, or title
- 📦 **Direct Package Access**: One-click installation links for companion packages
- 📄 **Citation Management**: Download BibTeX/RIS files for all your references
- 🌐 **Multi-Platform**: Works seamlessly on Windows and Mac
- ⚡ **Fast & Local**: Built-in database for instant offline search
- 🔗 **Rich Integration**: Links to PDF, Google Scholar, and article pages

---

## 📸 Quick Examples

### Example 1: Find panel data methods and install packages
```stata
. findsj panel, n(3)
  Searching ... Showing 3 of 103 articles
[1] Weighted-average least squares:  Beyond the classical linear regression model
    G. De Luca and J. R. Magnus. (2025). Stata Journal 25(4)
    Article | PDF | Google | Install | Ref | BibTeX | RIS
[2] Testing for slope heterogeneity bias in the fixed-effects estimator
    J. Alejo, A. F. Galvao, and G. Montes-Rojas. (2025). Stata Journal 25(4)
    Article | PDF | Google | Install | Ref | BibTeX | RIS
[3] Testing and estimating structural breaks in time series and panel data in Stata
    J. Ditzen, Y. Karavias, and J. Westerlund. (2025). Stata Journal 25(3)
    Article | PDF | Google | Install | Ref | BibTeX | RIS
```
👆 Click **Install** to directly install the companion package!

### Example 2: Search by author name
```stata
. findsj Baum, author n(2)
  Searching ... Showing 2 of 25 articles
[1] Stata tip 166: Changing the axis scale with marginsplot
    C. F. Baum. (2025). Stata Journal 25(4)
    Article | PDF | Google | Install | Ref | BibTeX | RIS
[2] Estimating treatment effects when program participation is misreported
    C. F. Baum, D. Tommasi, and L. Zhang. (2024). Stata Journal 24(4)
    Article | PDF | Google | Install | Ref | BibTeX | RIS
```

### Example 3: Find machine learning tools
```stata
. findsj machine learning, n(2)
  Searching ... Showing 2 of 10 articles
[1] Optimal policy learning using Stata
    G. Cerulli. (2025). Stata Journal 25(2)
    Article | PDF | Google | Install | BibTeX | RIS
[2] ddml: Double/debiased machine learning in Stata
    A. Ahrens, C. B. Hansen, M. E. Schaffer, and T. Wiemann. (2024). Stata Journal 24(1)
    Article | PDF | Google | Install | BibTeX | RIS
```

### Example 4: Search within article titles
```stata
. findsj differences, title n(2)
  Searching ... Showing 2 of 10 articles
[1] Avoiding the eyeballing fallacy: Visualizing statistical differences between estimates using the pheatplot command
    E. Brini, S. T. Borgen, and N. T. Borgen. (2025). Stata Journal 25(1)
    Article | PDF | Google | Install | Ref | BibTeX | RIS
[2] On synthetic difference-in-differences and related estimation methods in Stata
    D. Clarke, D. Pailañir, S. Athey, and G. Imbens. (2024). Stata Journal 24(4)
    Article | PDF | Google | Install | Ref | BibTeX | RIS
```

---

## 📥 Installation

### Quick Install (Recommended)

**International users (GitHub):**
```stata
net install findsj, from(https://raw.githubusercontent.com/BlueDayDreeaming/findsj/main/) replace
```

**China users (Gitee mirror - faster):**
```stata
net install findsj, from(https://gitee.com/ChuChengWan/findsj/raw/main/) replace
```

### Update Database

After installation, update to the latest article database:
```stata
findsj, update source(github)    // International users
findsj, update source(gitee)     // China users
findsj, update source(both)      // Auto fallback
```

---

## 🚀 Quick Start

### 1. Basic Search

Search by keyword (default):
```stata
findsj machine learning
```

Search by author:
```stata
findsj Baum, author
```

Search by title:
```stata
findsj treatment effects, title
```

Show more results:
```stata
findsj regression, n(20)        // Show 20 results
findsj panel, allresults        // Show all matching results
```

### 2. Download Citations

Click **BibTeX** or **RIS** buttons in search results to download citation files.

Configure download location:
```stata
findsj, setpath(D:/References)    // Set custom path
findsj, querypath                  // Check current path
findsj, resetpath                  // Reset to default
```

### 3. Export to Clipboard

Export citations in different formats:
```stata
findsj propensity score, markdown    // Markdown format
findsj panel data, latex             // LaTeX format
findsj regression, plain             // Plain text
```

The results are automatically copied to clipboard for pasting into your document.

---

## 📚 Complete Syntax

```stata
findsj [keyword(s)] [, options]
```

### Search Options
- `author` - Search by author name
- `title` - Search by article title
- `keyword` - Search by keyword (default, can be omitted)

### Display Options
- `n(#)` - Number of results to display (default: 10)
- `allresults` - Show all matching results
- `nobrowser` - Hide clickable links
- `nopdf` - Hide PDF links
- `nopkg` - Hide package installation links

### Export Options
- `markdown` - Export citations in Markdown format
- `latex` (or `tex`) - Export citations in LaTeX format
- `plain` - Export citations in plain text format
- `noclip` - Don't copy to clipboard (display only)

### Path Management
- `setpath(path)` - Set custom download directory
- `querypath` - Display current download path
- `resetpath` - Reset to default path

### Database Management
- `update` - Update article database (requires `source()`)
- `source(source)` - Specify update source:
  - `github` - Download from GitHub (international)
  - `gitee` - Download from Gitee (China, faster)
  - `both` - Try GitHub first, fallback to Gitee

### Advanced Options
- `getdoi` - Display DOI information for each article in search results
- `debug` - Show debugging information

---

## 💡 Advanced Examples

### Example 1: Find and Install a Package

Search for difference-in-differences methods, then click **Install**:
```stata
findsj difference, n(5)
```

### Example 2: Download All Citations for Your Literature Review

Search and download BibTeX files for all matching articles:
```stata
findsj, setpath(D:/MyPaper/References)
findsj causal inference
```
Click **BibTeX** buttons to download citations to your references folder.

### Example 3: Export Citation List for Your Manuscript

Export formatted citations for your paper:
```stata
findsj instrumental variable, latex allresults
```
Paste the output directly into your LaTeX document.

### Example 4: Author Bibliography

Get all publications by a specific author:
```stata
findsj "Christopher F. Baum", author allresults
```

### Example 5: Update Database Periodically

Keep your local database up-to-date:
```stata
findsj, update source(both)
```

---

## 🛠️ System Requirements

- **Stata**: Version 14.0 or later
- **Internet**: Required for database updates and real-time features
- **Operating System**: Windows, macOS, or Linux
- **Tools**:
  - Windows: PowerShell (built-in)
  - Mac/Linux: curl (pre-installed on most systems)

---

## 🔄 Database Coverage

The `findsj` database includes:
- **Stata Journal (SJ)**: All volumes and issues (2001-present)
- **Stata Technical Bulletin (STB)**: Complete archive (1991-2001)
- **Total**: 1,200+ articles with full metadata
- **Updates**: Manual updates via `findsj, update` command

Last database update: November 2025 (Volume 25, Issue 3)

---

## 📖 How It Works

1. **Local Database**: `findsj` uses a local `.dta` database containing article metadata
2. **Fast Search**: All searches are performed locally for instant results
3. **Smart Links**: Package names are extracted and linked to installation sources
4. **Cross-Platform**: Native file operations for each OS ensure compatibility

---

## 🤝 Contributing

Contributions are welcome! Please feel free to:
- Report bugs or request features via [GitHub Issues](https://github.com/BlueDayDreeaming/findsj/issues)
- Submit pull requests for improvements
- Share your use cases and feedback

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Data source: [Stata Journal](https://www.stata-journal.com/)
- Inspired by the needs of empirical researchers worldwide
- Built with ❤️ for the Stata community

---

## 📮 Contact

**Authors:**
- **Yujun Lian** - [arlionn@163.com](mailto:arlionn@163.com)
- **Chucheng Wan** - [chucheng.wan@outlook.com](mailto:chucheng.wan@outlook.com)

**Project Links:**
- **GitHub**: [BlueDayDreeaming/findsj](https://github.com/BlueDayDreeaming/findsj)
- **Gitee Mirror**: [ChuChengWan/findsj](https://gitee.com/ChuChengWan/findsj)
- **Issues**: Report bugs or request features on GitHub

---

**Happy researching! 🎉**
