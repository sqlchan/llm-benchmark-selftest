# 推理 / Agent 类 4 个基准自测调研（2026-10-30）

调研方式：逐个打开官方主页 / 论文 / GitHub / Hugging Face / 榜单页核实；打不开的页面用 `pwsh Invoke-WebRequest` 重试，仍打不开的标 unknown。所有数字均来自下方来源；估算值单独标注"粗估/假设"，不是官方统计。

## 一句话结论

| 基准 | 数据能拿到吗 | 自测可行性 | 主要成本 | 模型卡口径 |
|---|---|---|---|---|
| HLE | 能，HF `cais/hle`，gated 但公开，MIT | easy（纯文本 API 即可） | API 粗估 $25–$80 / 全量 | 42.6 = 2,500 题全量；44.0† = 2,158 题纯文本子集，均 w/o tools |
| AutomationBench v1.0.6 | 能，GitHub 公开 600 题，MIT | easy（本地模拟环境 + API） | API 粗估 $20–$100 / 600 题 | 60.5；与公开集数字吻合，官方榜则跑私有 held-out 集 |
| Agents' Last Exam v1.1 | 部分：122 题代码/metadata 公开；完整数据+reference 需人工审批（约 39 GB） | hard（要 Linux 真机/云 VM，单题可跑 5h） | API $20–$150 + VM $50–$300+ 量级 | 35.4；官方 v1.1 榜上无 DeepSeek 行，口径未注明 |
| Apex Bench v1.1 | 不能：未找到任何公开数据/主页/论文 | infeasible | 无法估算 | 72.1；只有厂商自报 |

---

## 1. HLE（Humanity's Last Exam）——最值得先跑，但必须说清"44.0 是哪个子集"

**口径核实（重点）**：官方 2025-04-03 定稿 2,500 题，其中 342 题带图（约 14%），纯文本子集是 **2,158 题**（Inspect AI 的 HLE 评测页明确写了 342/2,500 与 2,158，且说这与 CAIS 榜单的 "Text-Only" 口径一致）。DeepSeek 模型卡的 `42.6 (44.0†)` 里，† 脚注是 "text-only subset"，所以 **44.0 是 2,158 题纯文本子集、42.6 是 2,500 题全量**，两者都注明 w/o tools（不给搜索/工具）。官方确实另留了 **private held-out 集**（论文原话："maintaining a private test set of held out questions to assess model overfitting"，后续又形成第二个 held-out 私有集），所以公开数据只能复现公开集数字，不能验证官方榜的泛化口径。

**数据与判分**：数据集在 HF `cais/hle`（gated=auto，需要登录并同意条款；license=MIT，2,500 条 test split）。官方仓库 `centerforaisafety/hle` 自带 `hle_eval`：先 `run_model_predictions.py` 采样，再 `run_judge_results.py` 用 LLM judge（默认 `o3-mini-2025-01-31`）抽取最终答案判对错，指标是 Accuracy（另报 calibration error）。替代 harness 有 Inspect AI 的 `hle` 任务（可用 `-T include_multi_modal=false` 得到 2,158 题文本子集）。

**适不适合自测**：非常适合。纯文本子集用 OpenAI 兼容 API 就能跑，50 题冒烟几十分钟内出结果；官方脚本用 openai-python，`OPENAI_BASE_URL` 可指向自建/第三方端点。坑：① 数据集 gated，未登录会 401；② judge 版本/提示词会影响分数，自测不要和官方榜硬比；③ `max_completion_tokens` 不要低于 8192（官方 README 说会 model collapse）；④ 训练污染风险（题目带 canary 串）；⑤ HLE-Verified 审计指出部分标准答案有误（668 题 gold 子集可用）。成本：按 2,158 题、假设 2k 输入 + 15–30k 输出 tokens/题、DeepSeek 非高峰价（in $0.15/M、out $0.6/M）粗估 **$25–$80**，judge 另计；并发 20–50 时墙钟约 2–8 小时。

---

## 2. AutomationBench v1.0.6——600 题公开可跑，官方榜另有私有集

**口径核实**：Zapier 官方仓库 `pyproject.toml` 当前版本号就是 `1.0.6`（Python >=3.13），README 明确：公开集 **600 题**（6 个业务域各 100）+ `simple` 域 200 题（不计分，仅冒烟）；官方 zapier.com/benchmarks 榜单则跑**每个域单独的、未公开的 held-out 私有集**（官网写 "600+ held-out evaluation tasks"），所以本地分数只能"方向性"对齐官方榜，不能 1:1 复现。模型卡 60.5 与 README 公开集表里 Opus 5 50.3、Kimi K3 46.67、GPT-5.6 Sol 45.83 的数字吻合，**推测模型卡用的是公开 600 题自跑口径**，而官方榜是私有集——这是最容易踩的坑。

**数据与判分**：GitHub MIT 许可，仓库自带 47 个模拟 SaaS 工具/约 500 个端点的环境，agent 通过 REST API 操作；判分是纯程序化 end-state 断言（unit-tests），无 LLM judge；官方指标 `task_completed_correctly`（所有断言都过才 1），另有 `partial_credit` 诊断分。跑法很简单：`uv sync` → `uv run auto-bench --model <model> --num-examples 5 --domains sales` 冒烟；也可用 Prime Intellect 托管环境。模型接口是 OpenAI 兼容（`--base-url`），不需要 Docker/GPU/代码执行。

**适不适合自测**：适合，CPU + API 就行，5 题冒烟几分钟。坑：① 必须 Python 3.13+ 和 uv；② 公开集 vs 私有集口径差异；③ `--toolset`（api/zapier/limited_zapier）和 reasoning effort 会明显改分，配置要固定；④ 默认单题 50 步上限可能截断长流程；⑤ 第三方 llm-stats 的 v1.0.6 榜是 0–1 分且只有 6 个模型、没有 DeepSeek，别和模型卡 60.5 混比。成本：无官方 token 统计，按 600 题 × 假设 30 步 × 10–20k 输入 tokens/步 粗估 **$20–$100**（DeepSeek 非高峰价），CLI 自带费用统计，可先跑 20–50 题外推。

---

## 3. Agents' Last Exam（ALE v1.1）——公开的是 122 题，完整数据要审批

**口径核实**：官网宣传 "55 个细分行业、已收集 1,500+ 题、目标 5,000"，论文也写 1K+ tasks，但 **v1.1 可复现的公开基准是 122 个 active tasks**（Linux 86 + Windows 36；CPU 119、GPU 3；Docker 子集 78、ALE-CLI 子集 86）。公开的 HF 数据集 `agents-last-exam/agents-last-exam` 只有 task-card metadata（122 行）；**完整输入+隐藏 reference 在 `agents-last-exam-data-archive`，gated=manual，需要填表人工审批**，archive 约 39.2 GB（39,155,440,558 bytes），条款禁止用于训练、禁止在评测中暴露给模型、禁止再分发。官方 v1.1 leaderboard（API 拉取，2026-10-30）有 22 行/12 个模型，最高 pass 45.9%，**没有 DeepSeek 行**——所以模型卡 35.4 是自跑/未上榜数字，口径未注明。

**数据与判分**：代码 Apache-2.0、数据 CC-BY-4.0；评分是每个 task 的 `evaluate()` 对隐藏 reference 做确定性判分，给 [0,1] 分；官方同时报 passRate（满分 1.0 才算过）和 avgScore。运行需要真实 VM/沙箱：GCloud（推荐）、QEMU/KVM、Docker（仅 78 题 Ubuntu 子集）或已有 CUA 沙箱；单题 agent 预算示例 `wall_time_s: 18000`（5 小时），全量 122 题的官方 totalDurationS 汇总约 24–157 小时（跨模型），totalOutputTokens 2.6M–21.5M。

**适不适合自测**：对"个人 1–2 张卡 + API 预算"来说偏 hard：宿主机安装脚本只支持 Ubuntu/Debian（Windows 本机要 WSL2 或云 VM），完整数据要审批，3 个 GPU 任务要 Windows GPU 镜像，时间和云成本都高。建议要么只跑 Docker 子集的 5–10 题看 harness 是否通，要么直接放弃全量。API 成本按输出 tokens × DeepSeek 价粗估 **$20–$150**，VM 另计 **$50–$300+** 量级（未核实具体机型单价）。官方博客给过 frontier agent 每题 $1.33–$15.70 的参考值，可用来做预算上界。

---

## 4. Apex Bench v1.1——只找到厂商自报，无法自测

**核实结果**：截至 2026-10-30，唯一官方出处是 DeepSeek-V4.1-Flash-1017 模型卡对比表里的 `Apex Bench v1.1 = 72.1`。检索未找到官方主页、论文、GitHub 仓库、HF 数据集或官方榜单；模型卡也没有脚注说明题量、判分方式或 harness。第三方页面 phaseo 只转引模型卡，并注明 "distinct from MathArena Apex and APEX-Agents"；open-llm-radar 把它归类为 "Multimodal Agents"，且上面只有 3 个 DeepSeek 系模型（72.1 / 36.5 / 26.2），进一步说明它更像厂商内部基准而非公开基准。注意：不要与 MathArena Apex、Mercor APEX / APEX-Agents、llm-stats 的 "Apex"（一个 reasoning 榜）混淆，它们是不同东西。

**适不适合自测**：不可行（infeasible），没有数据、代码、题量、许可和判分规则。正式对比中应把这一项标成 unknown/自报，不能当作可复现的公开基准；若之后官方发布，需要重新核实数据与 harness。

---

## 建议的行动顺序（若目标是"自己测 DeepSeek-V4.1-Flash-1017"）

1. **HLE 纯文本子集 50 题冒烟** → 跑通后 2,158 题全量，成本最低、结论最可解释（但注意 44.0† 的口径）。
2. **AutomationBench 5 题冒烟 → 单域 100 题 → 600 题**，用 harness 自带 token/成本统计校准预算。
3. **ALE 只做 Docker 子集 5–10 题试水**（先申请 data-archive 权限），不要直接上全量；Windows 本机需 WSL2/云 VM。
4. **Apex Bench v1.1 跳过**，标注"厂商自报、无公开数据"。

所有 `usd_per_full_run` 都是按 DeepSeek 官方价（2026-10-30：deepseek-flash 非高峰 cache miss $0.15/M 输入、$0.6/M 输出，高峰翻倍；缓存命中输入 $0.003/M）做的粗估，token/题、步数均为假设，需要用 harness 实测校准；ALE 的 VM 成本未核实单价，只能给量级。
