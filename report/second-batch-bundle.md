# 第二批离线包：Terminal-Bench 4.0 + NL2Repo-Bench 打包实录（2026-10-31）

> 目标：把 **Terminal-Bench 4.0（v4.0.0）15 题** 与 **NL2Repo-Bench 10 题** 做成断网 Linux + Docker 可运行的离线包，模型走公司内网 OpenAI 兼容端点。
> 产物：`E:\bench-bundle\images\bench-images-batch2.tar`（**21.24 GB**，SHA256 `f91f4d9b70e9dcb5b86836df914f9cc873787a507fcf020fd8b3cde95e4faba9`）、
> `images/bench-images-runner-v2.tar`（0.59 GB，SHA256 `1d167439805f7ad05866fdddae0e91f8683208e9c7e8d4b19e46c3c5da04eb34`）、
> `data/tb4/`、`data/nl2repo/`、`offline/run_batch2*.sh`。离线包整包约 25.6 GB。
> 结论：**两个基准的离线链路都已打通**（详见第 6 节验证矩阵）。

## 1. 为什么第二批难在第一批之上

第一批（Automation-Bench + ProgramBench + DeepSWE）的镜像都是"自带环境"的；第二批的两个基准都有**运行时联网依赖**，必须逐层解决：

| 基准 | 断网时会断的环节 | 解决方式 |
| :-- | :-- | :-- |
| Terminal-Bench 4.0 | ① Harbor 安装 agent 时 `curl astral.sh` + `uv tool install`<br>② `apt-get install ca-certificates` 无条件执行<br>③ 任务镜像按 `@sha256:` digest 引用 | ① 派生任务镜像预装 uv+CPython3.12+mini-swe-agent+wheels 缓存（`UV_OFFLINE=1`）<br>② 给 runner 镜像打 Harbor 补丁（`offline/patches/harbor_offline_patch.py`）<br>③ 任务包内的镜像引用改写为 release tag |
| NL2Repo-Bench | ① `docker.all-hands.dev` 已 **NXDOMAIN**（原 registry 下线）<br>② OpenHands 对 volume 路径做正则校验，必须是 `/` 开头的宿主机路径<br>③ 运行时 CLI 命令含空格的任务文本被拆成 argv<br>④ 评测 `pip install -e .` 需要构建后端（hatchling 等）联网 | ① 换 `ghcr.io/all-hands-ai/openhands:0.56` + `runtime:0.56-nikolaik`（已验证可拉）<br>② 新增 `NL2REPO_HOST_ROOT`：runner 以「相同绝对路径」挂载离线包，容器路径=宿主机路径<br>③ 改用 `bash -c` + `shlex.quote`<br>④ 派生测试镜像（标签不变）预装 build-system.requires + 项目依赖，评测命令改为 `pip install --no-build-isolation --no-index -e .` |

## 2. TB4 子集选择（15/66）

筛选条件：Software/Operations/Security/Media 中与软件开发相关、排除 3 个 H100 GPU 题（`fp8-rmsnorm-gemm`、`jax-speedrun-gpu`、`math-eval-grader`）、优先 2 镜像以内、expert 时间可接受。

| 领域 | 任务 |
| :-- | :-- |
| 系统/调试 | `bun-sourcemap-leak`、`session-window-debug`、`kv-live-surgery` |
| 数据库 | `live-database-cutover`、`mvcc-lsm-compaction`、`wal-recovery-ordering` |
| 前端 | `cumulative-layout-shift`、`react-lead-form`、`nextjs-performance` |
| 算法/安全 | `vf2-speedup-networkx`、`html-js-filter`、`shadow-relay` |
| 遗留系统/服务 | `vba-userform-port`、`legacy-utility-triage`、`payments-pipeline-fix` |

镜像组成（**40 个**）：
- 15 个派生 environment 镜像 `tb4off/environment:<task>`（官方镜像 + 离线 agent 载荷）
- 15 个官方 verifier 镜像 `harborframework/terminal-bench:<task>-verifier-v4.0.0`
- 10 个 compose sidecar 镜像（release tag）

## 3. 离线 agent 载荷（TB4 的关键发明）

Harbor 0.25.0 的 `MiniSweAgent.install()` 固定执行：

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv python install 3.12
uv tool install --python 3.12 mini-swe-agent --with litellm --with orjson --with fastapi
```

离线方案：**只构建一次载荷**（`offline/tb4-agent-payload/`），再 COPY 进每个任务镜像：

```
/opt/tb4-agent/
├─ python/        # uv 管理的 CPython 3.12（python-build-standalone）
├─ tools/         # uv tool 安装的 mini-swe-agent 2.4.6 + litellm/orjson/fastapi
├─ bin/           # mini-swe-agent 等入口（软链到 /usr/local/bin）
└─ uv-cache/      # 安装上述包用到的全部 wheel（~205MB 压缩）
ENV UV_CACHE_DIR=... UV_PYTHON_INSTALL_DIR=... UV_TOOL_DIR=... UV_TOOL_BIN_DIR=... UV_OFFLINE=1
```

**离线验证（`--network none`）**：

```
$ docker run --rm --network none tb4off/environment:bun-sourcemap-leak \
    bash -c 'uv python install 3.12 && uv tool install --python 3.12 mini-swe-agent --with litellm --with orjson --with fastapi && mini-swe-agent --help'
Installed Python 3.12.16 in 37ms
Resolved 84 packages in 131ms
Installed 4 executables: mini, mini-e, mini-extra, mini-swe-agent
→ OFFLINE_AGENT_OK
```

> 载荷 `tb4-agent-payload.tar.gz` **205 MB**，`uv` 二进制 38 MB；同一载荷层在不同 base 上会被 docker 层去重。

## 4. Harbor 离线补丁（runner 镜像内）

`offline/Dockerfile.runner.v2` 构建时执行 `offline/patches/harbor_offline_patch.py`，对 Harbor 0.25.0 做 3 处最小补丁：

1. `ca_certificates` 的 `always_install=True` → `False`（断网时不再无条件 `apt-get update`）；
2. `ensure_system_dependencies` 的安装调用失败时，`HARBOR_OFFLINE=1` 下只告警不抛错（工具链已预装）；
3. `MiniSweAgent.install()` 先探测 `/opt/tb4-agent/bin/mini-swe-agent`，已预装则跳过联网安装。

同时 runner v2 增加 `docker-buildx`（NL2Repo 后处理需要 `docker build`）与 `/opt/nl2repo-venv`（python-on-whales）。

## 5. NL2Repo 离线适配
### 5.1 镜像源迁移
原 `docker.all-hands.dev/all-hands-ai/*` 域名已 **NXDOMAIN**（DoH 查询返回 Status 3），
`ghcr.io/all-hands-ai/openhands:0.56`（1.8GB）与 `ghcr.io/all-hands-ai/runtime:0.56-nikolaik`（3.0GB）可正常拉取，改引用即可。

### 5.2 宿主机路径问题
OpenHands 0.56 对 `sandbox.volumes` 做 `host_path:container_path[:mode]` 校验，要求 `host_path` 以 `/` 开头。容器里跑 harness 时容器路径在宿主机不存在，因此：
- 新增 `NL2REPO_HOST_ROOT` 环境变量（默认 = 当前目录），用于把 workspace/config 的 bind mount 源改写成宿主机路径；
- 离线包运行方式：`docker run -v "$BUNDLE:$BUNDLE" -w "$BUNDLE" ...`，**容器内路径与宿主机完全一致**。

### 5.3 命令拆分
`python -m openhands.core.main ... -t "<含空格的整段任务>"` 在经 docker CLI 封装后会被拆成多个 argv，
`-t` 只吃到第一个词。改为 `bash -c "python -m ... -t '$(shlex.quote ...)'"`。

### 5.4 离线评测
官方测试镜像只含骨架（`pyproject.toml` + `tests/`），`pip install -e .` 会联网装构建后端与依赖。离线包为 10 个任务各构建一个**派生测试镜像**（标签保持官方名）：
构建期从 `pyproject.toml` 读取 `build-system.requires` + `project.dependencies` 并安装；评测命令改写为
`pip install --no-build-isolation --no-index -e .`。

### 5.5 关键补丁：mcp 缺包（打包末期发现）

用 Ark 跑 TB4 mini-swe-agent 冒烟时，agent 安装全部成功、第 1 次 LLM 调用后立即退出：

```
ModuleNotFoundError: No module named 'mcp'
  at litellm/responses/mcp/litellm_proxy_mcp_handler.py -> litellm/proxy/_experimental/mcp_server/catalog.py
```

根因：Harbor 0.25.0 的安装命令没有 `--with mcp`，而 LiteLLM 1.106 顶层导入会加载 mcp；
第一批 ProgramBench 已经踩过同一个坑（`uv tool install mini-swe-agent ... --with mcp`）。

修复：**不重建整个载荷**，只给 15 个派生镜像追加一个 **~5.6MB 的补丁层**（`mcp` 及其 25 个依赖 `cffi/cryptography/httpcore2/httpx2/jwt/multipart/sse_starlette/truststore/uvicorn` 等），
并加 `ENV LITELLM_LOCAL_MODEL_COST_MAP=True`（避免 LiteLLM 启动时联网拉 model cost map）。

- 补丁包：`offline/tb4-agent-payload/agent-extra.tar.gz` + `Dockerfile.agent-mcp-fix`
- 应用脚本：`offline/fix_tb4_images.sh`（幂等：先 `docker run --network none ... import mcp` 检查，缺才构建）
- `offline/load_bundle.sh` 加载镜像后**自动**执行该脚本（`SKIP_TB4_FIX=1` 可跳过）

## 6. 验证矩阵（本机实测）

| 验证项 | 结果 |
| :-- | :-- |
| TB4 官方任务包 + prebuilt 镜像清单 | ✅ v4.0.0 release：66 题 / 157 镜像清单 / 任务包 452MB |
| TB4 40 个镜像按 release tag 拉取 | ✅ 全部成功（v4.0.0 别名） |
| TB4 oracle 端到端（官方镜像，html-js-filter） | ✅ reward=1.0（2/2 测试，约 3 分钟） |
| TB4 oracle 端到端（**派生镜像** + tag 引用，html-js-filter） | ✅ reward=1.0 |
| 派生任务镜像断网安装 agent | ✅ `--network none` 下 `uv tool install` 全部命中缓存 → `OFFLINE_AGENT_OK` |
| TB4 mini-swe-agent 冒烟（Ark `deepseek-v4-flash`） | ⚠️ agent 安装成功、LLM 调用产生轨迹；随后因 **缺 mcp** 退出（NonZeroAgentExitCode）→ 已由 5.5 补丁层修复（修复后镜像内 `import mcp` 通过） |
| mcp 补丁层验证（html-js-filter 派生镜像） | ✅ `--network none` 下 `import mcp/import litellm` 通过（LiteLLM 本地 cost map，无联网重试） |
| NL2Repo 官方测试镜像可拉取（ghcr） | ✅ 10 题全部拉取成功 |
| NL2Repo 派生测试镜像构建 | ✅ 10 个全部构建（标签不变） |
| NL2Repo harness 端到端（容器 + Ark） | ✅ app/runtime 容器启动、LLM 调用、workspace 挂载写文件、后处理构建评测镜像、pytest 运行与结果 JSON |
| OpenHands 0.56 双镜像 | ✅ `ghcr.io/all-hands-ai/openhands:0.56`(1.8GB)、`runtime:0.56-nikolaik`(3.0GB) |
| batch2 tar 完整性 | ✅ `tar -tf` 716 entries / 0 error（Docker 29 的 OCI archive 格式） |

> 备注 1：NL2Repo 冒烟把 `max_iterations` 降到 8 是为了快速验证链路（agent 8 轮后停止，得分很低属正常）；
> workspace 挂载/写文件已单独用 "写 hello.txt" 验证通过。
> 备注 2：TB4 正式 agent 分数未在本机跑（单题官方预算 8 小时）；本机只验证「安装 → 模型调用 → 任务执行 → verifier」链路。
> 备注 3：补丁层构建期间本机 Docker 曾因磁盘写满（vhdx 增长到 101GB）导致 containerd snapshot 状态损坏，
> 3 个镜像（live-database-cutover / nextjs-performance / html-js-filter）的补丁构建失败；本机已用 `docker commit` 手工验证
> 其中 html-js-filter 可修复，其余在公司干净环境重跑 `offline/fix_tb4_images.sh` 即可。
> 备注 4：上表除 tar 完整性外的原始证据已归档到
> [`report/results/tb4-oracle/`](results/tb4-oracle/)、[`report/results/tb4-agent-smoke/`](results/tb4-agent-smoke/)、
> [`report/results/nl2repo-smoke/`](results/nl2repo-smoke/)（含 verifier 输出、失败 traceback、评测镜像与 pytest 日志）。

## 7. 与第一批的关系

- **不重新打包**第一批内容：`bench-images.tar`（5.01GB）原样保留，两批 tar 各自加载。
- runner 镜像升级为 `bench-eval-runner:v2`（含 Harbor 补丁/buildx/NL2Repo venv），覆盖第一批的 runner；
  第一批命令（`run_stage1.sh`）兼容 v2。
- 两批共用 `offline/env/company.env` 的模型端点配置。

## 8. 公司端最短路径

```bash
cd /mnt/ssd/bench-bundle
./offline/load_bundle.sh "$PWD"              # 校验 + docker load（两批 tar）+ 自动打 mcp 补丁
cp offline/env/example.env offline/env/company.env && vi offline/env/company.env

./offline/run_batch2.sh oracle               # TB4 离线自检（不需要模型）
BUNDLE_DIR=$PWD TB4_TASKS=html-js-filter ./offline/run_batch2.sh tb4    # 单题冒烟
BUNDLE_DIR=$PWD ./offline/run_batch2.sh tb4  # 全子集（默认并发 2）
BUNDLE_DIR=$PWD NL2REPO_TASKS=aiofiles,humanize ./offline/run_batch2.sh nl2repo
```

分步操作、时间轴与第二批常见错误表见 [`company-day1-checklist-batch2.md`](company-day1-checklist-batch2.md)。

## 9. 已知限制 / 待验证

- **公司断网程度决定任务可用性**：TB4 官方任务默认 `network_mode=public`，部分题目本身依赖公网（下载/查询）。到公司后先跑 `oracle` 自检：oracle 都过不了的题，agent 也过不了，应剔除并在报告标注。
- **模型格式**：Ark 的推理型模型经 LiteLLM + mini-swe-agent 可能触发工具调用格式问题（第一批 ProgramBench 已踩过）；公司内网模型若有原生 tool-calling 更稳。
- **NL2Repo 单题成本/时长波动大**（官方不设轮数上限）；默认串行（端口 3000 固定）。
- **NL2Repo 测试命令改写**属于离线适配，与官方口径有差异，报告引用时需注明。
- TB4 `oracle` 自检已验证；**agent 真实跑分未在本机完成**（单题 8h 预算，冒烟只验证链路）。
