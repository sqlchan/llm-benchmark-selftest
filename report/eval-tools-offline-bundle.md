# 评测工具链离线包（DeepEval + Langfuse）

> 日期：2026-11-01 ｜ 定位：**辅助工具包**，用于上线后回归与生产观测，**不属于**模型卡 11 个基准，也不产出选型分数。
> 交付物：`E:\bench-bundle\tools\eval-tools`（约 **1.3 GB**），随主离线包同盘分发。
> 相关：[`eval-toolchain-offline.md`](eval-toolchain-offline.md)（五家工具可行性对比）、[`opencompass-offline-bundle.md`](opencompass-offline-bundle.md)（通用能力对比包，808 MB）。

## 1. 为什么单独打这个包

主包 `bench-bundle` 解决「**选型**」：用 5 个 agent/软件工程基准比出候选模型的强弱。
但公司采购落地还缺两件事：

1. **上线后回归**：模型/提示词一改，自己的应用输出有没有退化 → 需要能写断言的评测框架；
2. **生产观测**：线上到底发生了什么、花了多少 token、哪一步失败 → 需要 trace 平台。

`eval-toolchain-offline.md` 已论证这两类工具都能离线化，但此前**没有实际打包**。本包把其中成本最低的两个落地：

| 工具 | 角色 | 是否产基准分 |
| :-- | :-- | :-- |
| **DeepEval 4.3.2** | pytest 风格的应用评测框架（50+ 指标，judge 可指向内网 OpenAI 兼容端点） | ❌ 测自己的应用输出 |
| **Langfuse 4.72.0** | LLM 观测平台（trace/span、数据集、LLM-as-judge、成本） | ❌ 记录与分析 |

SWE-bench 与 OpenCompass 不进本包：前者与 DeepSWE 重复且离线成本最高（官方建议 120 GB），后者已有独立 808 MB 包。AgentCompass 暂不打包（需联网机先验证 1 题，见 §8）。

## 2. 包内容

| 路径 | 内容 | 大小 |
| :-- | :-- | --: |
| `docker/deepeval-offline-4.3.2.tar` | 预装 DeepEval 的镜像（python:3.12-slim + 离线 wheelhouse + 遥测关闭） | 109.5 MB |
| `docker/langfuse-v4-4.72.0-images.tar` | Langfuse v4 六镜像：web / worker / ClickHouse 26.3.62.3 / MinIO(chainguard) / Redis 7 / Postgres 17 | 1157 MB |
| `wheelhouse/deepeval-4.3.2-cp312.tar.gz` | 66 个 wheel（linux/cp312），装进公司自己的 Python 环境 | 25.1 MB |
| `wheelhouse/langfuse-sdk-5.1.0-cp312.tar.gz` | 28 个 wheel，Langfuse Python SDK（v4 OTLP 写入） | 5.5 MB |
| `compose/` | 官方 v4 compose（仅把 `TELEMETRY_ENABLED` 默认改为 false）+ `.env.example` | < 100 KB |
| `scripts/` | `load.sh` / `deepeval-demo.sh` / `langfuse-up.sh` / `langfuse-down.sh` / `langfuse-smoke.sh` / `selfcheck.sh` | < 100 KB |
| `examples/` | `test_demo.py`（断网确定性指标用例）、`langfuse_smoke.py`（OTLP 写入） | < 100 KB |
| `README.md`、`manifest.json`、`SHA256SUMS`、`docs/build-info.md` | 使用说明 / 机读清单 / 校验 / 构建记录 | < 100 KB |

合计 17 个文件、约 1.3 GB。`SHA256SUMS` 覆盖除自身外的全部文件。

## 3. 版本与锁定

| 组件 | 版本 | 说明 |
| :-- | :-- | :-- |
| DeepEval | **4.3.2** | PyPI 当日最新；`Requires-Python >=3.9,<4.0`；镜像内 Python 3.12 |
| Langfuse 服务端 | **4.72.0** | 镜像 tag `:4` 是**浮动**的，本包以 digest 锁定（见 manifest） |
| Langfuse SDK | **5.1.0** | 与 v4 服务端配套，走 OTLP |
| ClickHouse / Redis / Postgres | 26.3.62.3 / 7 / 17 | 与官方 compose 一致 |
| MinIO | chainguard `latest` | 无版本 tag，digest 锁定 |

镜像 ID 已写入 `manifest.json`，`docker load` 后可直接比对。

## 4. 构建方式（可复现）

1. 联网机 `pip download deepeval==4.3.2`（容器内，cp312）→ wheelhouse；
2. `Dockerfile.deepeval` 用 `pip install --no-index --find-links` 构建镜像，**安装阶段不联网**；
3. `docker pull` 官方 6 镜像（compose 原文），`docker save` 合并为一个 tar；
4. 脚本/示例/compose/文档随包附上，`SHA256SUMS` 与 `manifest.json` 生成。

完整命令见包内 `docs/build-info.md`。

## 5. 验证矩阵（2026-11-01 实测）

| 验证项 | 结果 |
| :-- | :-- |
| `docker save` → `docker rmi` → `docker load` 往返 | 7 个镜像 ID 与打包前完全一致 |
| DeepEval 断网运行（`--network none`） | `deepeval test run` 2/2 通过，退出码 0 |
| Langfuse 6 容器启动 | 全部 healthy；`/api/public/health` → `{"status":"OK","version":"4.72.0"}`（约 15 s） |
| 首次初始化 | `LANGFUSE_INIT_*` 自动建 org `company` / project `llm-eval`，public API Basic Auth 200 |
| OTLP 写入 | SDK 5.1.0 发送后 ClickHouse `events_full` 出现 `name=offline-smoke` 记录 |
| 旧协议行为（记录） | v4 默认 `events_only` 拒收 `/api/public/ingestion` 的 `trace-create`（400），需 `LANGFUSE_MIGRATION_V4_WRITE_MODE=dual` 才兼容老 SDK |
| 脚本 | 6 个 `bash -n` 通过；`langfuse-up.sh` 的 `.env` 自动生成逻辑在隔离目录实测通过 |

## 6. 公司怎么用

```bash
cd <bundle>/tools/eval-tools
bash scripts/load.sh            # 载入 7 个镜像
bash scripts/deepeval-demo.sh   # DeepEval 断网自检（应 2/2 通过）
bash scripts/langfuse-up.sh     # 启动 Langfuse（首次自动生成 compose/.env 与账号）
bash scripts/langfuse-smoke.sh  # 可选：OTLP 写入冒烟
bash scripts/selfcheck.sh       # 汇总自检
```

- DeepEval 接内网模型：`OpenAIModel(model=..., base_url=..., api_key=...)`，或设 `OPENAI_BASE_URL`/`OPENAI_API_KEY`/`OPENAI_MODEL_NAME`；
- 确定性指标（ExactMatch/PatternMatch）**不需要 judge**，纯断网可跑；语义类指标才需要；
- Langfuse 上线前改 `NEXTAUTH_URL` 为内网地址；老 SDK 兼容见 §5；
- 数据在 5 个命名卷，备份 = Postgres + ClickHouse + MinIO。

细节见包内 `README.md`。

## 7. 与主包 / 仓库的关系

- 主包 `load_bundle.sh` 只扫 `images/*.tar*`，**不会**加载本工具包，Day-1 加载顺序与耗时不变；
- 本包不改变 11 基准的数据流，也不进 `research/`/`report/` 的生成链；
- 与 `E:\opencompass-offline`（通用能力对比，808 MB）并列：选型看主包，广度看 OpenCompass，上线回归/观测看本包。

## 8. 已知限制与未做项

1. wheelhouse 只覆盖 **cp312**；公司应用若是 3.10/3.11，需联网机重下（命令在 `docs/build-info.md`）；
2. Langfuse 单机 compose，非高可用；生产用应外接 PG/CH/S3 并做备份；
3. DeepEval 内置 benchmark（MMLU/HellaSwag 等）数据**未预热**，首次用会联网；
4. `langfuse:4`、`minio:latest` 是浮动 tag，重打会漂移，需重跑验证；
5. **未打包**：AgentCompass（需先联网机跑通 1 题 Harbor 任务）、SWE-bench（与 DeepSWE 重复、离线成本最高）。

## 9. 来源

**本仓库**：[`eval-toolchain-offline.md`](eval-toolchain-offline.md)、[`opencompass-offline-bundle.md`](opencompass-offline-bundle.md)、[`../study/README.md`](../study/README.md)（DeepEval/Langfuse 学习手册与源码解析）、包内 `README.md` / `docs/build-info.md`。

**上游**：
- DeepEval <https://github.com/confident-ai/deepeval> ｜ 指标 <https://deepeval.com/docs/metrics-introduction>
- Langfuse <https://github.com/langfuse/langfuse> ｜ 自托管 <https://langfuse.com/self-hosting/deployment/docker-compose> ｜ v3→v4 升级 <https://langfuse.com/self-hosting/upgrade/upgrade-guides/upgrade-v3-to-v4>
