# findsj

**一键访问 Stata Journal 文章及其配套软件包**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stata](https://img.shields.io/badge/Stata-14%2B-blue)](https://www.stata.com/)
[![Version](https://img.shields.io/badge/version-2.1.0-brightgreen)](https://github.com/BlueDayDreeaming/findsj)

[English](README.md) | [中文文档](README_CN.md)

---

## 🎯 解决的痛点

**问题：**  
Stata Journal 的文章本身**并不会直接在期刊网站上附带对应的软件包**（ado 文件或 Stata 程序）下载链接。研究者必须：
1. 阅读文章找到软件包名称
2. 手动使用 `findit` 或 `ssc` 搜索软件包
3. 期望软件包仍然可用且被正确索引

**我们的解决方案：**  
`findsj` 提供**即时、可点击的访问**，在单次搜索中同时获取文章和配套软件包，节省您的时间和精力。

---

## ✨ 主要功能

- 🔍 **统一搜索**：搜索 1,255 篇 Stata Journal 文章（按关键词、作者或标题）
- 📦 **直接访问软件包**：一键安装配套软件包
- 📄 **文献管理**：下载 BibTeX/RIS 引用文件
- 🌐 **跨平台**：在 Windows和Mac上无缝运行
- ⚡ **快速本地化**：内置数据库实现即时离线搜索
- 🔗 **丰富集成**：链接到 PDF、Google Scholar 和文章页面

---

## 📸 快速示例

### 示例 1：查找面板数据方法并安装软件包
```stata
. findsj panel, n(3)
  Searching ... Showing 3 of 103 articles
[1] Weighted-average least squares:  Beyond the classical linear regression model
    G. De Luca and J. R. Magnus. (2025). Stata Journal 25(4)
    Web | PDF | Google | Install | Ref | BibTeX | RIS
[2] Testing for slope heterogeneity bias in the fixed-effects estimator
    J. Alejo, A. F. Galvao, and G. Montes-Rojas. (2025). Stata Journal 25(4)
    Web | PDF | Google | Install | Ref | BibTeX | RIS
[3] Testing and estimating structural breaks in time series and panel data in Stata
    J. Ditzen, Y. Karavias, and J. Westerlund. (2025). Stata Journal 25(3)
    Web | PDF | Google | Install | BibTeX | RIS
```
👆 点击 **Install** 直接安装配套软件包！

### 示例 2：按作者搜索
```stata
. findsj Baum, author n(2)
  Searching ... Showing 2 of 25 articles
[1] Stata tip 166: Changing the axis scale with marginsplot
    C. F. Baum. (2025). Stata Journal 25(4)
    Web | PDF | Google | Install | Ref | BibTeX | RIS
[2] Estimating treatment effects when program participation is misreported
    C. F. Baum, D. Tommasi, and L. Zhang. (2024). Stata Journal 24(4)
    Web | PDF | Google | Install | BibTeX | RIS
```

### 示例 3：查找机器学习工具
```stata
. findsj machine learning, n(2)
  Searching ... Showing 2 of 10 articles
[1] Optimal policy learning using Stata
    G. Cerulli. (2025). Stata Journal 25(2)
    Web | PDF | Google | Install | BibTeX | RIS
[2] ddml: Double/debiased machine learning in Stata
    A. Ahrens, C. B. Hansen, M. E. Schaffer, and T. Wiemann. (2024). Stata Journal 24(1)
    Web | PDF | Google | Install | BibTeX | RIS
```

### 示例 4：在文章标题中搜索
```stata
. findsj differences, title n(2)
  Searching ... Showing 2 of 10 articles
[1] Avoiding the eyeballing fallacy: Visualizing statistical differences between estimates using the pheatplot command
    E. Brini, S. T. Borgen, and N. T. Borgen. (2025). Stata Journal 25(1)
    Web | PDF | Google | Install | Ref | BibTeX | RIS
[2] On synthetic difference-in-differences and related estimation methods in Stata
    D. Clarke, D. Pailañir, S. Athey, and G. Imbens. (2024). Stata Journal 24(4)
    Web | PDF | Google | Install | BibTeX | RIS
```

---

## 📥 安装

### SSC 安装（推荐）

```stata
ssc install findsj, replace
```

⚠️ **说明：** 使用 `ssc install` 配合 `replace` 选项会正确更新程序和数据文件。

### 从 GitHub/Gitee 安装

**国际用户（GitHub）：**
```stata
* 第一步：安装程序文件（.ado, .sthlp）
net install findsj, from(https://raw.githubusercontent.com/BlueDayDreeaming/findsj/main/) replace

* 第二步：下载数据库（必需 - 选择一种方法）
findsj, updatesource source(github)   // 推荐：自动安装到正确位置
```

**中国用户（Gitee 镜像 - 更快）：**
```stata
* 第一步：安装程序文件
net install findsj, from(https://gitee.com/ChuChengWan/findsj/raw/main/) replace

* 第二步：下载数据库（必需）
findsj, updatesource source(gitee)    // 中国用户推荐
```

**⚠️ 重要说明：** Stata 的 `net install` 只下载程序文件（`.ado`、`.sthlp`）。数据库文件 `findsj.dta` 必须使用内置的 `updatesource` 命令单独下载，该命令会自动安装到正确位置。

> **备选方案：** 您也可以使用 `net get findsj, from(...)` 下载数据库文件，但它们会保存到**当前工作目录**，而不是 ado 路径。推荐使用 `updatesource` 命令，它会自动处理文件位置。

### 更新数据库

最便捷的方式更新至最新文章数据库：
```stata
findsj, update                         // 自动选择最优源（根据语言）
findsj, updatesource source(github)    // 强制使用 GitHub
findsj, updatesource source(gitee)     // 强制使用 Gitee
findsj, updatesource source(both)      // 尝试两个源，自动回退
```

---

## 🚀 快速开始

### 1. 基本搜索

按关键词搜索（默认）：
```stata
findsj machine learning
```

按作者搜索：
```stata
findsj Baum, author
```

按标题搜索：
```stata
findsj treatment effects, title
```

显示更多结果：
```stata
findsj regression, n(20)        // 显示 20 条结果
findsj panel, allresults        // 显示所有匹配结果
```

### 2. 下载引用文件

点击搜索结果中的 **BibTeX** 或 **RIS** 按钮下载引用文件。

配置下载位置：
```stata
findsj, setpath(D:/References)    // 设置自定义路径
findsj, querypath                  // 查看当前路径
findsj, resetpath                  // 重置为默认路径
```

### 3. 导出到剪贴板

以不同格式导出引用：
```stata
findsj propensity score, markdown    // Markdown 格式
findsj panel data, latex             // LaTeX 格式
findsj regression, plain             // 纯文本格式
```

结果会自动复制到剪贴板，可直接粘贴到文档中。

---

## 📚 完整语法

```stata
findsj [关键词] [, 选项]
```

### 搜索选项
- `author` - 按作者姓名搜索
- `title` - 按文章标题搜索
- `keyword` - 按关键词搜索（默认，可省略）

### 显示选项
- `n(#)` - 显示结果数量（默认：10）
- `allresults` - 显示所有匹配结果
- `nobrowser` - 隐藏可点击链接
- `nopdf` - 隐藏 PDF 链接
- `nopkg` - 隐藏软件包安装链接

### 导出选项
- `markdown` - 以 Markdown 格式导出引用
- `latex`（或 `tex`）- 以 LaTeX 格式导出引用
- `plain` - 以纯文本格式导出引用
- `noclip` - 不复制到剪贴板（仅显示）

### 路径管理
- `setpath(路径)` - 设置自定义下载目录
- `querypath` - 显示当前下载路径
- `resetpath` - 重置为默认路径

### 数据库管理
- `update` - 更新文章数据库（需配合 `source()` 使用）
- `source(来源)` - 指定更新来源：
  - `github` - 从 GitHub 下载（国际用户）
  - `gitee` - 从 Gitee 下载（中国用户，更快）
  - `both` - 先尝试 GitHub，失败后回退到 Gitee

### 高级选项
- `getdoi` - 在搜索结果中显示每篇文章的 DOI 信息
- `debug` - 显示调试信息

---

## 💡 高级示例

### 示例 1：查找并安装软件包

搜索双重差分方法，然后点击 **Install**：
```stata
findsj difference, n(5)
```

### 示例 2：为文献综述下载所有引用

搜索并下载所有匹配文章的 BibTeX 文件：
```stata
findsj, setpath(D:/MyPaper/References)
findsj causal inference
```
点击 **BibTeX** 按钮将引用下载到您的参考文献文件夹。

### 示例 3：为手稿导出引用列表

导出格式化的引用供论文使用：
```stata
findsj instrumental variable, latex allresults
```
直接将输出粘贴到您的 LaTeX 文档中。

### 示例 4：作者文献目录

获取特定作者的所有出版物：
```stata
findsj "Christopher F. Baum", author allresults
```

### 示例 5：定期更新数据库

保持本地数据库为最新：
```stata
findsj, update source(both)
```

---

## 🛠️ 系统要求

- **Stata**：14.0 或更高版本
- **互联网**：数据库更新和实时功能需要
- **操作系统**：Windows、macOS 或 Linux
- **工具**：
  - Windows：PowerShell（内置）
  - Mac/Linux：curl（大多数系统预装）

---

## 🔄 数据库覆盖范围

`findsj` 数据库包含：
- **Stata Journal (SJ)**：所有卷期（2001 年至今）
- **总计**：1,255 篇文章及完整元数据
- **更新**：通过 `findsj, update` 命令手动更新，或通过 GitHub Actions 每周自动更新

最后数据库更新：2026 年 2 月（第 25 卷第 4 期）

---

## 📖 工作原理

1. **本地数据库**：`findsj` 使用包含文章元数据的本地 `.dta` 数据库
2. **快速搜索**：所有搜索都在本地执行，实现即时结果
3. **智能链接**：提取软件包名称并链接到安装源
4. **跨平台**：针对每个操作系统的原生文件操作确保兼容性

---

## 🤝 贡献

欢迎贡献！您可以：
- 通过 [GitHub Issues](https://github.com/BlueDayDreeaming/findsj/issues) 报告错误或请求功能
- 提交改进的拉取请求
- 分享您的使用案例和反馈

---

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

---

## 🙏 致谢

- 数据来源：[Stata Journal](https://www.stata-journal.com/)
- 受全球实证研究者需求启发
- 为 Stata 社区用 ❤️ 构建

---

## 📮 联系方式

**作者：**
- **连玉君** - [arlionn@163.com](mailto:arlionn@163.com)
- **万储诚** - [chucheng.wan@outlook.com](mailto:chucheng.wan@outlook.com)

**项目链接：**
- **GitHub**：[BlueDayDreeaming/findsj](https://github.com/BlueDayDreeaming/findsj)
- **Gitee 镜像**：[ChuChengWan/findsj](https://gitee.com/ChuChengWan/findsj)
- **问题反馈**：在 GitHub 上报告错误或请求功能

---

**祝研究顺利！🎉**
