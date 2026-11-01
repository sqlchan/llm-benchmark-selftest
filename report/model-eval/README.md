# 五个基准是怎么评测模型的（逐基准详解）

> 本目录面向「要拿这 5 个基准去测模型」的人：每个基准一个文件，讲清楚**题目长什么样、模型要做什么、谁来判分、分数怎么算、有哪些坑**，并给出真实的题目例子（英文原文 + 中文翻译 + 判分点）。
> 这里的 5 个基准 = 本仓库离线包 `E:\bench-bundle` 实际打包的 5 个：Terminal-Bench 4.0、DeepSWE v1.1、NL2Repo-Bench、ProgramBench、Automation-Bench v1.0.6。
> 所有引文都来自离线包内真实任务文件（`data/`）或官方页面，逐条可在文末「来源」核对；标注 `# TODO verify` 的表示尚未实测或未核实。

## 0. 先建立共同概念：一个基准由 5 个部件组成

不管哪家基准，评测模型都可以拆成同样的 5 层。理解这 5 层，后面的差异就只是「参数不同」：

| 部件 | 作用 | 典型实现 |
| :-- | :-- | :-- |
| **题面（Prompt）** | 告诉模型要做什么 | 一段自然语言指令（TB4/DeepSWE/Automation）、一份规格文档（NL2Repo）、一份文档 + 一个二进制（ProgramBench） |
| **环境（Environment）** | 模型能操作的世界 | Docker 容器（TB4/DeepSWE/NL2Repo/ProgramBench）、模拟 SaaS（Automation 的 47 个工具） |
| **Agent scaffold（执行器）** | 把模型的输出变成动作 | Harbor + mini-swe-agent / claude-code（TB4）、Pier + mini-swe-agent（DeepSWE）、OpenHands（NL2Repo）、mini-swe-agent（ProgramBench）、`auto-bench` 的 function calling 循环（Automation） |
| **Verifier（判分器）** | 判断做没做对 | 任务自带 pytest/脚本（TB4）、隐藏 test.patch + F2P/P2P 白名单（DeepSWE）、上游 pytest 通过率（NL2Repo）、隐藏行为测试（ProgramBench）、程序化 end-state 断言（Automation） |
| **聚合（Aggregation）** | 把单题结果变成分数 | resolve rate（TB4）、Pass@1（DeepSWE）、平均通过率（NL2Repo）、Resolved 比例 / 平均通过率（ProgramBench）、strict pass rate（Automation） |

两个关键区别：

- **「判分器」不一定看代码**。TB4 看容器最终状态、DeepSWE 看行为测试、NL2Repo 看上游测试、ProgramBench 看黑盒行为、Automation 看数据库/邮件/表格的最终状态——**没有一个是 LLM 当裁判**（HLE 那种才是 judge）。
- **「分数」不是模型能力本身**，而是「模型 + scaffold + 采样参数 + 判分口径」的联合结果。同一模型换 scaffold、换 `--toolset`、换重跑次数，分数都会变。

## 1. 五个基准一览

| | Terminal-Bench 4.0 | DeepSWE v1.1 | NL2Repo-Bench | ProgramBench | Automation-Bench v1.0.6 |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 测什么 | 真终端里完成工程任务 | 真实仓库里做原创长程改动 | 从规格从零生成整个仓库 | 只给二进制 + 文档重建程序 | 模拟 SaaS 里跑业务流程 |
| 题量（官方） | 66 | 113（91 repo / 5 语言） | 104（9 类） | 200（24.8 万+ 测试） | 公开 600 + simple 200 |
| 单题给什么 | 一段指令 + 预装环境 | 一个仓库 @ base commit + 行为描述 | 一份约 18.8k tokens 规格 | 一个可执行二进制 + 文档 | 一句业务请求 + 世界状态 + 工具 |
| 模型交什么 | 容器最终状态 | 一个 git commit | 整个仓库 | `/workspace/executable` | 系统最终状态 |
| 判分器 | 任务 verifier（pytest/脚本） | 隐藏 test.patch + F2P/P2P 白名单 | 上游 pytest | 隐藏行为测试 | end-state 断言 |
| 单题分 | 0/1 | 0/1（+ partial） | 0–100% | 0–100%（Resolved 看 100%） | 0/1（+ partial_credit） |
| 整轮分 | resolve rate（官方 k=5） | Pass@1 | 平均测试通过率 | Resolved 比例 / 平均通过率 | strict pass rate |
| 单题上限 | 8 小时 | 3 小时 | 无轮数上限（单题可达数小时） | 6 小时 / 1000 步 | 50 步 |
| 离线包题量 | 36 | 20 | 16 | 5 | 600 |

> 「离线包题量」= `E:\bench-bundle` 当前实际可跑的题数（见 `manifest.json`）；官方题池见上表。子集评测只能做**同 harness 同子集横评**，不能对官方榜。

## 2. 阅读顺序

| 文件 | 内容 | 适合 |
| :-- | :-- | :-- |
| [01-terminal-bench-4.md](01-terminal-bench-4.md) | 真终端任务：Harbor 流程、verifier、8 小时预算、XSS/SATB/支付管道等题例 | 最接近真实工程，但最贵、评分争议最大 |
| [02-deepswe-v1-1.md](02-deepswe-v1-1.md) | 仓库改动：commit 收集、F2P/P2P、binary reward、Go/TS/Python 题例 | 代码 Agent 的首选自测 |
| [03-nl2repo-bench.md](03-nl2repo-bench.md) | 规格生成整仓：OpenHands 流程、上游 pytest 通过率、aiofiles 题例 | 看「从 0 到 1」的上限 |
| [04-programbench.md](04-programbench.md) | 二进制重建：cleanroom、黑盒测试、Score/Resolved、zoxide 题例 | 看模型最硬核的编程能力 |
| [05-automation-bench.md](05-automation-bench.md) | 业务流程：模拟 SaaS、断言引擎、正负断言、发票题例 | 最便宜、最接近公司内部自动化 |

## 3. 六个跨基准的常见问题（先读这一节，能少踩一半坑）

**Q1：为什么同一模型在不同基准上的分数不能直接比？**

因为「分数」的分母和口径都不同：TB4 是 66 题里通过几题（0/1 聚合），DeepSWE 是 113 题 Pass@1，NL2Repo 是 104 题的平均测试通过率（0–100%），ProgramBench 是 200 题里完全解出几题（Resolved），Automation 是 600 题的严格通过率。同样是「50 分」，含义完全不同。

**Q2：什么是 pass@k / k=5？**

同一个题跑 k 次，只要有一次通过就算通过（pass@k），或者报告 k 次的平均值。TB4 官方榜是 66 题 × 5 次 = 330 trials，取平均并给 95% 置信区间；DeepSWE 官方报 Pass@1（每題一次）。k 越大分数越高、成本也越高。我们离线包默认 k=1，TB4 可用 `TB4_K` 调整。

**Q3：为什么必须锁版本？**

TB4 是「连续基准」，3.0 的 74 题到 4.0 变成 66 题、修了 19–20 题，版本间不可比；DeepSWE 有 v1/v1.1 两代判分方式；Automation 有 v1.0.6 与更早版本；ProgramBench 2026-10-22 更新过。自测前先确认 `@4.0.0`、`v1.1`、`1.0.6` 这类版本号。

**Q4：为什么本地分数和官方榜对不上？**

三类原因：① 官方榜用**私有 held-out 集**（Automation、HLE 等）；② 官方榜的 scaffold/采样参数与你不同（TB4 的 claude-code vs mini-swe-agent）；③ 官方榜跑 k 次取平均，你只跑 k=1。能对上的只有「同版本 + 同 harness + 同子集 + 同采样」的同条件横评。

**Q5：什么是 reward hack？**

模型不解决问题，而是利用判分器的漏洞拿分（例如只屏蔽 `alert` 而不真正过滤 JS、改测试文件、让测试跳过）。TB4 被 Epoch 复核出 30/66 题存在这类缺陷；DeepSWE 会把「改依赖清单、加 TestMain 劫持测试」记为作弊信号；ProgramBench 用「二进制只可执行不可读 + 断网」防作弊。

**Q6：跑多少题才有区分度？**

单题是 0/1 的基准（TB4、DeepSWE），10 题只能看出方向，30 题以上才能粗略排序；0–100% 的基准（NL2Repo、ProgramBench）方差更大，5–10 题基本只能当冒烟。官方榜 TB4 是 66×5、DeepSWE 是 113 题全量、ProgramBench 是 200 题全量——本地子集永远有采样误差，报告里必须写「子集 + 题号」。

## 4. 来源

- 本仓库主报告：[`../benchmark-guide.md`](../benchmark-guide.md)（第 3 节逐项详解、第 4 节口径警告）、[`../api-only-5bench-plan.md`](../api-only-5bench-plan.md)（接入矩阵与预算）
- 离线包任务文件：`E:\bench-bundle\data\`（TB4 36 题、DeepSWE 113 题定义/20 题镜像、NL2Repo 104 题、ProgramBench 5 实例、AutomationBench v1.0.6 源码）
- 打包与实测记录：[`../first-batch-bundle.md`](../first-batch-bundle.md)、[`../second-batch-bundle.md`](../second-batch-bundle.md)、[`../third-batch-bundle.md`](../third-batch-bundle.md)
- 官方页面：<https://www.tbench.ai/>、<https://deepswe.datacurve.ai/>、<https://github.com/multimodal-art-projection/NL2RepoBench>、<https://programbench.com/>、<https://github.com/zapier/AutomationBench>
