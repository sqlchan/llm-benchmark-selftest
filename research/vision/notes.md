# 多模态/视觉类基准自测调研（Chartography / BabyVision / ZeroBench-main）

- 核实日期：2026-10-30；对应官方模型卡 `DeepSeek-V4.1-Flash-1017`（HF: deepseek-ai/DeepSeek-V4.1-Flash-1017）。
- 结构化的可机读字段见同目录 `benchmarks.json`（3 元素数组，键名严格按 `research/SCHEMA.md`，已通过 JSON 自检）。
- 先说结论：三个基准**都没有把“工具调用”写进官方默认协议**；模型卡里的 `w/tools` 是模型厂商把模型放进 agent harness（有工具的环境）后跑出的自报数：DeepSeek 的技术报告 §5.3.1 明确写了“视觉 agent 任务统一用 **Claude Code harness + 512k context、temperature 1.0、top-p 0.95**”，Table 3 报 Chartography/BabyVision 为 Pass@1、ZeroBench-main 为 Pass@5。它与官方 leaderboard 的 no-tools 分数不是一回事，**不能直接横比，也无法用官方脚本复现**。ZeroBench 官方 externals 表也把 DeepSeek 的提交标注为 “Claude Code harness tools; 5 samplings”，与此一致。

## 速览：能不能拿到数据、怎么跑、花多少钱

| 基准 | 数据/图片公开？ | 题量 | 许可 | 官方判分 | 官方是否要工具 | 自测难度 | 主要风险 |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| Chartography | **partial**：GitHub harness 公开，但 HF 数据集匿名访问 HTTP 401、HF 搜索无此数据集；官方号称已发布 100 题+图片，当前实测拿不到 | 100 | unknown（repo 无 LICENSE；HF 页打不开） | LLM judge（Gemini 3.5 Flash），专家区间 | **否**（论文明确 no tools/no crop/zoom） | hard（卡在数据） | 无数据 → 不能自测；模型卡 w/tools 分数无法复现 |
| BabyVision | **yes**：HF `UnipatAI/BabyVision`（MIT，388 题单 train split），GitHub data zip 约 48MB | 388（22 子类/4 大类） | MIT | LLM judge（论文 Qwen3-Max；代码默认 gpt-5.2） | **否**（官方 protocol 无工具） | easy | judge 换模型会变分；w/tools 协议不统一 |
| ZeroBench-main | **yes（gated）**：HF `jonathan-roberts1/zerobench` 需登录并同意“不公开答案/不用于训练”；也可走 VLMEvalKit 的 opencompass 镜像 | 100 主问题（+334 子问题） | MIT（GitHub LICENSE）；HF 数据卡未单独写 license | **exact-match**（精确字符串，不调 judge） | **否**（官方 no-tools；工具辅助成绩另标） | easy | Pass@5 要 5 次采样；格式错误直接算错；镜像与 v3 是否同步未核实 |

成本粗算（**估算，非官方**；按 DeepSeek API 官方价目 `deepseek-flash` = V4.1-Flash-1017，1M 上下文、支持视觉，错峰输入 $0.15/1M tokens、输出 $0.6/1M tokens，峰时翻倍；价格页核实于 2026-10-30）：

| 基准 | 调用量（全量） | 估算花费 | 依据 |
| :-- | :-- | :-- | :-- |
| ZeroBench-main（Pass@5） | 100 题 × 5 次 = 500 次 | 约 $0.1–$1.7 | 官方 leaderboard 给 tokens/question 约 3.7k–72.1k（5 次合计）；按 DeepSeek 错峰价折算 |
| BabyVision（Avg@3） | 388 题 × 3 pass ≈ 1164 次 + 1164 次 judge | 约 $0.3–$1（模型）+ judge 另计（若用 DeepSeek 当 judge 约 $0.1 量级） | 官方未给成本；按每题千级 tokens 估算 |
| Chartography（10 epochs） | 100 题 × 10 = 1000 次 + 1000 次 Gemini 3.5 Flash judge | 约 $1–$5（judge 费用未知） | 官方未给成本；按每题 2k–5k tokens 估算 |

> 说明：官方（ZeroBench leaderboard）给出的 cost/question 是前沿模型口径：$0.010–$1.11/题（Pixtral-Large $0.010、GPT-6 Luna $0.018、GPT-6 Sol $0.17、GPT-6 Astra $0.56、GPT-5.6 Sol $0.76、Claude Opus 5.5 $1.11），即 100 题全量约 $1–$111。换 DeepSeek 这类低价 API 会便宜一个数量级左右，但开 thinking 后输出 tokens 会显著增加。`w/tools` 的 agent harness 会多轮调用工具，token 可能再涨数倍，官方没给数字，标 unknown。

## 重点一：`w/tools` 到底指什么（逐项核实）

**结论（已核实到官方技术报告）**：`w/tools` 不是这三个 benchmark 的官方设置，而是发布方把模型放进 **agent harness（Claude Code）** 里跑出来的自报数。DeepSeek-V4.1 技术报告 §5.3.1 原文：*“For visual agent tasks, we evaluate using the Claude Code harness with a 512k-token context window, temperature set to 1.0, and top-p set to 0.95.”* 三个视觉基准（Chartography、BabyVision、ZeroBench 的 main set）都归在 “Visual agent” 这一类；Table 3 中 Chartography/BabyVision 以 **Pass@1**、ZeroBench-main 以 **Pass@5** 报告。Claude Code harness 意味着模型可以调用 shell/文件等工具（也就意味着可以写 Python 去裁剪、放大、测量图片），这是官方协议里明令禁止的（Chartography 论文 §3/§4.1 明确 no tools / no code execution / no cropping / no zooming）。

**为什么不能和官方榜直接比**：

- 官方默认协议全部 no-tools：Chartography 论文与 README 明确禁止工具；BabyVision 官方 MLLM 评测是单轮图+问→\boxed{}→judge；ZeroBench 官方主榜是 no-tools 的 5 次采样精确匹配。
- 同一模型在两套口径下差距巨大：官方 Chartography leaderboard 上 DeepSeek V4.1 Flash (Max reasoning) 只有 **11.6%**，而模型卡 Chartography (w/tools) 写 **83.0**。这不能解读为“工具让模型强了 7 倍”，而是题面+工具+judge/采样环境整体不同；官方没有工具赛道的评测协议可比。
- BabyVision 官方 leaderboard 额外收录了标注 “(with tools)”/“(with Python tools)” 的提交（如 Qwen3.8-Max w/tools 91.3 vs 无工具 82.0；Kimi K3 with Python tools 85.7），但各家工具集和协议不同，同样不可直接对齐。

**能不能复现**：不能靠官方 benchmark 脚本直接得到 w/tools 分。要复现需要：① 拿到该 benchmark 的官方题目/图片；② 搭一个 Claude Code（或同等的、能读图并运行代码的 agent）harness，并用相同的 512k context、temp 1.0、top-p 0.95、5 次采样；③ 沿用官方 judge/精确匹配。Claude Code harness 的具体版本、system prompt、工具 schema 未公开，所以只能“近似复现”，不能保证对齐。若目标是“和官方榜/别人对比”，应只跑 no-tools 官方协议。

## 重点二：“ZeroBench minimal vs main” 的澄清

这个问题实际上把两个不同维度的概念混在了一起，核实后可以精确回答：

1. **ZeroBench 没有 minimal 子集**。官方 v3 只有两个 split：`main`（100 题，headline 指标来源；模型卡 `ZeroBench-main (w/tools) 51.0` 就是这 100 题的 Pass@5 = 5 次采样至少 1 次答对的比例）和 `subquestions`（334 道从主问题拆出的“最小推理步骤”子问题，用于诊断/区分部分能力，**不是 Pass@5 的计算对象**）。依据：论文 v3、HF 数据集 API（splits 只有 `zerobench`/`zerobench_subquestions`）、项目页、GitHub README、VLMEvalKit、inspect_evals 均无 “minimal” split。
2. **“Minimal” 是 DeepSeek Harness（DSH）的一个运行模式**，出现在 DeepSeek-V4.1 技术报告：§5.3.1 说 code agent 用 “the Minimal mode of DeepSeek Harness”，附录 B.1 定义 “DSH: We use Minimal with a single bash tool; Standard with the full sdk profile…”。而视觉 agent（Chartography/BabyVision/ZeroBench main set）用的是 **Claude Code harness**，不是 DSH Minimal；技术报告原句也写的是 “main set of ZeroBench”。

所以：“ZeroBench-main” 属于**数据/题目层面**（100 题主集）；“Minimal” 属于**评测 harness 层面**（DSH 的单 bash 工具模式，且只用于 code agent）。两者不在同一维度，不存在“minimal 集 vs main 集”的数据子集对比。若某张表把 “ZeroBench-minimal” 当数据集名，官方没有这个定义，标 unknown。

## 逐项说明与自测判断

### 1) Chartography（Surge AI，2026-08，ECCV 2026 BEAM workshop）

**测什么**：专业图表阅读——在稀疏坐标轴上估读、等值线插值、Sankey 流线追踪、投影 3D 几何、领域惯例；图表来自 Kaplan-Meier、K 线、等值线、Bode 图、风玫瑰等专业格式，12 个领域，100 题，全部由执业专家出题并 3 人复核，51 题金标带“专家可接受区间”。**判分**：judge 只看题面/金标/回答、不看图，用 Gemini 3.5 Flash，一次试验一个二值，报告 mean pass@1；官方 harness 基于 Inspect AI，leaderboard 配置是 10 epochs/judge gemini-3.5-flash，论文写 20 trials。

**数据能不能拿**：这是三个里最糟的。论文与 HF 卡都声称 100 题、图片、provenance、评测代码已发布到 `huggingface.co/datasets/surgeai/chartography`，但 2026-10-30 实测：匿名访问该 dataset 及 HF API 均 **HTTP 401**，HF 按作者 `surgeai` 列数据集只有 DAYJOB-*/GDP.xlsx，搜索 “chartography” 结果为空；GitHub 仓库只有 harness 和 **2 个假任务**（manifest 明写 “not part of the released dataset”）。也就是说**真实 100 题/图片目前无法匿名下载**，需联系 benchmarks@surgehq.ai 或申请 HF 授权（获取方式未核实）。许可也未知（repo 无 LICENSE；arXiv 页的 CC BY 4.0 是论文许可，不等于数据许可）。

**怎么跑**：官方 README 的 Inspect AI harness（`uv run inspect eval src/chartography/task.py ...`）；没有真实数据时只能跑 2 个假任务冒烟。完整运行要 `-T hf_repo=surgeai/chartography`（当前会因 401 失败）。

**花多少钱**：官方无成本数据；100 题 × 10 次 ≈1000 次生成 + 1000 次 Gemini 3.5 Flash judge，按 DeepSeek 价估算约 $1–$5（judge 费用未知）。

**坑**：数据 401；模型卡 w/tools（83.0）是 Claude Code harness 口径（技术报告 §5.3.1：512k context、temp 1.0、top-p 0.95，Pass@1），与官方 no-tools 榜的 11.6 不可比、也无法用官方脚本复现；judge 固定且是自评配置；论文 20 trials 与 README 10 epochs 两套口径；许可不明。

**自测判断**：**hard → 目前不建议先做**。技术栈（Inspect AI + API）很轻，但拿不到数据就没有“自己测试”的可能；若能申请到 HF 授权，则属于“100 题、纯 API、几千次调用”的 medium 工作量，1–2 张卡的本地模型也能跑（不需要 GPU 集群）。适合有预算、愿意发邮件要数据的人。

### 2) BabyVision（UniPat AI，2026-01，ICML 2026）

**测什么**：不依赖语言先验的核心视觉能力（4 大类 22 子类）：细粒度辨别（找不同/找阴影）、视觉追踪（迷宫/地铁图/连线）、空间感知（3D 视图、折纸、数积木）、模式识别（旋转/镜像/叠加/补全）。388 题，号称 3 岁小孩可解，但成人基线 94.1、2026-01 最强 Gemini3-Pro-Preview 49.7。**判分**：LLM judge 判断语义等价（论文用 Qwen3-Max，自称与人工 100% 一致；官方代码默认 `openai/gpt-5.2`），`\boxed{答案}` 输出，Avg@3（3 次 pass 的均值±std）。

**数据能不能拿**：**能，最友好**。HF `UnipatAI/BabyVision` 是 MIT、公开未 gated、388 条单 train split，字段含 `question/image/ansType/options/choiceAns/blankAns/coT`；GitHub `UniPat-AI/BabyVision` 的 `data/babyvision_data.zip` 实测约 48MB（50,125,541 字节）。图片+文本，无需原始数据集以外的资源。

**怎么跑**：`git clone` → 解压 data zip → `pip install -r requirements.txt` → 设 `MODEL_*`/`JUDGE_*`（默认 OpenRouter OpenAI 兼容端点）→ `bash run_inference.sh` → `python compute_score.py results/*.json`；`NUM_PASSES` 默认 3、`NUM_PROCESSES` 默认 8。替代：VLMEvalKit 已内置 `BabyVision`（默认 judge gpt-5.2，数据直接拉官方 GitHub zip）。

**花多少钱**：官方无成本数据；388×3≈1164 次生成 + 1164 次文本 judge，DeepSeek 价估算模型侧约 $0.3–$1，judge 另计（若用 DeepSeek 当 judge 约 $0.1 量级）。

**坑**：judge 模型/版本必须固定（论文 Qwen3-Max、代码默认 gpt-5.2，换 judge 会改分）；指标是 Avg@3 不是单次；choice 题要输出选项字母；模型卡 `BabyVision (w/tools)=92.5` 非官方协议（技术报告 §5.3.1：Claude Code harness + 512k context，Pass@1；官方榜单另有各家 “(with tools)/(with Python tools)” 提交，如 Qwen3.8-Max w/tools 91.3 vs 无工具 82.0，工具集不统一）。

**自测判断**：**easy，最推荐先跑**。纯 API、388 题、约 1164 次生成，1–2 张卡/一个 API 预算都能承受；MIT 数据无门槛；评测脚本官方给全，冒烟可以抽 30–50 题、`NUM_PASSES=1`。适合作为“自己测试模型”的第一个视觉基准。

### 3) ZeroBench-main（Cambridge 等，2025-02 首发 / v3 2026-07，ICML 2026）

**测什么**：对抗式筛选出的“高难多步看图”推理：象棋 FEN、菜单/地图读数、雪flake 体积等，答案空间大、不可猜，发布时前沿模型 pass@1/pass^5 全 0；官方 leaderboard（2026-10）no-tools 最好已达 **52.0 pass@5 / 35.0 pass^5**（GPT-6 Astra；README 文字还停留在 30%/13%，以 leaderboard 为准）。**判分**：正则取最后一次 `{...}` 内容，与金标**精确匹配**（格式错误算错），不调 LLM judge；Pass@1=单次采样平均正确率，Pass@5=5 次采样至少答对 1 次的比例，Pass^5=5 次全对的比例。

**数据能不能拿**：**能，但 HF 是 gated**。`jonathan-roberts1/zerobench` 需登录并 Acknowledge（不得公开答案、不得训练，含 canary string）；HF API 元数据可读（100 main + 334 sub，download_size≈191MB），未登录取文件会 401。替代：VLMEvalKit 的 `ZEROBench` 用 opencompass 镜像 TSV（无需 gated 授权，但是否与 v3 同步未核实）。图片可单独下 `images.zip`。

**怎么跑**：官方**没有**评测脚本仓库（repo 只有 README/LICENSE/assets），只给 pass@1 的参考代码；Pass@5 要自己 5 次采样。两条现成替代：① UK AISI `inspect_evals`：`inspect eval inspect_evals/zerobench --model <model> --max-tokens 16000 --temperature 0.7 --top-p 0.95`（内置 pass@k 与 k/k reliability）；② VLMEvalKit：`python run.py --data ZEROBench --model <model> --verbose`（只算 accuracy=pass@1）。

**花多少钱**：官方 leaderboard 直接给了 cost/question 与 tokens/question（见上表），100 题 pass@5 全量按官方模型价约 $1–$111；DeepSeek 价估算约 $0.1–$1.7，是三个里最便宜的（不需要 judge 调用）。

**坑**：HF gated；精确匹配很严格（格式/单位/有效数字）；Pass@5 必须 5 次采样（官方老模型 temperature=0.7/top_p=0.95，新模型用默认参数）；无官方脚本需自写或用替代框架；模型卡 `ZeroBench-main (w/tools)=51.0` 是 Claude Code harness（512k context、temp 1.0、top-p 0.95）+ 5 次采样的自报值，官方主榜 no-tools 不可直接比。

**自测判断**：**easy，性价比最高**。100 题、500 次调用、不需要 judge、精确匹配最可复现；50 题 ×1 次 greedy 就能先估 pass@1。唯一门槛是 HF gated（或改用 VLMEvalKit 镜像）。1–2 张卡跑本地模型也可以（图片不大），但本地小模型大概率接近 0 分。

## 建议的自测顺序

1. **BabyVision**：数据 MIT、脚本官方、388 题；跑通后能立刻得到一个“语义 judge”型视觉分数（注意固定 judge）。
2. **ZeroBench-main**：100 题、500 次调用、无需 judge、成本最低，最可复现；先做 50 题 smoke，再上 5 采样。
3. **Chartography**：等技术/数据门槛解决（HF 授权或官方回复）再碰；否则只能跑 2 个假任务，没有自测意义。

## 主要来源（均于 2026-10-30 实际打开/请求）

- Chartography：<https://arxiv.org/abs/2608.10677>、<https://arxiv.org/html/2608.10677v1>、<https://github.com/surge-ai/chartography>、<https://surgehq.ai/benchmarks/chartography>、<https://surgehq.ai/blog/chartography>、<https://huggingface.co/datasets/surgeai/chartography>（unreachable，HTTP 401）
- BabyVision：<https://arxiv.org/abs/2601.06521>、<https://arxiv.org/html/2601.06521v2>、<https://github.com/UniPat-AI/BabyVision>、<https://huggingface.co/datasets/UnipatAI/BabyVision>、<https://unipat.ai/benchmarks/BabyVision>、<https://unipat.ai/blog/BabyVision>
- ZeroBench：<https://arxiv.org/abs/2502.09696>、<https://arxiv.org/html/2502.09696v3>、<https://zerobench.github.io>、<https://github.com/jonathan-roberts1/zerobench>、<https://huggingface.co/api/datasets/jonathan-roberts1/zerobench>、<https://ukgovernmentbeis.github.io/inspect_evals/evals/zerobench/index.html>
- 框架支持：VLMEvalKit `vlmeval/dataset/__init__.py`、`image_vqa.py`（ZEROBench）、`babyvision.py`（BabyVision）；Chartography 未在 VLMEvalKit 中（官方即 Inspect AI task）
- 模型卡、技术报告与价格：<https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash-1017/raw/main/README.md>、<https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash/blob/main/DeepSeek_V41_Tech_Report.pdf>（§5.3.1 视觉 agent 用 Claude Code harness + 512k、temp 1.0、top-p 0.95；Table 3 w/tools 三项指标；附录 B.1 DSH Minimal=单 bash）、<https://api-docs.deepseek.com/quick_start/pricing>
- 第三方旁证（非官方）：<https://www.llmreference.com/benchmark/zerobench-main-with-tools>（ZeroBench-main w/tools 指标 Pass@5、Claude Code harness、512k context）

> 免责：`setup_commands` 中的命令均摘自官方文档、**未在本机执行**（缺 API key/数据授权），已在 JSON 中标注 `# TODO verify`。所有金额为估算，仅用于量级判断。
