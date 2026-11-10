# 九个 Agent 评测集深读（2026-11-10）

> 对象：Terminal Bench 2.1、NL2Repo、DeepSWE、DSBench-Hard、AutomationBench (Public)、ApexBench (Pass@1)、Agents' Last Exam、Chartography、ZeroBench (Pass@5)
> 证据：本仓库本地实测（`TB-2.1-*.md`、`REPORT.md`、`harnesses/`、`eval_guanfang/`）+ 2026-11-10 在线复核（逐项分册见 本目录 `01-05-*.md`）。
> 仓库内相关文档：[`../benchmark-guide.md`](../benchmark-guide.md)（11 项逐条指南）、[`../benchmark-suite-analysis.md`](../benchmark-suite-analysis.md)（六模型 × 十一基准分析）、[`../model-eval/`](../model-eval/README.md)（五基准机制详解）、[`../../sources/deepseek-v41-flash-1017-model-card.md`](../../sources/deepseek-v41-flash-1017-model-card.md)。
> 路径说明：正文引用的 `TB-2.1-*.md`、`docs/`、`harnesses/`、`_stage/` 属于本地评测工作区，不在本仓库，仅作追溯。
> 约定：**厂商自报**（模型卡）≠ **官方榜**（官方协议/held-out）≠ **第三方复现**。`unknown` = 查不到；`unreachable` = 本网络打不开。

---

## 0. 先纠正一个前提：这 9 个名字来自一张模型卡

用户名单不是"九个公开基准"，而是 **HF `deepseek-ai/DeepSeek-V4-Flash-Vision-Exp`（2026-09-01）模型卡表格的 9/11 行**，顺序、写法（含括号）逐字一致。原表如下（DeepSeek 自报数字）：

| 分段 | 卡片原行 | Vision-Exp | V4-Flash-0731 | Opus-4.8 |
| :-- | :-- | --: | --: | --: |
| Text Agent | Terminal Bench 2.1 | 83.9 | 82.7 | 85.0 |
| Text Agent | NL2Repo | 57.7 | 54.2 | 69.7 |
| Text Agent | *Cybergym*（名单未列） | 75.3 | 76.7 | 78.3 |
| Text Agent | DeepSWE | 59.3 | 54.4 | 58.0 |
| Text Agent | *Toolathlon-Verified*（名单未列） | 75.9 | 70.3 | 76.2 |
| Text Agent | DSBench-Hard | 63.6 | 59.6 | 71.7 |
| Text Agent | AutomationBench (Public) | 25.7 | 25.1 | 27.2 |
| Multimodal Agent | ApexBench (Pass@1) | 36.5 | 26.2† | 39.4 |
| Multimodal Agent | Agents' Last Exam | 27.3 | 25.2† | 25.7 |
| Multimodal Agent | Chartography | 64.3 | – | 65.0 |
| Multimodal Agent | ZeroBench (Pass@5) | 35.0 | – | 34.0 |

卡片脚注（逐字要点）：
1. **文本 agent 行统一用 DeepSeek Harness 的 minimal mode**，`max` reasoning effort，`temperature=1.0, top_p=0.95`。
2. **†：V4-Flash-0731 在 ApexBench 与 ALE 上忽略输入中的多模态元素**（即"不看图做题"的基线）。

由此得到三条必须先接受的事实：

1. **括号不是版本号，是卡片自己的指标列名**：`(Public)`、`(Pass@1)`、`(Pass@5)` 是口径限定，不是独立机构协议；`(Public)` 尤其容易误导——它指"公开题集"，与官方榜的私有 held-out 不是一套题。
2. **9 项里只有 4 项能对到公开协议**（TB 2.1、DeepSWE、AutomationBench 公开集、ZeroBench）。另外 5 项：NL2Repo 官方 harness 有但卡片未披露、ALE 疑似 86 题子集、Chartography 协议与官方 no-tools 不一致、**DSBench-Hard 与 ApexBench 是 DeepSeek 内部基准（查无题源/judge/runner）**。
3. **这张卡是"厂商自报"，且跨卡不可比**：同一模型族在 6 周后（V4.1-Flash 卡）的同一列从 25.7→60.5（Automation）、59.3→77.0（DeepSWE）跳了 20–35 分（详见 §5）。**任何"某基准上涨 X 分"的时间序列叙事，先证明尺子没变。**

> 漏掉的两行：`Cybergym`（网络安全 agent）与 `Toolathlon-Verified`（工具调用 agent）。本报告未展开，若要做完整 11 项分析需补这两项。

---

## 1. 十句话结论

1. **九项分四组**：编码/终端（TB 2.1、NL2Repo、DeepSWE）、数据科学/内部 coding（DSBench-Hard）、长程与业务 Agent（Automation、ApexBench、ALE）、专业视觉（Chartography、ZeroBench）。组间分数不可比，组内也要看 harness。
2. **只有 4 项能在普通机器上完整复现**：TB 2.1（Harbor 公开）、DeepSWE（113 题公开+镜像）、AutomationBench 公开 600、ZeroBench（HF gated 可申请）。
3. **2 项根本不可测**：DSBench-Hard 与 ApexBench 是厂商内部集，题量、判分、harness、数据全无公开信息；引用只能写"厂商自报、不可复现"。
4. **3 项"能测但对不上原分"**：NL2Repo（官方 harness 有，但模型卡未披露设置，且抄源码漏洞没堵）、ALE（35.4 疑似 86 题 CLI 子集，非 122 全量）、Chartography（数据匿名 401 两年未开，卡片行与官方 no-tools 差 5 倍）。
5. **判分最干净的是 DeepSWE 与 AutomationBench**：功能 verifier + f2p/p2p 白名单 + 独立 verifier 容器；end-state 程序化断言、无 judge、正负断言近 1:1。两者的"假阳性/作弊面"在本批里最小。
6. **判分最脏的是 Chartography 与 ApexBench**：前者 LLM judge（Gemini 3.5 Flash，且 judge 自己参赛）+ 宽区间可"读错也对"；后者连判分器是什么都不知道。
7. **视觉两项的"单次噪声"远大于名次差**：ZeroBench n=100、Pass@5 的 95% CI 约 ±10pp（52 vs 43 不显著）；Chartography 论文标称 ±1.1pp 其实是 1 SE，真 95% 约 ±2.2pp，且 judge 方差未公开。
8. **成本跨度约 1000×**：ZeroBench 100 题×5 采样 $0.34–111；Automation 600 题 $20–60（DeepSeek 价）或 $680–2800（官方榜模型价）；TB 2.1 全量一轮 $1–100 但墙钟按天算；ALE 全量 122 题仅 agent 执行 24–157 小时。
9. **本仓库实测的噪声上限可参考**：TB 2.1 用 15 题 × k=3 × 3 遍（360 trials）测得**单次 15 题运行 95% 波动约 ±13pp（≈±2 题）**，pass@1 与 pass^3 缺口最大 24pp。小于这个量级的差距不要写结论。
10. **引用规则**：卡上 9 行里，能带脚注引用的只有 TB 2.1 / DeepSWE / Automation(公开集) / ZeroBench；NL2Repo 与 ALE 只能引"提升"不能引"领先"；Chartography 必须写"协议未知、与官方 no-tools 不可比"；**DSBench-Hard 与 ApexBench 不进入任何排名**。

---

## 2. 速览表

| # | 基准 | 测什么 | 题量 | 判分 | 官方版本/状态 | 公开协议 | 卡上这一行的可信度 |
| :-: | :-- | :-- | :-- | :-- | :-- | :-: | :-- |
| 1 | Terminal Bench 2.1 | 容器终端里做完整工程任务 | 89（本地 2 题无法 oracle，按 87 计） | 容器终态 pytest/脚本，0/1 | 2.1（2026-05-06）；官方已到 4.1（2026-11-09） | ✅ | 中（机制高，但已饱和、卡片未披露设置） |
| 2 | NL2Repo | 规格 → 可安装的完整 Python 库 | 104 | 上游 pytest 平均通过率（部分分） | v1/v2（2026-01），无榜单 | ⚠️ harness 有、设置未披露 | 中（分数不可对齐） |
| 3 | DeepSWE | 真实仓库的原创长程改造 | 113 | 功能 verifier + f2p/p2p，binary | v1.1（2026-06） | ✅ | 高（判分）/ 中（跨源） |
| 4 | DSBench-Hard | 内部困难 coding 题 | 内部集，题量 unknown | unknown | **DeepSeek 内部** | ❌ | 低（仅厂商自报） |
| 5 | AutomationBench (Public) | 模拟 SaaS 跨应用业务流程 | 公开 600（+200 simple） | end-state 断言，strict pass | 1.0.6，官方榜用 657 私有题 | ✅（公开集） | 中（公开集口径可锁定，但分数高于所有公开值） |
| 6 | ApexBench (Pass@1) | 多模态 Agent（含图像输入） | unknown | unknown | **DeepSeek 内部** | ❌ | 低 |
| 7 | Agents' Last Exam | 真机 CLI+GUI 长程职业任务 | 122 active（榜单/数据需审批） | 隐藏 reference + `evaluate()` | v1.1 | ⚠️ 子集口径未标注 | 低（未上官方榜、疑似 86 题子集） |
| 8 | Chartography | 专业图表读数 | 100 | LLM judge（Gemini 3.5 Flash），mean pass@1 | v1（2026-08），数据 401 | ⚠️ 官方 no-tools | 低（与官方协议差 5 倍） |
| 9 | ZeroBench (Pass@5) | 对抗式高难看图推理 | 100 main + 334 子题 | 精确匹配，pass@1/@5/^5 | v3（2026-07） | ✅ | 中（指标明确、但 w/tools 未标） |

---

## 3. 逐项深读

### 3.1 Terminal Bench 2.1（卡上 83.9 / 0731 82.7 / Opus-4.8 85.0）

**定位**：给 agent 一个装好环境的 Linux 容器 + 一段自然语言指令，让它在终端里自己折腾（写代码、装包、起服务、跑测试），最后用**独立 verifier 容器**检查"事情有没有做成"。不局限于软件工程：系统管理、安全、科学计算、数据处理、逆向都有。

**题源与版本谱系**：1.0（2025-05-19，约 100 题）→ 2.0（2025-11-07，重写为 Harbor + `task.toml`，89 题，论文 arXiv:2601.11868 描述的是这一版）→ **2.1（2026-05-06，89 题、题名不变，修 26–28 题【官方两处口径不一致：README 26 / 博客 28】，关闭社区提交）** → 3.0（2026-07-30，74 题，最好模型约 34%）→ 4.0（2026-08-28，66 题，删 8 修 19，统一 8h）→ **4.1（2026-11-09，沿用 4.0 题集，改 verifier 抗 reward hack 并重判 4.0 全部提交）**。2.1 的修复不是"变难"而是"变可信"：官方逐题提升最高 +84.3pp（`polyglot-c-py`），14 组 agent-model 平均 +0.9～+12.1pp、其中 2 组为负 → **2.0 与 2.1 数字不能混用，单模型跨度可达 12pp**。

**任务格式**：每题一个 Harbor task 目录：`instruction.md`（agent 唯一可见）、`environment/Dockerfile`、`tests/test.sh`（跑 pytest → `/logs/verifier/reward.txt`）、`solution/solve.sh`（oracle）、`task.toml`（类别、难度、专家/新手耗时、超时、资源、是否联网）。判分只看**容器最终状态**，不看敲了什么命令。2.1 的预算多为 900s（48 题）/1800s（17 题）/3600s（13 题），与 4.0 的"统一 8h"不同。

**质量门与反作弊**：官方每题有 oracle（必过）+ no-op（必不过）双向门禁；canary 写在 Dockerfile/tests；Dockerfile 不得含 tests/oracle；另用"必须作弊"的 prompt 攻题再人工复核。2026-04-19 起官方点名三起真实作弊（改 timeout 并把加密解放进 agent 二进制；把 `tests/` 打进 setup；先建 `AGENTS.md` 从网上 curl 答案），下榜/重判；随后 **2.1 关闭社区提交**，官方榜只剩 **18 条**（只收 maintainers 跑的结果）。**本地只做了 oracle 单向门禁（不过的题不进分母），没做 no-op**——能排除"环境假 0"，不能排除"测试过松"。

**已知缺陷/争议**：
- **`qemu-startup` 与 `qemu-alpine-ssh` 在本仓库离线环境 oracle 失败**（`debian:bullseye-slim` 安全源下线、build 时 `wget` Alpine ISO）→ 本地按 **87 题**计。但官方称 2.1 "no task is unsolved" → **正确写法是"本仓库环境下这两题无法 oracle，已剔除"，不是"TB 2.1 有两道坏题"**。
- **允许联网**（89/89 `allow_internet=true`）→ 理论上可查 oracle，已发生并被处理的作弊案例见上。
- **环境漂移是实测的**：Z.ai 只改 Dockerfile（装 `procps`/`python3`、`nproc` 限 4、预构建镜像），Opus 4.5 52.4% → 57.9%（+5.5pp）。
- **审计版本归属**：Epoch 的 "30/66 缺陷、Flawed" 审的是 **TB 4.0**，不是 2.1；2.1 没有独立第三方审计，唯一系统复核来自 Z.ai（2.1 共同作者，属自审）。
- **已饱和**：Z.ai 2026-08 原话"已拿到 85 分以上就不必再测 2.1"；官方榜前 4 名 80–87%、前 12 名 73% 以上。

**卡上 83.9 怎么读**：三件事一起说：① 卡片用的是 **DeepSeek Harness minimal mode**（不是官方中立脚手架 Terminus 2；官方榜同模型换 scaffold 实测跨度 0.2–8.1pp、方向不固定）；② 2.1 官方榜（tbench.ai，2026-11-10 抓取，仅 18 条）头部是 GPT-6 Astra 87.4%、Fable 5 83.8%、GPT-5.5 83.2% → 83.9 属"与头部同档"；③ 同一数据集的另一张"Harbor Hub 榜"（44 模型，收录规则未明示）把 **DeepSeek-V4.1-Flash 排到 90.6** → 同日两个都叫"官方"的榜，第一名差 3.2pp、模型池差 26 个。**所以 83.9 只说明"在 2.1 的饱和区"，不说明 2026-11 的前沿水平，也不能跨榜对齐。**

**本地实测价值（本仓库最硬的数据）**：15 条子集（按构建可行性筛，不是难度筛）× k=3 × 3 遍 = 360 trials，8 个模型。结论：① 单次 15 题 95% 波动 **±13pp（≈±1.9 题）**，单次 k=1 达 ±25pp；② pass@1 与 pass^3 缺口最大 24.4pp（"能碰到但拿不稳"）；③ 失败 74% 是"三遍全错"的系统性失败、只有 12% 是抖动；④ 15 题里仅 6 条真正有区分度（贡献 100 条失败的 85 条），4 条白送 27pp → 难度分布是双峰不是梯度；⑤ 本地 Flash 81.2% 与 Harbor Hub 榜 DeepSeek-V4.1-Flash 90.6% 差 9.4pp，几乎全是口径差。方法论见 `TB-2.1-METRICS.md`。

**可信度**：机制高（终态判分、tests 事后注入、判分前删 reward、双向门禁、真实作弊处理）；当前区分度低（已饱和）；版本可比性中低（2.0→2.1 跨度 12pp）。
**自测**：15 题 × k=3 只能内部粗排（±13pp）；对外引用必须 **89 题 × k=5 + Terminus 2**（±2–3pp，约 15h、$0.1k–2.1k）；两题按"修镜像"或"剔出分母写 87"处理，不要静默记 0。

---

### 3.2 NL2Repo（卡上 57.7 / 0731 54.2 / Opus-4.8 69.7）

**定位**：能力阶梯最右端——给一份需求文档 + 一个空工作区，从 0 到 1 写出**完整、可 `pip install` 的 Python 库**，再用上游仓库原始 pytest 打分。不给脚手架、不给函数签名、不给测试。

**构造**：104 个真实 Python 库（300–120k LOC、≥10 stars、pytest 全绿、三年内更新）。把仓库**反向工程**成四节规格（Project Description / Supports / API Usage Guide / Implementation Nodes），平均 **18.8k tokens**；用 AST 扫描保证"每个被测试调用的 API 都在文档里写清楚"。难度 Easy 26 / Medium 46 / Hard 32。

**判分**：Score = 上游 pytest **平均通过率**（部分分，0–100%），另报 Pass@1 Count（整库全绿的题数，论文最强 3–5/104）。为防 collection 一错全零，测试命令带 `--continue-on-collection-errors`。**Score 与 SWE 类"解决率"不是同一量纲**。

**协议与漏洞**：官方 harness = OpenHands 0.56 headless + 双镜像（openhands:0.56 + runtime:0.56-nikolaik）。主实验**不设轮数上限**（论文实测平均 181.6 轮）。**没有硬隔离阻止 agent `pip download`/`git clone` 目标库**——本仓库的一条 trial 就是这么刷出 26/26 的（已标为作弊膨胀）；论文 Table 8 还实测"把测试给 agent"能让 Sonnet4.5 从 40.2→59.4（+19.2pp）。**所以任何"NL2Repo 高分"先问：禁没禁联网、放没放测试。**

**卡上 57.7 怎么读**：论文最强（Sonnet 4.5 + Claude Code）40.2，卡片上一整列 6 个模型都在 56.8–75.3，**整列比论文高 20–35pp** → 几乎可以确定尺子变了（harness/轮数/是否放测试/子集，模型卡全未披露）。**能说的只有"比 0731 强 3.5pp"这种同卡内相对量**，不能说"57.7 相当于论文体系的多少"。

**可信度**：中（判分是真测试；但无 LICENSE、无榜单、抄源码漏洞、harness 未披露）。
**自测**：先 oracle 门禁（gold workspace 必须 100%），再跑 `markdownify`（83/83 干净）或 `jsonlines` 单题；单题约 30–60 分钟 + 一次 ~1GB 镜像。**必做**：判分容器禁 pip/git 目标包、确认 agent 自写 tests 被删。

---

### 3.3 DeepSWE v1.1（卡上 59.3 / 0731 54.4 / Opus-4.8 58.0）

**定位**：在真实开源仓库里做**原创的、长程的功能改动**，用**手写功能 verifier** 判分。针对 SWE 系两个结构性缺陷下药：题目会被背（挖公开 PR）、判分被继承测试绑死。

**数据**：113 题 / 91 个活跃仓库 / 5 语言。全部原创：从零写参考解、**永不合并回上游**；容器只 shallow clone base commit（无完整 `.git`，堵"从 git 历史捞 gold patch"）；每个仓库中位只贡献 1 题。参考解约 668 行、跨约 7 个文件（约为 SWE-bench Pro 的 5.5 倍代码量），prompt 却只有约 2k 字符。

**判分（v1.1 契约）**：Harbor schema 1.3；**f2p/p2p 白名单按 test node id**；**独立 verifier 容器**（`environment_mode="separate"`、无网）；提交捕获 = `[[verifier.collect]]` 的 `git diff --binary base HEAD`（300s）；`reward.json` + `ctrf.json` + partial 诊断；agent 超时 **10,800s**。缺席=失败（防删测试）、skipped=失败、同一测试多报告取最差；`reward=1` 当且仅当 f2p 全过且 p2p 零失败。**判分设计是当前 SWE 类里最干净的之一。**

**审计**：作者自建 LLM 判官审计里，DeepSWE 与 verifier 分歧率 **1.4%**（735 条中 2 假阳 + 8 假阴），SWE-bench Pro 32.4%（789 条中 67 + 189）。**能引用"低一个量级"，不能引用"Pro 判错 32.4%"**——分子只有个位数事件、判官是 GPT-5.5 且自己参赛、作者自审、无第三方复现。

**卡上 59.3 怎么读**：这是 0731/Vision-Exp 卡的 **DSH minimal mode** 成绩；6 周后的 V4.1 卡同一基准变成 **77.0**，harness 换成 Mini-SWE-V2（mini-swe-agent 移植版）。**59.3 与 77.0 之间既有模型换代也有 harness 变化，不能当"提升了 17.7 分"引用。** 论文口径（GPT-5.5 70.0）与 59.3 也不是同一模型。

**本地实测**：六模型 × 16 题 = 96 trials 只解出 3 条（Qwen3.8-Max 2/16、DeepSeek-Pro 1/16，其余 0），且 DeepSeek-Flash 的 `model.patch` 为 0 字节（能读懂但不写）。**这是本机 60 步上限 + 非官方 scaffold 的下界，不可对官方榜**，但它暴露了"能读懂 ≠ 会动手"的失败模式。

**可信度**：高（判分）/ 中（跨来源）。**自测首选**：`--n-tasks 10 --sample-seed 0`（官方确定性抽样），$2.4–134；要可比就 113 题全量。

---

### 3.4 DSBench-Hard（卡上 63.6 / 0731 59.6 / Opus-4.8 71.7）

**它是什么**：**DeepSeek 内部**的"困难 coding-agent 题集"，与 `DSBench-FullStack` 成对，模型卡脚注原文 "DSBench-Hard is an internal test set of difficult coding-agent problems"。同一数字在三张卡复现（0731 59.6 / 0813 67.2 / Vision-Exp 63.6），说明是固定题集 + 固定 harness，但**题集对外不可见**。

**它不是什么**：**不是** arXiv 2409.07703 的 DSBench（ICLR 2025 数据科学 agent 基准：466 data analysis + 74 data modeling，题源 Eloquence + Kaggle，最好 agent 34.12%）。两者同名不同物，题源领域、量级、判分全不同。**不能拿学术 DSBench 的任何协议/题量/judge 来描述它**。

**卡上 63.6 怎么读**：只有一个数字。题量、单题分、时限、judge、f2p/p2p、是否联网、污染风险全部 `unknown`。它与 Opus-4.8 的 71.7 差 8.1pp，但因为两边都是 DeepSeek 自跑、无协议，**不能当"落后 8.1 分"的能力结论**。
**可信度**：低（仅厂商自报）。**不可自测**。V4.1 卡起该行消失 → 内部集可能已停用。

---

### 3.5 AutomationBench (Public)（卡上 25.7 / 0731 25.1 / Opus-4.8 27.2）

**定位**：在模拟的企业 SaaS 世界里给一句业务请求（"把今早的供应商发票录进表格并汇总邮件"），agent 只能通过 REST 工具操作 47 个模拟应用（Gmail/Sheets/Slack/Salesforce/Zendesk/Jira/Calendly…）约 500 个端点；**没有 shell、没有文件系统、没有浏览器**；只检查世界最终状态。

**构造**：公开 600 题（6 域各 100）+ 200 道 simple（不计分，只作冒烟）。**正断言与负断言数量近 1:1**（"不该发邮件给谁""不该建这条记录"），专治"广撒网式 reward hacking"。判分 = `task_completed_correctly`（全部断言通过才 1）+ `partial_credit`（诊断/dense reward，官方定位为 RL 信号，**不能当奖励**——按本地题例推算，零工具调用的 agent 在 partial_credit 上约 0.44–0.59）。

**口径五层**（这是本项最重要的知识）：
| 口径 | 数据集 | 榜首 | 能否互比 |
| :-- | :-- | :-- | :-- |
| 官方榜 1.0.6 | **657 题私有 held-out** | Gemini 4 Carbon (High) **53.88%** | 榜内可比 |
| README 公开集表 | 公开 600 | Opus 5 50.3% | 与"同集同配置自跑"可比 |
| 厂商模型卡 | 推断公开 600 | DS-1017 60.5% | 只对上一行做方向性比对 |
| 第三方 AA | 私有 657 | 77.8%（指标不同） | 不可比 |
| llm-stats | 自报 | 0 verified | 不可用 |

**卡上 25.7 怎么读**：这行用的是 DSH minimal mode 跑公开集；6 周后 V4.1 卡同一行变成 **60.5**（+34.8）。**同一基准、同一厂商、12 个模型行里唯一能解释这种跳变的只有"换了 harness/effort/设置"**——而卡上没写。所以 25.7 与 60.5 都只能在同一张卡内横向比。

**可信度**：机制高（程序化 end-state、无 judge、公开可跑、官方称 run-to-run <1%）；数字中（公开集口径可锁定，但 60.5 高于所有已公布公开集值，也高于私有榜榜首 53.88%，无法核实）。
**自测**：全 11 项里最便宜（无 Docker/GPU/代码执行，MIT）。**第一个必做实验**：零工具基线（mock 模型从不调工具）跑 6 域，期望 pass=0%；>0 即说明存在空断言题。再 20 题 → 50 题 → 600 题（$20–60，3–10 小时）。

---

### 3.6 ApexBench (Pass@1)（卡上 36.5 / 0731 26.2† / Opus-4.8 39.4）

**它是什么**：**DeepSeek 内部的多模态 Agent 基准**——题目输入含图像/界面元素（卡片把该行放在 "Multimodal Agent Capabilities" 段；脚注明确 0731 基线"ignores the multimodal elements in the input"，即同一张卷子有人不看图做）。指标列名 `(Pass@1)`。

**它不是什么**：不是 MathArena Apex（数学推理，ETH/INSAIT，公开榜，首发最高 5.21%，V4.1 卡另有 `MathArena Apex (Pass@1)=65.6` 一行）；也不是 Mercor APEX/APEX-Agents（专业服务长程任务，HF `mercor/apex-agents` 480 题）；也不是 APEX-Bench（项目排程）或 llm-stats 的 "Apex"。**同名物至少 7 个，必须写全称与发布方。**

**卡上 36.5 怎么读**：`Pass@1` 只是标签，采样次数、judge、题量、协议全部 `unknown`；`36.5 → 72.1`（V4.1 卡的 `Apex Bench v1.1`）不能用来说"提升 35.6 分"——两卡之间 Automation 25.1→54.8、DeepSWE 54.4→74.2 同步跳变，说明尺子变了。
**可信度**：低。**不可自测**，不进入任何排名。

---

### 3.7 Agents' Last Exam（卡上 27.3 / 0731 25.2† / Opus-4.8 25.7）

**定位**：UC Berkeley RDI 的真机长程基准。给一段任务描述，让 agent 在真实 Windows/Linux 机器上用 CLI **和** GUI 自主完成专业工作（Siemens NX 建模、After Effects 动画…），结束后把**隐藏 reference** 放进去，由任务自带 `evaluate()` 打 [0,1]，报 passRate（全 1 才算过）与 avgScore。

**规模**：v1.1 **122 active**（Linux 86 + Windows 36；CPU 119 / GPU 3），45 near-term / 46 full-spectrum / 36 last-exam；55 子领域 / 13 行业簇（O*NET/SOC）。v1→v1.1 退役 30 题、改 57 题、6 题换开源软件；**v1/v1.1 日志不可复用**。真能判分的资产是 **gated=manual 的 39.2GB archive**；公开的只有 122 条 metadata。

**卡上 27.3 怎么读**：**未上官方榜，且疑似子集**。技报对上一版明确写 general agent 用 **ALE-CLI（86 题子集）**；论文说最难档"平均全通过率 <1%"，所以 27.3 不可能来自 36 题 last-exam 档，必是混合集。另有硬矛盾：llm-stats 汇总里 DeepSeek 0.354 与模型卡 35.4 逐位吻合（说明该站基本照抄厂商），但把 GPT-5.6 Sol 记成 52.7 而模型卡写 26.7（差 26pp）→ **"DeepSeek 在 ALE 表内第一"不成立**。

**可信度**：机制中-高（隐藏 reference 后置、确定性 grader、失败记 `score:null` 而非 0）；数字低。**建议只引用不自跑**：数据审批 + 仅 Ubuntu/Debian 宿主 + 真机镜像 + 单题 5h × 122 题，四道硬门槛。

---

### 3.8 Chartography（卡上 64.3 / 0731 – / Opus-4.8 65.0）

**定位**：Surge AI 的专业图表读数基准（100 题 / 12 领域）。图不是柱/折/饼，而是 Kaplan–Meier 曲线、K 线、等值线、Bode 图、风玫瑰、控制图。考"按图支持的精度读数"：稀疏轴估读、曲线间插值、细线追踪、投影 3D 几何、领域惯例。论文自陈**瓶颈在感知而非推理**。

**官方协议（关键）**：单条 user message（题面 + 内联图），**无 system prompt、无 few-shot、无工具（no code execution, cropping, or zooming）**；judge = `google/gemini-3.5-flash`，**每试次一次调用、judge 只看题面/金标/回答、从不看图**；51/100 带专家区间（落区间即对）；指标 mean pass@1，论文 20 trials/题、榜 10 epochs。**judge 自己也参赛**（Gemini 3.5 Flash 35.9 排第 3），论文原文承认这是 "self-judging condition"。

**卡上 64.3 怎么读（本报告最刺眼的一处）**：官方 no-tools 榜（论文冻结 2026-07）榜首 **45.0**，Claude Opus 4.8 只有 **11.3**，DeepSeek V4.1 Flash **11.6**（2026-10-30 存档）。而这张卡给 Opus-4.8 **65.0**、给 Vision-Exp **64.3**——**同一模型差 5.7 倍**。卡上没标 `w/tools`，但 V4.1 卡明确把同类行标成 `Chartography (w/tools) = 83.0`（Claude Code harness + 512k）。结论：**这一行必然不是官方 no-tools 协议；协议未知，不可与官方榜或 V4.1 卡的 w/tools 行直接比。**

**为什么 w/tools 等于换题**：论文把"不许裁剪/放大/写代码，只给一次机会"写成了构念本身，而 71pp 差距里唯一能量化的只有 reasoning effort（约 +5pp，论文 Table 4），其余（工具、分辨率、多轮、judge）全部 `unknown`。**正确表述是"83.0 与 11.6 不是同一构念的两个测量"，不是"工具带来 71pp 增益"。**

**数据**：HF `surgeai/chartography` 匿名 **401**（2026-10-30 与 11-10 两次实测），HF 搜索无结果，repo 无 LICENSE，GitHub 只有 harness + 2 个假任务。**自测不可能，只能引用。**
**可信度**：基准本体中-高；卡上这一行**低**。

---

### 3.9 ZeroBench (Pass@5)（卡上 35.0 / 0731 – / Opus-4.8 34.0）

**定位**：100 道人工出题、经对抗式筛选到"发布时前沿模型做不出"的高难看图推理（象棋 FEN、地图读数、雪花体积、Farsi 书法拼句…）。答案空间大、不可猜，必须从图里精确取数再算。错误分析同样指向**视觉而非计算**。

**判分**：确定性 exact-match，**无 judge**。取回答中**最后一个 `{...}`**，`strip().lower()` 后要求**长度相等且全等**；无数值容差（`0.40` ≠ `0.4`）；超 max_tokens 或空 completion 自动记错。指标 pass@1 / pass@5 / pass^5，均"over 5 samplings"；pass@1 用 greedy，pass@5/pass^5 用 temp 0.7 / top_p 0.95。**格式错误是真实风险**（单位、有效数字、末尾草稿里的花括号、长 CoT 截断）。

**`(Pass@5)` 的数学**：pass@5 = 5 次中至少 1 次对；pass^5 = 5 次全对；结构上 pass^5 ≤ pass@1 ≤ pass@5。官方榜首 GPT-6 Astra 实测 43.2 / 52.0 / 35.0，可整数自洽分解为「35 题稳定会做 + 17 题时对时错（均 2.4/5）」；若 5 次独立，pass@5 应≈94%——**说明 5 次采样强相关，Pass@5 里有约 17pp 是抖动而非能力**。n=100 → 二项 95% CI 约 **±10pp**，所以 52 vs 43 不显著。

**卡上 35.0 怎么读**：官方主榜是 **no-tools**（榜头标 "w/o tools"，工具跑的单列），而 V4.1 卡把同类行标成 `ZeroBench-main (w/tools) = 51.0`（Claude Code harness、512k、temp 1.0）。Vision-Exp 卡这一行**没标 w/tools**，协议未知。35.0 与官方榜同代模型的 41–53 差距不算离谱，但**不能与 w/tools 的 51.0 并列**。
**可信度**：基准本体高（判分确定性、gated+canary、三家框架实现、官方 2026-08 主动修正 0.71% 判定）；卡上这一行中-低。
**自测**：优先做。100 题×5 采样约 **$0.34–111**（官方 cost/question），DeepSeek 级 API 约 **$0.02–4**，1–5 小时；用 `inspect_evals/zerobench` 一条命令拿三指标。

---

## 4. 横向矩阵

| 维度 | TB 2.1 | NL2Repo | DeepSWE | DSBench-Hard | Automation(公开) | ApexBench | ALE | Chartography | ZeroBench |
| :-- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 输入 | 指令+容器 | 18.8k 规格 | 短 prompt+仓库 | 内部 | 一句请求+工具 | 图像+任务 | 任务+真机 | 单图 | 单图/多图 |
| 模型交什么 | 容器终态 | 整个仓库 | git diff | 未知 | 系统终态 | 未知 | 机器终态 | 文本答案 | `{答案}` |
| 判分器 | 终态测试 | 上游 pytest 通过率 | 功能 verifier | 未知 | end-state 断言 | 未知 | 隐藏 reference | LLM judge | 精确匹配 |
| 单题分 | 0/1 | 0–100% | 0/1 | 未知 | 0/1 | 未知 | 0–1 | 0/1 | 0/1 |
| 整轮指标 | resolve rate | 平均通过率 | Pass@1 | 未知 | strict pass | Pass@1 | passRate/avgScore | mean pass@1 | Pass@5 |
| 题量 | 89（87 可用） | 104 | 113 | 内部 | 600（榜 657 私有） | 内部 | 122 | 100 | 100 |
| 单题上限 | 8h（2.1 更短） | 无轮数上限 | 3h | 未知 | 50 步 | 未知 | 5h | 单轮 | 单轮 |
| 数据 | 公开 | 公开无 license | 公开/轨迹 gated | 无 | 公开 600 | 无 | 39.2GB gated | 401 | gated 可申请 |
| 全量成本 | $1–100/轮 | unknown（最贵量级） | $27–1515 | 无 | $20–60（DeepSeek 价） | 无 | $100–1000+ | unknown | $0.34–111 |
| 自测性价比 | 中 | 低 | 高 | 无 | **最高** | 无 | 低 | 极低 | 高 |
| 可信度 | 中 | 中 | 高 | 低 | 高（机制） | 低 | 低-中 | 低 | 高（本体） |

---

## 5. 跨卡不可比：为什么"涨了 35 分"不能当进步

同一模型族、6 周内的两张卡（Vision-Exp 2026-09-01 → V4.1-Flash 2026-10-16）同一列：

| 基准 | Vision-Exp 卡 | V4.1 卡 | Δ | 官方已知的变化 |
| :-- | --: | --: | --: | :-- |
| TB 2.1 / TB 4.0 | 83.9（2.1） | 42.3（4.0） | 换基准 | 2.1→4.0 题集/评分全变 |
| NL2Repo | 57.7 | 68.2 | +10.5 | harness 未披露 |
| DeepSWE | 59.3 | 77.0 | +17.7 | DSH minimal → Mini-SWE-V2 |
| DSBench-Hard | 63.6 | 停报 | — | 内部集停用 |
| Automation (Public) | 25.7 | 60.5 | **+34.8** | harness 变更（未披露） |
| ApexBench | 36.5 | 72.1（v1.1） | **+35.6** | v1.0→v1.1（未披露） |
| ALE | 27.3 | 35.4 | +8.1 | 仍疑似 ALE-CLI |
| Chartography | 64.3 | 83.0（w/tools） | +18.7 | 明确换成 w/tools |
| ZeroBench | 35.0 | 51.0（w/tools） | +16.0 | 明确换成 w/tools |

**读法**：同一列在 6 周内跳 20–35 分，只可能来自"换模型 + 换尺子"；而模型卡只披露了部分 harness。**任何跨卡时间序列（"v1.1 提升了 X 分""视觉版比文本版强 Y 分"）都不成立**，除非能证明两次的 harness、题集、采样完全一致。

---

## 6. 九条口径陷阱

| # | 基准 | 陷阱 | 正确写法 |
| :-: | :-- | :-- | :-- |
| 1 | TB 2.1 | 2.1 ≠ 4.0/4.1（89 vs 66 题，2.0→2.1 单模型跨度可达 12pp）；本地 2 题无法 oracle；卡片用 DSH minimal mode 而非 Terminus 2；官方"26/28 题"两处口径不一 | 写版本+分母（87/89）+harness+预算 |
| 2 | NL2Repo | 平均通过率是**部分分**；官方 harness=OpenHands 0.56 且卡片未披露设置；抄源码漏洞 | 写"平均测试通过率"+scaffold+是否禁联网 |
| 3 | DeepSWE | v1/v1.1 判分不同；官方 Pier+mini-swe；卡片两次用了不同 harness | 写 v1.1+harness commit+Pass@1 |
| 4 | DSBench-Hard | 与学术 DSBench 同名不同物；内部集无协议 | 只写"厂商内部集，自报，不可复现"；不排名 |
| 5 | Automation (Public) | 公开 600 ≠ 官方 657 私有；五套口径不可混 | 写"public-set pass rate"+版本+toolset+effort |
| 6 | ApexBench | 同名 ≥7 个；多模态 Agent 非 reasoning；Pass@1 只是标签 | 写全称+发布方；不排名 |
| 7 | ALE | 122 全量 vs ALE-CLI 86 子集；未上官方榜；竞品列自相矛盾 | 写题集口径+是否上榜；只引提升不引领先 |
| 8 | Chartography | 官方 no-tools vs 卡片未知协议（疑 w/tools），同模型差 5.7 倍；数据 401 | 写"协议未知/不可比"+judge+trials |
| 9 | ZeroBench | Pass@5 ≠ Pass@1；×5 成本；±10pp；exact-match 格式惩罚 | 写 Pass@5+5 samplings+no-tools/w-tools |

---

## 7. 成本、时间与自测路线

| 基准 | 全量成本 | 墙钟 | basis |
| :-- | :-- | :-- | :-- |
| ZeroBench | $0.34–111（100×5） | 1–5h | 官方 cost/question |
| Automation | $20–60（600 题，DeepSeek 价） | 3–10h | 本地实测 simple 5 题外推 + 官方 cost/task |
| DeepSWE | $27–1515（113 题） | 单题 ≤3h | 官方 avg cost/task |
| TB 2.1 | 官方榜整轮 **$0.1k–2.1k**（89×k=5，按模型）；本地 45 trials 7.5–125 积分 | 单 trial 20min–1h；89 题×k=5 约 15h | 官方榜 COST 字段 + 本地实测 |
| NL2Repo | unknown | 单题 30–60min | 本地单题 |
| ALE | API $20–150 + VM $50–300+ | 24–157h agent 时间 | 官方榜 tokens/duration |
| Chartography | unknown | 数十分钟–数小时 | 1000 生成+1000 judge |
| DSBench-Hard / ApexBench | unknown | unknown | 无公开数据 |

**三档路线**：

| 档 | 目的 | 组合 | 预算 |
| :-- | :-- | :-- | :-- |
| 冒烟（半天） | 验证链路 | ZeroBench 50×1；Automation 5 题；DeepSWE 单题；TB 2.1 oracle + 2 题 | <$5 |
| 方向（1–2 天） | 同 harness 粗排 | TB 2.1 固定 15 题×k=3；DeepSWE 10 题；ZeroBench 100×5；Automation 50 题 | $50–300 |
| 正式（1–2 周） | 可对外引用 | TB 89 题×k=5（Terminus 2）；DeepSWE 113 题；Automation 600 题；NL2Repo 3–5 题子集；视觉按官方 no-tools 单独报 | $1k–1.5k+ |

---

## 8. 怎么用这 9 个数字（引用规则）

| 用途 | 可用的行 | 必须带的条件 |
| :-- | :-- | :-- |
| **可带脚注引用** | TB 2.1 83.9；DeepSWE 59.3；Automation 25.7；ZeroBench 35.0 | 版本（2.1/v1.1/1.0.6/v3）+ harness（DSH minimal）+ 指标（Pass@1/Public/Pass@5）+ "厂商自报" |
| **只能引"相对提升"** | NL2Repo 57.7（vs 0731 54.2）；ALE 27.3（vs 25.2） | harness/题集未披露，不可跨卡、不可对论文 |
| **只能引"存在这个数"** | Chartography 64.3 | 协议未知、与官方 no-tools 差 5 倍、数据不可得 |
| **不引用** | DSBench-Hard 63.6；ApexBench 36.5 | 内部基准，无题源/judge/runner；只作"厂商能力宣称"的脚注 |

一句话：**这 9 行里，能撑起"排名"的只有 DeepSWE 与 Automation（且都只能在同一 harness 内）；能撑起"趋势"的是 TB 2.1 与 ZeroBench；其余 5 行只能描述厂商自述。**

---

## 9. 证据与待核实

- 分册：`01-tb21.md`（TB 2.1）、`02-nl2repo-deepswe.md`、`03-dsbench-apex.md`、`04-automation-ale.md`、`05-chartography-zerobench.md`；原始模型卡存档 `evidence/vision-exp-model-card.md`。
- **待核实**：TB 2.1 的两张"官方"榜（tbench.ai 18 条 vs Harbor Hub 44 模型）收录规则与卡片 83.9 用的是哪张/哪一子集；NL2Repo 卡片 harness/k；DSBench-Hard 与 ApexBench 的题量/判分（不可能核实，除非官方发布）；ALE 官方榜今日值（网关拦截）；Chartography 数据与协议（HF 401）；Automation 60.5 与 25.7 的 harness 差异。
- **本地实测的边界**：TB 2.1 的 ±13pp 来自 15 题子集，不能外推到 89 题全量；DeepSWE 96 trials 的下界来自 60 步上限 + 非官方 scaffold；NL2Repo 的 26/26 是作弊膨胀样本。
