# 复现命令清单（Runbook）

> 自动生成自 `report/all_benchmarks.json`。所有命令来自调研阶段核实的官方文档，**均未在本机实际执行**，涉及具体 provider/model slug 的命令请先小样本试跑。

> 通用前提：Harbor / Pier / ALE 需要 Python ≥ 3.12（用 `uv tool install` 隔离）；Docker 需运行中；模型侧建议使用 OpenAI 兼容端点或 Anthropic Messages 端点。


## 通用推理

### Humanity's Last Exam (HLE, finalized at 2,500 questions)

- **测什么**：覆盖数学、自然科学、人文等上百个学科的专家级闭卷问答，题目经多模型难度筛选，要求深度推理与广博知识，而非检索。题目为多选或精确短答，可直接自动判分。
- **数据**：公开；题量 2500；许可 MIT (dataset card); paper CC BY 4.0
- **数据入口**：https://huggingface.co/datasets/cais/hle
- **指标/判分**：准确率 Accuracy（另报 RMS calibration error）；judge=LLM-judge
- **官方 harness**：hle_eval：run_model_predictions.py 采样 + run_judge_results.py 判分；默认 judge 模型 o3-mini-2025-01-31
- **自测难度**：easy；快速子集：纯文本子集抽 50 题（官方脚本 --max_samples 50；或 Inspect 的 --limit 50）
- **整轮成本**：粗估 $25–$80（纯文本 2,158 题；假设平均 2k 输入 + 15–30k 输出 tokens/题，deepseek-flash 非高峰价；判分调用另计，建议按 $100 留量）；耗时：粗估 2–8 小时（2,158 题，并发 20–50；DeepSeek API 并发上限 2,500）。未实测。

命令：

```bash
git clone https://github.com/centerforaisafety/hle.git
cd hle
pip install -r requirements.txt
# TODO verify：数据集为 gated=auto，需先登录 HF 并同意条款（huggingface-cli login 或设置 HF_TOKEN）
cd hle_eval
python run_model_predictions.py --dataset cais/hle --model <your-model-name> --max_completion_tokens 8192 --num_workers 20 --max_samples 50
python run_judge_results.py --dataset cais/hle --predictions hle_<your-model-name>.json --num_workers 20 --judge o3-mini-2025-01-31
```

坑：1) 数据集 gated=auto，无 HF 授权直接 401；2) 模型卡 42.6 / 44.0† 的 † 指纯文本子集：44.0 是 2,158 题口径，42.6 才是 2,500 题全量（含 342 道带图题）；3) 官方 judge 默认 o3-mini，judge 版本/提示词变化会影响分数，自测分数与官方榜不可直接横比；4) max_completion_tokens 不要低于 8192，否则容易模型塌缩；5) 训练语料污染：题目带 BIG-bench 系 canary 串，商用模型可能已见过；6) HLE-Verified 审计发现部分标准答案有误（668 题 gold 子集），自测误差需考虑；7) 官方只公开 2,500 题，另有未公开 held-out 集，别声称能复现官方榜的泛化数字。

官方来源：
- <https://lastexam.ai>
- <https://arxiv.org/abs/2501.14249>
- <https://github.com/centerforaisafety/hle>
- <https://huggingface.co/api/datasets/cais/hle>
- <https://huggingface.co/datasets/cais/hle>
- <https://raw.githubusercontent.com/centerforaisafety/hle/main/hle_eval/run_judge_results.py>


## 代码修复（SWE）

### DeepSWE v1.1

- **测什么**：在真实开源仓库里完成「原创、长程」的工程改动：不是挖历史 PR 修复，而是从零编写、未回贡给上游的任务，参考解平均触及的代码量约为 SWE-Bench Pro 的 5.5 倍。重点考察定位、跨文件修改与验证能力。
- **数据**：部分公开；题量 113；许可 Apache-2.0（代码仓库）；HF 数据集卡片未标 license=unknown
- **数据入口**：任务定义公开在 GitHub：https://github.com/datacurve-ai/deep-swe（tasks/ 目录，含 task.toml、instruction.md、environment/Dockerfile、tests/）；HF 数据集 https://huggingface.co/datasets/datacurve/deep-swe 为 gated(auto)，需登录接受条款
- **指标/判分**：Pass@1（binary reward；另报 pass fraction、out tokens、steps、avg cost）；judge=unit-tests
- **官方 harness**：Pier + mini-swe-agent：pier run -p deep-swe/tasks --agent mini-swe-agent --model <provider/model>（v1.1 需 datacurve-pier > 0.3.0）
- **自测难度**：medium；快速子集：pier run -p deep-swe/tasks --agent mini-swe-agent --n-tasks 10 --sample-seed 0（官方提供的确定性抽样）；或单题 -p deep-swe/tasks/<task-id>
- **整轮成本**：113 题单轮约 $27–$1,515（按官方每任务平均成本 $0.24–$13.41 × 113；未含重试）；耗时：unknown（官方未给总时长；榜单有 avg steps 29–166）

命令：

```bash
# TODO verify（以下命令引自官方 Run 页与仓库 README，未在本机执行）
git clone https://github.com/datacurve-ai/deep-swe
uv tool install datacurve-pier   # v1.1 独立 verifier 环境要求 Pier > 0.3.0
export ANTHROPIC_API_KEY=...     # 换成实际 provider key
pier run -p deep-swe/tasks --agent mini-swe-agent --model anthropic/claude-opus-4-8
pier run -p deep-swe/tasks --agent mini-swe-agent --n-tasks 10 --sample-seed 0
```

坑：① HF 数据集 gated(auto)，要 HF 账号接受条款才能拿 parquet/轨迹，但任务定义在 GitHub 公开，理论上可绕过 HF；② v1.1 判分改为「独立干净容器 + [[verifier.collect]] 取 commit」，必须 Pier > 0.3.0，旧版会判错；③ 首跑需拉取各任务预构建镜像（Docker 空间/带宽大，有文档提到预拉 ECR 镜像）；④ 官方模型卡写 Mini-SWE-V2 harness、官方文档用 mini-swe-agent，口径不一致，跨来源比分数时要注明；⑤ 成本差异极大（$0.24–$13.41/题），先跑 10 题估算。

官方来源：
- <https://deepswe.datacurve.ai/run>
- <https://deepswe.datacurve.ai/data/v1.1>
- <https://deepswe.datacurve.ai/blog/deepswe-v1-1>
- <https://raw.githubusercontent.com/datacurve-ai/deep-swe/main/README.md>
- <https://raw.githubusercontent.com/datacurve-ai/deep-swe/main/LICENSE>
- <https://huggingface.co/api/datasets/datacurve/deep-swe>


## 自然语言 → 代码/仓库

### NL2Repo-Bench

- **测什么**：只给一份自然语言需求文档和一个空工作区，要求从 0 到 1 生成完整、可安装的 Python 库：自己做架构、依赖管理、多模块实现与打包。用原仓库的上游 pytest 套件判分，是少见的「长程 + 可执行验证」仓库生成基准。
- **数据**：公开；题量 104；许可 unknown（仓库无 LICENSE 文件，GitHub API license=null；arXiv 论文为 arXiv 非独占许可）
- **数据入口**：https://github.com/multimodal-art-projection/NL2RepoBench（test_files/ 为任务数据，workspaces/ 为 Docker 挂载，docker_self/ 为评测环境；未发现独立 HF 数据集）
- **指标/判分**：average test pass rate（0–100%；论文另报 Pass@1 count 与难度/类别分组）；judge=unit-tests
- **官方 harness**：仓库自带 main.py 驱动 OpenHands 0.56 headless 批量跑（config.json 配模型端点与任务列表，python main.py）；结果存 result/<uuid>.json
- **自测难度**：hard；快速子集：把 config.json 的 proNameList 只留 1–2 个任务（如 aiofiles、math-verify），max_pool_size 调成 1–2，先跑通整条链路
- **整轮成本**：unknown（无官方数据；按 104 题 × 长程多轮估计，属四个基准中单题最贵的量级之一，建议先跑 1–2 题）；耗时：unknown（论文提到模型交互数百轮、无轮数上限；仓库支持 max_pool_size 并发，默认示例 30）

命令：

```bash
# TODO verify（以下命令引自仓库 readme/requirements，未在本机执行）
git clone https://github.com/multimodal-art-projection/NL2RepoBench
pip install -r requirements.txt   # 依赖：openhands、python_on_whales、socketio、pydantic
docker pull docker.all-hands.dev/all-hands-ai/openhands:0.56
docker pull docker.all-hands.dev/all-hands-ai/runtime:0.56-nikolaik
# 编辑 config.json 填 baseUrl/sk/proNameList 后：
python main.py
```

坑：① 只支持本地 Docker（python-on-whales 管理容器），多机要共享文件系统（NFS）或手工搬文件；② 必须预置 openhands:0.56 与 runtime:0.56-nikolaik 两个镜像，版本不匹配会跑不起来；③ 无 LICENSE 文件，再分发/商用前需联系作者；④ 单题无轮数上限、交互数百轮，非常慢且贵，不适合全量自测；⑤ 结果按随机 UUID 存 result/，官方没给汇总脚本，要自己算平均通过率。

官方来源：
- <https://raw.githubusercontent.com/multimodal-art-projection/NL2RepoBench/main/readme.md>
- <https://raw.githubusercontent.com/multimodal-art-projection/NL2RepoBench/main/main.py>
- <https://raw.githubusercontent.com/multimodal-art-projection/NL2RepoBench/main/config.json>
- <https://raw.githubusercontent.com/multimodal-art-projection/NL2RepoBench/main/requirements.txt>
- <https://api.github.com/repos/multimodal-art-projection/NL2RepoBench>
- <https://arxiv.org/abs/2512.12730>

### ProgramBench

- **测什么**：只看编译后二进制 + 文档，在无源码、禁反编译、禁联网的容器里从零重建整个程序：自己选语言、做架构、写全部源码和构建脚本，最终行为要与原程序一致。测的是端到端软件设计与实现能力，而不是补丁或单文件生成。
- **数据**：公开；题量 200；许可 MIT（GitHub 仓库 LICENSE 与 HF 测试集均标 MIT）
- **数据入口**：测试集（MIT）：https://huggingface.co/datasets/programbench/ProgramBench-Tests ；运行镜像（tag task_cleanroom_v6）：https://hub.docker.com/orgs/programbench/repositories ；代码/评测 CLI：https://github.com/facebookresearch/ProgramBench
- **指标/判分**：Resolved（该题全部测试通过的比例，主指标）；辅助 Almost resolved（≥95% 测试通过）与平均测试通过率；judge=unit-tests
- **官方 harness**：programbench eval /path/to/run（uvx programbench 或 pip 安装后）；推理基线用 mini-extra programbench（mini-swe-agent）
- **自测难度**：medium；快速子集：先跑 1 个任务：Docker 镜像命名形如 programbench/<owner>_1776_<project>.<hash>:task_cleanroom_v6（2026-10-31 实测 ajeetdsouza_1776_zoxide.67ca1bc 可拉取，约 4.2GB）；任务/测试数据从 HF programbench/ProgramBench-Tests 获取，提交 submission.tar.gz 后 programbench eval 单实例目录
- **整轮成本**：平均 $36.36/题（Opus 5.5）→ 200 题约 $7.3k；官方 FAQ 称个别 run 总成本达 $5k；耗时：unknown（官方未给；单题允许较长步数/时间，几乎不受 step 限制）

命令：

```bash
# TODO verify（以下命令引自官方 README/docs，未在本机执行）
uvx programbench --help
uv tool install programbench   # 或 pip install programbench / uv pip install programbench
uv run programbench eval /path/to/my-amazing-agent-run
uv run programbench blob sync   # 预下载 HF 上的测试 blob（可选）
```

坑：① 所有镜像只构建 linux/amd64，Windows/macOS 不能原生跑（QEMU 模拟很慢），需 WSL2 或远程 Linux；② 推理容器必须断网，二进制只可执行不可读（objdump/strings/hexdump 会失败）；③ 每题平均 API 成本高（Opus 5.5 $36/题，200 题约 $7k）；④ eval 会按需拉 Docker 镜像和 HF 测试 blob，磁盘/带宽消耗大；⑤ 2026-10 时公开提交入口尚未开放（coming soon）；⑥ 镜像名不是 ffmpeg__ffmpeg.360a402 这种格式，需从 Docker Hub programbench 组织（每页 100 个、共 200 个）或 HF 实例列表取真实实例名；单任务镜像实测约 4.2GB（ajeetdsouza_1776_zoxide.67ca1bc），离线打包 5 题约 21GB。

官方来源：
- <https://programbench.com/>
- <https://raw.githubusercontent.com/facebookresearch/ProgramBench/main/README.md>
- <https://raw.githubusercontent.com/facebookresearch/ProgramBench/main/docs/README.md>
- <https://raw.githubusercontent.com/facebookresearch/ProgramBench/main/LICENSE>
- <https://huggingface.co/api/datasets/programbench/ProgramBench-Tests>
- <https://hub.docker.com/v2/repositories/programbench/>


## Agent / 自动化

### Agents' Last Exam (ALE v1.1)

- **测什么**：真实职业工作的长程（数小时到数周人类工时）多步任务：在 Windows/Linux 真机沙箱里同时用 CLI 与 GUI（Generalist CUA-agents），完成专业软件工作流；评分只看留下的产物是否达到隐藏 reference，确定性 grader 打 0–1 分。
- **数据**：部分公开；题量 122；许可 代码 Apache-2.0；数据 CC-BY-4.0
- **数据入口**：https://huggingface.co/datasets/agents-last-exam/agents-last-exam
- **指标/判分**：Pass rate（每题满分 1.0 算通过）+ 平均部分分 avgScore（0–1）；judge=unit-tests（任务内 evaluate() 对隐藏 reference 的确定性判分；部分任务含 text/image judge，可配置 JUDGE_*）
- **官方 harness**：ale_run：uv run python -m ale_run run my_experiment.yaml（先 --dry-run 检查）
- **自测难度**：hard；快速子集：先跑 hello_both 示例任务；再选 Docker 子集 78 题或 CPU 子集 119 题做小规模（如 5–10 题）试跑
- **整轮成本**：API 粗估 $20–$150；云 VM/沙箱成本另计（可能 $50–$300+，取决于机型、时长与并发）。官方榜 totalCostUsd 字段为 null，无法直接引用；ALE 博客给过 frontier agent 每题约 $1.33–$15.70 的参考值；耗时：官方榜全量 122 题的 totalDurationS 汇总约 8.8 万–56.4 万秒（≈24–157 小时 agent 执行时间）；实际墙钟取决于并发（并发 8 → 约 8–20 小时），另加 VM 启动/判分。单题 agent 预算示例 wall_time_s: 18000（5 小时）。

命令：

```bash
# 宿主机需 Ubuntu 22.04/24.04/26.04 或 Debian 12/13（Windows 需 WSL2/云 VM），以下在 Linux 上执行
git clone https://github.com/rdi-berkeley/agents-last-exam.git
cd agents-last-exam
bash env/install_host_deps.sh
uv sync --all-packages --locked
bash env/verify_host_env.sh
cp -n secret/.env.example secret/.env
cp example_exp.yaml my_experiment.yaml
# 按所选 provider（GCloud/QEMU/Docker）填 secret/.env 与 my_experiment.yaml；Docker 还需申请 data-archive 权限并下载约 39GB 数据
uv run python -m ale_run run my_experiment.yaml --dry-run
uv run python -m ale_run run my_experiment.yaml
```

坑：1) 完整数据（含隐藏 reference）是 gated=manual，需要人工审批，且条款禁止训练/评测中暴露/再分发；2) 宿主机安装脚本只支持 Ubuntu/Debian（Windows 本机不能直接跑，需 WSL2 或云 VM）；3) 需要真实 VM/沙箱：GCloud 推荐，QEMU/KVM 需 Linux+KVM，Docker 仅 78 题子集；4) 3 个 GPU 任务需要 Windows GPU 镜像；5) 单题预算可达 5 小时，全量 122 题是数十小时级 + 云成本；6) 模型卡 35.4 在官方 v1.1 leaderboard（2026-10-30）上查不到 DeepSeek 行（22 行/12 个模型，最高 pass 45.9%），口径/harness 未注明，不能当作官方榜数字；7) 公开集 122 题 ≠ 官网宣传的 1,500+ 题，别把 35.4 直接归因到 122 题或全量。

官方来源：
- <https://agents-last-exam.org>
- <https://arxiv.org/abs/2606.05405>
- <https://github.com/rdi-berkeley/agents-last-exam>
- <https://raw.githubusercontent.com/rdi-berkeley/agents-last-exam/main/README.md>
- <https://raw.githubusercontent.com/rdi-berkeley/agents-last-exam/main/docs/releases/v1.1.md>
- <https://huggingface.co/api/datasets/agents-last-exam/agents-last-exam>

### Apex Bench v1.1

- **测什么**：官方未公开说明。第三方聚合站 open-llm-radar 将其归类为 'Multimodal Agents'（视觉界面感知+操作的 agent 基准），但这并非官方描述，未获证实。
- **数据**：不公开；题量 0；许可 unknown
- **数据入口**：unknown
- **指标/判分**：unknown（模型卡只报 72.1，未说明单位/口径）；judge=unknown
- **官方 harness**：unknown
- **自测难度**：infeasible；快速子集：none（无公开数据/代码）
- **整轮成本**：unknown（无公开数据，无法估算）；耗时：unknown

命令：

```bash
# no public setup found as of 2026-10-30
```

坑：1) 只有厂商自报，无法复现、无法核验判分方式；2) 不要与 MathArena Apex、Mercor APEX/APEX-Agents 混淆（第三方页面明确说 Apex Bench v1.1 distinct from both；llm-stats 的 'Apex' 也是另一个 reasoning 榜）；3) 若官方后续发布，需重新核实数据、许可与 harness；在此之前正式对比中应标 unknown。

官方来源：
- <https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash-1017>
- <https://phaseo.app/zh-Hans/benchmarks/apex-bench-v1.1>
- <https://open-llm-radar.com/benchmarks/apexbench>

### AutomationBench v1.0.6

- **测什么**：在模拟的 SaaS 环境里通过 REST API 完成跨应用业务流程（CRM、邮箱、日历、Slack、财务等 47 个模拟工具、约 500 个端点）：自己发现正确端点、遵守分层业务规则、处理干扰/误导数据，最终把正确数据写进正确系统。
- **数据**：公开；题量 600；许可 MIT（代码与公开任务数据；LICENSE 含第三方 API schema 说明）
- **数据入口**：https://github.com/zapier/AutomationBench
- **指标/判分**：Pass rate（严格通过率）；另有 partial_credit 0–1 作为诊断/训练信号；judge=unit-tests（程序化 end-state 断言，无 LLM judge）
- **官方 harness**：仓库自带 CLI：uv run auto-bench --model <model>（工具风格 --toolset api|zapier|limited_zapier）
- **自测难度**：easy；快速子集：5 题冒烟：--num-examples 5；单域 100 题：--domains sales
- **整轮成本**：粗估 $20–$100（600 题 × 平均约 30 步 × 每步约 10–20k 输入 tokens + 少量输出，按 deepseek-flash 非高峰价；缓存命中时更低）。未实测，建议先跑 20–50 题用 harness 统计外推；耗时：粗估 3–10 小时（600 题，--max-concurrent 默认 100；单题最多 50 步）。

命令：

```bash
git clone https://github.com/zapier/AutomationBench.git
cd AutomationBench
uv sync
export OPENAI_API_KEY=<your-key>
uv run auto-bench --model <model-name> --num-examples 5 --domains sales
uv run auto-bench --model <model-name> --base-url <openai-compatible-endpoint> --api-key <key> --input-cost <usd-per-token> --output-cost <usd-per-token>
```

坑：1) 需要 Python >=3.13（pyproject 指定）与 uv；2) 公开 600 题 ≠ 官方榜私有 held-out 集，本地分数只能作方向性参考（官方也这么声明）；3) 模型卡 60.5 与 README 公开集上 Opus 5 50.3 / Kimi K3 46.67 / GPT-5.6 Sol 45.83 数字吻合，推测模型卡用的是公开 600 题自跑口径，而官方榜用私有集，两者不可混比；4) 工具风格（api / zapier / limited_zapier）与 reasoning effort 显著影响分数，必须固定配置；5) 单题 50 步上限可能截断长流程；6) third-party llm-stats 的 v1.0.6 榜是 0–1 分且只有 6 个模型，与模型卡口径不同。

官方来源：
- <https://github.com/zapier/AutomationBench>
- <https://raw.githubusercontent.com/zapier/AutomationBench/main/README.md>
- <https://raw.githubusercontent.com/zapier/AutomationBench/main/pyproject.toml>
- <https://raw.githubusercontent.com/zapier/AutomationBench/main/LICENSE>
- <https://arxiv.org/abs/2604.18934>
- <https://zapier.com/benchmarks>

### Terminal-Bench 4.0 (v4.0.0)

- **测什么**：在容器化终端环境里完成真实工程任务：写代码、跑命令、改文件、调试环境，覆盖面从软件工程到科学计算、ML、运维、安全、硬件与媒体。官方把它定位为「连续基准」，每季度左右删题/加题并重新校准资源，用语义化版本号区分「重跑/重判/可复用」。部分任务需要 GPU。
- **数据**：公开；题量 66；许可 Apache-2.0（GitHub 仓库 LICENSE）
- **数据入口**：数据集（含 tasks/verifiers/solutions）：https://hub.harborframework.com/datasets/terminal-bench/terminal-bench/4 ；代码与发布包：https://github.com/harbor-framework/terminal-bench/releases/tag/v4.0.0
- **指标/判分**：resolve rate（66 题通过率；官方榜单为 5 次运行平均 + 95% CI）；judge=unit-tests
- **官方 harness**：Harbor：harbor run -d terminal-bench/terminal-bench@4.0.0 -e modal -a <agent> -m <model> -k 5
- **自测难度**：hard；快速子集：先用 --agent oracle 跑单题验证 sandbox 环境是否正常，再抽 5–10 题、只跑 1 次；GPU 题需要 GPU sandbox（官方用 Modal，Daytona 也支持 GPU）
- **整轮成本**：整轮（5×66 trials）约 $634–$7,334（2026-10 榜单不同模型；Opus 5.5 max 为 $4,718.65）；耗时：单 trial 平均约 1,684–7,432 秒（榜单数据）；官方用 Modal 高并发，整轮现实耗时约数小时，取决于并发与 GPU 配额

命令：

```bash
# TODO verify（以下命令引自官方 Run 页，未在本机执行）
uv tool install 'harbor[modal]'
harbor run -d terminal-bench/terminal-bench@4.0.0 -e modal -a claude-code -m anthropic/claude-sonnet-5 -k 5
harbor view jobs
```

坑：① 有 GPU 任务，普通无 GPU 的 Docker 跑不全；② 官方榜单是 66 题 × 5 次，闭源 frontier 整轮 $0.6k–$7k；③ Epoch AI 2026-09 复核认为 4.0.0 有 30/66 题存在奖励 hack、答案泄漏、假阴/假阳等评分缺陷（评为 Flawed）；④ 单题超时上限 8 小时；⑤ 连续基准版本更新快，必须锁 4.0.0，否则结果不可比。

官方来源：
- <https://www.tbench.ai/>
- <https://www.tbench.ai/run>
- <https://www.tbench.ai/news/terminal-bench-4-0>
- <https://raw.githubusercontent.com/harbor-framework/terminal-bench/main/README.md>
- <https://raw.githubusercontent.com/harbor-framework/terminal-bench/main/LICENSE>
- <https://api.github.com/repos/harbor-framework/terminal-bench/releases>


## 多模态视觉

### BabyVision (v2, 2026-07)

- **测什么**：测不依赖语言先验的核心视觉能力：细粒度辨别（找不同/找相同/找阴影）、视觉追踪（迷宫、地铁图、连线）、空间感知（3D 视图、立方体展开、折纸、数积木）、视觉模式识别（逻辑/旋转/镜像/叠加/补全）。题目号称 3 岁小孩可解，但前沿 MLLM 远低于人类（成人基线 94.1；2026-01 最强 Gemini3-Pro-Preview 49.7）。
- **数据**：公开；题量 388；许可 MIT
- **数据入口**：https://huggingface.co/datasets/UnipatAI/BabyVision
- **指标/判分**：accuracy（论文为 Avg@3：3 次随机 pass 的均值±std；代码 NUM_PASSES 默认 3）；judge=LLM-judge
- **官方 harness**：官方 babyvision_eval：python evaluate_model.py（run_inference.sh 包装）→ python compute_score.py 聚合；数据+代码在 GitHub
- **自测难度**：easy；快速子集：抽 30–50 题、NUM_PASSES=1 跑一遍（约 1 分钟级至十几分钟，取决于 API）；全量 388 题 × 3 passes ≈1164 次生成 + 1164 次 judge。
- **整轮成本**：unknown（官方未给。估算公式：388 题 × 3 passes ≈1164 次模型调用 + 1164 次 judge 调用；按你的模型单价 × token 用量 + judge 费用）；耗时：unknown（官方 NUM_PROCESSES 默认 8，全量 1164 次生成，API 并发下粗估 1–3 小时，属估算）

命令：

```bash
# TODO verify 以下命令摘自官方 README/babyvision_eval/README，未在本机执行（需 API key）
git clone https://github.com/UniPat-AI/BabyVision && cd BabyVision
unzip data/babyvision_data.zip -d data/
pip install -r requirements.txt
cd babyvision_eval
export MODEL_API_KEY=<key> MODEL_BASE_URL=https://openrouter.ai/api/v1 MODEL_NAME=<model>
export JUDGE_API_KEY=<key> JUDGE_BASE_URL=https://openrouter.ai/api/v1 JUDGE_MODEL_NAME=openai/gpt-5.2
bash run_inference.sh
python compute_score.py results/model_results_run_*.json
```

坑：（1）judge 很关键：论文用 Qwen3-Max 作 judge（自称与人工 100% 一致），官方代码默认 openai/gpt-5.2；换便宜 judge 会改变分数，务必固定 judge 模型与版本。（2）指标是 Avg@3（NUM_PASSES 默认 3），单跑 1 次和榜单不可比。（3）模型卡 BabyVision (w/tools) 92.5 不是官方默认协议：官方 protocol 无工具；模型卡/技术报告用 Claude Code harness + 512k context（DeepSeek-V4.1 技术报告 §5.3.1，Table 3 以 Pass@1 报 BabyVision w/tools）；官方 leaderboard 另有标注 “(with tools)”/“(with Python tools)” 的提交（例：Qwen3.8-Max w/tools 91.3 vs 无工具 82.0；Kimi K3 with Python tools 85.7），各家工具集不同，分数不可直接横比。（4）答案有 blank/choice 两种，choice 要输出选项字母（A/B/C…），格式错了会被 judge 判错。（5）MIT 许可，数据可自由下载，但代码仓库 README 写 “released for research purposes”。（6）图片是谜题类，模型必须先“看清图”，thinking 模式默认开启时更接近论文设置。

官方来源：
- <https://arxiv.org/abs/2601.06521>
- <https://arxiv.org/html/2601.06521v2>
- <https://github.com/UniPat-AI/BabyVision>
- <https://raw.githubusercontent.com/UniPat-AI/BabyVision/main/babyvision_eval/README.md>
- <https://huggingface.co/datasets/UnipatAI/BabyVision>
- <https://huggingface.co/api/datasets/UnipatAI/BabyVision>

### Chartography (v1, 2026-08)

- **测什么**：测专业场景的图表阅读能力：在稀疏坐标轴上估读数值、在等值线/曲线间插值、追踪细线或重叠的流线（Sankey）、解读投影 3D 几何、遵守领域惯例（如该用哪条百分位曲线、能否外推）。图表是 Kaplan-Meier 曲线、K 线、等值线图、Bode 图、风玫瑰、控制图等专业格式，而非普通柱状/折线/饼图。题目由各领域执业专家撰写并经 3 位专家独立复核，考的是“看图”而不是查标签。
- **数据**：部分公开；题量 100；许可 unknown
- **数据入口**：https://huggingface.co/datasets/surgeai/chartography
- **指标/判分**：mean pass@1（100 题 × 每任务多次试验的二值结果取均值）；judge=LLM-judge
- **官方 harness**：Inspect AI 官方 harness（src/chartography/task.py，solver=generate()）；leaderboard 配置：100 题 × 10 epochs、judge=google/gemini-3.5-flash
- **自测难度**：hard；快速子集：官方 sample pack 只有 2 个假任务（task_packs/sample_charts，manifest 明确写 not part of the released dataset），可用于离线跑通 harness 与 scorer；真实 100 题必须拿到 HF 数据集，当前匿名不可得。
- **整轮成本**：unknown（官方未给成本。估算公式：100 题 × 10 次试验 × 单次调用 tokens × 你的模型单价 + 1000 次 Gemini 3.5 Flash judge 费用）；耗时：unknown（1000 次生成 + 1000 次 judge；API 并发下粗估数十分钟到数小时，属估算）

命令：

```bash
# TODO verify 以下命令均摘自官方 GitHub README / pyproject，未在本机执行（需 API key，且完整数据需 HF 授权）
# 官方依赖：Python>=3.11 + uv + inspect-ai>=0.3.244（见 pyproject.toml）
git clone https://github.com/surge-ai/chartography && cd chartography
# 用 2 个假任务冒烟（不需要真实数据集）
uv run inspect eval src/chartography/task.py -T limit=1 --model anthropic/claude-opus-4-8 -T judge_model=google/gemini-3.5-flash --max-connections 8
# 完整 100 题（需要能访问 HF 数据集 surgeai/chartography；当前匿名 401，见 notes）
uv run inspect eval src/chartography/task.py --model <your-model> --epochs 10 --epochs-reducer "mean,pass_at_10,at_least_10" -T judge_model=google/gemini-3.5-flash -T hf_repo=surgeai/chartography
```

坑：（1）最大门槛是数据：论文/HF 卡声称已发布 100 题到 huggingface.co/datasets/surgeai/chartography，但 2026-10-30 匿名访问该 HF dataset 返回 HTTP 401、HF 数据集搜索也搜不到 surgeai/chartography，GitHub 只含 harness + 2 个假任务 → 真实 100 题/图片当前拿不到（需联系 benchmarks@surgehq.ai 或 HF 授权，获取方式未核实）。（2）官方协议明确“no tools”：论文 §3“no external data, browsing, or tools are permitted”、§4.1“no tools (no code execution, cropping, or zooming)”，README 也写 “chart attached inline, no tools”。模型卡里的 Chartography (w/tools) 83.0 用的是厂商自建 agent 协议：DeepSeek-V4.1 技术报告 §5.3.1 写明“视觉 agent 任务统一用 Claude Code harness + 512k context、temperature 1.0、top-p 0.95”，Table 3 以 Pass@1 报 Chartography w/tools；该口径不是官方 no-tools 榜单，不可直接比：官方 Chartography 榜上 DeepSeek V4.1 Flash (Max reasoning) 只有 11.6%。（3）judge 固定为 Gemini 3.5 Flash 且 judge 是 leaderboard 中一个被测配置（自评条件），换 judge 会改变分数。（4）论文 20 trials vs README leaderboard 10 epochs，两套配置别混用。（5）数据集许可未确认（repo 无 LICENSE 文件，HF 页拿不到）。（6）VLMEvalKit 未支持 Chartography（已核实 vlmeval/dataset/__init__.py 无 chartography 导入），只能走官方 Inspect AI harness。

官方来源：
- <https://arxiv.org/abs/2608.10677>
- <https://arxiv.org/html/2608.10677v1>
- <https://github.com/surge-ai/chartography>
- <https://raw.githubusercontent.com/surge-ai/chartography/main/src/chartography/task.py>
- <https://raw.githubusercontent.com/surge-ai/chartography/main/task_packs/sample_charts/manifest.yaml>
- <https://raw.githubusercontent.com/surge-ai/chartography/main/pyproject.toml>

### ZeroBench (v3, 2026-07)

- **测什么**：高难、多步的“真看图”推理：题目经过对抗式筛选，发布时前沿模型 pass@1/pass^5 全为 0。覆盖象棋记谱、菜单/地图读数、雪flake 体积估算、音乐谱号等，必须从图片中精确提取信息并多步计算，答案空间大、无法靠猜。
- **数据**：公开；题量 100；许可 MIT（GitHub 代码仓库 LICENSE）；HF 数据卡未单独标注 license，且为 gated，需同意“不公开答案/不用于训练”条款
- **数据入口**：https://huggingface.co/datasets/jonathan-roberts1/zerobench
- **指标/判分**：Pass@1 / Pass@5 / Pass^5（5 次采样）；judge=exact-match
- **官方 harness**：无官方评测脚本（GitHub repo 仅 README/LICENSE/assets）；HF 数据卡 README 提供 pass@1 参考代码（正则取最后一次花括号内容后精确匹配），Pass@5 需自行做 5 次采样；leaderboard 由作者团队运行
- **自测难度**：easy；快速子集：抽 50 题 × 1 次 greedy 采样估 pass@1（约几分钟到十几分钟）；要报 Pass@5 必须 100 题 × 5 次采样（≈500 次调用），并固定采样参数。
- **整轮成本**：官方 leaderboard 给 cost/question：约 $0.010–$1.11/题（Pixtral-Large $0.010、GPT-6 Luna $0.018、GPT-6 Sol $0.17、GPT-6 Astra $0.56、GPT-5.6 Sol $0.76、Claude Opus 5.5 $1.11）→ 100 题全量约 $1–$111（按官方榜模型价格，pass@5 口径）；耗时：unknown（100 题×5 次=500 次调用；不进工具、API 并发下通常 10–60 分钟量级，属估算）

命令：

```bash
# TODO verify 以下命令未在本机执行；HF 数据为 gated，需先登录并同意条款（或改用 VLMEvalKit 镜像/自行 5 次采样）
pip install datasets
python -c "from datasets import load_dataset; d=load_dataset('jonathan-roberts1/zerobench', split='zerobench'); print(len(d))"
# 替代框架（UK AISI inspect_evals，官方文档已核实；需 pip install inspect-ai inspect-evals）
inspect eval inspect_evals/zerobench --model <model> --max-tokens 16000 --temperature 0.7 --top-p 0.95
# 替代框架（VLMEvalKit，已核实支持 ZEROBench；默认走 opencompass 镜像 TSV）
python run.py --data ZEROBench --model <model> --verbose
```

坑：（1）HF 数据是 gated(auto)：需登录并“Acknowledge”不公开答案/不用于训练才能下载（含 canary string）；不登录直接 API 访问文件会 401。VLMEvalKit 用 opencompass 镜像 TSV，可绕过 gating，但镜像是否与 v3 同步未核实。（2）官方判分是精确匹配，不做语义判断；花括号格式、大小写、单位、有效数字错一点就算错，必须在 prompt 里严格约束输出格式。（3）Pass@5 需要 5 次采样：官方老模型用 temperature=0.7/top_p=0.95，新模型用默认参数；单次 greedy 只能报 pass@1。（4）官方 code repo 只有 README/LICENSE/assets，没有评测脚本，得自己写（参考 README 片段）或用 inspect_evals/VLMEvalKit；VLMEvalKit 只算 accuracy(=pass@1)，不内置 pass@5。（5）模型卡的 ZeroBench-main (w/tools)=51.0 是工具增强、5 samplings 的自报值：DeepSeek-V4.1 技术报告 §5.3.1 写明视觉 agent 任务用 Claude Code harness + 512k context、temperature 1.0、top-p 0.95，Table 3 以此口径报 Pass@5；ZeroBench 官方 externals 表也把它标注为 “Claude Code harness tools; 5 samplings”。官方主榜是 no-tools，两者不可直接比较。（6）“minimal” 不是 ZeroBench 子集：官方只定义 main(100) 与 subquestions(334)；DeepSeek 技术报告里的 “Minimal” 是 DeepSeek Harness (DSH) 的 Minimal 模式（单个 bash 工具，用于 code agent 评测，见附录 B.1），与 ZeroBench 无关。详见 notes.md。

官方来源：
- <https://arxiv.org/abs/2502.09696>
- <https://arxiv.org/html/2502.09696v3>
- <https://github.com/jonathan-roberts1/zerobench>
- <https://zerobench.github.io>
- <https://huggingface.co/api/datasets/jonathan-roberts1/zerobench>
- <https://ukgovernmentbeis.github.io/inspect_evals/evals/zerobench/index.html>


## 框架与工具链

| 名称 | 类型 | 支持基准 | 安装 | 接口 | 已核实 | 链接 |
|---|---|---|---|---|---|---|
| Harbor | 通用 agent 评测/运行框架（Terminal-Bench 官方 harness） | Terminal-Bench 4.0 | uv tool install harbor  # 或 pip install harbor（PyPI 0.25.0，requires_python>=3.12） | CLI: harbor run -d <dataset@version> -a <agent> -m <model>；模型 slug 由 LiteLLM 解析成 provider/model；预置 40+ agent（claude-code、mini-swe-agent、codex、terminus-2、openhands 等）；--base-url / --api-key-name / --api-format 覆盖端点与协议；默认 Docker 沙箱，--env modal/daytona 上云；--repo/--path 可跑任意 Harbor 格式任务目录 | True | https://github.com/harbor-framework/harbor |
| terminal-bench（任务集仓库 + 旧版 tb CLI） | 基准任务集 + 旧版执行 harness | Terminal-Bench 4.0 | uv tool install terminal-bench  # 旧版 CLI `tb`；README 明确新用户改用 harbor | 旧 CLI: tb run --agent <agent> --model <model> --dataset-name ... --dataset-version ... --n-concurrent N；任务目录含 instruction / tests / oracle solution；当前数据集在 Harbor Hub 按 tag 发布（v3.0.0、v4.0.0） | True | https://github.com/harbor-framework/terminal-bench |
| Pier（datacurve-pier） | 代码 agent 评测框架（Harbor 分支，DeepSWE 官方 runner） | DeepSWE v1.1 | uv tool install datacurve-pier  # 或 pip install datacurve-pier；PyPI 0.3.1，requires_python>=3.12 | CLI: pier run -p deep-swe/tasks --agent mini-swe-agent --model anthropic/claude-opus-4-8；--n-tasks/--sample-seed 抽确定性子集；agent 用 YAML/env 配端点（claude-code 用 ANTHROPIC_BASE_URL/ANTHROPIC_AUTH_TOKEN）；environments: docker / modal | True | https://github.com/datacurve-ai/pier |
| mini-swe-agent v2（模型卡称 Mini-SWE-V2 / mini-swe-v2） | 极简 coding agent（bash-only），DeepSWE/ProgramBench 官方 baseline | DeepSWE v1.1、ProgramBench | pip install mini-swe-agent  # PyPI 2.4.6，requires_python>=3.10；或 uvx mini-swe-agent / pipx run mini-swe-agent | CLI: `mini`（单次交互式 agent）；`mini-extra swebench`、`mini-extra programbench`（批量）；模型走 LiteLLM（OpenAI Chat Completions/Responses、Anthropic 等），--model provider/model + 对应 *_API_KEY；环境 local/docker/singularity/bubblewrap 等；agent 只有 bash 一个工具，不依赖模型原生 tool-calling | True | https://github.com/SWE-agent/mini-swe-agent |
| Claude Code（Anthropic 官方 CLI agent） | agent harness（模型卡里 Terminal-Bench 4.0 的官方 harness） | Terminal-Bench 4.0、Agents' Last Exam | npm install -g @anthropic-ai/claude-code  # Node 18+；Windows 另需 Git for Windows | Anthropic Messages API；接第三方/自建模型靠环境变量：ANTHROPIC_BASE_URL、ANTHROPIC_AUTH_TOKEN、ANTHROPIC_MODEL、ANTHROPIC_DEFAULT_OPUS/SONNET/HAIKU_MODEL、CLAUDE_CODE_EFFORT_LEVEL、CLAUDE_CODE_AUTO_COMPACT_WINDOW；在 Harbor 里用 -a claude-code 由框架自动注入凭证与 base_url | True | https://code.claude.com/docs/en/quickstart |
| EvalScope（ModelScope） | 通用 LLM/多模态/agent 评测框架 | HLE、Terminal-Bench 4.0、DeepSWE v1.1、Automation-Bench v1.0.6、BabyVision、ZeroBench-main | pip install evalscope  # PyPI 1.14.1，requires_python>=3.10；TB4 额外 pip install 'evalscope[terminal_bench]'（文档要求 Python>=3.12、Harbor>=0.14.0,<1.0.0）；DeepSWE 额外 pip install 'evalscope[deep_swe]'；Automation-Bench 需 pip install "verifiers==0.1.12.dev2" 与 automation-bench（git 方式装 zapier/AutomationBench 固定 commit） | CLI: evalscope eval --model <name> --api-url <OpenAI 兼容 URL> --api-key <key> --datasets <name...> --limit N；judge 用 --judge '{"strategy":"llm","models":[{"model_id":"..."}]}'；TB4 通过 dataset_args.extra_params.agent_name 选 Harbor agent（terminus-2 用 EvalScope 模型，claude-code 等外部 CLI 需自带 key）、task_names 选子集 | True | https://github.com/modelscope/evalscope |
| Inspect AI（UK AISI）+ inspect_evals | 通用 LLM 评测框架 + 官方 eval 实现集 | HLE、ZeroBench-main、Chartography | pip install inspect-ai  # PyPI 0.3.286，requires_python>=3.11；pip install inspect-evals  # PyPI 0.27.0 | CLI: inspect eval <task> --model <provider/model>；内置 provider 含 openai、anthropic、google、deepseek、vllm、ollama、sglang；OpenAI 兼容第三方用 openai-api/<provider>/<model>（读 <PROVIDER>_API_KEY / <PROVIDER>_BASE_URL，如 DEEPSEEK_API_KEY+DEEPSEEK_BASE_URL）；-T 传 task 参数，--model-base-url 可指本地端点，--epochs/--epochs-reducer 算 pass@k | True | https://inspect.aisi.org.uk/ |
| VLMEvalKit（OpenCompass） | 多模态 VLM 评测工具包 | BabyVision、ZeroBench-main | git clone https://github.com/open-compass/VLMEvalKit && cd VLMEvalKit && pip install -e . | python run.py --data <DATASET> --model <MODEL_NAME> [--mode infer] [--verbose]；模型在 vlmeval/config.py 的 supported_VLM 注册，API key 放 VLMEvalKit/.env；judge/选项抽取默认用 LLM（也可用 LMDeploy 本地 judge），未配 key 时退化为精确匹配 | True | https://github.com/open-compass/VLMEvalKit |
| lm-evaluation-harness（EleutherAI） | 通用文本评测框架 |  | pip install lm_eval  # 也支持 pip install "lm_eval[api,vllm]" | CLI: lm_eval --model <hf\|vllm\|sglang\|local-completions\|local-chat-completions\|openai-completions...> --model_args base_url=... --tasks <task>；OpenAI 兼容端点用 local-completions/local-chat-completions + base_url | True | https://github.com/EleutherAI/lm-evaluation-harness |
| OpenAI simple-evals | 参考实现集（已停止维护） |  | git clone https://github.com/openai/simple-evals；仓库无统一 setup，按 eval 单独安装依赖（如 pip install openai / anthropic / human-eval） | python -m simple-evals.simple_evals --model <model> --examples <N>；sampler 仅 OpenAI 与 Anthropic | True | https://github.com/openai/simple-evals |
| AutomationBench 官方 CLI（zapier/AutomationBench） | 基准自带 runner（含模拟 SaaS 环境） | Automation-Bench v1.0.6 | git clone https://github.com/zapier/AutomationBench && cd AutomationBench && uv sync；key 用 OPENAI_API_KEY 环境变量或 --api-key 传入 | uv run auto-bench --model <model> [--domains all\|sales,...] [--toolset api\|zapier\|limited_zapier] [--base-url <OpenAI 兼容 URL>] [--api-key <key>] [--num-examples N] [--max-steps 50] [--max-concurrent 100] [--reasoning-effort low..max] [--responses-api]；也支持托管环境：prime env install zapier/AutomationBench && prime eval run zapier/AutomationBench | True | https://github.com/zapier/AutomationBench |
| HLE 官方评测脚本（centerforaisafety/hle） | 基准自带 runner | HLE | git clone https://github.com/centerforaisafety/hle && cd hle && pip install -r requirements.txt | cd hle_eval；python run_model_predictions.py --dataset cais/hle --model <model> --max_completion_tokens 8192 --num_workers 100（可加 --max_samples N 小样本）；再 python run_judge_results.py --dataset cais/hle --predictions <file> --judge <judge_model> --num_workers 100；走 openai-python 接口，judge 用结构化输出 | True | https://github.com/centerforaisafety/hle |
| ProgramBench CLI（facebookresearch/programbench） | 基准自带 eval runner | ProgramBench | pip install programbench  # 或 uvx programbench --help；开发 pip/uv 从源码装：git clone + uv sync | 推理：mini-swe-agent 的 mini-extra programbench（产物为 <out>/<instance>/submission.tar.gz + traj.json）；评测：uv run programbench eval <run_dir>；汇总：programbench info；测试 blob 预下载：programbench blob sync [instance_id] | True | https://github.com/facebookresearch/programbench |
| Agents' Last Exam（ale_run） | 基准自带评测框架（真机/VM + CUA） | Agents' Last Exam | git clone https://github.com/rdi-berkeley/agents-last-exam && cd agents-last-exam && bash env/install_host_deps.sh && uv sync --all-packages --locked && bash env/verify_host_env.sh；另需单独安装 agent CLI（claude-code/codex 等） | uv run python -m ale_run run my_experiment.yaml [--dry-run]；experiment yaml 选 agent（claude-code、codex、ALE-Claw 等）× 环境 provider（GCP VM / AWS / 阿里云 / QEMU-KVM / 本地 Docker 子集 / 已有 CUA 沙箱）× 任务列表（selected_tasks/full.txt 122 题、gpu.txt 3 题、docker_support.txt 78 题）；评分用任务内 evaluate() 对隐藏 reference 打分（0-1） | True | https://github.com/rdi-berkeley/agents-last-exam |
| Chartography 官方评测代码（surge-ai/chartography） | 基准自带评测代码（基于 Inspect AI） | Chartography | git clone https://github.com/surge-ai/chartography && cd chartography；README 用 uv run 运行（依赖 inspect-ai，uv 会自动装） | uv run inspect eval src/chartography/task.py --model <provider/model>；-T judge_model=<judge>、-T hf_repo=surgeai/chartography（跑全量 HF 数据）、-T limit=1、--max-connections；榜单口径：--epochs 10 --epochs-reducer "mean,pass_at_10,at_least_10" + judge_model=google/gemini-3.5-flash | True | https://github.com/surge-ai/chartography |
| NL2Repo-Bench 官方 runner（multimodal-art-projection/NL2RepoBench） | 基准自带 runner（OpenHands headless batch） | NL2Repo-Bench | git clone https://github.com/multimodal-art-projection/NL2RepoBench；需本机 Docker 并预拉 docker.all-hands.dev/all-hands-ai/openhands:0.56 与 docker.all-hands.dev/all-hands-ai/runtime:0.56-nikolaik 两个镜像 | 官方仓库跑 OpenHands headless 批量模式：改 config.toml（模型行为）与 config.json（startPro.baseUrl/sk/proNameList、max_pool_size）→ 跑入口脚本 main.py；用 python-on-whales 管理容器；任务数据在 test_files/，结果落 result/*.json；README 明确当前只支持本地执行，多机需自行做共享存储（NFS） | True | https://github.com/multimodal-art-projection/NL2RepoBench |
| vLLM（模型服务：OpenAI + Anthropic 双协议） | model server / endpoint |  | pip install vllm；启动：vllm serve <hf-model> --served-model-name <name> --enable-auto-tool-choice --tool-call-parser <parser> | OpenAI 兼容 /v1（chat/completions、responses）；Anthropic Messages /v1/messages（官方文档专门讲如何把 Claude Code 指到 vLLM：ANTHROPIC_BASE_URL=http://localhost:8000 + ANTHROPIC_AUTH_TOKEN=dummy + ANTHROPIC_DEFAULT_*_MODEL=<served name>）；工具调用需 --enable-auto-tool-choice 与模型匹配的 --tool-call-parser | True | https://github.com/vllm-project/vllm |
| Ollama（本地小模型服务，0 元档自检用） | 本地模型服务 |  | 从 https://ollama.com/download 安装；ollama pull <model> | OpenAI 兼容 /v1，默认 http://localhost:11434/v1（Inspect 的 ollama provider 默认即此地址；--model ollama/<model>）；原生不实现 Anthropic Messages，Claude Code 需再套代理 | True | https://ollama.com/ |
| Apex Bench v1.1（未找到可核实的公开评测代码） | 基准（无可核实 runner） | Apex Bench v1.1 | 无公开安装方式（TODO verify：未找到官方仓库 / 数据集 / runner） | unknown；检索到的第三方页面只给出 Pass@1 分数，未给出调用方式 | False | https://www.datalearner.com/benchmarks/apexbench |
| DeepSeek API（OpenAI + Anthropic 双协议端点） | model endpoint（SaaS） |  | 无需安装；platform.deepseek.com 取 API key | OpenAI 格式 base_url=https://api.deepseek.com；Anthropic 格式 base_url=https://api.deepseek.com/anthropic；model=deepseek-flash（即 DeepSeek-V4.1-Flash-1017）或 deepseek-v4-pro；1M 上下文 / 最大输出 384K；thinking 默认开启；Claude Code 接法：ANTHROPIC_BASE_URL + ANTHROPIC_AUTH_TOKEN；Responses API 亦支持 | True | https://api-docs.deepseek.com/ |
