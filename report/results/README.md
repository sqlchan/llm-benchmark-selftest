# 实测证据归档

本目录保存第一批基准实测的原始证据（模型输出、评测结果、冒烟日志），便于复核与写汇报。

| 目录 | 内容 |
| :-- | :-- |
| [`ark_*_simple5.json`](.) | Automation-Bench simple 5 题的原始结果 JSON（deepseek-v4-flash / glm-5.3-flash） |
| [`programbench-zoxide/`](programbench-zoxide/) | ProgramBench 单题（zoxide）完整证据：提交、轨迹、eval 结果（Score 56 / 531 tests） |
| [`deepswe-smoke/`](deepswe-smoke/) | DeepSWE 单题冒烟的 6 次尝试日志、Pier 配置、最终失败现场 |

来源环境：
- 模型：火山方舟 Ark，`deepseek-v4-flash`（base `https://ark.cn-beijing.volces.com/api/plan/v1`）
- 日期：2026-10-31
- 框架版本：AutomationBench 1.0.6、ProgramBench 1.2.5、Pier 0.3.1、mini-swe-agent 2.4.6

> 证据文件中的金额/耗时以当时实测为准；token 与成本字段为框架统计或 N/A。
