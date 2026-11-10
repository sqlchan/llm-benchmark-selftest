# 04 · AutomationBench (Public) 与 Agents' Last Exam（ALE）深读

> 核实日期 **2026-11-10**｜作者：agentic-analyst｜工作目录 `E:\ai\code\git\kaiyuan_coding`
> **本轮亲测（pwsh + Invoke-WebRequest，HTTP 200）**：`raw.githubusercontent.com/zapier/AutomationBench/main/{README.md,pyproject.toml}`、`arxiv.org/abs/2604.18934`、`zapier.com/benchmarks`、`raw.githubusercontent.com/rdi-berkeley/agents-last-exam/main/{README.md,docs/releases/v1.1.md}`、`arxiv.org/abs/2606.05405`、`huggingface.co/api/datasets/agents-last-exam/*`、`llm-stats.com/benchmarks/{automationbench-1.0.6,agents-last-exam}`、`artificialanalysis.ai/evaluations/automationbench-aa`。
> **本轮 unreachable**：`agents-last-exam.org`、`agenthle.org`（含 `/leaderboard`、`/api/demo/leaderboard/v1.1`）——网关返回 HTTP 200 + "URL过滤/访问被拒绝"页，正文不可读；ALE 官方榜今日值**无法复核**，只能转引本仓库 2026-10-30 的抓取记录并标注性质。
> **数字性质标记**：`〔官〕`官方榜/官方文档｜`〔厂〕`厂商自报（模型卡）｜`〔三〕`第三方（含自报汇总）｜`〔本〕`本仓库实测或转引｜`unknown` 查不到｜`unreachable` 打不开。

---

# A. AutomationBench (Public) — Zapier 的模拟 SaaS 业务流基准

## A1. 一句话定位与能力坐标

在**模拟的企业 SaaS 世界**里给一句业务请求（"把今早的供应商发票录进表格并汇总邮件"），agent 只能通过 **REST 风格工具**操作 Gmail/Sheets/Slack/Salesforce/Zendesk/Jira/Calendly 等 47 个模拟应用、约 500 个端点；**没有 shell、没有文件系统、没有浏览器**，跑完只检查"世界最终状态"对不对。

- 能力坐标：**业务流编排 + 端点发现 + 规则优先级 + 负面筛选**（不是终端通用、不是仓库修补、不是视觉）。
- 独有特征：**只判终态、不判过程、不判回复**；正断言与**负断言数量近乎 1:1**（考"不该做的事没做"）。

## A2. 出处与版本

| 项 | 内容 | 来源 |
| :-- | :-- | :-- |
| 发布方 | Zapier | — |
| 论文 | arXiv **2604.18934**，*AutomationBench*，Daniel Shepard & Robin Salimans，**2026-04-21** 投 v1（cs.AI） | 〔官〕本轮核实 |
| 仓库 | `github.com/zapier/AutomationBench`，**MIT** | 〔官〕 |
| 官方榜 | `zapier.com/benchmarks`，当前标题 **Leaderboard 1.0.6**（页面显示前 10 名 + "See 124 more" = **134 行**） | 〔官〕本轮核实 |
| 当前版本 | `pyproject.toml`：`version = "1.0.6"`、`requires-python = ">=3.13"`；依赖 `anthropic>=0.83.0`、`verifiers>=0.2.0`、`httpx`、`pydantic`、`rich`、`python-dotenv` | 〔官〕本轮核实 |
| 版本锚点建议 | 引用/自测一律锁 `1.0.6`；榜单页自身也标 1.0.6，两者目前同版 | 〔官〕 |

## A3. 题源与构造

| 项 | 数字 | 性质/来源 |
| :-- | :-- | :-- |
| 公开计分题 | **600**（Sales / Marketing / Operations / Support / Finance / HR 各 **100**） | 〔官〕README |
| 公开不计分题 | **simple 域 200**（1–2 步基础任务） | 〔官〕README |
| 官方榜私有集 | **657 题**（6 域，held-out，不发布） | 〔官〕AA 页写 "covers 657 tasks"；Zapier 页脚注出现 "260 of 657" |
| 工具面 | **47** 个模拟 SaaS 应用、**约 500** 个端点 | 〔官〕 |
| 题源 | Zapier 平台真实 workflow 模式（页面称基于 2B+ 月任务 / 3.7M 公司） | 〔官〕 |
| 防污染 | 官方榜只用私有 held-out，公开 600 仅"研究与实验"；官方明言私有集 "**purposely harder**" | 〔官〕README |

**simple 域的作用**（本项第二重要设计）：不计分、只当冒烟与"会不会调工具"的基线。天花板效应明显——本仓库实测 deepseek-v4-flash 与 glm-5.3-flash 各 **5/5（100%）**〔本〕，所以 `simple 5/5` 不能当基准分引用。

## A4. 判分契约

| 项 | 内容 |
| :-- | :-- |
| 判分器 | **程序化 end-state 断言**（`automationbench/rubric/assertions`），**无 LLM judge** |
| 单题双指标 | `partial_credit` = 通过断言数/总断言数（0–1，官方定位为 RL dense reward）；`task_completed_correctly` = 1 当且仅当**全部**断言通过 |
| 整轮指标 | 计分题（排除 simple）里 `task_completed_correctly=1` 的比例 = 官方 pass rate（**strict**） |
| 采样 | 单次运行；官方称 run-to-run variance **typically within 1%**〔官〕 |
| 断言类型 | 本地包内统计的高频类型：`gmail_message_sent_to_with_body_contains` 1093、`google_sheets_row_exists` 594、`gmail_message_not_sent_to` 470、`google_sheets_row_not_exists` 396、`slack_message_*` 373/372、`gmail_message_sent_to` 368、`salesforce_field_equals` 111〔本〕 |
| 负断言密度 | 本地 6 域题例：finance 4/9、support 14/30、hr 6/13、marketing 8/15、operations 6/11、sales 10/17〔本〕——**每题 44%–59% 的断言是"不该发生"** |

**假阳/假阴**：strict + 正负并列 → 假阳率低（"多做事"和"少做事"都会被扣）。假阴来源三处：① 断言写死（Zapier 自认"仍有未抓到的 bug，欢迎报 unfair task"〔官〕）；② 50 步截断；③ 口径（toolset / reasoning effort）不一致。官方另公布失败模式画像："**72% 的 Opus 失败、91% 的 Gemini 失败、84% 的 GPT-5.4 失败是"自称完成但世界状态错"**〔官〕——即模型自述完全不计分。

## A5. 执行协议

| 项 | 内容 |
| :-- | :-- |
| 官方 harness | `uv sync` → `uv run auto-bench --model <m>` |
| 工具模式 | `--toolset api\|zapier\|limited_zapier`，**默认 `api`**；官方榜**跑 API 模式**〔官〕 |
| API 模式的工具面 | 只给**两个工具**：`search`（BM25 检索 API schema，返回 top 5）+ `execute`（curl 风格 method/URL/body）。"**发现正确端点本身是考点**"〔官〕 |
| 步数上限 | `--max-steps` 默认 **50**（官方："rarely hit"）〔官〕 |
| 并发 | `--max-concurrent` 默认 **100** |
| 推理强度 | `--reasoning-effort low\|medium\|high\|xhigh\|max`；README 公开集表注明"各模型取最高可用 effort"〔官〕 |
| 其他 | `--responses-api`、`--search-top-k`（默认 20，**仅 zapier toolset**）、`--input-cost/--output-cost`、`--export-json`、`--save-every`、`--tasks`、`--skip` |
| 模型接入 | OpenAI 兼容 `--base-url/--api-key`；`claude-*` 前缀自动走 Anthropic API |
| 资源 | **不需 Docker / GPU / 代码执行**（世界是进程内 Pydantic 模拟，"state lives locally so runs are reproducible"） |

> ⚠ **本地证据需修正的一处**：`report/model-eval/05-automation-bench.md` §2.3 写 "`api`：直接给 REST 风格函数"。这与官方 FAQ 的"API 模式只给 `search`+`execute` 两个工具"**冲突**；`tasks.py` 里的 `zapier_tools` 字段是一个个应用级工具名（`gmail_find_email`…），更像 **zapier toolset** 的工具清单。三种 toolset 的精确工具面 = **unknown**（本地无仓库源码，`E:\bench-bundle\data\AutomationBench` 与 `sandbox\AutomationBench` 均不存在），建议以源码为准再定稿。

## A6. 数据可得性与许可

- **可完全自测**：公开 600 + simple 200 随仓库发布，MIT；`uv sync` 后即跑。
- **私有 657 题不可得**：仅官方榜使用，无获取渠道。
- **离线可用性（本仓库最强项）**：`--network none` 下用 mock OpenAI 端点跑完 1 题、判分、导出 JSON、`exit 0`〔本〕；runner 镜像内已烘 Python 3.13 venv（`uv sync --frozen --python 3.13`），运行期 `uv run --offline`。
- **部署门槛**：Python **≥3.13** + `uv`；Windows 终端 GBK 会让 rich 在**导出之后**崩（`UnicodeEncodeError: 'gbk' codec can't encode '✓'`，表现为 exit 1 但数据不丢）→ 设 `PYTHONUTF8=1`〔本〕。
- 替代 harness：Prime Intellect 托管环境〔官〕；EvalScope `automation_bench`（未实测）；第三份独立复现 = Artificial Analysis **AutomationBench-AA**〔三〕。

## A7. 成本与时长

| 口径 | 数字 | basis |
| :-- | :-- | :-- |
| 〔官〕官方榜 cost/task（前 10 名） | **$1.14–$4.64 / 题** → 600 题 **≈$680–$2,800** | zapier.com/benchmarks 的 "Cost / task" 列，按各家标准 list price |
| 〔本〕DeepSeek 价实测 | simple 5 题 754,874 in / 35,387 out = **约 151k 输入 tokens/题** → $0.15/M 输入 + $0.6/M 输出 ≈ **$0.023/题** → 600 题 **≈$14 起** | simple 域最容易；域任务步数更多，实际 **$20–60/600 题** 合理 |
| 〔本〕墙钟 | simple 5 题 **489.6 s**（并发 4）；sales 100 题 @并发 5 约 **35 min–1 h**；600 题 **3–10 h** | 实测 + 线性外推 |
| 关键结论 | 官方 $"2.12/题" 与本地 "$0.02–0.03/题" 差 **两个数量级**，差异**全部来自模型单价**，不是题量 | — |

## A8. 已知缺陷、争议与 reward hacking 面（本节为重点）

**A8.1 口径缺陷**

1. **公开 600 ≠ 官方 657**：官方用词是 "directional agreement"、"may not match 1:1"〔官，README〕。
2. **版本内也在变难**：README 原文——私有题"有时会在版本更新中**被改得更难**，以便修 bug 时把榜单最高分维持在同一水平"〔官〕。这意味着**同一 1.0.6 号内的历史分数不可跨时间比对**，且"公开集涨分 → 榜分涨分"只是"likely (but not guaranteed)"。
3. **论文 <10% vs 现榜 53.88%**：论文摘要"Even the best frontier models currently score below 10%"（2026-04，v1 早期口径）〔官〕；2026-11 官方榜榜首 **53.88%**〔官〕。**约 5 倍落差**，主因是版本 + 模型换代，两者绝不可并列引用。

**A8.2 reward hacking 面（逐条回答"是否能用极简路径绕过业务规则"）**

| 面 | 结论 | 依据 |
| :-- | :-- | :-- |
| "过程要求"是否被判 | **不判**。只判终态，所以"先读政策表再动手"这类要求，**没写成断言就等于没考** | 〔官〕"Only the resulting data is scored; the agent's reply is ignored" |
| "极简路径"是否可行 | **可行且被设计接受**：agent 可以直接 `execute` PATCH 目标字段，只要终态对就满分 | 〔官〕判分定义；非漏洞，是"看结果不看合规"的取舍 |
| 一条 `execute` 通吃？ | 不能。官方榜 API 模式只给 `search`+`execute`，**终点 URL 与 body schema 要自己发现**；发现错端点 → 4xx / 写错对象 | 〔官〕 |
| 空断言/恒真断言题 | **unknown**（本地无源码，无法逐题审计）→ 但可用实验判定（见 A10） | — |
| 负断言能否被"什么都不做"刷 | 能。`*_not_exists` / `*_not_sent_to` 在不行动时**全部通过** | 逻辑必然 |
| `partial_credit` 安全性 | **不安全**。按本地 6 域题例的负断言占比，一个**零工具调用**的 agent 在 partial_credit 上理论上限 ≈ **0.44 / 0.47 / 0.46 / 0.53 / 0.55 / 0.59（6 题均值 ≈0.51）**〔本，推算未实测〕。把它当 RL 奖励会奖励"不动手" | 本地 §5.8 统计 |
| strict 指标安全性 | **高**。正负断言同时要过，"全做"（shotgun）和"不做"都过不了 | 〔官〕"negatives exist to prevent shotgun reward hacking, like emailing everyone" |

**A8.3 其他争议**：`--toolset` 与 `--reasoning-effort` 显著改分（跨模型比较必须固定，否则重演"scaffold ≠ scaffold"陷阱）；50 步上限对长流程题可能截断（官方称"rarely hit"，本地无 600 题实测，unknown）。

## A9. 分数怎么读（**五套口径，不可混用**）

| # | 口径 | 数据集 | 模型数 | 榜首 | DeepSeek | 能否互比 |
| :-: | :-- | :-- | :-: | :-- | :-- | :-- |
| ① | 〔官〕官方榜 1.0.6 | **私有 held-out 657** | 134 行 | Gemini 4 Carbon (High) **53.88%**（$2.12/题）；Claude Opus 5.5 (Max) 42.47% | **无行** | 榜内可比；run-to-run ±1% |
| ② | 〔官〕README 公开集表 | 公开 600 | 10 | Claude Opus 5 **50.3%**；Kimi K3 46.67%；GPT-5.6 Sol 45.83% | 无行 | 只与"同集同配置自跑"可比 |
| ③ | 〔厂〕模型卡 1.0.6 | 推断=公开 600 | 6 | DeepSeek-V4.1-Flash-1017 **60.5** | 60.5 / 54.8 | 只能对 ② 做方向性比对 |
| ④ | 〔三〕AutomationBench-AA | 私有 657 | 29 / 256 | Gemini 4 Carbon (High) **77.8%** | 有 DeepSeek 家族参与但页面文本未给分值 | **不可**与①③比（指标不同） |
| ⑤ | 〔三〕llm-stats "v1.0.6" | 自报 | 7 | MiniMax M3.1 Flash **0.628** | 无 | **不可用**（页面自标 0 verified / 7 self-reported、Unverified） |

**为什么③只能是"公开集自跑"**：模型卡的 Automation 行里，Opus 5 = 50.3、K3 = 46.7、GPT-5.6 Sol = 45.8 与 README 公开集表**逐格吻合**〔本轮核对〕；GLM 之所以差（模型卡 48.8 vs README 26.17）是因为 README 列的是更老的 **GLM 5.2**。三格吻合足以把该行锁定为公开集口径。
**但 60.5 仍无法核对**：它高于公开集最高值 50.3%、也高于官方榜最高值 53.88%。若 60.5 是官方榜口径，它就该是榜首（而榜首只有 53.88%）；所以**60.5 不可能是①的成绩**，且官方榜前 10 与页面 payload 中均无 DeepSeek 字样。

**读法三条**：①≠②≠③，任何并列都是错的；④⑤不进能力结论；跨模型比较必须"同集 + 同 toolset + 同 effort + 单次"。

## A10. 可信度评级 + 自测建议

- **机制与判分：高**〔理由：程序化 end-state、无 judge、公开可跑、正负断言并列、官方榜公开且给 cost/task、variance<1%〕。
- **模型卡 60.5 这个数字：中**〔理由：口径可锁定为公开集自跑（三格吻合），但**高于所有已公布同集数字**、无官方榜行、且官方明言公开集↔私有集不保证 1:1〕。
- **自测性价比：全 11 项里最高**（无 Docker、无 GPU、无代码执行、MIT、600 题全量可离线跑）。

**建议路径（按顺序，全部先固定 `--toolset api --reasoning-effort <同一值> --max-steps 50`）**

1. **零基线（必做，10 分钟级）**：用一个"从不调工具"的 mock 模型跑 `--domains all`。期望 `pass rate = 0%`。**若 >0，即证明存在空断言/恒真题**，必须逐题复盘后才能报分。（本仓库 simple 2 题已得 0%〔本〕，但未覆盖 6 个计分域。）
2. **20 题冒烟**：`--domains sales --num-examples 20`，验链路 + 摸 token/步数分布。
3. **50 题趋势**：6 域各 8–10 题（`--tasks` 或分域跑），够看 ±5 pp 的模型差异。
4. **600 题全量**：$20–60（DeepSeek 价）/ 3–10 h，出"**public-set pass rate**"，报告里必须写这四个词，不得称"官方榜分"。
5. 报告必带：版本 1.0.6、toolset、reasoning effort、max-steps、是否触顶、公开集 vs 私有集声明。

# B. Agents' Last Exam（ALE v1.1）— 真机 CLI+GUI 的长程职业考试

## B1. 一句话定位与能力坐标

给 agent **只有一段任务描述**，让它在**真实 Windows/Linux 机器**上（真装真软件）用 CLI **和** GUI 自主干完一件专业工作（Siemens NX 建模、After Effects 动画、Unreal 布景…），结束后再把**隐藏 reference** 放进去，由任务自带的 `evaluate()` 比对交付物打 [0,1] 分。

- 能力坐标：**长程（人类数小时–数周工时）+ 真机专业软件 + CLI/GUI 混合**。论文把对象叫 **Generalist CUA-agents**（不能只会终端，也不能只会点鼠标）。
- 与 Automation 的互补关系：Automation = "无 GUI 的纯 API 业务流"；ALE = "有 GUI 的真软件专业活"。两者是 11 项里唯一的"业务/真机 Agent"两支。

## B2. 出处与版本

| 项 | 内容 | 来源 |
| :-- | :-- | :-- |
| 发布方 | **UC Berkeley RDI** × RDI Foundation；250+ 行业专家参与 | 〔官〕论文摘要 + README |
| 论文 | arXiv **2606.05405**，*Agents' Last Exam*（v1 2026-06-03，**v4 2026-10-25**；**378 位作者**） | 〔官〕本轮核实 |
| 仓库 | `github.com/rdi-berkeley/agents-last-exam`；**软件 Apache-2.0 / 数据 CC-BY-4.0** | 〔官〕 |
| 官网 / 榜 | `agents-last-exam.org`、榜 `agenthle.org/leaderboard` | **unreachable**（本轮网关拦截） |
| 当前版本 | **v1.1**：**122 active tasks**（v1 → v1.1 **退役 30 题**） | 〔官〕README + `docs/releases/v1.1.md` |
| 常见误称 | "1,500+ 题 / 目标 5,000" 是**采集池**（论文说 "covering 1K+ tasks"）；可复现评测集只有 122 | 〔官〕论文 vs README |

## B3. 题源与构造

| 项 | 数字 | 来源 |
| :-- | :-- | :-- |
| 可复现评测集 | **122**（Linux 86 + Windows 36） | 〔官〕 |
| 计算档 | CPU **119** / GPU **3**（3 个 Windows GPU 任务） | 〔官〕 |
| 运行子集 | `ale_cli.txt` **86**（Linux，含桌面工作流）；`docker_support.txt` **78**（本地容器） | 〔官〕 |
| 难度分层 | **45 near-term / 46 full-spectrum / 36 last-exam**（三档重叠） | 〔官〕 |
| 领域 | **55 subdomains / 13 industry clusters**，参照 **O*NET / SOC 2018** 职业分类 | 〔官〕 |
| v1.1 改动量 | **57 题需重跑**（instruction 47 / verification 43 / environment 32 / data 23，可重叠），65 题保留；6 题从商业软件迁到开源（Blender/FreeCAD/LinuxCNC/MuseScore/Ardour/Kratos） | 〔官〕v1.1.md |
| 防污染 | 隐藏 reference **在 agent 跑完之后**才 stage；条款禁止训练/评测中暴露/再分发 | 〔官〕 |
| 版本铁律 | v1 与 v1.1 **日志不可复用**（"Do not reuse v1.1 logs for v1"） | 〔官〕v1.1.md |

## B4. 判分契约

| 项 | 内容 |
| :-- | :-- |
| 单题判分 | 任务内 `main.py` 的 `evaluate()`，对隐藏 reference 打分 **[0,1]** |
| 整轮指标 | **passRate**（该题得 1.0 才算通过）+ **avgScore**（平均部分分） |
| judge | 主体是**确定性 grader**（比文件/截图/数值）；**部分任务含 text/image judge**，可独立配 `JUDGE_BASE_URL / JUDGE_API_KEY / JUDGE_MODEL` |
| 错误处理 | v1.1 明确：评测失败（含 judge 返回非法）记 **`score: null`**，**不替换成 0**、也不让 agent 超时掩盖 → 这点比多数基准严谨 |
| 采样 | **单次运行**（官方榜未公布重复采样；`resume` 靠 `task.revision` 哈希 + 已成功评测的数值才复用） |
| 假阳风险 | 低（reference 隐藏且后置 + 确定性 grader + 统一 trajectory/raw log/artifact 全量留存） |
| 假阴风险 | 中：grader 过严/环境漂移 → v1.1 专门改了 **43 题 verification**，并承认过去有"reference answer 错误、阈值无依据"的情况 |

## B5. 执行协议

| 项 | 内容 |
| :-- | :-- |
| 官方 harness | `ale_run`：`uv run python -m ale_run run my_experiment.yaml [--dry-run]` |
| 宿主 | **仅 Ubuntu 22.04/24.04/26.04 或 Debian 12/13**；Linux + systemd 下需 **root 或免交互 sudo**（`systemd-run`/`systemctl`）；**Windows 本机不能直接跑**（需 WSL2/云 VM） |
| provider | **GCloud（推荐）**、AWS EC2+S3、阿里云 ECS+OSS、**QEMU/KVM**（Linux+KVM）、**本地 Docker**（仅 78 题 Ubuntu 子集）、已有 CUA sandbox；HF Sandbox **已从 v1.1 排除** |
| agent | Claude Code / Codex / Kimi Code / OpenClaw / Pi / Qwen Code / ZCode / **ALE-Claw**（参考实现）；GUI 通过**跨 OS 的 CUA MCP bridge**（screenshot/click/type/scroll）暴露成普通工具 |
| 单题预算 | `wall_time_s: 18000`（**5 小时**）示例；`concurrency` 自定 |
| 版本锁 | `releases/v1.1/assets.json`：数据集 revision、disk SHA256、云镜像 identity、Docker digest、`uv.lock` |
| 数据准备 | Docker 路径须先**申请 data-archive 权限**再 `scripts/fetch_task_data.sh --revision --sha256` |

## B6. 数据可得性与许可

| 资产 | 门禁 | 内容 | 来源 |
| :-- | :-- | :-- | :-- |
| `agents-last-exam/agents-last-exam` | **gated=false**（公开） | **仅 task-card metadata**：`task_cards.parquet`、`eval.yaml`、`release-v1.1.json`；122 行；4.2 MB；lastModified 2026-10-22 | 〔官〕本轮核实 HF API |
| `...-data-archive` | **gated=manual**（人工审批） | 完整 input + software + **evaluator references**；**39,155,440,558 B ≈ 39.2 GB**；条款禁止训练/评测暴露/再分发 | 〔官〕本轮核实 HF API |
| 许可 | 软件 Apache-2.0 / 数据 CC-BY-4.0 | — | 〔官〕 |

→ **只有 metadata 是自由的；能真正判分的资产全部要审批。** 这是"不能低成本自测"的第一道硬门。

## B7. 成本与时长

| 项 | 数字 | basis |
| :-- | :-- | :-- |
| 官方榜总输出 tokens（122 题） | **2.6M–21.5M**（≈21k–176k 输出/题，跨模型） | 〔本〕2026-10-30 拉官方榜 JSON |
| 官方榜总耗时（122 题） | **8.8 万–56.4 万秒 ≈ 24–157 小时** agent 执行时间 | 同上 |
| 单题成本参考 | **$1.33–$15.70 / 题**（frontier agent） | 〔官〕RDI 发布博客 |
| 官方榜金额字段 | `totalCostUsd = null`（**官方不给钱**） | 〔本〕 |
| 本仓库估算 | API **$20–$150** + 云 VM/沙箱 **$50–$300+**（VM 单价未核实 → 只能给量级） | 〔本〕basis: DeepSeek 价 + 机型未定 |
| 全量现实感 | 122 题 × 5 h 上限 × 单跑 = **数十小时 agent 时间**，VM 启动/判分另计；并发 8 也要 8–20 h 墙钟 | 推算 |

## B8. 已知缺陷与争议

1. **35.4 的口径没有任何官方标注**。技术报告（对上一版）在 p.32 明确写 general agent 用 **"Agents' Last Exam (ALE-CLI)"**，而 ALE-CLI 是 122 题中的 **86 题**子集〔本，技报转引〕→ 35.4 最可能是 **ALE-CLI 86 题自报 Pass@1**，既不是 122 题全量，更不是官网"1,500+"。
2. **35.4 不可能是"最硬档"成绩**。论文摘要：最难 tier "**the average full pass rate is below 1%**"〔官〕；而 last-exam 档 = 36 题。若 35.4 只跑最难档不可能成立 → 分母必是混合集，**具体是哪 86/122 题 unknown**。
3. **竞品列自相矛盾（本节最关键发现）**。llm-stats 的 ALE 榜（26 模型、**0 verified / 26 self-reported**、Unverified、2026-11-10）里：

| 模型 | 模型卡〔厂〕 | llm-stats〔三〕 | 差 |
| :-- | --: | --: | --: |
| DeepSeek-V4.1-Flash-1017 | 35.4 | **0.354** | 0.0 ✅ |
| DeepSeek-V4.1-Flash | 31.8 | **0.318** | 0.0 ✅ |
| GLM-5.3 | 28.5 | **0.285** | 0.0 ✅ |
| **GPT-5.6 Sol** | **26.7** | **0.527** | **+26.0 pp ❌** |
| Kimi K3 / K3.1 Pro | 27.6 | 0.432 | 不可比（型号不同名） |
| Opus 5 | 28.6 | 无同名行 | unknown |

→ 三个格子逐位吻合，说明该榜基本是**照抄各厂模型卡**；既然如此，**GPT-5.6 Sol 的 26.7 与厂方自报 52.7 差 26 pp** 就无法解释。**"DeepSeek 在 ALE 表内第一（35.4 vs 竞品 26.7–28.6）"这个说法不成立**：若按 llm-stats 口径，DeepSeek 排第 15/26，前 8 名都在 50% 以上，GPT-6.1 Terra 60.0。
4. **官方榜今日不可复核**：`agenthle.org/leaderboard` 与 `/api/demo/leaderboard/v1.1` **unreachable**（网关拦截）。据本仓库 2026-10-30 抓取：**22 行 / 12 个模型、最高 pass 45.9%、无 DeepSeek 行**〔本〕。今日值 unknown。
5. **版本漂移极重**：v1→v1.1 退役 30 题、改 57 题、6 题换软件、30 题里含"反馈验证过于绑定固定措辞"这类判分缺陷修复〔官〕→ **跨版本（乃至 v1/v1.1）分数一律不可比**。
6. **真机方差**：单题单跑 + pass 阈值 = 恰好 1.0（[0,1] 分制），122 题下"1 题翻面 ≈ 0.8 pp"；GUI 操作（点击坐标、Unicode 剪贴板、渲染重试）在 v1.1 里仍要专门修（"acknowledge Unicode clipboard transfers on Linux"）〔官〕→ 环境漂移是持续成本，不是一次性问题。

## B9. 分数怎么读

| 口径 | 数据 | 规模 | 最高 | DeepSeek |
| :-- | :-- | :-- | :-- | :-- |
| 〔官〕官方 v1.1 榜 | 122 题，需审批数据，harness 受控 | 22 行 / 12 模型（2026-10-30） | **pass 45.9%** | **无行** |
| 〔三〕llm-stats 汇总（自报、Unverified） | 混合口径（各厂自报） | 26 模型 | **60.0%**（GPT-6.1 Terra） | 35.4（第 15） |
| 〔厂〕模型卡 | 未标注（推断 ALE-CLI 86 题 Pass@1） | 6 | 35.4（DeepSeek） | 35.4 |

**读法**：模型卡的 ALE 行只能引"DeepSeek 从 31.8 提升到 35.4（+3.6）"这一**代际提升**，不能引"领先竞品"或"表内第一"；不能与官方榜 45.9% 之类数字并列；报区间只能报"自报汇总 26.7–35.4 / 官方榜最高 45.9% / 各厂自报最高 60.0%"三段，且每段标口径。

## B10. 可信度评级 + 自测建议

- **机制与数据（v1.1 122 题）：中-高**〔隐藏 reference 后置、确定性 grader、全量 trajectory 可审计、版本 manifest 齐全、评测失败记 null 而非 0〕。
- **35.4 这个数字：低**〔无官方榜行、无指标标注、分母不明（86？122？）、竞品列与第三方汇总差 26 pp〕。
- **综合评级：低-中**，与本仓库 `benchmark-suite-analysis.md` 的分级一致，但**理由要换成更强的两条**（竞品列自相矛盾 + 论文 <1% 与 35.4 的分母矛盾）。

**为什么不建议自跑（四条硬门槛，任一都足以劝退）**

1. **数据门**：能判分的资产 = 39.2 GB、gated=manual 人工审批，且条款禁止在评测中暴露给模型——公司内网走审批 + 合规说明的成本 > 收益。
2. **宿主门**：仅 Ubuntu/Debian；Linux systemd 下要 root 或免交互 sudo；Windows 本机需 WSL2/云 VM。**我们主力机是 Windows**。
3. **镜像门**：Windows/Linux 真机镜像（QEMU 磁盘 / GCloud image / Docker digest）+ 3 个 Windows GPU 任务，等于自建一套 VDI 农场。
4. **方差门**：单题 5 h 上限、单跑、pass=1.0 严格阈值 → 想得到能对外说"±x pp"的结论，至少要 3 次重复 × 122 题 ≈ 三次数十小时，成本不可控。

**若必须试水（唯一推荐做法）**：先 `git clone` + `env/install_host_deps.sh` + `uv sync --all-packages --locked` + `verify_host_env.sh`，只在 **Linux 云机**上跑 `selected_tasks/hello_both.txt`（示例题）与 `docker_support.txt` 的 **5 题**，全程 `--dry-run` 先验；预算按 **$1.33–$15.70/题 + VM 小时费** 取上界。目标只写一句：**"harness 通了、判分出了"**，不出能力分数。

# C. 两项合并结论与引用建议

| 维度 | AutomationBench (Public) | Agents' Last Exam v1.1 |
| :-- | :-- | :-- |
| 能力坐标 | 业务流 / REST API 编排 / 端点发现 | 长程真机 / CLI+GUI / 专业软件 |
| 判分 | 程序化 end-state 断言，**无 judge**，strict | 隐藏 reference + `evaluate()`，**部分含 judge** |
| 公开可跑 | **600 全公开**（MIT，无 Docker） | 仅 122 条 metadata；**判分资产 39.2 GB gated** |
| 本地集 vs 榜集 | 600 公开 ↔ **657 私有** | 122 公开 ↔ 榜（需审批 + 受控 harness） |
| 单题上限 | 50 步（分钟级） | **5 小时** |
| 自测成本 | **$20–60 / 600 题** | **$100–1,000+**（VM 另计） |
| 可信度 | 机制**高** / 数字（60.5）**中** | 机制**中-高** / 数字（35.4）**低** |
| 自测建议 | **便宜，先跑 20 → 50 → 600** | **只引用，不自跑** |

**两句可抄的引用句式**

- AutomationBench：*"DS-V4.1-Flash-1017 在 AutomationBench **公开 600 题**（v1.0.6，`--toolset api`）上 60.5%（厂商自报），该口径与 zapier.com/benchmarks 的 **657 题私有 held-out** 榜（榜首 53.88%）**不可 1:1 对齐**。"*
- ALE：*"DS-V4.1-Flash-1017 在 Agents' Last Exam 上 35.4%（厂商自报，推断为 **ALE-CLI 86 题**子集 Pass@1），该数字**未出现在** 官方 v1.1 榜（2026-10-30 抓取：12 模型、最高 45.9%、无 DeepSeek 行），且模型卡的竞品列与实际自报数据存在 26 pp 级矛盾。"*

**本次无法核实、留 TODO 的点**：① 三种 `--toolset` 的精确工具面（本地无源码）；② 公开 600 题是否存在空断言题（需跑零基线）；③ 官方榜 134 行里是否有 DeepSeek 行（页面只渲染前 10）；④ ALE 官方榜今日数值（域名被网关拦截）；⑤ 模型卡 60.5 / 35.4 的 harness 配置（模型卡与技报均未逐项标注 1017 的设置）。

## 来源

- AutomationBench 仓库（README / pyproject / CLI 参数）：<https://raw.githubusercontent.com/zapier/AutomationBench/main/README.md>、<https://raw.githubusercontent.com/zapier/AutomationBench/main/pyproject.toml>
- AutomationBench 官方榜（1.0.6、134 行、cost/task、657 held-out、API 模式双工具、负断言防 hacking）：<https://zapier.com/benchmarks>
- 论文：<https://arxiv.org/abs/2604.18934>
- 第三方独立复现（private 657 题、guardrail 归零的 objective 口径）：<https://artificialanalysis.ai/evaluations/automationbench-aa>
- 第三方自报汇总（0 verified / 7 self-reported）：<https://llm-stats.com/benchmarks/automationbench-1.0.6>
- ALE 仓库（122 题、task lists、provider、host 要求）：<https://raw.githubusercontent.com/rdi-berkeley/agents-last-exam/main/README.md>
- ALE v1.1 运行指南（退役 30 题 / 改 57 题 / 版本锁 / judge 配置 / score:null）：<https://raw.githubusercontent.com/rdi-berkeley/agents-last-exam/main/docs/releases/v1.1.md>
- ALE 论文：<https://arxiv.org/abs/2606.05405>
- ALE 数据门禁（公开 metadata / gated 39.2 GB archive）：<https://huggingface.co/api/datasets/agents-last-exam/agents-last-exam>、<https://huggingface.co/api/datasets/agents-last-exam/agents-last-exam-data-archive>
- ALE 自报汇总（26 模型、0 verified）：<https://llm-stats.com/benchmarks/agents-last-exam>
- **unreachable**：<https://agents-last-exam.org>、<https://agenthle.org/leaderboard>、<https://agenthle.org/api/demo/leaderboard/v1.1>
- 本仓库证据：`report/model-eval/05-automation-bench.md`、`report/stage2-automation-validation.md`、`report/ark-simple5-comparison.md`、`report/benchmark-suite-analysis.md`、`report/all_benchmarks.json`、`research/reasoning-agent/notes.md`、`offline/run_stage1.sh`
