# NL2Repo-Bench 并行化补丁（2–3 并发）

本目录是 **NL2Repo-Bench harness 并行化改动**的说明与补丁工件，供离线包（公司 32C/64G Linux 宿主）使用。

- 目标：让 NL2Repo harness 在单进程内安全并发跑 2–3 题，把 10 题从串行 2–8h 压到约 1–3h。
- 默认行为不变：不设任何新环境变量时等价于原来的串行（端口 3000、`NL2REPO_MAX_POOL=1`、不清理容器）。
- 分数口径不变：并发只影响调度/资源隔离，不影响单题判分协议。

---

## 1. 结论摘要

| 项目 | 结论 |
|---|---|
| 并发能力 | 单进程 `ThreadPoolExecutor(max_workers=NL2REPO_MAX_POOL)`，每任务独立的宿主端口、app 容器、state 卷、工作区、post-process 镜像/容器/日志/结果文件 |
| 隔离修复 | OpenHands state 卷由共享 `.openhands` 改为 **per-port** `.openhands-<port>` |
| 端口问题 | 新增 `NL2REPO_PORT_BASE`（默认 3000），端口 = base + 任务序号，可避开宿主残留容器/其他服务 |
| 残留容器 | 新增可选 `NL2REPO_CLEANUP=1`：启动前清理**本批次任务名**的残留容器（默认关闭） |
| 验证等级 | **机制级已验证**（2 题真并发：线程、端口、容器、state、post-process、result JSON 全通过）；**模型分数不可用**（Windows 宿主限制 + mock），见 §7 |
| 建议并发 | 32C/64G：`NL2REPO_MAX_POOL=3`（先 2 再 3）；不要与 TB4/DeepSWE 同机同时跑 |

---

## 2. 改动文件清单

以下路径均相对**离线包根目录**（仓库里对应 `sandbox/batch2/nl2repo/harness/` 与 `offline/`）。

### 2.1 `data/nl2repo/harness/openhands/openhands_app.py`（核心）

- 顶部新增模块 docstring：说明 `NL2REPO_PORT_BASE` / `NL2REPO_CLEANUP` / `NL2REPO_HOST_ROOT` 与 per-port 隔离设计。
- 新增 `DEFAULT_PORT_BASE = 3000` 与解析函数 `_env_int()` / `_as_bool()` / `_resolve_port_base()` / `_resolve_cleanup()`：
  **config.json 字段优先，其次同名环境变量，最后默认值**（非法值告警后回退）。
- `start_app()`：OpenHands state 目录
  `_host_path(".openhands")` → `_host_path(f".openhands-{app_data.port}")`，首跑自动创建并打印路径；
  每个并发实例不再共享同一个 `/.openhands` 卷。
- `start_app()`：任务启动日志补充 `host port N, container openhands-app-N`，便于并发取证。
- 新增 `cleanup_stale_containers(task_list)`：`NL2REPO_CLEANUP=1` 时在线程池启动**之前**，
  只按本批次精确容器名清理残留：`openhands-app-<port>`、`python-test-<task_uuid>`；
  不会误删其他 harness 进程（不同端口基数 → 不同名字）或用户容器。逐个容器记日志。
- `start_openhands()`：
  - 解析并打印 `port_base` / `cleanup` / `max_pool_size`；
  - 端口分配由硬编码 `3000 + i` 改为 `port_base + i`；
  - 端口范围校验（1–65535；末端口越界直接中止并提示调小 `NL2REPO_PORT_BASE`）；
  - 同名任务去重（并发下同名任务会复用 `workspaces/<name>_bo1`、`result/<uuid>.json`、
    `openhands-app-<port>`、`python-test-<uuid>`，原串行实现会静默互相覆盖）；
  - 启动前打印 `Task/port plan`（如 `aiofiles->3000, humanize->3001`）。

### 2.2 `offline/run_batch2.sh`

- 新增**通用 PROFILE 机制**：先 `source offline/env/company.env`（端点/模型），
  若设置 `PROFILE`（如 `32c64g`）则再 `source "$BUNDLE/offline/config/$PROFILE.env"`
  （并发/超时等运行参数，覆盖 company.env 同名变量）。
  - **注意**：profile 在 company.env **之后** source，因此 profile 内赋值的变量
    （`TB4_N_CONCURRENT`、`NL2REPO_MAX_POOL`、`NL2REPO_PORT_BASE`、`NL2REPO_TASKS` 等）
    **也会覆盖调用方 export 的同名环境变量**；要临时调这些值请**不要设 PROFILE**，
    或由调用方先 source profile 再覆盖（见 §8）。
  - profile 文件缺失时报错 `exit 2`，并打印 `offline/config/` 下可用 profile 列表；
  - 未设置 `PROFILE` 时行为与原来完全一致。
- `docker run` 新增透传：`-e NL2REPO_PORT_BASE`（默认 3000）、`-e NL2REPO_CLEANUP`（默认 0）。

### 2.3 `offline/run_batch2_inner.sh`

- `run_nl2repo()`：读取 `NL2REPO_PORT_BASE` / `NL2REPO_CLEANUP`，除 `max_pool_size` 外
  一并写入 harness `config.json` 的 `port_base` / `cleanup` 字段（harness 优先读 config）；
  启动前打印 `tasks / max_pool / max_iterations / port_base / cleanup` 解析结果。
- 新增 `NL2REPO_PYTHON` 覆盖（默认 `/opt/nl2repo-venv/bin/python`）：仅用于本机/CI 调试替换解释器，
  公司正式跑不设即可。

### 2.4 补丁工件（本目录/`offline/patches/`）

| 文件 | 用途 |
|---|---|
| `offline/patches/nl2repo_parallel.patch` | harness 补丁，`-p1`（在 harness 根目录应用） |
| `offline/patches/nl2repo_parallel.p0.patch` | 同一改动的 `-p0` 变体（在 harness 根目录应用） |
| `offline/patches/nl2repo_offline_scripts.patch` | `offline/run_batch2.sh` + `offline/run_batch2_inner.sh` 补丁，`-p1`（在离线包根目录应用） |
| `offline/nl2repo-harness/apply_parallel_patch.sh` | 应用/检查/回滚 harness 补丁（默认不修改任何文件，需显式 `--apply-to`） |

补丁基于改动前的 `openhands_app.py`（SHA256 前缀 `F31E446548F9…`，与 E 包 `data/nl2repo/harness` 一致），
应用后 SHA256 前缀 `A3FD56CF5014…`。

---

## 3. 并发设计

### 3.1 隔离矩阵（全部 per-task / per-port）

| 对象 | 命名 | 说明 |
|---|---|---|
| 调度 | `ThreadPoolExecutor(max_workers=max_pool_size)` | 单进程多线程；`max_pool_size` 来自 config.json（`NL2REPO_MAX_POOL`） |
| 宿主端口 | `NL2REPO_PORT_BASE + 任务序号` | 默认 3000/3001/3002… |
| app 容器 | `openhands-app-<port>` | `--rm`；端口 3000→宿主端口 |
| OpenHands state 卷 | `.<bundle>/data/nl2repo/harness/.openhands-<port>` | **本次修复点**（原为共享 `.openhands`） |
| 工作区 | `workspaces/<pro>_bo1/workspace` | 每任务独立，`{{VOLUMES}}` 指向自己的 workspace |
| OpenHands 配置 | `workspaces/<pro>_bo1/config.toml` | 每任务独立生成 |
| post-process Dockerfile/build context | `workspaces/<pro>_bo1/` | 每任务独立，behind 各自目录 |
| 测试镜像 tag | `python-test-<pro>_bo1` | 每任务独立 tag，并发 build 不冲突 |
| 测试容器 | `python-test-<pro>_bo1` | 每任务独立名，跑完 stop+remove |
| 任务日志 | `workspaces/<pro>_bo1/log.log` | 每任务独立文件 |
| 结果文件 | `result/<pro>_bo1.json` | 主线程在 future 完成后串行写，无写冲突 |
| 进程级日志 | `logs/application.log` | 单进程内 logging 模块自带线程锁，安全 |

### 3.2 线程安全复核（`grep` 结论）

- `docker_self/docker_service.py`：**每次操作都新建 `DockerClient`**（`create_docker_client()`），
  底层是独立 `docker` 子进程调用 → 多线程并发安全。
- `logging_config.py`：单进程 `RotatingFileHandler` 由 logging 模块锁保护，线程安全；
  每任务另有独立 `log.log`（`DualLogger`）→ 无共享写。
- `test_data_service.test_data_list`：启动线程池前在主线程一次性加载，之后只读。
- `_host_root()` / `_host_path()`：每次读环境变量/拼路径，只读。
- 已知残余（**不影响**当前离线包部署，见 §8）：`create_docker_client()` 的 **TLS 远程分支**会临时修改
  `os.environ`（`DOCKER_HOST` 等），多线程下不是原子操作；离线包默认 `hostname=localhost` 走本地分支，
  不触碰 `os.environ`。若未来改用 TLS 远程 docker，需要改成 per-call env 或加锁。
- `create_openhands_container()` 是**未被调用**的旧函数（其中 state 路径本来就是 per-port），
  对运行时无影响；若将来启用需同步本补丁的默认值。

### 3.3 残留清理（`NL2REPO_CLEANUP=1`）

- 触发时机：线程池启动前（主线程），只清理本批次任务名；
- 清理对象：`openhands-app-<port>`（`--rm` 在进程被 kill / docker 守护进程重启后可能残留）
  与 `python-test-<task_uuid>`（post-process 中断残留）；
- 默认关闭；每次删除都打日志，结束时打印清理数量；
- 不会做全前缀 `openhands-app-*` 通杀，因此**不会误删其他 harness 进程**的容器。

---

## 4. 环境变量表

| 变量 | 默认值 | 作用 | 生效位置 |
|---|---|---|---|
| `NL2REPO_MAX_POOL` | `1`（`run_batch2.sh`）；32c64g profile 置 `3` | 同时跑几题（`max_pool_size`） | `run_batch2_inner.sh` 写 config.json |
| `NL2REPO_PORT_BASE` | `3000` | 宿主端口基数；第 i 题端口 = base + i；**多个 harness 进程并行时必须不同** | `run_batch2.sh` 透传 → config.json `port_base` |
| `NL2REPO_CLEANUP` | `0`（关） | `1` 时启动前清理本批次残留容器 | `run_batch2.sh` 透传 → config.json `cleanup` |
| `NL2REPO_MAX_ITERATIONS` | `500` | 单题最大交互轮数（写入 harness 模板；冒烟可调小，正式跑保持 500 才可比） | `run_batch2_inner.sh` 改模板 |
| `NL2REPO_TASKS` | 不设时 `aiofiles,humanize,sqlparse` | 逗号分隔的题名子集；32c64g profile 为 10 题全量 | `run_batch2_inner.sh` |
| `NL2REPO_HOST_ROOT` | `run_batch2.sh` 自动设为 `$BUNDLE/data/nl2repo/harness` | harness 在**容器内**运行时，提供其对应宿主机绝对路径（docker volume 源路径） | harness `_host_root()` |
| `NL2REPO_PYTHON` | `/opt/nl2repo-venv/bin/python` | 仅调试/CI 替换解释器用，正式跑不设 | `run_batch2_inner.sh` |
| `PROFILE` | 空 | 设置后 `run_batch2.sh` 追加 source `offline/config/$PROFILE.env`（如 `32c64g`） | `run_batch2.sh` |

> 兼容性：`config.json` 里同时支持 `port_base` / `cleanup` 字段（`run_batch2_inner.sh` 会写入）；
> 手工调用 harness 时也可以直接写这两个字段，优先级高于环境变量。

---

## 5. 32C/64G 建议并发与资源估算

- **建议 `NL2REPO_MAX_POOL=3`**（先 2 稳定跑通再上 3；出现 OOM / Docker 明显卡顿 / free < 4–6GB 时退到 2，最低 1）。
- 单题资源：OpenHands app 容器（0.56）+ runtime 沙箱（0.56-nikolaik）+ pytest 测试容器，
  **峰值约 2–4GB 内存/题**（经验估算口径，与 `report/company-32c64g-concurrency.md` 一致）；
  pool=3 合计约 6–12GB，再加宿主 Docker/OS 基线余量，32C/64G 安全。
- 端口：pool=3 占 3 个宿主端口（默认 3000–3002）；被占用时整段后移（如 `NL2REPO_PORT_BASE=3100`）。
- 磁盘：每题会 `docker build` 一个 `python-test-<task>` 镜像（基于 `nl2repobench/<task>:1.0` + 工作区副本），
  10 题预计新增数 GB～十几 GB 镜像层 + 每任务 workspace zip；建议 Docker data root 放在 1TB 盘
  （与第二批整包 ≥250GB 空闲的口径一致）。
- 工期：10 题串行约 2–8h（Lead/文档口径）；pool=3 理论约 1–3h（含 post-process 的串行尾巴）。
  **本例是估算，未在公司 Linux 宿主实测**，以首跑日志为准。
- **不要**与 TB4（Harbor）或 DeepSWE（Pier）在同一台机器同时跑：内存叠加 + 容器前缀/端口互相干扰；
  NL2Repo 的 app/runtime 容器名模式与其它基准不冲突，但资源是共享的。

---

## 6. 补丁应用 / 校验 / 回滚

### 6.1 应用 harness 补丁

```bash
# 1) 先检查（dry-run，不写盘）
bash offline/nl2repo-harness/apply_parallel_patch.sh \
  --check --apply-to "$BUNDLE/data/nl2repo/harness"

# 2) 应用（自动备份 openhands_app.py 为 .bak-<时间戳>，可用 --strip 0 走 p0 变体）
bash offline/nl2repo-harness/apply_parallel_patch.sh \
  --apply-to "$BUNDLE/data/nl2repo/harness"

# 3) 校验
grep -n "NL2REPO_PORT_BASE" "$BUNDLE/data/nl2repo/harness/openhands/openhands_app.py"
```

> 用 `bash <脚本>` 而不是 `./<脚本>`，避免离线包从 Windows 打包时丢失可执行位；
> 若文件有 +x，`./offline/nl2repo-harness/apply_parallel_patch.sh` 也可以。

等价的原生命令（两种 strip 都可用）：

```bash
patch --dry-run -p1 -d "$BUNDLE/data/nl2repo/harness" < offline/patches/nl2repo_parallel.patch
patch           -p1 -d "$BUNDLE/data/nl2repo/harness" < offline/patches/nl2repo_parallel.patch
# 或 p0（补丁头不含 a/ b/ 前缀）
patch --dry-run -p0 -d "$BUNDLE/data/nl2repo/harness" < offline/patches/nl2repo_parallel.p0.patch
```

### 6.2 应用 offline 脚本补丁

`offline/run_batch2.sh` / `offline/run_batch2_inner.sh` 也可以直接由离线包构建方同步文件；
若走补丁：

```bash
patch --dry-run -p1 -d "$BUNDLE" < offline/patches/nl2repo_offline_scripts.patch
patch           -p1 -d "$BUNDLE" < offline/patches/nl2repo_offline_scripts.patch
```

### 6.3 回滚

```bash
# harness
bash offline/nl2repo-harness/apply_parallel_patch.sh \
  --revert --apply-to "$BUNDLE/data/nl2repo/harness"
# 或反向 patch / 恢复备份
patch -R -p1 -d "$BUNDLE/data/nl2repo/harness" < offline/patches/nl2repo_parallel.patch
# offline 脚本
patch -R -p1 -d "$BUNDLE" < offline/patches/nl2repo_offline_scripts.patch
```

> `apply_parallel_patch.sh` 默认**不会**修改任何文件（无 `--apply-to` 时只打印帮助与默认路径）；
> 应用前自动把被改文件备份为 `openhands_app.py.bak-<时间戳>`。

---

## 7. 验证与证据

### 7.1 静态检查（通过）

- `python -m py_compile`：`openhands_app.py` + harness 全部 `.py`（Python 3.11.15 / hostenv 3.12.13）通过。
- `bash -n`：`run_batch2.sh`、`run_batch2_inner.sh`、`apply_parallel_patch.sh`（Git Bash）通过。
- 补丁自检（`patch` + `git apply` 双工具）：
  - `-p1` / `-p0` dry-run、真实应用、反向回滚全部通过；
  - 应用后 `openhands_app.py` SHA256 = 改动后文件（字节级一致）；
  - `run_batch2*.sh` 补丁应用/回滚后 SHA256 与改动前一致。
- `PROFILE` 机制本地验证（stub `docker` 截获参数）：profile 覆盖 company.env、缺失 profile `exit 2` 并提示、无 profile 保持原行为。
- `run_batch2_inner.sh` 本地验证（stub 解释器）：config.json 正确写入 `port_base=3100/cleanup=true/max_pool_size=2`，模板 `max_iterations` 被改写。

### 7.2 2 题并发冒烟（机制通过）

环境：Windows 11 + Docker Desktop；harness 复制自打过补丁的副本，`max_pool_size=2`、
`port_base=3100`、`cleanup=true`、`max_iterations=6`、题 aiofiles + humanize、模型为本地 mock。

结果（详见 `concurrency-summary.md`）：

- 两个 app 容器 `openhands-app-3100` / `openhands-app-3101` 同时启动，启动时间差 0.1s，
  **生命周期重叠 10.139s**；`docker ps` 轮询多次快照同时看到两个容器（端口 3100/3101 各自映射 3000）；
- 两个 `ThreadPoolExecutor-0_0/0_1` 线程并发干活，日志时间戳重叠；
- 两个 post-process 测试容器 `python-test-aiofiles_bo1` / `python-test-humanize_bo1` **同时运行**；
- 两个 `result/aiofiles_bo1.json`、`result/humanize_bo1.json` 均生成；
- `workspaces/` 两套任务目录、state 目录 `.openhands-3100`/`.openhands-3101` 分离；
- `NL2REPO_CLEANUP=1` 预置 2 个残留容器后，启动时日志显示「本次清理 2 个残留容器」；
- 运行结束后 `docker ps -a` 为空（`--rm` + cleanup 正常）。

### 7.3 明确的限制（**机制已验证，模型分数不可用**）

- 本次在 **Windows 宿主**冒烟：OpenHands 0.56 的 `finalize_config()` 不接受 Windows 盘符挂载格式
  `D:/.../workspace:/workspace:rw`（要求正好 3 段），app 容器启动后立即 `ValueError` 退出，
  mock 未收到任何 chat/completions 请求 → **没有跑通「模型→agent→runtime」路径**。
  复现日志：`sandbox/nl2repo/parallel-test/evidence/windows-openhands-app-error.log`。
  这是 OpenHands 上游的挂载解析限制（与并行补丁无关）；公司 Linux 宿主路径以 `/` 开头，不存在该问题。
- 冒烟使用 mock 模型（固定「不调用工具、直接结束」），**分数/通过率不可用**。
- 因此正式口径：**并发机制已验证（可交付）；模型分数必须在公司 Linux 宿主用真实端点跑首题小规模验证后再放量。**

### 7.4 证据路径（仓库内，`sandbox/` 被 gitignore，仅本地产物）

`sandbox/nl2repo/parallel-test/evidence/`：

| 文件 | 内容 |
|---|---|
| `concurrency-summary.md` | 自动生成的并发证据摘要（判定/表格/口径） |
| `run_parallel.log` | harness 完整控制台日志（含线程名、时间戳） |
| `docker-ps-snapshots.log` | 运行期间每 2s 的 `docker ps` 快照（两个 app 容器 + 两个测试容器并存证据） |
| `run-meta.json` | 起止时间、退出码、result 文件 SHA256、workspaces、state 目录 |
| `mock-server.log` | mock 模型请求记录（只有探活 GET，无 chat/completions → 见 §7.3） |
| `windows-openhands-app-error.log` | Windows 挂载格式 ValueError 复现日志 |
| `profile-tests.txt` | `run_batch2.sh` PROFILE 机制测试输出 |
| `run-method-tests.txt` | §8 三种跑法（无 PROFILE / 先 source profile 再覆盖 / PROFILE 覆盖命令行）的实际取值验证 |
| `apply-script-tests.txt` | `apply_parallel_patch.sh` 各模式 + 32c64g wrapper 集成测试输出 |
| `verify-patch-final.txt` | 补丁 p1/p0/git apply/回滚 + 关键 SHA256 最终校验记录 |
| `static-checks.txt` | py_compile / bash -n / E 包未被修改 的最终记录 |
| `docker-images.txt` / `docker-ps-after-run.txt` | 冒烟用镜像清单 / 运行后容器清理状态 |

（`concurrency-summary.md` 由 `sandbox/nl2repo/parallel-test/analyze_parallel_smoke.py` 自动生成。）

---

## 8. 公司正式跑法

前置：离线包已 `load_bundle.sh` 载入镜像；`offline/env/company.env` 已填内网端点与模型名；
`offline/config/32c64g.env`（本批新增）已随包分发。

```bash
cd <离线包根目录>

# 正式跑（推荐）：32C/64G wrapper（自动 export PROFILE=32c64g，使用 profile 里的并发值）
./offline/run_batch2_32c64g.sh nl2repo
# 等价：
PROFILE=32c64g ./offline/run_batch2.sh nl2repo

# 首跑小规模验证 / 现场调参：**不要用 PROFILE**（profile 里的值会覆盖命令行环境变量）。
# 方式 A：直接调 run_batch2.sh，命令行变量全部生效
NL2REPO_TASKS=aiofiles,humanize NL2REPO_MAX_POOL=2 NL2REPO_PORT_BASE=3100 \
NL2REPO_CLEANUP=1 ./offline/run_batch2.sh nl2repo

# 方式 B：想复用 profile 的其它参数时，由调用方先 source profile、再覆盖、且不设 PROFILE
set -a; . offline/config/32c64g.env; set +a
NL2REPO_MAX_POOL=2 NL2REPO_PORT_BASE=3100 NL2REPO_TASKS=aiofiles,humanize \
  ./offline/run_batch2.sh nl2repo

# PROFILE 本身的覆盖优先级：profile 在 company.env 之后被 source，profile 内赋值的变量
# 会覆盖调用方环境变量；`NL2REPO_CLEANUP` 不在 profile 里，所以命令行仍可控制。
# 可选：启动前清理上一轮残留容器（默认关；确认没有其他 harness 在跑再用）
NL2REPO_CLEANUP=1 ./offline/run_batch2_32c64g.sh nl2repo
```

结果与日志：

- 结果 JSON：`$BUNDLE/data/nl2repo/harness/result/<task>_bo1.json`
- 总日志：`$BUNDLE/data/nl2repo/harness/logs/application.log`
- 单题 post-process 日志：`$BUNDLE/data/nl2repo/harness/workspaces/<task>_bo1/log.log`
- 单题 OpenHands 配置/工作区：`$BUNDLE/data/nl2repo/harness/workspaces/<task>_bo1/`
- Docker 侧：`docker ps`（运行期可见 `openhands-app-*` / `python-test-*` / `runtime-*`）、
  `docker images`（含 `python-test-<task>` 测试镜像）

> 若离线包在 Windows 上打包、脚本可执行位丢失：用 `bash offline/run_batch2_32c64g.sh nl2repo`
> 或 `bash offline/run_batch2.sh nl2repo` 调用（脚本内部逻辑不变）；也可让打包方
> `git update-index --chmod=+x` 后再打包。

运行中检查命令：

```bash
docker ps --format '{{.Names}}\t{{.Ports}}\t{{.Status}}' | grep -E 'openhands-app|python-test|runtime'
tail -f "$BUNDLE/data/nl2repo/harness/logs/application.log" | grep -E 'Task UUID|Container openhands-app|Post-processing'
```

---

## 9. 残余风险

1. **Windows 宿主不可用于真实 agent 跑分**（§7.3 的挂载格式限制）；公司 Linux 无此问题但需首跑验证。
2. **多 harness 进程共享同一 harness 目录不支持**：`logs/application.log`、`workspaces/`、`result/`
   会互相竞争。并发保证只在「单进程多线程」内；需要多进程时复制整个 harness 目录，
   给每个进程不同的 `NL2REPO_PORT_BASE`（并在 run_batch2.sh 层面分开 `BUNDLE` 挂载或工作副本）。
3. **残留容器**：docker 守护进程重启 / 进程被 kill 会留下 `--rm` 残留；
   用 `NL2REPO_CLEANUP=1` 或手动 `docker rm -f openhands-app-<port> python-test-<task>`。
4. **无全局超时**：app 等待循环依赖容器自身退出；若 OpenHands 卡死，线程会一直等；
   正式跑建议 tmux 守护 + 观察日志，必要时 kill 后 `NL2REPO_CLEANUP=1` 重跑。
5. **并发 docker build**：2–3 题同时 post-process 会并发 build 测试镜像，Docker daemon IO/CPU 压力上升；
   机器慢时症状是整体变慢而不是失败，可降到 pool=2。
6. **TLS 远程 docker 不是线程安全的**（§3.2 的 `os.environ` 写）；离线包默认本地 `localhost` 不受影响。
7. **post-process 失败会留 `python-test-<task>` 镜像/容器**（名字 per-task 隔离，不串题）；
   重跑时 build 会覆盖同名 tag，容器名冲突用 cleanup 或手动删。
8. **`-it` 依赖**：`run_batch2.sh` 用 `docker run -it`；公司若在非 TTY（如 CI/cron）里跑，
   需要改成 `-i` 或加 `-t` 判定的包装（本次未改，属既有行为）。
9. **`NL2REPO_CLEANUP` 的作用域**：只清理「本批次任务名」，不会清理宿主机上其它历史
   `openhands-app-*`（避免误杀）。需要全量清理时手工执行，不要在正式跑期间做。

---

## 10. 回滚方法

1. 最快：`bash offline/nl2repo-harness/apply_parallel_patch.sh --revert --apply-to "$BUNDLE/data/nl2repo/harness"`
   （或 `patch -R -p1 …` / 从 `.bak-<时间戳>` 恢复）。
2. offline 脚本：`patch -R -p1 -d "$BUNDLE" < offline/patches/nl2repo_offline_scripts.patch`，
   或直接回退这两个文件。
3. 回滚后行为回到串行：只有 `NL2REPO_MAX_POOL=1` 时结果与改动前一致；即使 pool>1 也会退化为
   旧逻辑（共享 `.openhands`、端口固定 3000），**不要**在回滚后开并发。
4. 已生成的结果文件/镜像不受回滚影响；重跑前可按需清理 `result/`、`workspaces/`、`.openhands*`。
