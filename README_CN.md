# findsj

**在 Stata 中搜索、阅读和引用 Stata Journal 文章**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stata](https://img.shields.io/badge/Stata-16%2B-blue)](https://www.stata.com/)
[![Version](https://img.shields.io/badge/version-3.2.5-brightgreen)](https://github.com/BlueDayDreeaming/findsj)

[English](README.md) | [中文文档](README_CN.md)

当前版本：**3.2.5（23Jul2026）**。

`findsj` 可以按照关键词、作者或标题搜索 Stata Journal（SJ）文章。每条结果
均提供可点击的文章页面、基于 DOI
的出版商 PDF 链接（可用时，访问权限取决于出版商）、Google Scholar、软件包搜索、
引用生成以及 BibTeX/RIS 下载链接。

当前随附数据库包含 **1,269 条记录**。程序优先搜索本地数据库，从而实现快速
的离线检索；本地数据库不可用时，才回退到 Stata Journal 官方网站。即使本地
数据库存在，也可以用 `online` 选项显式选择网站搜索。`findsj` 显示或导出网站
提供的匹配结果，不再额外按查询词进行后置筛选；`n()` 和 `allresults` 仍用于
控制显示或导出的记录数。DOI 检索同样遵循“本地优先、必要时在线查询”的顺序。

## 主要功能

- 本地优先的关键词、作者和标题搜索
- 本地作者搜索使用完整 token 匹配：查询中的所有姓名 token 必须同时匹配
- 显式 `online` 模式保留 Stata Journal 网站返回的匹配结果
- 可点击的文章、PDF、Google Scholar 和软件包搜索链接
- 默认显示 Markdown、LaTeX 和纯文本引用按钮
- 批量导出 Markdown、LaTeX 或纯文本引用
- 按文章 ID 直接下载 BibTeX 和 RIS 文件
- 可持久保存的下载路径设置
- GitHub Actions 每月检查数据库更新

## 系统要求

- Stata 16 或更高版本
- 在线回退、数据库更新和外部链接需要互联网连接
- Windows、macOS 或 Linux

批量导出会在 **Windows 和 macOS** 上自动复制到剪贴板。**Linux 不支持
自动复制到剪贴板**，但导出文件仍会正常生成。

## 安装

### SSC

同时安装程序和附属数据库：

```stata
ssc install findsj, all replace
```

`all` 选项会把 `findsj.dta` 与程序文件一起安装。没有本地数据库时，
`findsj` 仍可使用在线回退，但搜索和 DOI 查询可能较慢。

### GitHub

规范仓库为
[BlueDayDreeaming/findsj](https://github.com/BlueDayDreeaming/findsj)。

```stata
net install findsj, from(https://raw.githubusercontent.com/BlueDayDreeaming/findsj/main/) all replace
findsj, updatesource source(github)
```

希望使用 Gitee 镜像的用户可以运行：

```stata
net install findsj, from(https://gitee.com/ChuChengWan/findsj/raw/main/) all replace
findsj, updatesource source(gitee)
```

## 快速开始

默认按关键词搜索：

```stata
findsj did, n(3)
findsj panel data, n(3)
```

按作者搜索：

```stata
findsj cox, author
findsj "Christopher F. Baum", author allresults
```

在本地数据库搜索中，作者查询不区分大小写，并按完整姓名 token 匹配。因此，
搜索 `lian` 不会误匹配 `Iliana`。多词查询要求所有 token 同时存在：
`Christopher F. Baum` 要求作者字段中完整出现 `Christopher`、`F` 和 `Baum`
三个 token。

显式查询 Stata Journal 网站：

```stata
findsj lian, author online allresults
```

在 `online` 模式中，匹配规则由网站决定。`findsj` 不会再按查询词进行额外
后置筛选（包括本地搜索所用的完整姓名 token 规则），因此本地和在线结果集
可能不同；可用 `n()` 或 `allresults` 控制显示的网站记录数。

仅搜索文章标题：

```stata
findsj panel data, title
```

显示全部匹配结果：

```stata
findsj regression, allresults
```

## 引用工具

有 DOI 时，常规搜索结果默认就会显示 `.md`、`.latex` 和 `.txt` 引用按钮，
无需指定 `ref`。在常规搜索中，`ref` 的作用是额外显示 DOI 信息：

```stata
findsj did, ref n(1)
```

若提供文章 ID，`ref` 会显示该文章的三种引用格式：

```stata
findsj st0001, ref
```

批量导出搜索结果：

```stata
findsj causal inference, md n(2)
findsj panel data, latex
findsj regression, text noclip
```

可用别名包括：

- Markdown：`md`、`markdown`
- LaTeX：`latex`、`tex`
- 纯文本：`plain`、`text`、`txt`

`noclip` 会禁用自动复制到剪贴板。在 Linux 上无论是否指定该选项都不会自动
复制，但导出文件仍会保存。

## BibTeX 和 RIS 下载

已知文章 ID 时，可直接下载引用文件：

```stata
findsj st0377, bib
findsj dm0065, ris
```

搜索结果中的 **BibTeX** 和 **RIS** 按钮提供相同操作。

设置这些文件的保存位置：

```stata
findsj, setpath(D:/References)
findsj, querypath
findsj, resetpath
```

## 语法与选项

```stata
findsj [关键词] [, 选项]
findsj 文章ID, ref
findsj 文章ID, bib
findsj 文章ID, ris
findsj, update
findsj, updatesource [source(github|gitee|both)]
findsj, setpath(路径)
findsj, querypath
findsj, resetpath
```

### 搜索范围

- `author` — 搜索作者字段；本地搜索按完整姓名 token 并使用 AND 逻辑，
  在线搜索则保留网站的匹配结果
- `title` — 搜索文章标题
- `keyword` — 按关键词搜索（默认）

### 搜索来源

- `online` — 跳过本地数据库并查询 Stata Journal 网站；显示或导出网站提供的
  匹配结果，不再由 `findsj` 按查询词进行额外后置筛选

### 显示控制

- `n(#)` — 最多显示多少条结果，默认为 10
- `allresults` — 显示全部匹配结果

### 引用与导出

- `ref` — 在搜索结果中显示 DOI；与文章 ID 一起使用时显示该文的引用格式
- `getdoi` — 显示 DOI 信息
- `md`、`markdown` — 以 Markdown 格式导出
- `latex`、`tex` — 以 LaTeX 格式导出
- `plain`、`text`、`txt` — 以纯文本格式导出
- `noclip` — 不把批量导出结果复制到剪贴板
- `bib` — 下载指定文章 ID 的 BibTeX 文件
- `ris` — 下载指定文章 ID 的 RIS 文件

### 下载路径

- `setpath(路径)` — 持久设置 BibTeX/RIS 下载目录
- `querypath` — 显示当前下载目录
- `resetpath` — 把下载目录重置为当前工作目录

### 数据库管理

- `update` — 使用 `source(both)` 的语言环境自适应双源回退策略
- `updatesource` — 未指定 `source()` 时显示可点击的来源菜单
- `updatesource source(github)` — 仅从 GitHub 更新
- `updatesource source(gitee)` — 仅从 Gitee 更新
- `updatesource source(both)` — 中文环境先尝试 Gitee，其他环境先尝试 GitHub，失败时再使用另一个源

也就是说，`findsj, update` 等价于：

```stata
findsj, updatesource source(both)
```

常规搜索完成后，`r(search_source)` 会以 `local` 或 `online` 标明实际使用的
搜索路径。

## 数据库覆盖与维护

- Stata Journal：2001 年至今
- 随附记录数：截至 2026 年 7 月为 1,269 条
- 仓库数据库检查：GitHub Actions 每月运行

可随时手动刷新已安装的数据库：

```stata
findsj, update
```

## 引用

若在研究中使用 `findsj`，请在配套 Stata Journal 文章发表后引用该文。

## 联系方式与链接

- 连玉君：[arlionn@163.com](mailto:arlionn@163.com)
- 万储诚：[chucheng.wan@outlook.com](mailto:chucheng.wan@outlook.com)
- 仓库：[BlueDayDreeaming/findsj](https://github.com/BlueDayDreeaming/findsj)
- 问题反馈：[GitHub Issues](https://github.com/BlueDayDreeaming/findsj/issues)
- Gitee 镜像：[ChuChengWan/findsj](https://gitee.com/ChuChengWan/findsj)

## 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE)。
