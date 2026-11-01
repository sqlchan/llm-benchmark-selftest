# DeepSeek-V4.1-Flash-1017 模型卡 11 个基准：自测指南

> 整理日期：2026-10-30 ｜ 依据：HF 官方模型卡 + 11 个基准的官方主页/论文/仓库/榜单（逐条核实）+ 20 个评测框架文档。
> 目标读者：想「自己跑这些基准测模型」的人。所有金额为量级估算，所有命令来自官方文档但**未在本机执行**（见文末「未核实项」）。

---

## 0. 三分钟结论

| 问题 | 答案 |
| :-- | :-- |
| 11 个基准都能自己跑吗？ | **10 个能，1 个不能**。Apex Bench v1.1 只有模型卡自报数字，查不到主页/论文/数据/runner。 |
| 跑出来的分数能和模型卡对上吗？ | **多数对不上，且这是正常的**：模型卡数字是厂商自报，部分用了 `w/tools` 口径（官方协议是 no-tools），部分基准官方榜用的是**私有 held-out 集**。详见第 4 节。 |
| 最便宜、最快能出数字的是哪些？ | **ZeroBench-main**（100 题、500 次调用、无需 judge，估 $0.1–1.7）→ **BabyVision**（388 题、MIT 数据，估 $0.3–1 + judge）→ **HLE 纯文本**（估 $2–8/50 题）。 |
| 最贵、最容易翻车的是哪些？ | **Agents' Last Exam**（真机 VM/GUI，单题 5 小时）、**ProgramBench**（linux/amd64 + 断网，$36/题）、**Terminal-Bench 4.0**（66 题 ×5 次，整轮 $634–7,334）。 |
| 用什么框架跑？ | 没有一个框架能通吃。**EvalScope 覆盖 6/11** 最省事；Inspect AI 覆盖 HLE/ZeroBench（Chartography 官方就是 Inspect 写法）；Harbor=TB4、Pier=DeepSWE、其余各有官方 runner。 |
| 本机能直接跑 DeepSeek-V4.1-Flash-1017 吗？ | **不能**。权重约 763B 参数（~0.76 TB），官方参考推理用 8 路张量并行。本地只能用小模型跑通管道，真分数走 API。 |

**推荐路线（个人/小团队）**：先跑档 0（0 元，验证管道）→ 档 1（$50–150，出可比较粗分数）→ 需要时再上档 2。详见第 6 节。

---

## 1. 模型卡上的 11 个基准是什么

模型卡对比表（自报值，原表还含 K3=Kimi K3、GLM-5.3、GPT-5.6 Sol、Opus 5 的对照列）：

| # | 基准 | 大类 | 一句话 | 模型卡 1017 | 上一个版本 |
| :-: | :-- | :-- | :-- | --: | --: |
| 1 | HLE（w/o tools） | 通用推理 | 百学科专家级闭卷问答 | 42.6（纯文本 44.0†） | 36.8（39.1†） |
| 2 | Terminal-Bench 4.0 | Agent | 容器终端里完成真实工程任务 | 42.3 | 31.2 |
| 3 | DeepSWE v1.1 | 代码修复 | 真实开源仓库里的原创长程改码 | 77.0 | 74.2 |
| 4 | ProgramBench | 代码生成 | 只看二进制+文档，从零重建整个程序 | 29.1 | 20.3 |
| 5 | NL2Repo-Bench | 仓库生成 | 自然语言规格 → 完整可安装 Python 库 | 68.2 | 65.4 |
| 6 | Automation-Bench v1.0.6 | Agent | 模拟 SaaS 里跨应用完成业务流程 | 60.5 | 54.8 |
| 7 | Agents' Last Exam | Agent | 真机上的长程职业工作（CLI+GUI） | 35.4 | 31.8 |
| 8 | Apex Bench v1.1 | Agent（存疑） | 未公开说明；只有模型卡这一行数字 | 72.1 | 64.6 |
| 9 | Chartography（w/tools） | 视觉 | 专业图表阅读（等值线、K 线、Bode 图…） | 83.0 | 78.9 |
| 10 | BabyVision（w/tools） | 视觉 | 婴儿级核心视觉推理（388 题） | 92.5 | 89.6 |
| 11 | ZeroBench-main（w/tools） | 视觉 | 高难多步「真看图」推理（100 题） | 51.0 | 49.0 |

> 说明：K3=Kimi K3。带 `w/tools` 的三项是**工具增强**口径（放入 Claude Code harness 跑），不是这三家基准的官方默认协议——见第 4.1 节，这是本报告最重要的一条。

---

## 2. 横向对比（自测视角）

| 基准 | 题量 | 数据公开 | 许可 | 指标 | 判分 | 官方 harness | 需 Docker/GPU | 自测难度 | DeepSeek 价量级① |
| :-- | --: | :-- | :-- | :-- | :-- | :-- | :-- | :-- | --: |
| HLE | 2,500（文本 2,158） | ✅ HF gated | MIT | Accuracy | LLM judge | `hle_eval` / Inspect | 否/否 | 🟢 易 | $25–80 |
| Terminal-Bench 4.0 | 66 | ✅ | Apache-2.0 | resolve rate（k=5 均值） | 容器内 verifier | Harbor（agent=claude-code） | 是/H100×3 题 | 🔴 难 | $634–7,334 |
| DeepSWE v1.1 | 113 | ⚠️ 题目公开，HF gated | Apache-2.0 | Pass@1 | 行为 verifier | Pier + mini-swe-agent | 是/否 | 🟡 中 | $27–1,515 |
| ProgramBench | 200 | ✅ | MIT | Resolved | 隐藏行为测试 | `programbench eval` | 是（linux/amd64）/否 | 🟡 中 | ~$7,300 |
| NL2Repo-Bench | 104 | ✅（无 LICENSE） | unknown | 平均测试通过率 | 上游 pytest | OpenHands 0.56 batch | 是/否 | 🔴 难 | $100–500（估） |
| Automation-Bench v1.0.6 | 600 公开（+200 simple） | ✅ | MIT | strict Pass rate | 程序化 end-state 断言 | `uv run auto-bench` | 否/否 | 🟢 易 | $15–60 |
| Agents' Last Exam v1.1 | 122 公开 | ⚠️ 完整数据需审批（39 GB） | Apache-2.0 + CC-BY-4.0 | passRate / avgScore | 隐藏 reference 确定性判分 | `ale_run` | 是/GPU 3 题 | 🔴 很难 | $100–1,000+ |
| Apex Bench v1.1 | 未公开 | ❌ | unknown | unknown | unknown | **无公开 runner** | — | ⛔ 不可行 | 无法估算 |
| Chartography | 100 | ⚠️ HF 当前 401 | unknown | mean pass@1 | LLM judge（Gemini 3.5 Flash） | 官方 Inspect task | 否/否 | 🔴 难（卡数据） | $10–40 |
| BabyVision | 388 | ✅ MIT | MIT | accuracy（Avg@3） | LLM judge | `babyvision_eval` | 否/否 | 🟢 易 | $5–25 |
| ZeroBench-main | 100（+334 子题） | ✅ HF gated | MIT | Pass@1/@5/^5 | 精确匹配（无 judge） | 无官方脚本；用 inspect_evals / VLMEvalKit / EvalScope | 否/否 | 🟢 易 | $5–15 |

① 按 2026-10-30 DeepSeek 官方价（deepseek-flash 谷时：输入 cache miss $0.15/M、输出 $0.6/M；峰时翻倍）粗估的**整轮** API 成本，含 judge 的话通常再加 20–100%，非报价。带 GPU/VM 的基准另有算力成本。

---

## 3. 逐项详解

### 3.1 HLE — Humanity's Last Exam（通用推理）

- **测什么**：数学、自然科学、人文等上百学科的专家级闭卷题，经多模型难度筛选，考深度推理与广博知识，而非检索。多选或精确短答，可直接自动判分。
- **数据**：HF `cais/hle`，**gated=auto**（需登录同意条款），MIT，2,500 题；其中 342 题含图（~14%），**纯文本子集 2,158 题**。官方另保留未公开 private held-out 集用于防过拟合。
- **口径**：模型卡 42.6 = 2,500 题全量（含图）；44.0† = 2,158 题纯文本子集。官方 `run_model_predictions.py` 默认 `temperature=0`，judge 默认 `o3-mini-2025-01-31`。
- **怎么跑**：`hle_eval` 两段式（预测 + judge），或 `inspect eval inspect_evals/hle`、EvalScope `--datasets hle`（纯文本加 `include_multi_modal=false`）。
- **成本**：全量估 $25–80（thinking 模型输出 1–3 万 tokens/题很常见）；judge 另计，建议按 $100 留量。
- **坑**：gated 数据集无授权 401；`max_completion_tokens` 别低于 8192；judge 版本/提示词一变分数就变；部分标准答案有误（HLE-Verified 有 668 题 gold 子集）；别声称能复现官方榜的泛化数字（held-out 未公开）。
- **建议**：个人自测首选「推理类」。先 50 题（约 $2–8）验证 judge，再放大。

### 3.2 Terminal-Bench 4.0（Agent / 终端）

- **测什么**：在容器化终端里完成真实工程任务（写代码、跑命令、调环境），覆盖软件、科学、ML、运维、安全、硬件、媒体。定位「连续基准」，每季度左右删/加题并重新校准。
- **版本**：v4.0.0（2026-08-26），66 题（3.0 的 74 题删 8、修 19–20 题）。**务必锁 `@4.0.0`**，版本间不可比。
- **数据**：任务/verifier/oracle 解都在 Harbor Hub + GitHub，Apache-2.0。
- **官方 harness**：Harbor（`harbor run -d terminal-bench/terminal-bench@4.0.0 -a <agent> -m <model> -k 5`）。模型卡说的「Claude Code harness」= Harbor 里 `-a claude-code`，不是另一个框架。
- **成本**：官方榜 330 trials 约 $634–$7,334；单 trial 平均 1,684–7,432 秒。
- **坑**：3 题需 H100、11 题多容器（本地 Docker 跑不全，官方推荐 `--env modal`）；8 小时/题超时；**Epoch AI 2026-09 复核认为 4.0.0 有 30/66 题存在奖励 hack、答案泄漏、假阴/假阳等评分缺陷（评为 Flawed）**——引用分数时必须带上这条。
- **建议**：最后再上。先用 `-a oracle` 验证沙箱，再抽 5–10 题只跑 k=1。

### 3.3 DeepSWE v1.1（代码修复 / SWE）

- **测什么**：真实开源仓库里的「原创、长程」工程改动（不是挖历史 PR），113 题、91 个仓库、TypeScript/Go/Python/JS/Rust 五语言；参考解代码量约为 SWE-Bench Pro 的 5.5 倍。
- **数据**：任务定义在 GitHub 公开；HF 数据集 `datacurve/deep-swe` 为 gated(auto)（轨迹/parquet）。
- **官方 harness**：`pier run -p deep-swe/tasks --agent mini-swe-agent --model <provider/model>`，v1.1 判分改为「提交 commit → 干净容器 apply → 跑行为 verifier」，**要求 `datacurve-pier > 0.3.0`**。
- **成本**：官方榜每任务 $0.24–$13.41（113 题约 $27–1,515）；小样本用 `--n-tasks 10 --sample-seed 0`（官方确定性抽样）。
- **坑**：HF 轨迹库 gated；首跑要拉大量任务镜像（磁盘/带宽）；模型卡写「Mini-SWE-V2 harness」而官方文档写 mini-swe-agent，**两者是否同一版本未核实**，跨来源比分数要注明。
- **建议**：最值得作为「代码 Agent 类」第一个自测对象：官方支持 10 题抽样，成本可控。

### 3.4 ProgramBench（代码生成 / 程序重建）

- **测什么**：只给编译后的二进制 + 文档，在无源码、禁反编译、禁联网的容器里从零重建整个程序（从 jq/ripgrep 到 FFmpeg/SQLite/PHP 解释器），200 个实例、24.8 万+ 条行为测试。
- **数据**：测试集 HF `programbench/ProgramBench-Tests`（MIT、非 gated）+ DockerHub `task_cleanroom_v6` 镜像 + GitHub `facebookresearch/ProgramBench`。
- **指标**：主指标 **Resolved**（该题全部隐藏测试通过），辅助 Almost resolved（≥95%）；判分是行为测试，不是 LLM judge。
- **成本**：官方榜平均 $36.36/题（Opus 5.5）→ 200 题约 $7.3k；单题上限 6 小时 / 1000 步 / 20 CPU / 60 GB。
- **坑**：镜像**只有 linux/amd64**（Windows 需 WSL2 或远程 Linux）；推理容器必须断网、二进制不可读；2026-10 公开提交入口还未开放。
- **口径警告**：模型卡 **29.1 与榜单主指标 Resolved（最高 18.5%）不是同一口径**，不可直接比。
- **建议**：想挑战端到端代码生成可以试单题（1 题 ≈ $36 + 算力），全量不现实。

### 3.5 NL2Repo-Bench（自然语言 → 完整仓库）

- **测什么**：只给一份约 18.8k tokens 的自然语言规格 + 空工作区，从 0 到 1 生成完整可安装 Python 库（104 题 / 9 类），用原仓库上游 pytest 判分（通过用例占比）。
- **数据**：GitHub `multimodal-art-projection/NL2RepoBench`（`test_files/` 任务、`workspaces/` 挂载、`docker_self/` 环境）；**无 LICENSE 文件**，再分发/商用需联系作者。
- **官方 harness**：`main.py` 驱动 OpenHands 0.56 headless 批量（需 `openhands:0.56` 与 `runtime:0.56-nikolaik` 两个镜像），`config.json` 填 baseUrl/sk/任务列表，`python main.py`。
- **坑**：只支持本地 Docker；单题**无轮数上限**、交互数百轮，极慢极贵；结果按 UUID 存 `result/`，没有汇总脚本要自己算。
- **建议**：性价比低，留到档 2；先只跑 1–2 题（如 aiofiles、math-verify）验证链路。

### 3.6 Automation-Bench v1.0.6（Agent / 业务流程）

- **测什么**：模拟 SaaS 环境里通过 REST API 完成跨应用业务流程（47 个模拟工具、约 500 端点），自己发现端点、遵守分层业务规则、处理干扰数据，最终状态正确才算通过。判分是**程序化 end-state 断言，无 LLM judge**。
- **数据**：GitHub `zapier/AutomationBench`（MIT），公开 600 题（6 域 ×100）+ simple 200 题（不计分，仅冒烟）。
- **官方 harness**：`uv sync` → `uv run auto-bench --model <model>`；支持 `--base-url/--api-key/--domains/--toolset/--max-steps`。
- **成本**：600 题估 $15–60（单题最多 50 步）；先 `--domains simple --num-examples 2` 冒烟。
- **坑**：**官方榜用的是私有 held-out 集（600+），本地公开集分数只能方向参考，永远对不上**；需 Python ≥3.13 + uv；工具风格（api/zapier/limited_zapier）与 reasoning effort 显著影响分数，必须固定。
- **建议**：最便宜的「多步工具调用」自测入口，适合无 Docker 环境。

### 3.7 Agents' Last Exam v1.1（Agent / 长程真机）

- **测什么**：真实职业工作的长程任务（数小时到数周人类工时），在 Windows/Linux 真机沙箱里同时用 CLI 与 GUI 操作专业软件；评分看产物是否达到隐藏 reference。
- **数据**：v1.1 公开基准 **122 个 active tasks**（Linux 86/Windows 36、CPU 119/GPU 3）；完整数据（含隐藏 reference）是单独的 HF data-archive，**gated=manual 需人工审批、约 39.2 GB**，条款禁止训练/暴露/再分发。
- **官方 harness**：`ale_run`（`uv run python -m ale_run run my_experiment.yaml`），需自备 VM/沙箱（GCloud/QEMU-KVM/本地 Docker 仅 78 题子集）。
- **成本**：API 估 $20–150，云 VM 另计 $50–300+；官方榜 totalCostUsd 为 null；单题 wall_time 示例 5 小时。
- **坑**：宿主安装脚本只支持 Ubuntu/Debian（Windows 需 WSL2/云 VM）；单题可达 5 小时；**模型卡 35.4 在官方 v1.1 榜上查不到 DeepSeek 行**（22 行/12 模型），口径未注明。
- **建议**：个人自测门槛最高，除有云预算和 Linux 机器，否则不建议碰。

### 3.8 Apex Bench v1.1（Agent，未公开）

- **状态**：截至 2026-10-30，唯一出处是 DeepSeek 模型卡一行「72.1」；无主页、论文、仓库、数据集、榜单。第三方聚合页只转引模型卡，并注明它与 MathArena Apex、Mercor APEX/APEX-Agents **不是同一个东西**。
- **结论**：**无法自测，也无法核验**。正式对比中应标 unknown。若官方后续发布，需重新核实数据/许可/harness。

### 3.9 Chartography（视觉 / 专业图表）

- **测什么**：专业图表阅读（稀疏坐标轴估读、等值线插值、Sankey 流线、投影 3D、领域惯例），100 题、12 专业领域，全部执业专家出题+3 人复核，51 题金标带专家可接受区间。
- **数据**：官方称已发布到 HF `surgeai/chartography`，但 2026-10-30 实测**匿名访问该 dataset 与 API 均 401**、HF 搜索无结果；GitHub 只有 harness + 2 个假任务（manifest 注明 not released dataset）。**当前拿不到真实 100 题**，需联系 benchmarks@surgehq.ai 或申请 HF 授权；许可 unknown。
- **官方协议**：Inspect AI task，no tools（论文明确禁止外网/工具/裁剪/放大），judge 固定 `gemini-3.5-flash` 且不看图；leaderboard 是 100 题 ×10 epochs。
- **口径警告**：模型卡 `83.0 (w/tools)` 是 Claude Code harness 口径，官方 no-tools 榜上 DeepSeek V4.1 Flash (Max reasoning) 只有 **11.6%**——两个数字不可比、也不可用官方脚本复现。
- **建议**：数据到手前不碰；只能跑 2 个假任务做链路冒烟。

### 3.10 BabyVision（视觉 / 核心视觉推理）

- **测什么**：不依赖语言先验的核心视觉能力：细粒度辨别、视觉追踪（迷宫/地铁图）、空间感知（3D 视图/折纸/数积木）、模式识别。388 题 / 22 子类 / 4 大类，号称 3 岁小孩可解，成人基线 94.1。
- **数据**：HF `UnipatAI/BabyVision`（**MIT、公开未 gated、388 条**）+ GitHub `data/babyvision_data.zip`（约 48 MB）。最友好。
- **指标/判分**：accuracy = Avg@3（3 次采样均值），LLM judge 判语义等价；`\boxed{答案}` 输出，choice 题输出选项字母。
- **怎么跑**：`babyvision_eval` 设 `MODEL_*`/`JUDGE_*` → `bash run_inference.sh` → `python compute_score.py`；替代：VLMEvalKit `--data BabyVision`。
- **成本**：模型侧约 $0.3–$1 + judge（DeepSeek 价）；全量 388×3≈1,164 次生成。
- **坑**：judge 必须固定（论文 Qwen3-Max，代码默认 gpt-5.2，换 judge 会改分）；模型卡 92.5 是 w/tools 口径，不可与官方 no-tools 榜直接比（官方榜另有各家「with tools」标注但协议不统一）。
- **建议**：**最推荐作为第一个视觉基准**。

### 3.11 ZeroBench-main（视觉 / 高难看图推理）

- **测什么**：对抗式筛选的高难多步看图题（象棋 FEN、菜单/地图读数、雪花体积估算…），答案空间大不可猜；发布时前沿模型 pass@1/pass^5 全 0。
- **数据**：HF `jonathan-roberts1/zerobench`，**gated(auto)**（需同意「不公开答案/不用于训练」，含 canary string），100 main + 334 subquestions（子题只用于诊断，不参与 Pass@5）。
- **指标**：`{final answer}` 精确匹配，无 LLM judge；Pass@1、**Pass@5（5 次采样至少 1 次答对）**、Pass^5。
- **怎么跑**：官方 repo 只有 README/参考代码（无评测脚本），推荐 `inspect eval inspect_evals/zerobench`（内置 pass@k）或 VLMEvalKit `--data ZEROBench` 或 EvalScope `--datasets zerobench`。
- **成本**：100×5=500 次调用，估 $0.1–1.7（DeepSeek 价）；官方榜给前沿模型 cost/question $0.010–$1.11。
- **坑**：HF gated；精确匹配很严格（格式/单位/有效数字错一点就算错）；Pass@5 必须 5 次采样；「minimal」不是 ZeroBench 子集（那是 DeepSeek Harness 的单 bash 工具模式，只用于 code agent）；模型卡 51.0 是 w/tools + 5 采样的自报值，官方 no-tools 榜 2026-10 最好 52.0（GPT-6 Astra），两者口径不同。
- **建议**：**性价比最高的自测基准**（不需要 judge、题量小、协议最可复现）。

---

## 4. 关键口径警告（决定你的数字有没有意义）

### 4.1 `w/tools` ≠ 官方协议，这是最大的坑

Chartography / BabyVision / ZeroBench-main 三项在模型卡带 `w/tools` 标注。DeepSeek 技术报告 §5.3.1 写明：视觉 agent 任务统一用 **Claude Code harness + 512k 上下文、temperature 1.0、top-p 0.95**，Chartography/BabyVision 报 Pass@1、ZeroBench-main 报 Pass@5。这意味着模型可以调 shell/文件工具（能写 Python 裁剪、放大、测量图片），而三家基准官方协议都是 **no-tools**。

后果：
- **官方脚本跑不出 w/tools 分**；Claude Code harness 的版本、system prompt、工具 schema 未公开，只能近似复现。
- 同一模型两套口径差距巨大：Chartography 官方 no-tools 榜 DeepSeek V4.1 Flash 只有 **11.6%**，模型卡 w/tools 写 **83.0**。
- 因此：**自测请只跑官方 no-tools 协议**，报告里明写「no-tools」；若要做工具增强对比，自己搭统一 harness 并注明。

### 4.2 私有 held-out 集：永远对不上官方榜

- HLE：官方另有未公开 private held-out 集。
- Automation-Bench：官方榜用私有 held-out 集（600+ 题），本地公开 600 题的分数只能方向参考。
- Agents' Last Exam：完整数据（含隐藏 reference）gated=manual，公开 122 题 ≠ 官网宣传的 1,500+ 题。
- 结论：**本地跑分和榜单分数的差异，先归因于数据集/协议，而不是模型能力**。

### 4.3 厂商自报 vs 第三方复现

模型卡 11 行里至少两行有明显异常或争议：ProgramBench 29.1 与官方榜主指标 Resolved（最高 18.5%）不可比；Terminal-Bench 4.0 v4.0.0 被 Epoch AI 复核出 **30/66 题评分缺陷**（Flawed）。引用模型卡数字时建议同时给出第三方复核状态。

### 4.4 版本必须锁死

| 对象 | 必须锁的版本 |
| :-- | :-- |
| Terminal-Bench | 数据集 `@4.0.0`（2026-08-26） |
| DeepSWE | `datacurve-pier > 0.3.0`（判分方式在 v1.1 变了） |
| ZeroBench | 数据 revision + 100 main 集（不是子题） |
| Automation-Bench | 仓库 `1.0.6` |
| Chartography | README 的 10 epochs 口径（论文是 20 trials，别混） |
| HLE | 2,500 定稿集 + 固定 judge（默认 o3-mini） |

### 4.5 采样参数不能一套跑所有基准

模型卡推荐 `temperature=1.0, top_p=1.0`（使用口径）；HLE 官方默认 `temperature=0`；ZeroBench 老模型用 `temperature=0.7, top_p=0.95`、Pass@5 需 5 次采样；Chartography 榜单 10 epochs；BabyVision 默认 Avg@3。**每套基准按官方配置，别统一改。**

---

## 5. 工具链怎么选

没有一个框架通吃 11 个。按「装一个就能跑几个」排序：

| 框架 | 覆盖本次基准 | 适合谁 | 关键点 |
| :-- | :-- | :-- | :-- |
| **EvalScope**（`pip install evalscope`） | 6/11：HLE、TB4（`terminal_bench_v4`）、DeepSWE（`deep_swe`）、Automation-Bench、BabyVision、ZeroBench | 想「一条命令 + OpenAI 兼容端点」快速出数的人 | 只认 `--api-url/--api-key`；TB4/DeepSWE 扩展要 Python≥3.12、Harbor≥0.14；DeepSWE 对不支持 Responses API 的端点要传 `pier_agent_kwargs={'model_class':'litellm'}` |
| **Inspect AI + inspect_evals** | HLE、ZeroBench（Chartography 官方代码本身就是 Inspect 写法） | 想要严谨日志/复现的实验派 | `inspect eval inspect_evals/hle`、`.../zerobench`；provider 支持 OpenAI/Anthropic/DeepSeek/vLLM/Ollama |
| **Harbor** | Terminal-Bench 4.0（官方） | 跑 TB4 的唯一正确入口 | 内置 40+ agent（claude-code/mini-swe-agent/codex…）；`--env modal` 上云；接自建模型用 `--base-url/--api-key-name/--api-format` |
| **Pier**（`datacurve-pier`） | DeepSWE v1.1（官方） | 跑 DeepSWE | 解决 air-gapped 任务里 agent 装不上的问题；不直接读 Harbor registry，要 `harbor download` 后 `-p` 指本地目录 |
| **VLMEvalKit** | BabyVision、ZEROBench（不支持 Chartography） | 只做视觉模型横评 | `python run.py --data <DATASET> --model <MODEL>`，需在 `config.py` 注册模型 |
| 官方 runner | ProgramBench、NL2Repo-Bench、ALE、Chartography、Automation-Bench | 对应单个基准 | 见第 3 节与 `report/runbook.md` |
| ~~lm-evaluation-harness~~ | **不支持这 11 个中的任何一个** | — | 多模态只有 mmmu 原型，官方建议改用 lmms-eval |
| ~~OpenAI simple-evals~~ | **不含这 11 个中的任何一个** | — | 2025-07 起停止更新 |

**自建/第三方模型接入要点**：
- Claude Code 只吃 **Anthropic Messages**；Harbor/Pier 的多数 agent 吃 **OpenAI Chat Completions**（部分支持 Responses）。
- 本地 vLLM 跑工具调用必须 `--enable-auto-tool-choice --tool-call-parser <匹配 chat template 的 parser>`；vLLM 也实现了 `/v1/messages`，可喂 Claude Code。
- thinking 模式会改采样行为；DeepSeek 多轮 tool call 要把 assistant 完整 content（含 thinking/tool_use）回传，否则可能 400。
- judge 是第二笔钱：HLE / ZeroBench / BabyVision / Chartography 都要 judge 调用（HLE 还要结构化输出能力）。

---

## 6. 三档自测路线

> 前提假设：Windows + Docker 29 + 无 GPU。完整命令见 `report/runbook.md` 与 `report/benchmarks.xlsx` 的「自测方案」页。

### 档 0：0 元本地小样本（1–2 天，验证管道，不出分数）

目标：确认「数据能下、Docker 能跑、判分能出、judge 能调」。模型侧用 Ollama 小模型/免费额度即可。

1. 装工具：`uv tool install harbor`、`pip install evalscope inspect-ai inspect-evals`、克隆 VLMEvalKit。
2. TB4 oracle 自检（不用模型）：`harbor run -d terminal-bench/terminal-bench@4.0.0 -a oracle -k 1 --n-concurrent 1`。
3. Chartography 离线链路：官方 2 个假任务 + `mockllm/model`，验证 Inspect 与 scorer。
4. HLE 10 题 + judge；ZeroBench 5 题；BabyVision 2–5 题；Automation simple 2 题。

### 档 1：一周 API 预算（$50–150，出可比较粗分数）

按便宜→贵、无 Docker→有 Docker 排序：**HLE（纯文本，先 50 题）→ ZeroBench-main → BabyVision → Automation-Bench（simple→sales）→ Chartography（拿到数据后 limit=10）→ DeepSWE 10 题 → TB4 5–10 题**。

### 档 2：完整复现（四位数预算起）

按官方 harness + 官方版本 + 官方 judge 跑全量，重点在「能解释与模型卡的差异」而不是追平。计划把 ProgramBench / NL2Repo / ALE 留到最后（见第 8 节）。

---

## 7. 本机环境适配（Windows / 无 GPU / Python 3.11）

| 限制 | 影响 | 对策 |
| :-- | :-- | :-- |
| Python 3.11（本机） | Harbor/Pier/ALE 要 ≥3.12 | `uv tool install`（uv 自带隔离 3.12），别动系统 Python |
| 无 GPU | 本地跑不了 763B 模型；TB4 的 3 题/Apex 等需 H100 | 真分数走 API（DeepSeek 有 OpenAI + Anthropic 双协议端点） |
| 镜像 linux/amd64 | ProgramBench 不能原生跑 | WSL2（慢）或租 Linux 云机 |
| ALE 需 Linux 宿主 + VM/GUI | Windows 跑不了 | WSL2/云 VM，或跳过 |
| HF gated 数据集 | HLE/ZeroBench/DeepSWE/Chartography(401) | 登录 + 同意条款；Chartography 需邮件申请 |
| Docker 资源 | TB4 多容器/GPU 任务、ProgramBench 20CPU/60GB | 先小样本；重活上云（`--env modal`） |

---

## 8. 成本估算与省钱技巧

- **先标定再放大**：跑 5–10 题，用 harness 输出的 token/耗时外推，agent 类基准 token 随轮数超线性增长，外推留 1.5–2× 冗余。
- **错峰**：DeepSeek 谷时输入 $0.15/M、输出 $0.6/M，峰时翻倍（峰=UTC 周一至周五 01:00–04:00、06:00–10:00）。
- **judge 别用贵模型**：HLE/ZeroBench/BabyVision/Chartography 的 judge 可自选（官方口径除外），但**必须固定**并在报告注明。
- **缓存**：多轮 agent 场景输入大量重复，cache hit 便宜 20–50 倍。
- **并发**：DeepSeek flash 并发上限 2,500；Harbor/Pier 用 `--n-concurrent`，本地 Docker 别开太高。
- **参考锚点**：DeepSWE 官方 $0.24–11.84/题；ZeroBench 官方 cost/question $0.010–1.11；TB4 整轮 $634–7,334。

---

## 9. 结果怎么记（建议的报告模板）

跑完至少记录这 10 项，否则数字不可比：

```
基准/版本：      例如 Terminal-Bench 4.0 (v4.0.0)
数据集：         来源 + 版本/revision + 是否私有 held-out
模型与接口：      模型名/版本 + endpoint 协议（OpenAI/Anthropic）
harness：        名称 + 版本（Harbor 0.25.0 / Pier 0.3.1 / ...）
agent/scaffold：  claude-code / mini-swe-agent + 版本
采样参数：       temperature / top_p / max_tokens / reasoning effort
judge：          模型 + 版本 + prompt 版本（若用 judge）
重复次数：       k / epochs / Pass@5 的 5 次采样
指标口径：       Resolved / Pass@1 / passRate / Avg@3 ...（写清定义）
成本与耗时：     总 token、总费用、墙钟时间、并发
```

**对比原则**：只和「同版本 + 同 harness + 同 judge + 同采样」的数字比；模型卡数字只能作为参考，且要标注它是自报/第三方复核状态。

---

## 10. 局限与待核实项

1. **Apex Bench v1.1**：无官方来源，只有模型卡一行数字；第三方明确它不是 MathArena Apex / Mercor APEX。
2. **「Mini-SWE-V2」**：DeepSeek 新闻的叫法；PyPI 上是 `mini-swe-agent` 2.4.6，是否同一版本/config 未核实。
3. **Harbor/Pier 接 DeepSeek 端点的确切 slug 与参数组合**：未实测。
4. **Chartography HF 数据**：当前匿名 401，是否 gated / 需申请未知。
5. **HLE 纯文本子集题量（2,158）**：来自 inspect_evals 文档，DeepSeek 模型卡未给。
6. **VLMEvalKit 的 `--data` 名称字符串**：类名已确认，具体参数以 `run.py --help` 为准。
7. **vLLM 对 V4.1-Flash-1017 的支持**：官方只给自有 reference inference（MP=8），未列 vLLM。
8. **所有 setup 命令均未在本机执行**：`research/` 里标了 `# TODO verify`；首次运行请小样本试。

---

## 11. 参考来源（分组）

- **模型卡/官方发布**：<https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash-1017>、<https://api-docs.deepseek.com/news/news261017>、<https://api-docs.deepseek.com/quick_start/pricing>、技术报告 `DeepSeek_V41_Tech_Report.pdf`（§5.3.1 视觉 agent 口径）
- **HLE**：<https://lastexam.ai>、<https://arxiv.org/abs/2501.14249>、<https://github.com/centerforaisafety/hle>、<https://huggingface.co/datasets/cais/hle>
- **Terminal-Bench**：<https://www.tbench.ai/>、<https://github.com/harbor-framework/terminal-bench>、Harbor 文档、<https://epoch.ai/benchmarks/terminal-bench-4/review>
- **DeepSWE**：<https://deepswe.datacurve.ai/>、<https://github.com/datacurve-ai/deep-swe>、<https://github.com/datacurve-ai/pier>、<https://arxiv.org/abs/2607.07946>
- **ProgramBench**：<https://programbench.com/>、<https://github.com/facebookresearch/ProgramBench>、<https://huggingface.co/datasets/programbench/ProgramBench-Tests>
- **NL2Repo-Bench**：<https://github.com/multimodal-art-projection/NL2RepoBench>、<https://arxiv.org/abs/2512.12730>
- **Automation-Bench**：<https://github.com/zapier/AutomationBench>、<https://zapier.com/benchmarks>、<https://arxiv.org/abs/2604.18934>
- **Agents' Last Exam**：<https://agents-last-exam.org>、<https://github.com/rdi-berkeley/agents-last-exam>、<https://arxiv.org/abs/2606.05405>
- **Chartography**：<https://surgehq.ai/benchmarks/chartography>、<https://github.com/surge-ai/chartography>、<https://arxiv.org/abs/2608.10677>、HF `surgeai/chartography`（401）
- **BabyVision**：<https://unipat.ai/benchmarks/BabyVision>、<https://github.com/UniPat-AI/BabyVision>、<https://huggingface.co/datasets/UnipatAI/BabyVision>、<https://arxiv.org/abs/2601.06521>
- **ZeroBench**：<https://zerobench.github.io>、<https://github.com/jonathan-roberts1/zerobench>、<https://huggingface.co/datasets/jonathan-roberts1/zerobench>、<https://arxiv.org/abs/2502.09696>、inspect_evals
- **框架**：EvalScope、Inspect AI（<https://inspect.aisi.org.uk>）、Harbor、Pier、mini-swe-agent、VLMEvalKit、lm-evaluation-harness、OpenAI simple-evals

---

## 附录：本目录文件

| 文件 | 内容 |
| :-- | :-- |
| `report/benchmark-guide.md` | 本文（总报告） |
| `report/benchmark-suite-analysis.md` | 6 模型 × 11 基准的测试集分析与分数解读（2026-11-01，含可信度分级、口径陷阱、名次热力图） |
| `report/opencompass-offline-bundle.md` / `report/eval-toolchain-offline.md` / `report/eval-tools-offline-bundle.md` | 辅助工具（不属于 11 基准）：OpenCompass 离线对比包（808 MB）、五家评测/观测工具离线可行性对比、DeepEval + Langfuse 离线工具包（1.3 GB） |
| `report/benchmarks.xlsx` | 11 个基准结构化对比表（含 Harness 清单、三档方案、来源页） |
| `report/runbook.md` | 每个基准的复现命令清单（自动生成） |
| `report/benchmarks.csv` / `report/all_benchmarks.json` | 机读数据 |
| `research/` | 4 份调研原始产出（JSON + 中文笔记，含逐条来源与坑） |
| `scripts/` | 合并校验、runbook 生成、xlsx 生成脚本 |
