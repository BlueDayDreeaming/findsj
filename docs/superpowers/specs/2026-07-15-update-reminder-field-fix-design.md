# `findsj` 数据库更新提醒字段修复设计

## 背景

`findsj_check_update` 从 `findsj_version.dta` 读取数据库更新时间，并在数据超过 90 天时提醒用户更新。当前版本文件由 `auto_update.py` 生成，日期字段名为 `update_date`，但 `findsj.ado` 读取不存在的 `last_update`，因此检查会静默退出。

## 目标

- 让 `findsj.ado` 正确读取 `findsj_version.dta` 中的 `update_date`。
- 数据库更新时间超过 90 天时，每次调用 `findsj` 都显示更新提醒。
- 数据库未超过 90 天时不显示提醒。
- 版本文件不存在、无法读取或缺少 `update_date` 时，保持现有的静默跳过行为。

## 非目标

- 不支持旧字段 `last_update`。
- 不增加每日一次或其他提醒限频机制。
- 不修改 `auto_update.py` 或重新生成 `findsj_version.dta`。
- 不改变数据库下载和更新逻辑。

## 实现设计

仅修改 `findsj_check_update`：

1. 将字段检查从 `last_update` 改为 `update_date`。
2. 从第一条记录读取 `update_date`，保存到本地宏。
3. 保留现有 `YYYY-MM-DD` 解析、天数计算和 `days_diff > 90` 判断。
4. 更新相关注释和显示逻辑中的本地宏名称，使名称与数据文件一致。

## 测试设计

使用 Stata 执行回归测试，至少覆盖：

1. 版本文件包含旧日期的 `update_date` 时显示提醒。
2. 版本文件包含未超过 90 天的 `update_date` 时不显示提醒。
3. `update_date` 缺失时静默跳过，不中断 `findsj`。

先运行测试确认当前代码因字段不匹配而失败，再修改 `findsj.ado` 并重新运行测试。最后检查完整差异，确保没有覆盖工作区中已有的用户修改。
