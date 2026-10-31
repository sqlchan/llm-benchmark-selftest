# OpenCompass 离线模型对比包（opencompass-offline）

> 定位：**辅助工具**，用于把多个模型放在同一套通用基准上横向对比；**不属于**模型卡上的 11 个基准，也不改变本仓库的 11 基准数据流。
> 交付物是一个独立目录（不在本仓库内）：`E:\opencompass-offline`，约 **808 MB**，可整体复制到公司离线机器。
> 基于 **OpenCompass 0.5.4**（PyPI wheel 固定版本），纯 CPU、无需外网、无需 GPU。

## 1. 为什么单独做这个包

本仓库主报告解决的是「复现模型卡上 11 个基准」；但公司还需要回答另一类问题：**在通用能力上，几个候选模型谁更强**。
OpenCompass 是上海人工智能实验室的一站式评测平台，预置 100+ 数据集与 API 模型接入能力；本包把其中一批数据集、镜像与配置预先离线化，
形成一个与主评测包互不干扰的「模型对比」工具包。

| 维度 | 主评测包 `bench-bundle` | 本对比包 `opencompass-offline` |
| :-- | :-- | :-- |
| 目的 | 复现模型卡 5 个 agentic/软件工程基准（DeepSWE v1.1、TB4、NL2Repo、ProgramBench、Automation-Bench） | 通用能力横向对比（知识/推理/数学/代码/中文/指令遵循 + LCB/HLE） |
| 运行 | Harbor/Pier 官方 harness + Docker 沙箱 | OpenCompass 0.5.4 + Docker（API 模型，CPU） |
| 口径 | 与官方 harness/模型卡对齐 | **不可与模型卡 agentic 分数混比**，只做同配置下的模型间比较 |
| 位置 | `E:\bench-bundle` | `E:\opencompass-offline`（独立目录） |

两者互不修改、可放在同一块移动硬盘。

## 2. 包内容与版本

| 文件 | 大小 | 说明 |
| :-- | --: | :-- |
| `docker/opencompass-0.5.4-py312.tar` | **695.5 MB** | OpenCompass 0.5.4 + Python 3.12 + 依赖（CPU torch），含 `manifest.json`，Docker 20.10 可 `docker load` |
| `data/compass-data.tar.gz` | **111.9 MB** | 203 个数据集条目缓存（解压约 193 MB），含 LiveCodeBench v6 与 HLE 纯文本本地数据 |
| `configs/`、`scripts/`、`env/`、文档 | < 100 KB | `compare.py`（模型+套件）、`selfcheck.py`、加载/运行/自检脚本、env 模板 |
| 合计 | **约 808 MB** | |

版本锁定：OpenCompass **0.5.4**、Python **3.12**、PyTorch 2.15 CPU；关键依赖按兼容性固定
（`openai<2`、`anthropic<1`、`filelock==3.16.1`、human-eval fork、math-verify 0.9.0），详见包内 `docs/build-info.md`。

## 3. 数据集与套件

15 个数据集族、203 个配置条目，全部规则判分（HLE 为 LLM-Judge）：

| 数据集 | 题量（实测） | 指标 |
| :-- | --: | :-- |
| MMLU | 14,042 | accuracy |
| MMLU-Pro | 12,032 | accuracy |
| C-Eval（val） | 1,346 | accuracy |
| CMMLU（test） | 11,582 | accuracy |
| GPQA-Diamond | 198 | accuracy |
| AIME2024 / AIME2025 | 30 / 30 | math_verify 正确率 |
| MATH-500 | 500 | math_verify 正确率 |
| GSM8K | 1,319 | accuracy |
| HumanEval | 164 | pass@1（容器内执行） |
| MBPP | 500 | pass@1（容器内执行） |
| IFEval | 541 | strict/loose 指令遵循率 |
| HellaSwag | 10,042 | accuracy |
| **LiveCodeBench** | v6 code generation 175（×6 采样）+ execution 479 + test output 442 | pass@1 |
| **HLE（纯文本）** | 2,158（官方 2,500，过滤掉 342 道图题） | LLM-Judge accuracy / f1 |

套件（每个模型的请求量，估算；多模型线性叠加）：

| 套件 | 内容 | 约请求数 |
| :-- | :-- | --: |
| `quick` | 各集抽样子集（HumanEval 固定全量 164） | ≈ 1.0k |
| `standard`（默认） | MMLU-Pro / GPQA / AIME / MATH-500 / GSM8K / HumanEval / MBPP / IFEval / C-Eval | ≈ 16.7k |
| `zh` | C-Eval + CMMLU | ≈ 12.9k |
| `hard` | LiveCodeBench（3 子任务）+ HLE（LLM-Judge） | ≈ 4.1k + 2,158 次 judge 调用 |
| `full` | `standard` + `zh` + MMLU + HellaSwag + LiveCodeBench（**不含 HLE**，避免 judge 依赖） | ≈ 55.6k |

## 4. 公司内网使用

### 4.1 安装（3 步）

```bash
cd /data/opencompass-offline
sha256sum -c SHA256SUMS                 # 全包校验
bash scripts/load_image.sh              # docker load
bash scripts/setup_data.sh              # 解压数据缓存（约 1 分钟，一次即可）
cp env/company.env.example env/company.env
vi env/company.env                      # 填 OC_API_BASE/OC_API_KEY/OC_MODELS（HLE 再填 OC_JUDGE_*）
```

### 4.2 运行与查看

```bash
bash scripts/run.sh compare_20261101                 # standard
OC_SUITE=quick bash scripts/run.sh smoke             # 先冒烟验证接口/限速
OC_SUITE=zh bash scripts/run.sh zh_compare
OC_SUITE=hard bash scripts/run.sh hard_compare       # LiveCodeBench + HLE（需 OC_JUDGE_*）
OC_SUITE=full bash scripts/run.sh full_compare
bash scripts/show_results.sh                         # 最近一次汇总
```

### 4.3 HLE 的 LLM-Judge

HLE 需要 judge 模型（只支持 OpenAI 兼容接口）：

```bash
OC_JUDGE_MODEL=<judge 模型名>
OC_JUDGE_API_KEY=<judge key>
OC_JUDGE_API_BASE=<OpenAI 兼容地址，到 /v1 为止>
```

建议 judge 使用与候选模型**不同**的较强模型，并在报告中记录 judge 型号；judge 与候选相同会引入自评偏差。
judge 调用量与 HLE 题量相同（2,158），需单独考虑限流。

### 4.4 离线自检

```bash
bash scripts/selfcheck.sh
```

在 `--network none` 下用容器内 mock 模型 + mock judge 跑通
「数据加载 → 推理 → 判分 → 汇总」全链路（含 HumanEval/LiveCodeBench 代码执行与 HLE judge），
输出 `SELFCHECK OK` 即离线可用。自检分数无意义。

## 5. 实测验证（2026-11-01）

- 镜像与数据在 **Docker 20.10.24**（dind）上 `docker load` 成功，并嵌套运行离线自检通过（含 LCB/HLE 链路）；
- `--network none`：规则判分、代码执行判分（HumanEval/MBPP/LCB）、LLM-Judge（HLE，mock judge）全部跑通；
- `hard` 套件用真实 `compare.py` 配置 + mock judge 端到端冒烟通过；
- OpenAI 兼容（`OpenAISDK`）与 Anthropic 兼容（`ClaudeSDK`）两条链路均验证；
- 数据预热 203 条、0 失败；`sha256sum -c SHA256SUMS` 全包通过。

## 6. 口径与限制（重要）

1. **不可与模型卡 11 项分数混用**：本包是通用能力自测，与主评测包的 agentic 口径不同。
2. **HLE 只含纯文本**：官方 2,500 题中 342 道含图，本包沿用 OpenCompass `image == ''` 过滤，实际 2,158 题；HLE 数据仅限公司内部使用，不要公开传播/再上传。
3. **LiveCodeBench 版本**：使用 OpenCompass `livecodebench_v6_academic`（v6 code generation 175 题 × 6 采样），不是「全部发布时间窗口」。
4. **数据许可**：HLE 为 MIT（含 canary 字符串，官方要求不公开传播）；LCB 为 MIT；C-Eval、CMMLU 等对商用/再分发另有约定；对外发布结果前请逐项核对。
5. **LLM-Judge 依赖**：`hard` 套件需要可用 judge；`standard/zh/full` 无 judge 依赖。
6. 结果只适合**同配置下的模型间比较**，不要直接对榜（prompt/few-shot/版本差异）。

## 7. 数据来源

| 数据 | 来源 |
| :-- | :-- |
| OpenCompass 平台/框架 | <https://github.com/open-compass/opencompass> · <https://opencompass.readthedocs.io/zh_CN/latest/> |
| 大部分数据集缓存 | OpenCompass OSS（`opencompass.oss-cn-shanghai.aliyuncs.com`，zip + md5） |
| LiveCodeBench v6 | <https://huggingface.co/datasets/livecodebench/code_generation_lite> · <https://livecodebench.github.io/>（MIT） |
| LiveCodeBench execution/test output | OpenCompass OSS `execution-v2.zip` / `test_generation.zip` |
| HLE | 官方 <https://huggingface.co/datasets/cais/hle>（gated）；经 ModelScope 镜像 <https://modelscope.cn/datasets/cais/hle> 下载后转本地纯文本缓存；官网 <https://lastexam.ai/>（MIT，内部使用） |
| HumanEval 判分器 | <https://github.com/open-compass/human-eval>（OpenCompass fork） |

## 8. 重建方法（维护者）

离线包在开发机构建（构建资料在 `sandbox/opencompass/`，未入仓库，避免仓库体积膨胀）：

1. `build/Dockerfile` 构建 `opencompass-offline:0.5.4` 镜像；
2. 数据目录 `data/` 放入 HLE/LCB 本地数据后，运行容器内 `prepare_inside.sh`（`warmup_data.py`）加载并记录 manifest；
3. `docker buildx build --output type=docker,dest=...` 导出镜像 tar（含 manifest.json，兼容 Docker 20.10）；
4. 容器内 `tar -czf` 打包数据目录；
5. 用 `make_manifest.py` 生成 `SHA256SUMS` 与 `manifest.json`，再用 Docker 20.10 dind 做一次 `docker load` + 离线自检。

如需更新（新增数据集/升级 OpenCompass），按同一流程重建并替换 `E:\opencompass-offline` 下的 `docker/`、`data/`、`configs/`、`scripts/`，再重生成校验文件。

## 9. 变更记录

| 日期 | 变更 |
| :-- | :-- |
| 2026-10-31 | 首版：OpenCompass 0.5.4 + 13 个数据集族、4 档套件，约 716 MB，Docker 20.10.24 实测 |
| 2026-11-01 | 新增 **LiveCodeBench**（v6 codegen + execution + test output）与 **HLE（LLM-Judge）**；新增 `hard` 套件；数据 203 条，整包约 808 MB |
