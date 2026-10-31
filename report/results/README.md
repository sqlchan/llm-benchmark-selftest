# 实测证据归档

本目录保存两批基准实测的原始证据（模型输出、评测结果、冒烟日志），便于复核与写汇报。

## 第一批（Automation-Bench / ProgramBench / DeepSWE）

| 目录 | 内容 |
| :-- | :-- |
| [`ark_*_simple5.json`](.) | Automation-Bench simple 5 题的原始结果 JSON（deepseek-v4-flash / glm-5.3-flash） |
| [`programbench-zoxide/`](programbench-zoxide/) | ProgramBench 单题（zoxide）完整证据：提交、轨迹、eval 结果（Score 56 / 531 tests） |
| [`deepswe-smoke/`](deepswe-smoke/) | DeepSWE 单题冒烟的 6 次尝试日志、Pier 配置、最终失败现场 |

## 第二批（Terminal-Bench 4.0 / NL2Repo-Bench）

| 目录 | 内容 |
| :-- | :-- |
| [`tb4-oracle/`](tb4-oracle/) | TB4 oracle 自检两次（官方 `@sha256` 镜像 / 第二批 release-tag 派生镜像），任务 `html-js-filter`，均 reward=1.0、2/2 tests |
| [`tb4-agent-smoke/`](tb4-agent-smoke/) | TB4 mini-swe-agent 冒烟失败现场：Windows GBK 编码中止、缺 `mcp` 的 `NonZeroAgentExitCodeError`，以及 mcp 补丁层构建日志 |
| [`nl2repo-smoke/`](nl2repo-smoke/) | NL2Repo 单题（aiofiles）端到端链路证据：OpenHands 容器、模型调用、workspace 挂载、评测镜像与 pytest、结果 JSON（**机制验证，非正式分数**） |

来源环境：
- 模型：火山方舟 Ark，`deepseek-v4-flash`（base `https://ark.cn-beijing.volces.com/api/plan/v1`）
- 日期：2026-10-31
- 框架版本：AutomationBench 1.0.6、ProgramBench 1.2.5、Pier 0.3.1、mini-swe-agent 2.4.6、Harbor 0.25.0、OpenHands 0.56

> 证据文件中的金额/耗时以当时实测为准；token 与成本字段为框架统计或 N/A。
> 第二批证据中的 API key 已脱敏；`tb4-oracle`/`tb4-agent-smoke` 的分数仅代表链路状态（oracle 通过 / agent 未正式跑分），
> 不得当作模型能力结论。正式跑分方法见 [`../company-day1-checklist-batch2.md`](../company-day1-checklist-batch2.md)。
