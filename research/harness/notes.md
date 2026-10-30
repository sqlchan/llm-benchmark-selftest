# 自测 harness / 评测工具链调研笔记

> 调研日期：2026-10-30 ｜ 对应任务：task-4 ｜ 交付物：`research/harness/harnesses.json` + 本文件
> 范围：把模型卡上的 11 个基准（HLE、Terminal-Bench 4.0、DeepSWE v1.1、ProgramBench、NL2Repo-Bench、Automation-Bench v1.0.6、Agents' Last Exam、Apex Bench v1.1、Chartography、BabyVision、ZeroBench-main）落到「自己能跑」的命令级路径。

---

## 0. 一页结论

**覆盖矩阵（11 个基准 → 可核实能跑的入口）**

| 基准 | 官方 harness（核实） | 可替代框架 | 自测难度 |
|---|---|---|---|
| HLE | [cais/hle `hle_eval`](https://github.com/centerforaisafety/hle) | inspect_evals `hle`、EvalScope `hle`、VLMEvalKit `HLEDataset` | 易（无 Docker，需 judge） |
| Terminal-Bench 4.0 | Harbor `-a claude-code -d terminal-bench/terminal-bench@4.0.0` | EvalScope `terminal_bench_v4`（底层就是 Harbor） | 中（Docker 必需，66 题，3 题需 H100） |
| DeepSWE v1.1 | Pier `--agent mini-swe-agent` | EvalScope `deep_swe`（底层就是 Pier） | 中（Docker，113 题） |
| ProgramBench | `programbench eval` + `mini-extra programbench` | 无 | 难（200 题，amd64-only Docker，6h/题） |
| NL2Repo-Bench | 官方 runner（OpenHands headless batch，104 题） | 无 | 难（Docker + OpenHands 镜像） |
| Automation-Bench v1.0.6 | `uv run auto-bench`（zapier/AutomationBench） | EvalScope `automation_bench` | 易（纯 API，公开 600+200） |
| Agents' Last Exam | `ale_run`（rdi-berkeley/agents-last-exam） | 无 | 很难（真机 VM/GUI，Linux host，122 题） |
| Apex Bench v1.1 | **未找到公开 runner**（TODO verify） | 无 | 目前不可自测 |
| Chartography | surge-ai/chartography（Inspect AI 写法） | 无 | 易-中（100 题，judge，HF 可能需申请） |
| BabyVision | 官方 `babyvision_eval`（UniPat-AI/BabyVision） | EvalScope `baby_vision`、VLMEvalKit `BabyVision` | 易-中（388 样例，judge） |
| ZeroBench-main | 官方 repo 脚本（pass@1 片段/官方评测） | inspect_evals `zerobench`、EvalScope `zerobench`、VLMEvalKit `ZEROBench` | 易（100 题 ×5 采样） |

**三条最重要的结论**

1. **不要幻想用一个框架跑完 11 个。** 现实分工是：Harbor 负责 Terminal-Bench 4.0（官方就是它，Claude Code 只是 Harbor 里的一个 agent）；Pier 负责 DeepSWE v1.1；ProgramBench / NL2Repo-Bench / ALE / Chartography 各有自己的 runner；HLE / ZeroBench / BabyVision 则有多家通用框架支持。
2. **最适合「一个人起步」的是 EvalScope**：一份 `pip install evalscope` 就能覆盖 6/11（HLE、TB4、DeepSWE v1.1、Automation-Bench、BabyVision、ZeroBench），且模型侧只认 OpenAI 兼容 `--api-url`，接 DeepSeek/自建端点最省事；第二选择是 **Inspect AI + inspect_evals**（HLE、ZeroBench，且 Chartography 官方代码本身就是 Inspect 写法）和 **VLMEvalKit**（BabyVision、ZEROBench）。
3. **本机跑不了 DeepSeek-V4.1-Flash-1017 本体。** HF safetensors 元数据显示总参数约 **763B**（I8 557B + FP8 204B + BF16 2B），权重就是 ~0.76 TB 量级；官方 `inference/README.md` 的参考实现固定用 **8 路张量并行（MP=8，每个 rank 一份转换后的 checkpoint）**。本机是 Windows + Python 3.11、无 GPU 说明，所以「0 元本地」只能理解为**用 Ollama 小模型把管道跑通**，真正的模型分数只能走 API。

---

## 1. 每个框架一段（都已打开官方页面核实，命令来自官方文档）

### 1.1 Harbor（Terminal-Bench 4.0 的官方 harness）
`laude-institute`/`harbor-framework` 出品，Terminal-Bench 创建者的通用 agent 评测框架，PyPI 包 `harbor`（当前 **0.25.0**，要求 **Python>=3.12**）。装法 `uv tool install harbor` 或 `pip install harbor`。它把「任务集（Harbor 格式：instruction + 环境 + verifier）」和「agent」解耦：`-d` 选数据集、`-a` 选 agent（内置 40+：`claude-code`、`mini-swe-agent`、`codex`、`terminus-2`、`openhands`……）、`-m` 选模型（LiteLLM slug，如 `anthropic/claude-opus-5`）。默认用本机 Docker 跑沙箱，`--env modal/daytona` 上云并行。它有三套端点路由机制，`--base-url` / `--api-key-name` / `--api-format` 是接自建模型的关键；不确定时先加 `--dry-run` 看它解析出的 provider、endpoint、API 格式与凭证来源。Terminal-Bench 4.0 的官方命令是 `harbor run -d terminal-bench/terminal-bench@4.0.0`（数据集 v4.0.0，2026-08-26 发布），模型卡所说的「Claude Code harness」= `-a claude-code`。Harbor 还可以 `--repo`/`--path` 直接吃任意 Harbor 格式任务目录（DeepSWE 的任务就是 Harbor 格式），但 DeepSWE 官方用 Pier。

### 1.2 terminal-bench 任务集仓库（+ 旧版 `tb` CLI）
`harbor-framework/terminal-bench` 是任务集本体（每条任务含英文 instruction、测试脚本、oracle 解），旧版 `pip install terminal-bench` 提供 `tb run ...` CLI。README 已经明确「新用户请改用 harbor」，所以 **2026 年做 TB4 不要用 `tb`**，直接用 Harbor。GitHub releases 核实到 `v4.0.0`（2026-08-26，assets 有 `prebuilt-images.json` 与 450MB 的 `terminal-bench-prebuilt-v4.0.0.tar.gz`），v3.0.0 是 74 题的首发版；EvalScope 文档记录 **TB 4.0 = 66 个任务（11 个多容器任务、3 个需 H100、agent 超时 8h/任务）**。旧 `tb` 对 v4.0 数据集的兼容性没核实 → 不要用。

### 1.3 Pier（DeepSWE v1.1 的官方 runner）
Datacurve 把 Harbor fork 成 Pier（PyPI `datacurve-pier`，**0.3.1**，要求 **Python>=3.12**），专门解决「agent 装进 air-gapped 任务」的问题：Harbor 对 `allow_internet=false` 的任务会拦掉一切出网请求（包括装 agent 和调模型），Pier 允许给每个 agent 配安装脚本和网络 allowlist，Docker 与 Modal 两种环境都支持。DeepSWE 官方 README 给的路径是 `git clone datacurve-ai/deep-swe` → `uv tool install datacurve-pier` → `pier run -p deep-swe/tasks --agent mini-swe-agent --model anthropic/claude-opus-4-8`；小样本用 `--n-tasks 10 --sample-seed 0`（确定性抽样），单题用 `-p deep-swe/tasks/<task-id>`。v1.1 起评分改成「agent 提交 commit → sidecar collect hook 抽 patch → 在干净容器里 apply 并跑测试」，因此要求 `datacurve-pier>0.3.0`。注意 Pier 不直接解析 Harbor registry 数据集，要先用 Harbor `harbor download` 拉下来再 `-p` 指本地目录。

### 1.4 mini-swe-agent v2（模型卡的「Mini-SWE-V2 / mini-swe-v2」）
Princeton/Stanford SWE-bench 团队维护的 ~100 行极简 coding agent（PyPI `mini-swe-agent`，当前 **2.4.6**，Python>=3.10）：只有一个 bash 工具、线性 history、每步 `subprocess.run`，所以**不依赖模型原生 tool-calling**，任何能跑 chat/response 的模型都能上。DeepSWE 官方博客说明「所有模型固定用 mini-swe-agent 跑，以排除 scaffold 差异」，DeepSeek 官方新闻写的是「mini-swe-v2 harness」——**是否就等于 mini-swe-agent v2.4.6、用了什么 config，尚未核实，标 TODO verify**。它同时是 ProgramBench 的官方 baseline：`mini-extra programbench --model ... --workers N --slice 0:5`。CLI 还有 `mini`（单次）和 `mini-extra swebench`（批量）。模型走 LiteLLM，所以 `--model deepseek/deepseek-flash` + `DEEPSEEK_API_KEY` 这类写法在原理上成立（Pier 上的模型 slug 未逐一实测 → TODO verify）。

### 1.5 Claude Code（Anthropic 官方 CLI agent）
`npm install -g @anthropic-ai/claude-code`（Node 18+，Windows 还要 Git for Windows）。协议上**只支持 Anthropic Messages**，接第三方/自建模型靠环境变量：`ANTHROPIC_BASE_URL`、`ANTHROPIC_AUTH_TOKEN`、`ANTHROPIC_MODEL`、`ANTHROPIC_DEFAULT_{OPUS,SONNET,HAIKU}_MODEL`、`CLAUDE_CODE_EFFORT_LEVEL`、`CLAUDE_CODE_AUTO_COMPACT_WINDOW`。DeepSeek 官方有专门的 Claude Code 集成文档，把 base_url 指到 `https://api.deepseek.com/anthropic`、模型写 `deepseek-flash[1m]` 即可（DeepSeek 侧把 `claude-sonnet*/haiku*` 映射到 `deepseek-flash`、`claude-opus*` 映射到 `deepseek-v4-pro` 并按 pro 计费）。vLLM 也实现了 Anthropic Messages，因此本地部署的模型同样能喂给 Claude Code（需开启 tool calling）。它是 **Terminal-Bench 4.0 官方 harness**，也是 ALE 支持的 agent 之一；但它是通用编码 agent，**不要用它跑纯视觉问答基准**。

### 1.6 EvalScope（ModelScope）
`pip install evalscope`（**1.14.1**，Python>=3.10），一条 `evalscope eval --model X --api-url <OpenAI 兼容> --api-key <k> --datasets <名> --limit N` 就能跑。它覆盖本次 11 个里的 6 个：`hle`、`terminal_bench_v4`（要求 Python>=3.12 + `evalscope[terminal_bench]`、Harbor>=0.14,<1.0）、`deep_swe`（`evalscope[deep_swe]`，底层 Pier）、`automation_bench`、`baby_vision`、`zerobench`。judge 用 `--judge '{"strategy":"llm","models":[{"model_id":"..."}]}'` 配；HLE 跑纯文本要设 `include_multi_modal=false`；TB4 用 `extra_params.agent_name` 选 Harbor agent（`terminus-2` 用 EvalScope 模型，`claude-code`/`codex` 作为外部 CLI 要自带 key），`task_names` 可以选子集但分数不能与完整 4.0 直接比；DeepSWE 对不支持 Responses API 的 OpenAI 兼容商要传 `pier_agent_kwargs={'model_class':'litellm'}`。

### 1.7 Inspect AI（UK AISI）+ inspect_evals
`pip install inspect-ai`（**0.3.286**，Python>=3.11）+ `pip install inspect-evals`（**0.27.0**）。CLI 是 `inspect eval <task> --model <provider/model>`，provider 覆盖 OpenAI/Anthropic/Google/DeepSeek/vLLM/Ollama/SGLang 等；第三方 OpenAI 兼容端点用 `openai-api/<provider>/<model>`，它按 `<PROVIDER>_API_KEY` / `<PROVIDER>_BASE_URL` 约定读环境变量（例如 `DEEPSEEK_API_KEY` + `DEEPSEEK_BASE_URL`）。`inspect_evals` 里有 **hle** 和 **zerobench**：zerobench 从 HF `jonathan-roberts1/zerobench` 读主集 100 题 / 子题 334 题，默认 `k=5` epochs，一次产出 pass@1、pass@5、5-of-5 reliability（数据 revision 固定为 `13c35e5…`）。**Chartography 的官方评测代码就是用 Inspect 写的**（见 1.11），所以 Inspect 是第二重要的通用框架。HLE 的默认配置与 CAIS 榜单不完全可比，要按需 pin `include_multi_modal` / `answer_type` / `only_hle_verified_gold` / `rolling` / judge。

### 1.8 VLMEvalKit（OpenCompass）
`git clone https://github.com/open-compass/VLMEvalKit && cd VLMEvalKit && pip install -e .`，用 `python run.py --data <DATASET> --model <MODEL_NAME>` 跑，模型要在 `vlmeval/config.py` 的 `supported_VLM` 里注册，key 放 `.env`，judge/选项抽取默认走 LLM。我在 `vlmeval/dataset/__init__.py` 的 `IMAGE_DATASET` 列表里**确认了 `BabyVision` 与 `ZEROBench` 两个数据集类**（另有 `HLEDataset`，属多模态 HLE 口径）；**Chartography 不在支持列表**（只有 ChartQAPro/CharXiv 等）。它支持 thinking 切分（`SPLIT_THINK=True`）和长输出 TSV（`PRED_FORMAT=tsv`）。具体 dataset 名字符串以 `run.py --help` / `supported_datasets()` 为准（文档没逐一列出 → TODO verify）。

### 1.9 lm-evaluation-harness（EleutherAI）
`pip install lm_eval`，`lm_eval --model ... --tasks ...`，OpenAI 兼容端点用 `local-completions`/`local-chat-completions` + `base_url`。**核实结论：它不支持这 11 个基准中的任何一个**——官方任务表里没有 HLE/ZeroBench/ProgramBench 等；多模态只有一个 `mmmu` 原型，README 自己建议改用 `lmms-eval`。所以对本次自测**不适用**，只在补传统文本能力横评时用。

### 1.10 OpenAI simple-evals
`simple_evals` 在 README 里已声明 2025-07 起停止为新模型/基准更新，只保留 HealthBench / BrowseComp / SimpleQA 的参考实现，sampler 只有 OpenAI 与 Anthropic。**不含 11 个基准任何一个 → 不用于自测**。留着它只是因为任务要求核实。

### 1.11 各基准自带 runner（核实要点）
- **HLE**：`centerforaisafety/hle`，`hle_eval/run_model_predictions.py` 生成预测 → `run_judge_results.py` 用 LLM judge（结构化输出）打分；2500 题、14% 含图、24% 单选 / 76% 简答，官方默认 `temperature=0`，不建议 `max_completion_tokens<8192`，`--max_samples` 可小样本。
- **ProgramBench**：`facebookresearch/programbench`，`pip install programbench`；推理用 `mini-extra programbench`（产物 `submission.tar.gz`），评测 `uv run programbench eval <run_dir>`，`programbench blob sync` 可预下载测试 blob。**200 个实例、6 种语言，镜像只支持 linux/amd64，推理容器 `--network none`，单题 6h / 1000 步 / 20CPU/60GB。**
- **NL2Repo-Bench**：`multimodal-art-projection/NL2RepoBench`，**104 题**，官方 runner 跑 **OpenHands headless 批量**（需 `openhands:0.56` 与 `runtime:0.56-nikolaik` 镜像，`config.toml` 配模型、`config.json` 配 baseUrl/sk/任务列表，python-on-whales 管容器，只支持本地执行）。
- **Automation-Bench v1.0.6**：`zapier/AutomationBench`，`uv sync` 后 `uv run auto-bench --model ...`（支持 `--base-url/--api-key/--domains/--toolset/--max-steps/--reasoning-effort/--responses-api`）；公开 600 题 + `simple` 200 题基线（不计分），**官方榜单是私有 held-out 集，本地分数只能方向性参考**；也可 `prime env install zapier/AutomationBench && prime eval run ...`。
- **Agents' Last Exam**：`rdi-berkeley/agents-last-exam`，`ale_run` 框架；v1.1 有 **122 个活跃任务**（55 subdomain / 13 行业簇，3 个 GPU 任务），宿主安装脚本只支持 Ubuntu/Debian，环境 provider 有 GCP/AWS/阿里云/QEMU-KVM/本地 Docker 子集，agent（claude-code、codex、ALE-Claw…）通过 CUA MCP bridge 操作真机 GUI。**个人自测门槛最高。**
- **Chartography**：`surge-ai/chartography`，**100 题**，评测代码基于 Inspect AI：`uv run inspect eval src/chartography/task.py --model ...`，`-T judge_model=...`、`-T hf_repo=surgeai/chartography` 跑全量；榜单口径是 10 epochs + `gemini-3.5-flash` judge，`--epochs-reducer "mean,pass_at_10,at_least_10"`；`task_packs/sample_charts` + `mockllm` 可离线 dry run。HF 数据集匿名 raw 请求返回 401（可能需登录/申请 → TODO verify）。
- **BabyVision**：`UniPat-AI/BabyVision`，两条 track（MLLM 主评测 / 图像生成评测），MLLM track 走 `babyvision_eval/`：`MODEL_BASE_URL`/`MODEL_API_KEY`/`MODEL_NAME` + `JUDGE_*` 环境变量 → `bash run_inference.sh` → `python compute_score.py results/*.json`；答案格式 `\boxed{}`，LLM judge 判分。EvalScope 记 388 个测试样例、4 大类 22 子类。
- **ZeroBench-main**：`jonathan-roberts1/zerobench`，主集 **100 题**（子题 334），指标 pass@1 / **pass@5** / pass^5（官方 = 每题 5 次采样）；README 给了 pass@1 的参考代码（`{final answer}` 抽取 + 字符串精确匹配），官方榜单还公布 cost/question（$0.30–$1.01）。**inspect_evals / EvalScope / VLMEvalKit 三个框架都实现了它，且 ZeroBench 官网直接链到 inspect_evals 的实现。**

---

## 2. 自建 / 第三方模型接入的常见坑

1. **协议不对，全部白干。** Claude Code 只吃 **Anthropic Messages**；mini-swe-agent / Pier / Harbor 的多数 agent 吃 **OpenAI Chat Completions**（部分支持 Responses）；Harbor 的 `--api-format` 只能选 agent 支持的格式。好消息：DeepSeek 官方同时提供 `https://api.deepseek.com`（OpenAI）和 `https://api.deepseek.com/anthropic`（Anthropic）；vLLM 也实现了 `/v1/messages`，本地模型可以喂给 Claude Code。
2. **tool calling 要显式开。** vLLM 必须 `--enable-auto-tool-choice --tool-call-parser <parser>`，parser 与模型 chat template 必须匹配，否则 Claude Code / OpenHands 会「能聊天但不会动手」。Inspect 走 `openai-api` 时默认给工具 schema 加 `strict: true`，有的兼容端点会拒 → `-M strict_tools=false`。
3. **thinking 模式会改变采样行为。** DeepSeek 的 `temperature` 在 thinking 模式固定 1.0（Anthropic 协议下 `budget_tokens` 被忽略）；DeepSeek 官方文档明确：多轮 tool call 时必须把 assistant 的完整 content（含 thinking / tool_use block）回传，否则可能 400；`claude*` 名字会被映射到 DeepSeek 模型，别以为是真 Claude。
4. **图像输入有三档限制。** DeepSeek API：`deepseek-flash` 支持 user 消息和 tool_result 里的图，assistant 消息里的图 400；`deepseek-v4-pro` 不处理图像（替换成 `[Unsupported Image]`）。HLE 有 14% 多模态题；BabyVision / ZeroBench 全部依赖图像 → 用 v4-pro 或纯文本模型跑这三个基准等于自废武功。
5. **每套 harness 的默认采样参数不同。** 模型卡推荐 `temperature=1.0, top_p=1.0, max_tokens≥256K`（训练/使用口径）；HLE 官方脚本默认 `temperature=0`；ZeroBench 要 5 次采样算 pass@5；Chartography 榜单要 10 epochs。**不要一套参数跑所有基准**，否则数字既不可比也不可复现。
6. **判分器是第二笔账，也是偏差来源。** HLE / ZeroBench / BabyVision / Chartography 都要 LLM judge（HLE 还要结构化输出能力）；judge 换模型，分数就变。Chartography 的榜单强绑 `gemini-3.5-flash` judge；HLE 要 pin judge 和 prompt 才能和 CAIS 数字对齐。
7. **Python 版本是硬门槛。** Harbor 0.25 / Pier 0.3.1 / ALE 都要求 **Python>=3.12**，而本机是 3.11。最省事：用 `uv tool install`（uv 会自带隔离的 3.12 环境）；不要动系统 Python。EvalScope 本体 3.10 即可，但 TB4/DeepSWE 扩展照样要 3.12。
8. **Docker 架构与网络策略。** ProgramBench 镜像只有 linux/amd64，Windows 上要 WSL2 + amd64 模拟（很慢）或干脆租 Linux 机器；ProgramBench 推理容器**无网**；Pier 的 air-gapped 任务靠 allowlist 才能让 agent 调模型。Harbor/Pier 默认本机 Docker，TB4 的 11 个多容器任务对 Docker 资源要求更高。
9. **Windows 自测的现实约束。** 本机 Windows + Docker 29 可以跑 Harbor（默认本机 Docker）与 Pier（docker/modal）的单容器任务；但 ALE（Linux 宿主安装脚本、QEMU/VM、GUI）需要 WSL2/云 Linux；NL2Repo 需要 Linux 容器 + OpenHands 镜像；ProgramBench 需要 linux/amd64。**建议：Windows 上只做「框架安装 + 小样本 + 判分链路」，重活扔 Linux 云机。**
10. **数据门禁与版本锁。** Chartography 的 HF 数据集匿名访问 401（可能 gated）；TB4 要 pin `@4.0.0`；DeepSWE v1.1 要 `pier>0.3.0`；ZeroBench 数据要 pin revision；Automation-Bench 官方榜是私有集（永远对不上）。写报告时必须写清「哪个版本/哪套数据/哪个 judge」。
11. **别名陷阱。** 「Mini-SWE-V2」官方新闻的叫法、PyPI 上是 `mini-swe-agent` v2.x；「Claude Code harness」= Harbor 的 `-a claude-code`，不是 Anthropic 的评测；「ZeroBench-main」≠ ZeroBench-subquestions（后者 334 题，是分析用子题）。引用数字前先对齐口径。
12. **成本失控的重灾区是 agent 类基准。** TB4 单题超时 8h、ProgramBench 单题 6h/1000 步、ALE 每题一台 VM。务必先看各 harness 的 `step_limit` / `cost_limit` / `timeout` / `--n-concurrent`，先跑 1–5 题标定再放大。

---

## 3. 成本与耗时估算方法

### 3.1 通用公式

```
总成本 ≈ Σ_任务 [ (输入 tokens × 输入单价 + 输出 tokens × 输出单价)
                  × (1 + 重试/失败率) ]
        + judge 调用成本（通常 = 任务数 × (judge 输入 + judge 输出) × judge 单价）
        + 基础设施成本（Docker 主机 / 云 VM 小时数 / GPU 小时数 / 存储）
        + 数据与镜像拉取成本（一次性，ProgramBench prebuilt ~450MB、TB4 prebuilt ~450MB）
```

**做法**：不要拍脑袋乘总数。先跑 `limit`/`--n-tasks`/`--slice` 取 **5–10 题**，记录 harness 输出的 token 数与耗时（EvalScope 有 token 统计，DeepSWE/Pier 有 `Avg cost per task`、`Out tok`、`Steps`，ZeroBench 榜单直接给 `cost/question`），再线性外推到全量；agent 类基准的 token 随轮数**超线性**增长，外推时留 1.5–2× 冗余。

### 3.2 已核实的成本锚点（可直接引用）

- **DeepSWE v1.1 榜单**（每模型 113 题，官方页面给出 Avg cost / Out tok / Steps）：`gpt-5.6-luna` $0.61/task（73k out，102 步）、`deepseek-v4-pro` $1.67/task（106k out，155 步）、`gemini-3.8-flash` $2.36/task（143k out，166 步）、`glm-5.3-flash` $0.24/task（73k out，123 步）、`claude-opus-5` $11.84/task（118k out，99 步）、`gpt-6-astra` $4.43/task（30k out，29 步）。
- **ZeroBench 官方榜单**：top 模型的 `cost/question` 在 $0.30–$1.01（含 pass@5 的 5 次采样）。
- **DeepSeek API 价格**（2026-10-30，per 1M tokens，谷/峰）：`deepseek-flash` 输出 **$0.6/$1.2**、输入 cache miss **$0.15/$0.3**、cache hit **$0.003/$0.006**；`deepseek-v4-pro` 输出 **$1.98/$3.96**、输入 cache miss **$0.66/$1.32**、cache hit **$0.022/$0.044**。峰值时段 = UTC 周一至周五 01:00–04:00、06:00–10:00（北京时间白天对应谷时更多，跑批可错峰省钱）。并发上限 flash 2500 / pro 500。

### 3.3 按基准的量级估算（粗估，必须用小样本标定后替换）

| 基准 | 题量 / 结构 | deepseek-flash 量级 | 主要成本驱动 |
|---|---|---|---|
| HLE | 2500 题（文本子集另算，题量 unknown） | **$10–70**（含 judge） | thinking 输出长度 + judge |
| Terminal-Bench 4.0 | 66 题，8h/题超时 | **$50–300** | 长时 agent 循环、Docker 主机；3 题需 H100 |
| DeepSWE v1.1 | 113 题 | **$20–120** | ~100 步/题、~80–150k 输出 tokens/题 |
| ProgramBench | 200 题，6h/题上限 | **$400–1600 + 算力** | 1000 步上限、20CPU/60GB×6h |
| NL2Repo-Bench | 104 题 | **$100–500** | 整仓生成，输出极长 |
| Automation-Bench v1.0.6 | 公开 600 + simple 200 | **$15–60** | 50 步/题 × 47 个工具 |
| Agents' Last Exam | 122 题（3 GPU） | **$100–1000+** | 云 VM/GPU 小时数 >> 模型 token |
| Chartography | 100 题 ×10 epochs + judge | **$10–40** | 图片输入 + judge ×1000 |
| BabyVision | 388 样例 + judge | **$5–25** | 大图输入 + judge |
| ZeroBench-main | 100 题 ×5 采样 + judge | **$5–15** | 5 次采样 + judge |
| Apex Bench v1.1 | unknown | 无法估算 | 无公开数据 |

> 单位是美元、按上面 DeepSeek 价格粗估，**不作为报价承诺**；`judge` 若换成强模型（如前沿闭源模型）成本可能翻数倍。真实数字以 5–10 题实测的 token/耗时外推。

### 3.4 时间估算

- **HLE**：2500 次调用，`--num_workers 100` 量级下几小时；小样本 10 题几分钟。
- **ZeroBench**：500 次调用（100×5），1–2 小时。
- **Chartography**：1000 次生成 + 1000 次 judge，2–6 小时。
- **DeepSWE**：单题 30 分钟–8 小时（30–170 步），113 题在 8–16 并发下 **1–4 天**。
- **TB4**：单题上限 8h，66 题串行 500h 量级 → 必须并发（Harbor `--n-concurrent`，或 `--env modal` 上云）。
- **ProgramBench**：200 题 × 最长 6h，20 并发也要几十小时。
- **ALE**：每题要开 VM/装环境，10–40 分钟起步，122 题并行也以天计。
- **NL2Repo**：整仓生成，单题分钟到小时级，104 题在 `max_pool_size` 并发下数小时–1 天。

---

## 4. 最小可行自测矩阵（三档）

> 假设：Windows + Docker 29 + 无 GPU；目标是「先确认数据/判分/接口都通，再花钱」。三档按「先便宜后贵、先无 Docker 后有 Docker、先通用框架后专用 runner」排序。

### 档 0：0 元本地小样本（1–2 天，验证管道，不出分数）

目标不是测模型，而是确认「数据能下、Docker 能跑、判分能出、judge 能调」。
硬件限制：**DeepSeek-V4.1-Flash-1017 本机跑不了**（763B 参数、官方 MP=8），模型侧用 Ollama 小模型或任意免费额度，甚至可以先用 mock 模型。

1. **装工具（一次）**：`uv tool install harbor`、`pip install evalscope inspect-ai inspect-evals`、`git clone` VLMEvalKit 并 `pip install -e .`。Python 3.11 不够，全部走 uv 隔离的 3.12。
2. **Harbor oracle 自检**（不用模型，验证 Docker/数据集）：
   `harbor run -d terminal-bench/terminal-bench@4.0.0 -a oracle -k 1 --n-concurrent 1`（`-k 1` 先只跑 1 个重复）→ 能跑通说明 TB4 数据/镜像 OK。
3. **Chartography 离线链路**（不用 key）：按官方 README 用 `-T limit=2 --model mockllm/model -T judge_model=mockllm/model` 跑 sample task pack，验证 Inspect 安装与 scorer 流程。
4. **HLE 10 题 + judge**：`python run_model_predictions.py --dataset cais/hle --model <ollama 小模型> --max_completion_tokens 8192 --num_workers 4 --max_samples 10`，再跑 `run_judge_results.py`，确认 judge 结构化输出能工作。
5. **ZeroBench 5 题**：`load_dataset('jonathan-roberts1/zerobench', split='zerobench')` 取前 5 题，按 README 的 pass@1 片段跑（验证图片能喂进去）。
6. **BabyVision 2–5 题**：`babyvision_eval` 设 `MODEL_*`/`JUDGE_*` 走 OpenRouter/本地 judge，确认 `\boxed{}` 抽取。
7. **Automation-Bench simple 子集 2 题**：`uv run auto-bench --model <ollama> --domains simple --num-examples 2`（无需 Docker、无需真 SaaS 凭据）。

产出：一份「哪些命令能跑通、报什么错」的清单；这档跑完再进档 1，能省下大量 API 钱。

### 档 1：一周 API 预算（建议 $50–150，出「可比较的粗分数」）

**推荐的基准子集与顺序**（便宜 + 无 Docker 的在前）：

| 顺序 | 基准 | 框架/命令 | 样本量 | 为什么先跑 |
|---|---|---|---|---|
| 1 | HLE（纯文本） | EvalScope `hle` + `include_multi_modal=false`，或 `inspect eval inspect_evals/hle` | 先 50，再 250 | 无 Docker、最便宜，先验证 judge 与口径（44.0† 是文本子集） |
| 2 | ZeroBench-main | EvalScope `zerobench`（pass@1 先跑）或 inspect_evals `zerobench` | 100 全量 | 只有 100 题，5 采样可控；图片链路一次验证 |
| 3 | BabyVision | EvalScope `baby_vision` 或官方 `babyvision_eval` | 先 50，再 388 | 388 样例，judge 链路成熟 |
| 4 | Automation-Bench | `uv run auto-bench`（或 EvalScope `automation_bench`） | `simple` 200 → sales 100 | 纯 API，验证多步工具调用与状态判分 |
| 5 | Chartography | 官方 Inspect repo（先确认 HF 访问权限） | 先 `limit=10`，再 100（epochs 1，非榜单 10） | 100 题，judge 单次，便宜；榜单口径最后再加 epochs |
| 6 | DeepSWE v1.1 | Pier `--n-tasks 10 --sample-seed 0`（或 EvalScope `deep_swe --limit 10`） | 10 题 | 第一次上 Docker agent；10 题可外推 113 题成本 |
| 7 | Terminal-Bench 4.0 | Harbor `-d terminal-bench/terminal-bench@4.0.0` + `task_names`/子集 | 5–10 题 | 最贵的 agent 基准，等 Docker 与并发都调好再上 |

**刻意留到档 2**：ProgramBench（amd64-only、200×6h）、NL2Repo-Bench（OpenHands 镜像 + 104 题）、Agents' Last Exam（VM/GUI）、Apex Bench（无 runner）。

档 1 的命令骨架（DeepSeek 端点示例，Harbor/Pier 的 deepseek slug 组合需实测 → TODO verify）：

```bash
# 1) HLE（EvalScope，OpenAI 兼容端点）
pip install evalscope
evalscope eval --model deepseek-flash \
  --api-url https://api.deepseek.com --api-key $env:DEEPSEEK_API_KEY \
  --datasets hle --limit 50 \
  --judge '{"strategy":"llm","models":[{"model_id":"deepseek-flash"}]}'
# 纯文本模型记得在 dataset_args.hle.extra_params 里设 include_multi_modal=false

# 2) ZeroBench（EvalScope）
evalscope eval --model deepseek-flash \
  --api-url https://api.deepseek.com --api-key $env:DEEPSEEK_API_KEY \
  --datasets zerobench --limit 100 \
  --judge '{"strategy":"llm","models":[{"model_id":"deepseek-flash"}]}'

# 3) Automation-Bench 官方 CLI（公开 simple 子集）
git clone https://github.com/zapier/AutomationBench && cd AutomationBench && uv sync
uv run auto-bench --model deepseek-flash --base-url https://api.deepseek.com \
  --api-key $env:DEEPSEEK_API_KEY --domains simple --num-examples 20 --max-concurrent 8

# 4) DeepSWE 小样本（Pier + mini-swe-agent；slug/端点组合 TODO verify）
git clone https://github.com/datacurve-ai/deep-swe
uv tool install datacurve-pier
$env:DEEPSEEK_API_KEY="..."; pier run -p deep-swe/tasks --agent mini-swe-agent `
  --model deepseek/deepseek-flash --n-tasks 10 --sample-seed 0

# 5) TB4 小样本（Harbor + claude-code；组合命令 TODO verify 实测）
harbor run -d terminal-bench/terminal-bench@4.0.0 `
  -a claude-code -m deepseek-flash `
  --base-url https://api.deepseek.com/anthropic `
  --api-key-name DEEPSEEK_API_KEY --api-format anthropic_messages `
  --n-concurrent 4
```

### 档 2：完整复现（按榜单单口径，预算四位数起）

目标：每个基准都按「官方 harness + 官方数据版本 + 官方 judge/采样」跑一遍，能解释与模型卡数字的差异。

| 基准 | 完整复现命令/入口 | 规模 | 注意 |
|---|---|---|---|
| HLE | `hle_eval` 全量 + 固定 judge | 2500 | 分清 42.6（全集）/44.0†（文本子集） |
| TB 4.0 | `harbor run -d terminal-bench/terminal-bench@4.0.0 -a claude-code -m ... --n-concurrent N` | 66 | 3 题需 H100、11 题多容器，建议 `--env modal` |
| DeepSWE v1.1 | `pier run -p deep-swe/tasks --agent mini-swe-agent --model ...` | 113 | 官方固定 mini-swe-agent；确认 `pier>0.3.0` |
| ProgramBench | `mini-extra programbench` + `programbench eval` | 200 | linux/amd64 主机；每题 6h 上限 |
| NL2Repo-Bench | 官方 OpenHands batch + `config.toml` | 104 | 需 `openhands:0.56` / `runtime:0.56-nikolaik` |
| Automation-Bench | `uv run auto-bench --domains all` | 600（+200 simple） | 官方榜是私有集，公开分只能方向对齐 |
| Agents' Last Exam | `uv run python -m ale_run run my_experiment.yaml` | 122 | Linux 宿主 + 云 VM；3 个 GPU 任务 |
| Apex Bench v1.1 | **无法复现**（TODO verify） | unknown | 目前只有第三方榜单数字 |
| Chartography | 官方 repo，`--epochs 10 --epochs-reducer "mean,pass_at_10,at_least_10" -T judge_model=google/gemini-3.5-flash` | 100×10 | 需 HF 数据集访问权限 |
| BabyVision | 官方 `babyvision_eval` 全量 + `JUDGE_MODEL` | 388 | 判分必须用官方 judge 口径 |
| ZeroBench-main | 官方脚本 5 采样，或 `inspect eval inspect_evals/zerobench -T k=5` | 100×5 | 报告 pass@1/pass@5/pass^5 三个数 |

**预期偏差（提前写进结论，避免被当成 bug）**：
- Reasoning effort / thinking 开关、`temperature/top_p`、max_tokens 与官方不同；
- judge 模型与 prompt 不同（HLE、ZeroBench、BabyVision、Chartography 全部受影响）；
- Automation-Bench 私有 held-out 集：**永远对不上**官方分；
- TB4 数据集版本（必须 4.0.0）、DeepSWE v1.1 的 verifier 版本、ZeroBench 的 revision；
- agent harness 版本（尤其 mini-swe-agent v2.x 小版本）会影响分数；
- 部分题依赖 H100/多容器/特定 OS，缺环境会变成 0 分而不是 skip。

---

## 5. TODO verify 清单（已经在 JSON 里用 `verified:false` 或 notes 标注）

1. **Apex Bench v1.1**：未找到任何官方仓库/数据集/runner，只有第三方榜单页（DataLearner、Open LLM Radar、UltraBench、phaseo），DataLearner 明说「未提供独立基准主页/题量/机构」。→ 需要直接问发布方或翻 DeepSeek 技术报告。
2. **Mini-SWE-V2 的确切定义**：DeepSeek 新闻写「mini-swe-v2 harness」，PyPI 只有 `mini-swe-agent`（2.4.6）；是否同一版本、用什么 config 未核实。
3. **Pier/Harbor 接 DeepSeek 端点的精确命令**：模型 slug 在 LiteLLM 里应为 `deepseek/deepseek-flash`，但 Pier 的连接参数（`agent.env` 还是 `config_yaml`）与 Harbor 的 `--api-key-name` 组合没有实测。
4. **Chartography HF 数据集访问门槛**：匿名 raw 401，是否 gated / 需申请未知。
5. **VLMEvalKit 里 BabyVision / ZEROBench 的准确 dataset 名称字符串**：类名已确认，`--data` 参数值以 `run.py --help` 为准。
6. **HLE text-only 子集题量与官方 judge**：模型卡只给 44.0†，未给子集大小与 judge 型号；官方脚本 `--judge` 需自选。
7. **vLLM 对 DeepSeek-V4.1-Flash-1017 的支持**：官方只给了自己的 reference inference（MP=8），未把 vLLM 列为 serving 方式。
8. **NL2Repo-Bench 的 `config.toml` 字段与入口脚本**：README 提到 config.toml/config.json 与 main.py（仓库文件列表可见），但完整的「OpenAI 兼容 baseUrl + 模型名」示例未在 README 展开。

---

## 6. 来源（本次实际打开过的页面）

- Harbor README / 文档：<https://github.com/harbor-framework/harbor>、<https://docs.harborframework.com/getting-started/quick-start.md>、<https://docs.harborframework.com/agents/pre-integrated-agents.md>、<https://docs.harborframework.com/agents/agent-auth-resolution.md>、<https://docs.harborframework.com/datasets/datasets.md>
- Terminal-Bench 仓库与 v4.0.0 release：<https://github.com/harbor-framework/terminal-bench>、<https://api.github.com/repos/harbor-framework/terminal-bench/releases>
- Pier README：<https://github.com/datacurve-ai/pier>；DeepSWE README / blog：<https://github.com/datacurve-ai/deep-swe>、<https://deepswe.datacurve.ai/blog/deepswe>、<https://deepswe.datacurve.ai/blog/deepswe-v1-1>
- mini-swe-agent README / PyPI：<https://github.com/SWE-agent/mini-swe-agent>、<https://pypi.org/project/mini-swe-agent/>、<https://mini-swe-agent.com/latest/usage/programbench/>
- ProgramBench：<https://github.com/facebookresearch/programbench>、<https://github.com/facebookresearch/programbench/blob/main/docs/README.md>、<https://huggingface.co/datasets/programbench/ProgramBench-Tests>
- HLE：<https://github.com/centerforaisafety/hle>、<https://huggingface.co/datasets/cais/hle>
- ZeroBench：<https://github.com/jonathan-roberts1/zerobench>、<https://zerobench.github.io/>、<https://huggingface.co/datasets/jonathan-roberts1/zerobench>、<https://github.com/UKGovernmentBEIS/inspect_evals/tree/main/src/inspect_evals/zerobench>
- Chartography：<https://arxiv.org/abs/2608.10677>、<https://github.com/surge-ai/chartography>、<https://huggingface.co/datasets/surgeai/chartography>
- BabyVision：<https://github.com/UniPat-AI/BabyVision>、<https://arxiv.org/pdf/2601.06521>
- Automation-Bench：<https://github.com/zapier/AutomationBench>、<https://arxiv.org/abs/2604.18934>
- ALE：<https://github.com/rdi-berkeley/agents-last-exam>、<https://arxiv.org/abs/2606.05405>
- NL2Repo-Bench：<https://github.com/multimodal-art-projection/NL2RepoBench>、<https://arxiv.org/abs/2512.12730>
- EvalScope 各基准文档：<https://github.com/modelscope/evalscope/tree/main/docs/zh/benchmarks>（hle / terminal_bench_v4 / deep_swe / automation_bench / baby_vision / zerobench）
- Inspect：<https://inspect.aisi.org.uk/providers.html>、<https://github.com/UKGovernmentBEIS/inspect_evals>、<https://pypi.org/project/inspect-ai/>、<https://pypi.org/project/inspect-evals/>
- VLMEvalKit：<https://github.com/open-compass/VLMEvalKit>、<https://github.com/open-compass/VLMEvalKit/blob/main/docs/en/Quickstart.md>、<code>vlmeval/dataset/__init__.py</code>
- lm-evaluation-harness：<https://github.com/EleutherAI/lm-evaluation-harness>、<code>lm_eval/tasks/README.md</code>
- OpenAI simple-evals：<https://github.com/openai/simple-evals>
- vLLM：<https://github.com/vllm-project/vllm/blob/main/docs/serving/integrations/claude_code.md>、<https://docs.vllm.ai/en/latest/serving/online_serving/>
- Claude Code + DeepSeek：<https://api-docs.deepseek.com/quick_start/agent_integrations/claude_code.md>、<https://api-docs.deepseek.com/guides/anthropic_api.md>
- DeepSeek 模型卡 / 价格 / 发布新闻：<https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash-1017>（含 `inference/README.md`、`encoding/README.md`）、<https://api-docs.deepseek.com/quick_start/pricing.md>、<https://api-docs.deepseek.com/news/news261017.md>
- Apex Bench 第三方页面（仅用于说明“无官方 runner”）：<https://www.datalearner.com/benchmarks/apexbench>、<https://open-llm-radar.com/benchmarks/apexbench>、<https://phaseo.app/zh-Hans/benchmarks/apex-bench-v1.1>
- PyPI 版本核实：harbor 0.25.0 / datacurve-pier 0.3.1 / mini-swe-agent 2.4.6 / evalscope 1.14.1 / inspect-ai 0.3.286 / inspect-evals 0.27.0
