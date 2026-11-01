# 评测/观测工具链离线可行性对比（AgentCompass + 四家）

> 日期：2026-11-01 ｜ 口径：只看**能否在公司断网 Linux + Docker 环境部署**，不评价基准质量。
> 结论先行：**五者官方都没有「离线安装包」**，但都能通过「预装 wheel + 预拉/预构建镜像 + 预热数据」离线化；
> 相对成本：**Langfuse ≈ DeepEval < OpenCompass < AgentCompass < SWE-bench**（估算，依据见 §2/§3）。
> 体积/工期均为估算，未实测项已标 `# TODO verify`；禁止把本文数字当作已实测结论引用。
> 相关：本仓库已单独交付 **OpenCompass 离线对比包**（`E:\opencompass-offline`，约 808 MB，见 [`opencompass-offline-bundle.md`](opencompass-offline-bundle.md)），本文只做横向定位，不重复其细节。

## 1. 五者是什么（先分清类别）

| 项目 | 类型 | 主要用途 | 与 5 基准（TB4/DeepSWE/NL2Repo/ProgramBench/Automation-Bench）的关系 | 许可证 |
| :-- | :-- | :-- | :-- | :-- |
| **AgentCompass** | Agent 评测框架（OpenCompass 团队，2026-09 发布） | 统一跑 30+ 公开基准、10+ harness（mini-SWE-agent/OpenHands/Codex/Claude Code 等），Model/Benchmark/Harness/Environment 解耦 | 可作「第二意见」框架；内置 DeepSWE v1.1（commit `0b9fabbb`，与我们的离线包一致）、SWE-bench Verified/Pro、Terminal-Bench 2 系列；`harbor` benchmark 可直接跑本地 Harbor 格式任务 | Apache-2.0 |
| **OpenCompass** | 通用 LLM 评测平台 | 100+ 数据集（知识/推理/代码/长上下文等），支持 API 与本地模型 | **不是 agent 基准**，不能替代 5 基准；可补通用能力面（MMLU/C-Eval 等） | Apache-2.0 |
| **SWE-bench** | 具体基准 + 官方评测 harness | 真实 GitHub issue 修复，Docker 沙箱评测 | 与我们已选的 **DeepSWE 同族**（SWE 风格），口径不同、重复度高 | MIT |
| **DeepEval** | LLM 应用评测框架（pytest 风格） | 50+ 指标、LLM-as-a-judge、agent 轨迹评测；非基准库 | 用于**上线后内部回归**，不产出选型基准分 | Apache-2.0 |
| **Langfuse** | LLM 观测/追踪平台 | trace、数据集、LLM-as-judge 评估 | **不产出基准分数**，是记录/分析工具 | MIT（`ee/` 目录商业许可） |

## 2. 离线安装可行性总表

| 项目 | 官方离线包 | 官方离线说明 | 离线化最小步骤 | 关键离线依赖 | 体积量级（估算） | 难度 |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| AgentCompass | ❌ | 部分有（依赖管理/网络/胶囊章节） | `uv` wheelhouse 安装（含 `[extras]`）+ 预拉 Docker 基线镜像 + 预置 benchmark 数据/任务镜像 | Python wheels、Docker 镜像、HF/上游数据、任务环境内工具链 | 框架 ~百 MB 级；数据/镜像取决于所选 benchmark | 中（只跑本地 Harbor 任务时可复用现有镜像 → 低） |
| OpenCompass | ❌（本仓库已自建 808 MB 离线包） | ✅（数据集缓存/离线运行文档） | pip wheelhouse + 按数据集预热 `COMPASS_DATA_CACHE`/`HF_DATASETS_CACHE` | Python wheels、各数据集（来源分散：OSS/HF/ModelScope/本地） | 本仓库离线包 808 MB（实测）；官方全量视数据集 | 本仓库已解决（中） |
| SWE-bench | ❌ | ❌（但 CLI 支持本地数据） | pip + 本地数据集（HF 缓存/JSONL）+ 联网机 `swebench images build` 或预拉实例镜像 + `docker save` | Docker 实例镜像（每实例一个）、HF 数据集 | **官方建议 120 GB 空闲**；镜像总量数十–上百 GB | **高** |
| DeepEval | ❌ | ❌（但支持本地存储/自定义 judge） | pip wheelhouse；judge 换内网 OpenAI 兼容端点；如用本地 NLP 指标/内置 benchmark 再预热模型与数据 | Python wheels、本地模型缓存、benchmark 数据 | wheels ~百 MB 级 | 低 |
| Langfuse | ❌ | ❌（只有自托管 compose 文档） | 联网机 `docker compose pull` → `docker save` → 内网 `docker load` → `docker compose up` | 6 个 Docker 镜像（见 §3.5）；SDK 为 pip 包 | 约几 GB（估算） | 低–中 |

## 3. 逐项说明

### 3.1 AgentCompass（最值得关注的「第二意见」框架）

- **安装**：当前仓库 `pyproject.toml` 版本 **1.0.1**，要求 **Python ≥ 3.12**；PyPI 首个 release 为 **v1.0.0（2026-09-30）**，`pip install agentcompass`；源码安装为 `uv pip install -e .`，验证命令 `agentcompass --version`。
- **能力**：内置 30+ 基准、10+ harness；文档列出 DeepSWE（默认 v1.1）、SWE-bench Verified/Pro/Multilingual、Terminal-Bench 2/2.1/Verified/Science、Harbor、GAIA、OSWorld 等。
- **离线关键点（有官方文档依据）**：
  1. 可选依赖按 extra 预装（`swebench`、`mini-swe-agent` 等），**自动安装默认关闭** → 离线环境提前装好即可，运行期不联网。
  2. Docker provider 的出口代理镜像默认 `python:3.12-alpine`，**离线主机需预拉该镜像**。
  3. 官方「Runtime Capsule」文档明确：离线环境应提供 registry cache、可离线的 `install_command`、`preinstalled` 或 `upload`（即任务环境内的 harness/工具链要预热）。
  4. 数据来源各自为政：DeepSWE 首次使用会克隆到 `data/deepswe/` 并提供 `dataset_path` 本地目录参数；Terminal-Bench 2 首次使用从 GitHub 浅克隆仓库；SWE-bench Verified 优先 `dataset_zip_url`，缺失时才从 Hugging Face 加载 → **离线要逐 benchmark 预热**。
- **与本仓库的复用点（最省钱路径）**：AgentCompass 的 `harbor` benchmark 可以直接读**本地 Harbor task 目录**（等价 `harbor run -p`），用 task 自带 verifier 打分。我们的 TB4 任务就是 Harbor 格式（`task.toml` + `instruction.md` + `tests/test.sh` + `environment.docker_image`），镜像已在离线包里（当前 36 题，`bench-images.tar` + `bench-images-batch2.tar` + `bench-images-tb4-extra.tar`）→ 只跑「AgentCompass + 现有 TB4 任务」时，**只需框架 wheelhouse，不需要额外基准数据/镜像**。
  `# TODO verify`：AgentCompass 对 TB4 任务的 `verifier.environment_mode=separate`、artifacts 收集是否与 Harbor 完全一致；建议先在联网机跑通 1 题再打包。
- **版本口径警告**：AgentCompass 的 Terminal-Bench 模块是 **Terminal-Bench 2 / 2.1 / Verified / Science**（数据集 `terminal-bench-2`），与本仓库选的 **Terminal-Bench v4.0.0** 不是同一数据版本，**分数不可混用**；DeepSWE 模块默认 v1.1（commit `0b9fabbb`）与我们的离线包一致，可对齐。

### 3.2 OpenCompass

- **本仓库现状（重要）**：已有实测离线包 **`E:\opencompass-offline`**（OpenCompass **0.5.4**、约 **808 MB**、15 个数据集族 / 203 个配置条目，含 LiveCodeBench v6 与 HLE LLM-Judge；Docker 20.10.24 实测可用），详见 [`opencompass-offline-bundle.md`](opencompass-offline-bundle.md)。**OpenCompass 的离线问题在本仓库已经解决**，剩下只是「要不要扩数据集 / 升版本」。
- **安装**：pip 安装（`opencompass`、`opencompass[api]`、`opencompass[full]`）；主环境支持 Python 3.12；部分代码执行类数据集（APPS/TACO/LiveCodeBench code gen）依赖 `pyext`，需 Python 3.10 → 若按官方全量方式离线，可能要两套 venv（本仓库离线包已把 LCB 执行环境内置，规避了这一点）。
- **离线说明（官方）**：文档《数据集下载与缓存》明确无统一下载器；`DATASET_SOURCE=HF|ModelScope` 选来源，`COMPASS_DATA_CACHE`/`HF_DATASETS_CACHE` 指定缓存；并提示「离线运行前应确认数据文件和其他相关资源均已准备完成」。
- **风险**：各数据集加载方式不同（有的走 OSS/HF/ModelScope，有的要用户手动准备），离线可跑率需逐数据集验证；`# TODO verify` 选定的 2–3 个数据集在断网下的首次运行。
- **与公司目标**：适合补通用能力分（如 MMLU/C-Eval），不覆盖我们已选的 5 个 agent 基准。

### 3.3 SWE-bench

- **官方要求**：Docker；建议 x86_64、**120 GB 空闲、16 GB RAM、8 核**；评测资源密集。
- **离线可行路径（v5 CLI）**：`DATASET` 支持别名/HF id/**本地路径**；`--task-repo ./swe-bench-tasks` 用本地任务仓库构建镜像；`swebench images build verified` 可在联网机预构建/预拉，再 `docker save` 带入内网。数据集也可用 HF 缓存或本地 JSON/JSONL。
- **成本**：每个实例一个镜像（Verified 500 / Lite 300），镜像与构建时间是四家里最重的；离线包体积会显著超过当前主包（约 50 GB）。
- **结论**：与 DeepSWE 重复度高，除非公司明确要求「对齐官方 SWE-bench 榜」，否则不建议为选型再打包。

### 3.4 DeepEval

- **安装**：`pip install deepeval`（Python ≥ 3.9）；本质是 pytest 化的 LLM 应用评测，50+ 指标，LLM-as-judge 可用任意模型（**内网 OpenAI 兼容端点即可**）。
- **离线关键点**：
  1. wheelhouse 安装即可，无强制云依赖；结果可本地存（JSON 默认 / SQLite，路径 `.deepeval/`，可用 `DEEPEVAL_CACHE_FOLDER` 改）。
  2. 部分指标依赖本地 NLP/embedding 模型，首次使用会下载 → 需预热缓存。
  3. 内置 benchmark（MMLU/HellaSwag/GSM8K/HumanEval 等）首次运行需拉数据 → 需预热；`# TODO verify` 具体缓存位置与是否有官方离线开关（以实测为准）。
- **定位**：适合公司上线后对自己应用/agent 做回归（CI 里跑），**不用于选型基准**。

### 3.5 Langfuse

- **是什么**：LLM 观测/追踪平台（trace、dataset、LLM-as-judge 评估），核心 MIT，`ee/` 目录商业许可。
- **自托管 compose（v4）包含 6 个镜像**：`langfuse-web:4`、`langfuse-worker:4`（来自 `docker.langfuse.com`）、`clickhouse/clickhouse-server:26.3.62.3`、`cgr.dev/chainguard/minio`、`redis:7`、`postgres:17`。
- **离线做法**：在能访问上述 registry 的联网机 `docker compose pull` → `docker save` 全部镜像 → 内网 `docker load` → 修改 compose 密钥后 `docker compose up`；SDK 是 pip 包。
- **注意**：官方文档没有「离线/air-gap」模式说明，属于标准 Docker 自托管；它不产出基准分数，需自己配置 dataset/评估器。

## 4. 与现有离线包的关系与建议

- **现状**：`E:\bench-bundle` 已扩至 **4 个镜像 tar / 约 50 GB**（TB4 36 题 + NL2Repo 10 题 + 第一批 DeepSWE/ProgramBench，另含 CentOS 7 Docker 安装包）；**五者均未加入主离线包**，但 **OpenCompass 已有单独实测离线包** `E:\opencompass-offline`（808 MB，见 §3.2）。5 个基准仍由各自官方 harness 覆盖（Harbor / Pier / mini-swe-agent / ProgramBench / AutomationBench / OpenHands）。
- **优先级建议（按性价比）**：
  1. **默认不加**：现有 5 基准已能完成选型，没必要为「工具好看」增加离线维护面。
  2. **想要第二意见 → 只加 AgentCompass**：用现有 TB4 任务 + 现有镜像，仅打包框架 wheelhouse（估算百 MB 级）；先跑通 1 题再放量。需要 SWE-bench/TB2 时再单独备镜像/数据。
  3. **上线后回归 → DeepEval + Langfuse**：两者最轻，DeepEval 打 wheelhouse，Langfuse 打 6 镜像 compose；不参与选型。
  4. **通用能力面 → OpenCompass**：已落地，直接复用 `E:\opencompass-offline`；不足时再按需扩数据集（见 `opencompass-offline-bundle.md` §6）。
  5. **不建议 SWE-bench**：与 DeepSWE 重复，且是四家里离线成本最高的。
- **第三批打包粗略范围（估算）**：AgentCompass-only 约百 MB 级；DeepEval+Langfuse 约几 GB（Langfuse 6 镜像）；OpenCompass 无需再打（已有 808 MB）；SWE-bench Lite 数十 GB 起。`# TODO verify` 以实际 `pip download` / `docker images` 体积为准。

## 5. 未验证项与风险（引用前必读）

- `# TODO verify` AgentCompass 在完全断网环境跑 Harbor 本地任务（含 separate verifier）尚未实测；理论上 wheelhouse + 现有镜像可行，需先在联网机验证 1 题。
- `# TODO verify` DeepEval 内置 benchmark 的离线数据缓存细节未实测（是否可完全预热）。
- `# TODO verify` OpenCompass 各数据集离线可跑率不一致，需逐数据集验证。
- `# TODO verify` SWE-bench 镜像实际体积/构建时间未实测（官方只给 120 GB 磁盘建议）。
- **版本口径**：AgentCompass 的 TB2 系列 ≠ 本仓库的 TB v4.0.0；DeepSWE v1.1 数据 commit 一致（`0b9fabbb`）。任何分数引用必须写明「基准版本 + harness + 数据集 commit」。
- **许可/再分发**：框架许可见 §1；基准数据集与任务镜像的许可需看各自数据集卡片，随离线包再分发前确认。

## 6. 来源（访问日期均为 2026-11-01）

**本仓库相关**：[`opencompass-offline-bundle.md`](opencompass-offline-bundle.md)（OpenCompass 离线包实测）、[`second-batch-bundle.md`](second-batch-bundle.md)（TB4/NL2Repo 离线包）、[`company-day1-checklist-batch2.md`](company-day1-checklist-batch2.md)（公司端操作）。

**上游官方**：
- AgentCompass：<https://github.com/open-compass/AgentCompass>（README、`pyproject.toml`、`docs/zh/`）；依赖管理 <https://agent-compass.mintlify.app/en/user_guide/using_agentcompass/dependencies>；Harbor benchmark <https://agent-compass.mintlify.app/en/user_guide/modules/benchmarks/harbor>；DeepSWE <https://agent-compass.mintlify.app/en/user_guide/modules/benchmarks/deepswe>；Terminal-Bench 2 <https://agent-compass.mintlify.app/en/user_guide/modules/benchmarks/terminal_bench_2>；SWE-bench Verified <https://agent-compass.mintlify.app/en/user_guide/modules/benchmarks/swebench_verified>；环境网络策略 <https://agent-compass.mintlify.app/en/user_guide/modules/environments/configuration/network>；Runtime Capsule <https://agent-compass.mintlify.app/en/developer_guide/architecture/runtime_capsules>
- OpenCompass：<https://github.com/open-compass/opencompass>（README_zh-CN）；数据缓存与离线运行 <https://github.com/open-compass/opencompass/blob/main/docs/zh_cn/user_guides/data_and_cache.md>；数据集配置 <https://github.com/open-compass/opencompass/blob/main/docs/zh_cn/user_guides/datasets.md>
- SWE-bench：<https://github.com/SWE-bench/SWE-bench>；任务仓库 <https://github.com/SWE-bench/swe-bench-tasks>
- DeepEval：<https://github.com/confident-ai/deepeval>；benchmarks <https://deepeval.com/docs/benchmarks-introduction>；本地存储 <https://deepeval.com/docs/evaluation-local-backend-storage>
- Langfuse：<https://github.com/langfuse/langfuse>（`docker-compose.yml`、`LICENSE`）；自托管文档 <https://langfuse.com/self-hosting/deployment/docker-compose>

> 本文只解决「能不能离线装」；具体「值不值得跑」以 `report/api-only-5bench-plan.md` 的选型结论为准。
