# 第一批离线包：打包实录（2026-10-31）

> 目标：把 Automation-Bench + ProgramBench（3 题）+ DeepSWE（10 题）打包成可带到公司断网 Linux 环境运行的 Docker 离线包。
> 结果：**已生成 `E:\bench-bundle`，整包 5.06 GB，全部验证通过。**

## 1. 最终产物

```
E:\bench-bundle\
├─ README.md                    # 公司端使用说明
├─ manifest.json                # 版本/清单
├─ SHA256SUMS                   # 镜像 tar 校验
├─ Dockerfile                   # runner 构建文件（可重建）
├─ images\
│  ├─ bench-images.tar          # 5.01 GB，14 个镜像（单 tar，共享层只存一份）
│  ├─ image-list.txt
│  └─ SHA256SUMS
├─ data\                        # ~60 MB
│  ├─ AutomationBench\          # v1.0.6, commit 4a8e106
│  ├─ deep-swe\tasks\           # commit 0b9fabbb，113 题任务定义
│  ├─ deepswe_selected.json     # 本次 10 题清单
│  ├─ programbench_blobs\       # 3 题的 tests/*.tar.gz（HF snapshot 5954a19）
│  └─ tools\mock_openai_server.py
├─ offline\
│  ├─ docker-compose.yml
│  ├─ load_bundle.sh            # 公司端：校验 + docker load
│  ├─ run_stage1.sh             # 公司端：端点/容器/小样本自检
│  └─ env\example.env
└─ logs\
```

## 2. 镜像清单（14 个）

| 类别 | 镜像 | 说明 |
| :-- | :-- | :-- |
| runner | `bench-eval-runner:local` | Ubuntu 24.04 + uv + Harbor 0.25.0 + Pier 0.3.1 + mini-swe-agent 2.4.6 + ProgramBench 1.2.5 + AutomationBench（Python 3.13 venv） |
| ProgramBench | `programbench/ajeetdsouza_1776_zoxide.67ca1bc:task_cleanroom_v6` 等 3 个 | 镜像名规则：`instance_id.replace('__','_1776_')` |
| DeepSWE | `public.ecr.aws/d3j8x8q7/swe-bench-202605:<hash>-v1.1` × 10 | 任务镜像在 public ECR，需预拉 |

DeepSWE 选中的 10 题（语言覆盖 python/go/typescript/javascript/rust 各 2 题）见 `data/deepswe_selected.json`。

## 3. 关键经验（下次打包直接复用）

1. **镜像包不要逐个 `docker save`**：14 个镜像逐个 save 会膨胀到 ~50GB；**单 tar `docker save img1 img2 ...` 会去重共享层，最终只有 5.01GB**（任务镜像共享同一 base）。
2. **ProgramBench 镜像命名**：`DOCKER_ORG/instance_id.replace('__','_1776_')`，tag `task_cleanroom_v6`；单镜像 `docker images` 显示约 4.2GB，但共享层后整包很小。
3. **ProgramBench 离线数据**：用 `PROGRAMBENCH_BLOB_DIR=<本地目录>` 指向 `<instance_id>/` 结构；`blob sync` 在有本地目录时只校验不下载。
4. **容器内 pip 不可用**（Docker build 中 `pip3 install` 返回 "from versions: none"），但 `uv tool install` 正常；runner 构建改为全 uv。
5. **Aliyun Docker Hub 镜像偶尔 403**：同一镜像隔一会儿重试即可（ubuntu:24.04 首次 403、重试成功）。
6. **Docker Desktop 需先启动**（daemon 29.9.2）；`docker.sock` 兄弟容器在 Windows 上同样可用。
7. **AutomationBench 要求 Python ≥3.13**：runner 里用 `uv sync --frozen --python 3.13` 烘焙独立 venv，运行期 `uv run --offline` 可用。

## 4. 已完成验证

| 验证项 | 结果 |
| :-- | :-- |
| `docker load -i images/bench-images.tar` | ✅ 全量加载 |
| sha256 校验（Ubuntu 容器内 `sha256sum -c`） | ✅ OK |
| runner 工具链 | ✅ harbor/pier/mini-extra/programbench/auto-bench |
| **docker.sock 兄弟容器** | ✅ runner 内 `docker run hello-world` 成功 |
| **完全离线（--network none）AutomationBench + mock** | ✅ 1 题跑完、判分、导出 JSON、exit 0 |
| ProgramBench 本地 blob 解析 | ✅ 离线指向本地目录 |

## 5. 未验证 / 已知限制

- **未跑真实模型的大样本**：ProgramBench/DeepSWE 的完整端到端（含任务容器 + 真实模型）留到公司环境；本机只验证了链路与容器。
- **模型 API**：公司内网端点需可达（或宿主机反代 + `host.docker.internal`）。
- ProgramBench 仅 3 题、DeepSWE 仅 10 题镜像；扩题需重跑打包（在家）。
- 镜像 tar 5GB，建议用移动 SSD 传输（U 盘也行，但慢）。

## 6. 公司端最短路径

```bash
cd /path/to/bench-bundle
./offline/load_bundle.sh            # 校验 + docker load
cp offline/env/example.env offline/env/company.env && vi offline/env/company.env
docker compose -f offline/docker-compose.yml --env-file offline/env/company.env up -d
docker compose -f offline/docker-compose.yml exec runner bash /workspace/offline/run_stage1.sh
```

详细说明见离线包内 `README.md`。

## 7. 端到端冒烟实录（2026-10-31）：基础设施通，模型格式待调

用 Ark `deepseek-v4-flash` 跑 ProgramBench 单题（`ajeetdsouza__zoxide`），依次暴露并修复了 4 个问题：

| # | 现象 | 原因 | 修复 |
| :-: | :-- | :-- | :-- |
| 1 | `docker run ... exit 125: range of CPUs is from 0.01 to 16.00` | ProgramBench 默认要求 20 CPU / 60GB，本机 16 CPU / 16GB | 覆盖 `environment.run_args`，去掉 `--cpus/--memory/--memory-swap`（公司机器可能同样需要） |
| 2 | `ModuleNotFoundError: No module named 'programbench'` | `mini-extra programbench` 要求 programbench 在 mini-swe-agent 的同一 Python 环境 | `uv tool install mini-swe-agent --with programbench==1.2.5` |
| 3 | `ModuleNotFoundError: No module named 'mcp'` | LiteLLM 1.106 懒加载 `mcp` | 同上 `--with mcp` |
| 4 | `litellm.InternalServerError: Missing credentials` / `LLM Provider NOT provided` | LiteLLM 只读 `OPENAI_API_KEY`；裸模型名无法判断 provider | 容器加 `-e OPENAI_API_KEY`；模型名用 `openai/<model>` 前缀 |

**最终状态**：任务容器启动 ✅、模型 API 调用 ✅、agent 跑了 13 分钟 ✅、`submission.tar.gz` + 轨迹已生成 ✅；但 Ark `deepseek-v4-flash` 是推理型模型，经 LiteLLM 输出的内容反复无法被 mini-swe-agent 解析（`RepeatedFormatError`），ProgramBench 判分未完成。

**结论**：
- 离线包与容器链路**没有阻塞问题**；卡点在「推理模型的 tool-call 输出格式」与 scaffold 的适配。
- 到公司用内网模型时，建议先跑 `run_stage1.sh` 的 Automation simple 1 题；若模型也有 reasoning/tool-call 格式问题，需要按 `report/api-only-5bench-plan.md` 的做法调 `format_error_template` / 换非推理模型 / 用支持原生 tool-calling 的模型。
- DeepSWE（Pier + mini-swe-agent）同样会受此影响，建议先用 1 题验证模型格式兼容性再放量。

## 8. 后续：ProgramBench 端到端跑通并拿到真实分数（2026-10-31）

在修复以下 5 项后，Ark `deepseek-v4-flash` 在 `ajeetdsouza__zoxide.67ca1bc` 上完成「agent → 提交 → eval」全链路：

| # | 问题 | 修复 |
| :-: | :-- | :-- |
| 1 | 任务容器 20 CPU/60GB 超限 | 覆盖 `environment.run_args`（去掉 `--cpus/--memory`） |
| 2 | `No module named 'programbench'` | runner 镜像 `uv tool install mini-swe-agent --with programbench==1.2.5` |
| 3 | `No module named 'mcp'` | 同环境 `--with mcp` |
| 4 | 凭据/模型名 | 容器加 `-e OPENAI_API_KEY`，模型名 `openai/<model>`，`max_tokens=16384`（否则推理内容截断 → RepeatedFormatError） |
| 5 | **eval 报 `results_read_failed`** | 官方 `eval/run.sh` 会 `pip install pytest-timeout`；断网时失败。给任务镜像做派生修复（预装 pytest-timeout + 本地 wheelhouse + `/etc/pip.conf` 禁网），见 `offline/programbench-eval-fix/` |

**结果**：

```
Evaluation Summary
 ajeetdsouza__zoxide.67ca1bc   Score 56   (531 tests)
 Average                       56   1 instances
```

> 注意：Score=56 是**测试通过比例**，任务未 resolved（ProgramBench 主指标 Resolved 要求全部测试通过）。当前 agent 在 40 步/900 秒上限处被截断（LimitsExceeded），提高 `step_limit`/`wall_time_limit_seconds` 有望更高。

**本次运行消耗**（同一 trajectory 统计）：92 次模型调用，prompt 1,654,554 tokens，completion 51,123 tokens（其中 reasoning 36,463），墙钟 12 分 57 秒；无缓存外网成本可忽略。

## 9. DeepSWE 单题冒烟（2026-10-31）

**目标**：用 Pier + mini-swe-agent 跑 1 道 DeepSWE 题（`abs-module-cache-flags`，Go），验证任务环境、模型调用、agent 执行、verifier 链路。

**冒烟中修复的 4 个问题**：

| # | 现象 | 根因 | 修复 |
| :-: | :-- | :-- | :-- |
| 1 | `unknown flag: --project-name` | runner 镜像缺 `docker compose` 插件（Pier 用 compose 起任务环境） | Dockerfile apt 加 `docker-compose-v2` |
| 2 | `NonZeroAgentExitCodeError`（agent 无输出） | Pier 对 `openai/` 前缀自动选 `litellm_response`（Responses API），Ark 不支持 | agent kwargs `model_class: litellm` |
| 3 | `ModuleNotFoundError: No module named 'mcp'` | Pier 在任务镜像里现场装 mini-swe-agent 不带 `mcp`，LiteLLM 懒加载失败 | agent kwargs `extra_python_packages: [mcp]` |
| 4 | CLI 多层引号导致 `model_kwargs` 被转义破坏 | PowerShell→bash→pier 的 `--ak` 参数 | 改用 **Pier YAML job 配置**（`offline/deepswe-pier-job.example.yaml`） |

**验证结果**：
- ✅ 任务环境：Pier 通过 docker compose 构建并启动 DeepSWE 任务镜像（2 CPU / 8GB 任务限制已被 `cpu/memory_enforcement_policy: ignore` 覆盖）
- ✅ 模型调用：Agent 在沙箱内实际执行 8–14 分钟（多次 ReAct 步骤、工具调用），无凭据/格式错误
- ⚠️ 未拿到 verifier 分数：官方单题 agent 预算 3 小时；冒烟设 14–36 分钟时限，到点被截断（`AgentTimeoutError`），或被 mini-swe 的 `step_limit` 提前结束导致空 patch → `RewardFileNotFoundError`
- 结论：**链路可用，DeepSWE 单题真实耗时在 30 分钟–数小时量级**；正式评估建议 `agent_timeout_multiplier: 0.5–1.0`，10 题可 `n_concurrent_trials: 2–4` 并行（注意本机资源）

**模板**：[`offline/deepswe-pier-job.example.yaml`](deepswe-pier-job.example.yaml)
