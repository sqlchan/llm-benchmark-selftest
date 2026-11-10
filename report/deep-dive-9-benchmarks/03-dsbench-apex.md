# 03 · DSBench-Hard 与 ApexBench (Pass@1) 定性报告

> 核查时间：2026-11-10（Asia/Shanghai）。方法：`pwsh Invoke-WebRequest` 抓 HuggingFace 模型卡原文（`resolve/main/README.md`）、arxiv abs/html/API、GitHub raw、Bing 搜索；PDF 用 Python 解压 stream 抽文本。
> 本文件只做「定性 + 证据」；凡查不到的写 `unknown` 并附检索证据。**不要为了凑篇幅补协议细节。**

---

## 0. 头号结论：这两个基准名都来自同一张模型卡，且都不是你名单里以为的那个东西

用户名单的 9 项，与 **`deepseek-ai/DeepSeek-V4-Flash-Vision-Exp`（HF，2026-09-01）模型卡表格逐字同序**，只少了同表的 `Cybergym` 和 `Toolathlon-Verified` 两行：

| 卡片原行（Vision-Exp README） | 用户名单 | 是否一致 |
| --- | --- | --- |
| Terminal Bench 2.1 | Terminal Bench 2.1 | ✅ 逐字 |
| NL2Repo | NL2Repo | ✅ 逐字 |
| ~~Cybergym~~ | — | 名单未列 |
| DeepSWE | DeepSWE | ✅ 逐字 |
| ~~Toolathlon-Verified~~ | — | 名单未列 |
| DSBench-Hard | DSBench-Hard | ✅ 逐字 |
| AutomationBench (Public) | AutomationBench (Public) | ✅ 逐字含括号 |
| ApexBench (Pass@1) | ApexBench (Pass@1) | ✅ 逐字含括号 |
| Agents' Last Exam | Agents' Last Exam | ✅ 逐字 |
| Chartography | Chartography | ✅ 逐字 |
| ZeroBench (Pass@5) | ZeroBench (Pass@5) | ✅ 逐字含括号 |

**推论（高置信）**：用户名单 = 该卡「Text Agent Capabilities + Multimodal Agent Capabilities」两段表格的子集拷贝。括号里的 `(Public)` / `(Pass@1)` / `(Pass@5)` 就是**卡片自己写的指标列名**，不是版本号，也不是独立评测机构的口径限定。

由此得到两条与任务书前提冲突的结论：

1. **DSBench-Hard 不是 arXiv 2409.07703 的 DSBench**（那个是数据科学 agent 基准）。它是 **DeepSeek 自建、内部（internal）的 coding-agent hard 测试集**，模型卡脚注明写 "internal test set"。名字撞车而已。
2. **ApexBench 不是 MathArena Apex**（数学推理），而是 **DeepSeek 自建的多模态 Agent 基准**；DeepSeek 同一张 V4.1-Flash 卡里另有一行明确写了 `MathArena Apex (Pass@1)`，两者并存 → 它们确实是两个东西。

---

## A. DSBench-Hard

### A.1 一句话定位

厂商内部「困难 coding-agent 题集」的**自报分数**；无公开题源、无判分器、无 harness 说明、无榜单。能力坐标：仓库/代码修补（与 Terminal-Bench、DeepSWE 同列于「Code Agent」段）。

### A.2 出处与版本（唯一的权威出处 = HF 模型卡本身）

| 模型卡 | 日期 | DSBench-Hard | 同表 DSBench-FullStack† | URL |
| --- | --- | ---: | ---: | --- |
| DeepSeek-V4-Flash-0731 | 2026-08-01 | **59.6** | 68.7 | <https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash-0731> |
| DeepSeek-V4-Pro-0813 | 2026-08-13 | **67.2** | 71.1 | <https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro-0813> |
| DeepSeek-V4-Flash-Vision-Exp | 2026-09-01 | **63.6** | （未列） | <https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash-Vision-Exp> |
| DeepSeek-V4.1-Flash / -1017 | 2026-10-16 / 17 | **未列（0 次出现）** | 未列 | <https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash> |

**脚注原文（V4-Pro-0813 与 V4-Flash-0731 一致）**：
> † DSBench-FullStack is an internal full-stack development test set; DSBench-Hard is an internal test set of difficult coding-agent problems.

即：**官方自己承认是内部集**。两个集（FullStack / Hard）成对出现，像是一套内部评测的两个难度层。V4.1 两卡改报 Terminal-Bench 4.0 / DeepSWE / ProgramBench 后，DSBench 系列整段消失 → 该内部集**跨代已停用或停报**。

### A.3 同表对照行（说明它是被当作「与人竞品横比」用的）

V4-Pro-0813 同表 DSBench-Hard 全行：`DS-V4-Pro-0813 67.2 / DS-V4-Flash-0731 59.6 / DS-V4-Pro(Preview) 31.1 / DS-V4-Flash(Preview) 25.8 / GLM-5.2 54.5 / Kimi K3 63.0 / Opus-4.8 71.7 / Fable-5 68.3`。
→ 跨卡一致性可核验：Flash-0731 的 59.6、Pro(Preview) 的 31.1、Opus-4.8 的 71.7 在两张卡里完全相同。**说明它是固定的题集 + 固定 harness，不是随手编的数**；但题集内容对外不可见。

### A.4 判分 / 题源 / 成本 / 污染

全部 `unknown`。仅有的可推断信息：
- 卡片把 DSBench-Hard 归在「Code Agent」段，eval 设置与其它 code agent 基准相同：`DeepSeek Harness` 的 **minimal mode**、`max` reasoning effort、`temperature=1.0, top_p=0.95`（V4-Flash-0731 脚注 1；Vision-Exp 脚注 1 同）。**harness 本身未开源**（0731 卡写 "to be released"）。
- 题量、单题分、时限、是否 f2p/p2p 测试、judge 类型：**无任何公开信息**。
- 成本：无法估算（`unknown`）。
- 污染风险：无法评估；内部集理论上污染风险低，但没有题源就无法验证，且 DeepSeek 自家模型在此项上被 Opus-4.8 反超 4.5 分（67.2 vs 71.7），至少不像「刷过的自家集」。

### A.5 任务书前提的三处事实纠正（重要，避免写进总报告）

| 任务书/传闻说法 | 官方实际 | 证据 |
| --- | --- | --- |
| DSBench = "466 data modeling + 537 data analysis" | **466 data analysis + 74 data modeling**（合计 540） | arXiv 2409.07703 摘要 v1 与 v3 **均**如此；项目页同 |
| 题源 = ModelOff / DataBench 等 | **Eloquence（ModelOff 历年题） + Kaggle**；无 "DataBench" | 同上；EnvCommons/DSBench README 写 "ModelOff financial modeling compet… + Kaggle" |
| 存在 "Hard" 子集 / 2026 改名扩版 | **学术 DSBench 无 Hard 子集**；官方页面、README、HF 数据集均无 "hard" 分层 | <https://liqiangjing.github.io/dsbench.github.io/>、<https://github.com/LiqiangJing/DSBench>、HF `liqiang888/DSBench` |

> 顺带：`537` 这个数字在我核查的所有官方页面（摘要 v1/v3、项目页、GitHub README、EnvCommons）中**都不存在**，疑为二手转述错误。学术 DSBench 的判分是 data-analysis 单轮答案 + **LLM judge 判对错**（`compute_answer.py`，README 明写用 OpenAI key）、data-modeling 用 Kaggle 指标相对提升（RPG），最好 agent 只解出 34.12% analysis 题——**与 Hard 的 59.6/67.2 量级完全不同，不可能是同一题集**。

### A.6 检索证据（"DSBench-Hard" 反查）

| 检索面 | 结果 |
| --- | --- |
| Bing `"DSBench-Hard"`（带引号） | 200，**只回退到学术 DSBench**（LiqiangJing/DSBench、项目页、arXiv 2409.07703、EnvCommons/DSBench、CSDN/知乎转述）；Bing 明显忽略引号 |
| Bing `DSBench Hard benchmark` / `"DSBench-Hard" benchmark model card` / `DSBench-Hard DeepSeek Kimi Qwen GLM 2026` | 同上，三次返回同一批 10 条，无任何模型卡命中 |
| GitHub API `search/repositories?q=dsbench` | total=22，全部为学术 DSBench 或其衍生/同名杂物（`Repurposu/dsbench` 数据结构库、`datastax-archive/dsbench-labs` 数据库工具…），**无 hard 子集仓库** |
| GitHub API `search/repositories?q=apexbench` | total=4，均与本议题无关 |
| HF `api/datasets?search=dsbench` | 6 条，均为 `liqiang888/DSBench` 衍生，无 hard 版 |
| arXiv API `ti:DSBench` | 429 限流（未取到）；abs 页直接核实已足够 |
| **HF 模型卡原文（决定性）** | DSBench-Hard 出现在 0731 / 0813 / Vision-Exp 三卡；`Apex` 在 V4.1 两卡中出现 1 次（MathArena Apex）；`DSBench` 在 V4.1 两卡中 **0 次** |

**结论**：`DSBench-Hard` 在公开互联网上**没有任何独立出处**，只能定位到「DeepSeek 模型卡表格里的一行 + 一句 internal 脚注」。名字撞车学术 DSBench，是纯巧合（也可能是刻意沿用的缩写），**不可引用学术 DSBench 的任何协议/题量/judge 来描述它**。

---

## B. ApexBench (Pass@1)

### B.1 仓库旧结论的复核结果：**主体成立，但有两处需要更新**

| 旧结论（截至 2026-10-30） | 2026-11-10 复核 | 判定 |
| --- | --- | --- |
| 唯一出处是 DeepSeek 模型卡一行 `Apex Bench v1.1 = 72.1` | 成立（V4.1-Flash-1017 卡，2026-10-17），且**仍未出现**在任何 tech report（V4.1 技报 PDF 全文 `Apex Bench`/`ApexBench`/`DSBench` 均 0 次） | ✅ 维持 |
| 无主页 / 论文 / 数据 / runner | 成立。`apexbench.ai` **DNS 不存在**（未能解析远程名称）；HF `api/datasets?search=apexbench` 与 `api/models?search=apexbench` 均返回 `[]`；GitHub 无 DeepSeek 相关仓库 | ✅ 维持 |
| 第三方只是转引 | 成立，但**本轮无法打开复核**：phaseo / open-llm-radar / datalearner / mercor.com 在本机被网关过滤拦截（见 §D） | ⚠️ 沿用 2026-10-30 记录 |
| ≠ MathArena Apex、≠ Mercor APEX/APEX-Agents | 成立，且**新增强证据**：DeepSeek 自己的 V4.1-Flash 卡里 `MathArena Apex (Pass@1)` 与 `Apex Bench v1.1` **同时存在且数值不同**（见 B.3） | ✅ 加强 |
| （旧结论未覆盖）**ApexBench 是"多模态 Agent"基准而非 reasoning 榜** | **新增证据**：Vision-Exp 卡把 `ApexBench (Pass@1)` 放在 **"Multimodal Agent Capabilities"** 段；脚注 2：「† For ApexBench and Agents' Last Exam, DeepSeek-V4-Flash-0731 **ignores the multimodal elements in the input**」→ 题目输入含图像/多模态 | 🆕 需修正任务书假设 |
| （旧结论未覆盖）**同名物不止 4 个，至少 7 个** | 见 B.4 对照表 | 🆕 |

### B.2 一手数字（全部来自 DeepSeek 自家 HF 卡，均为厂商自报）

`DeepSeek-V4-Flash-Vision-Exp`（2026-09-01）「Multimodal Agent Capabilities」段：

| Benchmark | Vision-Exp | V4-Flash-0731 | Opus-4.8 |
| --- | ---: | ---: | ---: |
| **ApexBench (Pass@1)** | **36.5** | 26.2† | 39.4 |
| Agents' Last Exam | 27.3 | 25.2† | 25.7 |
| Chartography | 64.3 | - | 65.0 |
| ZeroBench (Pass@5) | 35.0 | - | 34.0 |

`DeepSeek-V4.1-Flash-1017`（2026-10-17）主表：

| Benchmark | 1017 | V4.1-Flash | K3 | GLM-5.3 | GPT-5.6 Sol | Opus 5 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| **Apex Bench v1.1** | **72.1** | 64.6 | 47.8 | 56.6 | 54.3 | 65.8 |

### B.3 同一个名字，两个月内从 26.2 涨到 64.6 —— 这是个红旗

- `ApexBench`（无版本号）与 `Apex Bench v1.1` **极可能是同一基准的前后两个版本**，但**没有任何官方文字确认**这一点（`unknown`）。
- 若视为同一基准：DS-V4-Flash 从 26.2 → 64.6（+38.4）、DeepSeek 自家 36.5 → 72.1（+35.6），而同期 ALE 从 25.2 → 31.8（+6.6）。**同一基准确在 6 周内涨 38 分不合常理** → 更可能是「v1.0 → v1.1 改了题集/判分/是否给多模态」。
- **横向对照更致命**：同一时期 DeepSeek 其它卡上的 `AutomationBench (Public)` 也从 25.1（0731 卡）跳到 54.8（V4.1-Flash 卡），`DeepSWE` 54.4 → 74.2。**多张卡、多个基准同时出现 20–30 分级跳变**，说明跨卡数字不可比（harness/effort/数据集版本至少变了一个）。→ 用 Apex Bench 数字做时间序列对比（如「V4 视觉版 36.5 → V4.1 72.1 提升一倍」）是**错误推论**。

### B.4 同名物对照表（至少 7 个，务必拆开）

| # | 名称 | 发布方 | 测什么 | 指标 | 公开性 | 代表分数 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | **Apex Bench v1.1 / ApexBench (Pass@1)** | DeepSeek（内部） | 多模态 Agent（题目含图像输入） | 卡片标 Pass@1 | ❌ 无主页/论文/数据/runner | 72.1（V4.1-1017 自报）/ 36.5（Vision-Exp 自报） |
| 2 | **MathArena Apex** | SRI Lab @ ETH Zürich + INSAIT（Dekoninck et al., 2025） | 极难数学**最终答案**题（初始 12 题，持续追加） | 准确率（~Pass@1） | ✅ 主页/榜单公开 | 2025-08 首发最高 **5.21%**；DeepSeek V4 技报 `Apex (Pass@1) 34.5`、`Apex Shortlist 85.9`；V4.1-Flash 卡 `MathArena Apex 65.6` |
| 3 | **Mercor APEX / APEX-Agents** | Mercor | 长程跨应用专业服务任务（投行/咨询/法务；docx/xlsx/pdf/email/chat/calendar） | 任务完成度 | ✅ HF `mercor/apex-agents`（480 题，gated=auto，CC-BY-4.0，arXiv 2601.14242）、`mercor/apex-agents-v1.1`（240 题，2026-08） | 未在本轮核实具体分数 |
| 4 | **llm-stats "Apex"** | LLM Stats 聚合站（页面标注 Maintainer: Mercor） | 页面自称「frontier reasoning，STEM/逻辑，纯文本」 | 0–1.0 | ⚠️ 页面自标 **Verification: Self-reported / Status: Unverified**，仅 2 个模型 | Nemotron 3 Ultra 0.848、Qwen3.7-Plus 0.227（2026-11-10 页面） |
| 5 | **APEX-Bench (Agentic Planning EXam)** | 社区项目（maxsnijders / apex-bench org） | 项目排程 agent（Primavera XER 文件、自然语言改排程） | 未核实 | ✅ GitHub Apache-2.0 / 数据 CC-BY-4.0，站点 apex-bench.com | 无 |
| 6 | **APEX-Bench（学术海报编辑）** | arXiv 2601.04794（Breesiu/APEX） | 514 条学术海报编辑指令，VLM-as-a-judge | 多维判分 | ✅ arXiv + GitHub | 无 |
| 7 | 其它同名杂物 | — | GitHub `cyanxiao/apex-bench`（Apex Legends 赛果预测）、`apexfitness.com`（健身凳）、`apexbenchmark.com` 等 | — | — | 与议题无关 |

> 说明：llm-stats 的 "Apex" 描述为 **reasoning**，与 Mercor 官方 APEX（专业服务任务）自相矛盾，且只有 2 个模型、自报未核验 → 该页**不能作为任何一方的权威口径**，最多当「第三方转引」引用。
> 任务书里「llm-stats 的 Apex 是一个 reasoning 榜」这一描述**成立**，但把它归给 Mercor 是本轮新增信息，且与该站自身描述不一致，需标注为可疑。

### B.5 `(Pass@1)` 到底限定了什么

| 口径 | 定义 | 与 Pass@1 的差别 | 在本项上的可用性 |
| --- | --- | --- | --- |
| **Pass@1** | 每题采样 **1** 次，答对记 1；指标 = 题均成功率 | 成本最低、方差最大 | 卡片标注就是这个，但**是否真的只采样 1 次不可核验** |
| pass@k | 每题采样 k 次，**至少 1 次**答对即算过 | k 增大时分数单调上升，且与 Pass@1 不可横比（ZeroBench 名单里的 `(Pass@5)` 就是这种，成本 ×5） | 不适用 |
| avg@k | 每题采样 k 次，取**平均**正确率 | 比 pass@k 低、比单次 Pass@1 稳；是估计 Pass@1 的常用降噪手段 | 若厂商私下用 avg@k 却写 Pass@1，会**高估稳定性** |

噪声量级（通用结论，非本基准实测）：二项分布下，n 题、真实成功率 p 的单次估计标准差 ≈ `sqrt(p(1-p)/n)`。若题量 n 未知，则噪声**完全不可估**——这是本项最硬的限制。
- 例：n=200、p=0.7 时 ±1σ ≈ 3.2pp；n=50 时 ≈ 6.5pp。**跨模型 1–3 分差在这类题量下通常不显著。**
- 本项还有一个额外方差源：**多模态输入的渲染分辨率/是否给图**——Vision-Exp 卡脚注明说 0731 基线「ignores the multimodal elements」，等于同一张卷子有人不看图做。这类协议差异的影响远大于采样噪声。

**判定：`Pass@1` 在本项仅是模型卡的标注（label），不是可核验的协议。** 采样次数、temperature（其它 DeepSeek 卡用 `temp=1.0, top_p=0.95`，可类推但未对该行单独确认）、judge、题量全部 `unknown`。

---

## C. 可信度评级与「不能下的结论」

### C.1 评级

| 项 | 评级 | 理由 |
| --- | --- | --- |
| **DSBench-Hard = DeepSeek 内部 coding-agent hard 集（定性）** | **高** | 三张 HF 卡逐字同表 + 明确 internal 脚注 + 跨卡数字一致（59.6/31.1/71.7 复现） |
| **DSBench-Hard 的数值/协议/题量** | **低（≈unknown）** | 零公开信息，无题源、无 judge、无 harness、无 runner |
| **DSBench-Hard ≠ 学术 DSBench (ICLR 2025)** | **高** | 题源、领域（数据科学 vs coding agent）、量级（34.12% vs 67.2）三重不符 |
| **ApexBench = DeepSeek 内部多模态 Agent 基准（定性）** | **高** | Vision-Exp 卡分段标题 + "ignores multimodal elements" 脚注 + 与 MathArena Apex 同行并存 |
| **ApexBench 的数值/协议** | **低** | 无题量/判分/harness；两卡同名不同值（36.5 vs 72.1/64.6），版本关系未确认 |
| **「ApexBench 是 reasoning 榜」** | **否证** | 一手卡片归在 Multimodal Agent 段 |
| 名单 9 项 = Vision-Exp 卡片子集 | **高** | 9/9 逐字同序，含括号写法 |

### C.2 不能下的结论（写总报告时逐条禁止）

1. ❌ 不能说「DSBench-Hard 基于 ICLR 2025 DSBench，是数据科学 agent 基准」——名字撞车，题源领域完全不同。
2. ❌ 不能引用学术 DSBench 的 466/74 题量、LLM judge、RPG 指标、34.12% 基线去描述 DSBench-Hard。
3. ❌ 不能写「DSBench-Hard 是公开基准」或「可复现/可自测」；它是 internal，无 runner。
4. ❌ 不能拿 67.2（Pro-0813）与 63.6（Vision-Exp）做「版本提升」叙事——两卡模型不同、报的集可能不同、且缺题量。
5. ❌ 不能拿 `ApexBench 36.5` 与 `Apex Bench v1.1 72.1` 算增长率或说「v1.1 更容易」；两卡之间多个基准同步跳变，跨卡不可比。
6. ❌ 不能凭 72.1 > 65.8（Opus 5）说「DeepSeek 在 Apex 上领先 Opus」——同表竞品数字也是 DeepSeek 自己跑的自报值，未给 harness/轮数/采样。
7. ❌ 不能把 `Apex Bench v1.1` 与 `MathArena Apex`、`Mercor APEX/APEX-Agents`、`APEX-Bench`、llm-stats `Apex` 任一合并或互证。
8. ❌ 不能说 `Pass@1` 已核实；只能说「卡片标注为 Pass@1」。
9. ❌ 不能给出 DSBench-Hard / ApexBench 的题量、单题成本、全量时长、judge 模型——全部 unknown。
10. ❌ 不能把这两个基准放进任何「能力排名/横评矩阵」的正式结论区；只能放进「厂商自报、不可核验」附表。

### C.3 自测性价比建议

- **DSBench-Hard / ApexBench：均不可自测（infeasible）**。无数据、无 runner、无许可信息。若目标是「自己测 DeepSeek-V4.1-Flash-1017」，这两项唯一正确处置是**引用时标注「厂商内部基准，自报，不可复现」**，并从排名表剔除或单列。
- 若必须做同类自测替代：coding 方向用 **Terminal-Bench 2.1 / DeepSWE v1.1**；多模态 agent 方向用 **Chartography（注意 no-tools）/ ZeroBench（Pass@5）**；数学推理若要覆盖「Apex」语义，只能用 **MathArena Apex 官方榜**（且注意其题集是持续追加的 living set，跨月不可比）。

---

## D. 打不开 / 被拦截的 URL（本轮实测，2026-11-10）

| URL | 状态 | 性质 |
| --- | --- | --- |
| `https://www.datalearner.com/benchmarks/apexbench` | 返回 200 但是**网关过滤页**（"URL过滤 访问被拒绝…海康上网策略限制"） | 本机网络出口拦截，**非站点错误**；无法复核其 Pass@1 表述 |
| `https://phaseo.app/zh-Hans/benchmarks/apex-bench-v1.1` | 同上（过滤页） | 同上 |
| `https://open-llm-radar.com/benchmarks/apexbench` | 同上（过滤页） | 同上；仓库 2026-10-30 的 "Multimodal Agents / 72.1·36.5·26.2" 记录沿用 |
| `https://www.mercor.com/apex/` | 同上（过滤页） | 改用 HF `mercor/apex-agents*` 数据集卡取证 |
| `https://www.mojeek.com/search?q=%22DSBench-Hard%22` | 同上（过滤页） | 备用搜索引擎不可用 |
| `https://baike.baidu.com/item/ApexBench` | **403 Forbidden** | 站点反爬；仅能引用 Bing 摘要（二手） |
| `https://apexbench.ai/`、`https://www.apexbench.ai/` | **DNS 未能解析**（NXDOMAIN 类） | 不存在该站点 → 支持「无官方主页」结论 |
| `https://grep.app/api/search?q=...` | **429 Too Many Requests**（3 次重试均失败） | 代码搜索面未覆盖，是本次检索的**盲区** |
| `http://export.arxiv.org/api/query?...ti:DSBench` | 首次 429，重试后部分成功 | arXiv API 限流，改用 abs 页直取 |
| `https://llm-stats.com/benchmarks/apex` | 200，但含 "Confirm you're human" 验证提示 | 正文已取到，数据可能不完整 |

---

## E. 给 Lead 的合并建议（一句话级）

- **把这两项从「9 个公开基准」框架里拆出来**，单列一节「厂商内部基准（2 项）」，与 Chartography/ZeroBench 的 w-tools 问题并列，作为「口径陷阱」的极端案例：**同一张表里的 9 个名字，7 个有公开协议、2 个（DSBench-Hard / ApexBench）连题量都没有。**
- 总报告的「基准清单」应改为：用户名单实为 **DeepSeek-V4-Flash-Vision-Exp 模型卡表格的 9/11 行**，其中 `Cybergym`、`Toolathlon-Verified` 被略去。这一步能一次性解释为什么 9 个名字看起来「不像同一层的基准」。
