# 公司 32C/64GB 宿主机：并发配置与容量/工期规划

> 适用机器：公司 Linux 宿主机，**32 vCPU / 64GB RAM / 1TB 盘**，Docker 可用、**离线**、模型走内网 OpenAI 兼容端点。
> 适用离线包：`bench-bundle`（4 个镜像 tar 合计 **46.5 GiB**；TB4 36 题 + NL2Repo 10 题 + DeepSWE 10 题 + ProgramBench 3 题 + Automation-Bench）。
> 配套文件：[`offline/config/32c64g.env`](../offline/config/32c64g.env)（并发预设）、[`offline/run_batch2_32c64g.sh`](../offline/run_batch2_32c64g.sh)（入口 wrapper）、[`offline/deepswe-pier-32c64g.yaml`](../offline/deepswe-pier-32c64g.yaml)（DeepSWE Pier 模板）；NL2Repo 并行补丁随 `offline/nl2repo-harness/` 交付（README + apply 脚本）。
> 口径：本文数字均为**估算或按仓库现有实测数据推算**，每项标注依据；未实测项显式写 "未实测"。token 量级的价格日期/假设沿用报告现有口径（DeepSeek 官方价，2026-10-30）；金额请按实际模型单价折算。

---

## 0. 结论速览

| 基准 | 一轮规模 | 并发（32C/64G 建议） | 内存峰值（典型 / 最坏） | 单模型一轮 wall-clock |
| :-- | :-- | :-: | :-: | :-- |
| Terminal-Bench 4.0 | 36 题 | `TB4_N_CONCURRENT=3` | ~20–30GB / 56GB | **约 1 天**（典型 6–25h；全跑满最坏 96h≈4 天） |
| NL2Repo-Bench | 10 题 | `NL2REPO_MAX_POOL=3` | 6–12GB / ~16GB | **1–3h**（最坏 8h；串行时 2–8h） |
| DeepSWE v1.1 | 10 题 | `n_concurrent_trials: 3` | ~24GB / ~32GB | **3–9h**（最坏 10h） |
| ProgramBench | 3 题 | `--workers 1`（串行） | 4–16GB / <16GB | **1.5–3h**（单题上限 6h，失败重跑另计） |
| Automation-Bench | sales 100 题 | `--max-concurrent 5` | 无任务容器（<1GB） | **约 35min–1h**（视内网端点 QPS；建议预留 1–1.5h） |

**三条结论：**

1. **32 vCPU 不是瓶颈**：顺序跑任一基准时 CPU 声明峰值 ≤32 核（TB4 n=3 最坏恰好 32），典型只有 8–12 核；`cpus` 是限额不是占用，超卖可接受。
2. **64GB 内存是第一约束**：TB4 最坏叠加 56GB（n=3）已接近上限，**基准之间必须顺序跑**；跑 TB4 期间只允许穿插纯 API 的 Automation-Bench，不要与 DeepSWE/NL2Repo/ProgramBench 混跑。
3. **磁盘按 ≥250GB 空闲准备**（峰值估算约 200GB），Docker data root 必须在 1TB 那块盘上；低于 20GB 空闲时先清 build cache，**不要 `docker system prune`**（会删掉已 load 的离线镜像）。

---

## 1. 机器适配结论

| 项 | 结论 | 依据 |
| :-- | :-- | :-- |
| 32 vCPU | 够用；TB4 n=3 最坏 3 题声明 16+8+8=32 核，典型 n=3 约 9.7 核（36 题声明合计 116 核 / 36）；DeepSWE 3×2 核、NL2Repo pool=3 ×~2 核 | TB4 task.toml 资源统计（本机解析 `data/tb4/tasks/*/task.toml`）；DeepSWE 每 trial 2C（[`deepswe-smoke/README.md`](results/deepswe-smoke/README.md)） |
| 64GB 内存 | 单基准顺序跑都能容纳，**混跑会超**（见第 3 节最坏叠加与第 9 节降级规则） | 见第 2、3 节 |
| 1TB 磁盘 | 需要 **≥250GB 空闲**（4 tar 46.5GiB + 解压/派生镜像/build cache 峰值估算约 200GB）；最低红线 ≥140GB | [`company-day1-checklist-batch2.md`](company-day1-checklist-batch2.md) §0；[`second-batch-bundle.md`](second-batch-bundle.md) §10（本机 vhdx 峰值 118.7GB） |
| Linux + Docker | 可跑（docker.sock 兄弟容器模式已在本机 Windows Docker Desktop 验证；Linux 只需注意「容器路径=宿主机路径」，见第 10 节） | [`offline-airgap-plan.md`](offline-airgap-plan.md) §1.1；[`second-batch-bundle.md`](second-batch-bundle.md) §5.2 |
| 离线 | 4 个 tar load 后 124 个镜像 tag（TB4 36 env + 61 verifier/sidecar + NL2Repo 12 + runner 2 + 第一批 13）；全部任务镜像已打包，无需联网 | [`company-day1-checklist-batch2.md`](company-day1-checklist-batch2.md) §1 |
| 内网模型端点 | 必须**从容器网络可达**。注意分两层：runner 容器可用 `host.docker.internal`（`run_batch2.sh` 已加 `--add-host`）；**TB4/DeepSWE 的 agent 跑在任务容器里，任务容器没有这个映射** → `OPENAI_API_BASE`/Pier 的 `api_base` 要写任务容器可达的地址（内网地址，或 docker0 网关 `172.17.0.1` 反代） | [`company-day1-checklist-batch2.md`](company-day1-checklist-batch2.md) Step 3（含 a/b/c 三步验证） |

---

## 2. 各基准并发表（含依据）

| 基准 | harness / 入口 | 并发参数 | 原默认 | 32C/64G 建议 | 依据 |
| :-- | :-- | :-- | :-: | :-: | :-- |
| Terminal-Bench 4.0 | Harbor，`./offline/run_batch2_32c64g.sh tb4` | `TB4_N_CONCURRENT` | 2（脚本默认） | **3** | 36 题单题内存上限 16GB（4 题）、最坏叠加见 §3.1；n=4 会到 72GB > 64GB |
| NL2Repo-Bench | OpenHands harness，`./offline/run_batch2_32c64g.sh nl2repo` | `NL2REPO_MAX_POOL` + `NL2REPO_PORT_BASE` | 1（端口 3000 固定） | **3**（端口 3000–3002） | 每任务 app+runtime 约 2–4GB；并行补丁把 10 题从串行压到 1–3h |
| DeepSWE v1.1 | Pier，`offline/deepswe-pier-32c64g.yaml` | `n_concurrent_trials` | 1（冒烟模板） | **3** | 每 trial 约 2C/8GB（[`deepswe-smoke/README.md`](results/deepswe-smoke/README.md)）→ 3 并发约 6C/24GB |
| ProgramBench | `mini-extra programbench` | `--workers` | 按 CLI | **1（串行）** | 默认请求 20C/60GB 超过单机，已用 `run_args` 覆盖；单题重，串行最稳（[`first-batch-bundle.md`](first-batch-bundle.md) §7/§8） |
| Automation-Bench | `auto-bench` CLI（纯 API） | `--max-concurrent` | 100（官方默认） | **5** | 无任务容器，瓶颈是端点 QPS/TPM；5 并发与实测 simple 5 题的并发量级（4）接近 |

> TB4 / NL2Repo 的并发值写在 `offline/config/32c64g.env`，由 `run_batch2.sh` 的 PROFILE 机制注入 runner；DeepSWE 在 Pier YAML 里；ProgramBench / Automation 不走 `run_batch2.sh`，按本表命令参数执行。

---

## 3. 内存与 CPU：最坏叠加与典型占用

### 3.1 Terminal-Bench 4.0（主要内存消耗方）

36 题的 Harbor 任务定义（本机解析 `E:\bench-bundle\data\tb4\tasks\*\task.toml`；按每题 `max(environment, verifier.environment)` 统计）：

| 资源 | 分布 |
| :-- | :-- |
| cpus | `{2: 26 题, 4: 5 题, 8: 3 题, 16: 1 题, 6: 1 题}` |
| memory | `{4096MB: 19 题, 8192MB: 12 题, 16384MB: 4 题, 12288MB: 1 题}` |
| 最重 | **16C/16GB 只有 1 题**：`live-database-cutover`（另有 3 题声明 16GB 内存：`distributed-dedup` 8C/16GB、`medical-claims-processing` 2C/16GB、`uefi-bootkit` 2C/16GB） |

**最坏叠加口径**（本机容量规划用，保守）：

```
峰值内存 ≈ N × 16GB（单题内存上限） + 8GB（OS + dockerd + runner 容器基线）
n=2 ≈ 40GB    n=3 ≈ 56GB    n=4 ≈ 72GB（>64GB，不可用）
```

- 64GB 机器 → **默认 n=3**；出现 OOM/宿主 `free < 6GB`/`dmesg` 有 oom-kill 时退 **n=2**，最低 1。
- 典型占用远低于最坏值：36 题声明内存合计 244GB / 36 ≈ **6.8GB/题**，n=3 平均约 20GB + 基线 ≈ **20–30GB**。
- **额外风险一（待验证）**：每题 verifier 在独立环境跑（`environment_mode = separate`）。若某 trial 的 agent 环境与 verifier 环境短暂同时存活，最重题可能瞬时 16+16=32GB —— 因此**首次跑 `live-database-cutover` 时先用 n=1–2 观察** `docker stats`，确认再放开。
- **额外风险二**：36 题里 **11 题用 docker-compose 起 sidecar**（`cumulative-layout-shift`、`kv-live-surgery`、`legacy-utility-triage`、`live-database-cutover`、`nextjs-performance`、`payments-pipeline-fix`、`ctr-optimization`、`freight-dispatch-shift`、`heat-pump-warranty`、`intrastat-meldung`、`medical-claims-processing`）。sidecar（mysql/postgres/redis/customer 等）**没有单列内存限制**，实际占用可能高于 `environment.memory_mb` 声明值——这是最坏叠加要留 8GB 余量的原因。
- **CPU**：n=3 最坏 16+8+8=32 核恰好占满 32 vCPU，但 CPU 可超卖、不会 OOM；典型 ~10 核，不构成限制。

### 3.2 其它基准

| 基准 | 典型 / 最坏内存 | 说明 |
| :-- | :-- | :-- |
| NL2Repo | 6–12GB / ~16GB | 每任务 app + runtime 约 2–4GB × pool=3；OpenHands 进程/日志开销另计 |
| DeepSWE | ~24GB / ~32GB | 3 trial × 8GB + runner/Docker 基线；任务容器声明 2C/8GB（`cpu/memory_enforcement_policy: ignore` 下由 Docker 兜底） |
| ProgramBench | 4–16GB | 默认申请 20C/60GB 已被 `run_args` 覆盖；本机 16C/16GB 跑完 `zoxide`（900s/40 步截断），说明单题实际 <16GB；4–16GB 为保守预留 |
| Automation | <1GB | 纯 API 进程 + 100 个 HTTP 客户端；瓶颈是端点 QPS，不是本机资源 |

### 3.3 组合规则

**不要同时跑两个「带容器」的基准。** 最坏的组合是 TB4 n=3（56GB）+ NL2Repo pool=3（12GB）≈ 68GB，直接触发 OOM kill；即便是典型值 20–30GB + 12GB 也在 32–42GB，余量会被 sidecar 和 buildx 吃掉。
唯一允许的穿插：**TB4 跑批期间跑 Automation-Bench（纯 API、不占内存）**，但要盯端点限流——两边共用同一份 RPM/TPM。

---

## 4. 单模型一轮 wall-clock（工期）与推算

| 基准 | 估算 | 推算依据 / 最坏情况 |
| :-- | :-- | :-- |
| TB4 36 题，n=3 | **约 1 天** | 36/3 = 12 轮 × 单 trial 平均 1,684–7,432 秒（tbench.ai 榜单 `avg_trial_duration_sec`，2026-10-30）= **5.6–24.8h**，取"约 1 天"；多数题远早于 8h 预算结束。**最坏**：全部跑满 8h 上限 = 36×8/3 = **96h≈4 天**（checklist 在 n=2 口径下给典型 2–4 天，本表 n=3 的最坏值与之同量级） |
| NL2Repo 10 题，pool=3 | **1–3h** | 10/3 ≈ 4 轮 × 单题 10min–2h（[`company-day1-checklist-batch2.md`](company-day1-checklist-batch2.md) Step 8 口径）= 40min–8h；典型 1–3h。串行（pool=1）时 2–8h |
| DeepSWE 10 题，3 并发 | **3–9h** | 10/3 ≈ 4 轮 × 单题 30min–数小时（[`deepswe-smoke/README.md`](results/deepswe-smoke/README.md)：真实耗时 30 分钟–数小时，官方单题预算 3h）→ 典型 3–9h；最坏 10×3h/3 = 10h |
| ProgramBench 3 题，串行 | **1.5–3h** | 单题 30–60min × 3（单题上限 6h/题，官方允许长步数）；本机 `zoxide` 实测 12min57s 是 **900s/40 步截断**下的链路值，正式跑给足步数后按 30–60min/题预留 |
| Automation sales 100，5 并发 | **约 35min–1h** | 实测 simple 5 题 489.6s（`--max-concurrent 4`，deepseek-v4-flash，[`stage2-automation-validation.md`](stage2-automation-validation.md) §6）→ 100 题在 5 并发、端点 QPS 充足时约 30–60min；QPS 不足会线性变慢，**预留 1–1.5h** |

**一个模型 5 个基准顺序跑完 ≈ 2–3 天**（TB4 的 1 天占大头，其余合计 6–16h）。若只有一台机器要给 3–5 个候选模型出对比，按模型逐个串行（每个 2–3 天）而不是并行（内存不够）。

---

## 5. 磁盘预算

| 项 | 量级 | 依据 |
| :-- | --: | :-- |
| 4 个镜像 tar（原始） | **46.5 GiB** | 5.04 + 19.78 + 21.14 + 0.55 GiB（[`company-day1-checklist-batch2.md`](company-day1-checklist-batch2.md) §0） |
| load 后镜像解压 | 约 2–2.5× | checklist §0；期望 124 个镜像 tag |
| 派生评测镜像 + buildx build cache | 数十 GB 量级 | NL2Repo 每题后处理 `docker build` 评测镜像；本机 Docker vhdx 峰值 118.7GB（[`second-batch-bundle.md`](second-batch-bundle.md) §10） |
| **建议空闲** | **≥250GB**（峰值估算约 200GB；最低红线 ≥140GB） | 峰值口径见上两行 |

- **Docker data root 必须在 1TB 盘上**：`docker info --format '{{.DockerRootDir}}'` 确认；若默认落在系统盘，改 `/etc/docker/daemon.json` 的 `data-root` 后重启 docker。
- 跑批期间至少留 **20GB** 空闲；不足时 `docker builder prune -f`（**不要** `docker system prune`，会删掉 load 进来的离线镜像）；确认没有残留评测容器后 `docker system df` 看回收效果。
- 结果归档（JSON/轨迹/verifier 输出）通常在 GB 以内，重跑会持续累积；离开公司前 `tar czf` 压缩并核对 `sha256sum`。

---

## 6. 每基准的推荐命令

> 除特别说明外都在**离线包根目录**执行；`company.env` 里配 `OPENAI_API_BASE / OPENAI_API_KEY / MODEL_NAME`（真实 key 只写在已 gitignore 的 `company.env`）。
> 若 `./offline/*.sh` 报 `Permission denied`（Git checkout 默认不带可执行位），先 `chmod +x offline/*.sh`，或用 `bash offline/run_batch2_32c64g.sh ...`。

### 6.1 TB4（走 run_batch2.sh，PROFILE 注入并发）

```bash
# 先单题 oracle 自检（不需要模型，约 3–5 分钟）
TB4_TASKS=html-js-filter ./offline/run_batch2_32c64g.sh oracle

# 全 36 题 oracle 自检（约 1–2 小时；用来剔除环境不通的题）
./offline/run_batch2_32c64g.sh oracle 2>&1 | tee logs/tb4-oracle.log

# 单题 agent 冒烟（5% 预算，约 24 分钟；冒烟不要用 wrapper，否则 profile 的
# TB4_AGENT_TIMEOUT_MULTIPLIER=1.0 会覆盖 0.05——直接调 run_batch2.sh）
TB4_TASKS=html-js-filter TB4_AGENT_TIMEOUT_MULTIPLIER=0.05 TB4_N_CONCURRENT=1 \
  ./offline/run_batch2.sh tb4

# 正式跑：n=3、超时倍数 1.0（写在 32c64g.env 里）；用 tmux，不能 nohup
tmux new -s bench
./offline/run_batch2_32c64g.sh tb4 2>&1 | tee logs/tb4-full.log
```

### 6.2 NL2Repo（走 run_batch2.sh；依赖并行补丁）

```bash
# 冒烟：只跑 1 题、8 轮（链路验证，分数无意义）。
# 冒烟不要用 wrapper：profile 会把 max_iterations 覆盖回 500；直接调 run_batch2.sh。
NL2REPO_TASKS=aiofiles NL2REPO_MAX_ITERATIONS=8 ./offline/run_batch2.sh nl2repo

# 正式：10 题、pool=3（任务清单/端口基数/轮数上限都在 32c64g.env）
./offline/run_batch2_32c64g.sh nl2repo 2>&1 | tee logs/nl2repo-full.log
```

### 6.3 DeepSWE（Pier YAML，不用 run_batch2.sh）

```bash
BUNDLE=/mnt/ssd/bench-bundle            # 离线包根目录（按实际改）
mkdir -p "$BUNDLE/jobs"

# 替换占位符并改成「离线包内绝对路径」，产出不入 git 的本地副本
export OPENAI_API_KEY=...   # 宿主上先 export；key 不写进命令历史/文件
sed -e 's#REPLACE_ME_MODEL#company-model-x#' \
    -e "s#REPLACE_ME_OPENAI_API_BASE#http://10.0.0.1:8080/v1#" \
    -e "s#/workspace/jobs#$BUNDLE/jobs#; s#/workspace/data#$BUNDLE/data#" \
    "$BUNDLE/offline/deepswe-pier-32c64g.yaml" > "$BUNDLE/jobs/deepswe-32c64g.local.yaml"

docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock -v "$BUNDLE:$BUNDLE" -w "$BUNDLE" \
  -e OPENAI_API_KEY \
  bench-eval-runner:v2 pier run -c "$BUNDLE/jobs/deepswe-32c64g.local.yaml"
```

> 两个注意点：① **先单题冒烟**（`agent_timeout_multiplier: 0.2` 或 `task_names` 留 1 题）确认 Linux 下 Pier 的 jobs 路径可见性，再跑 10 题正式（见第 12 节待验证项）。② YAML 里的 `api_base` 是**任务容器**去访问的地址：不要写 `host.docker.internal`（Pier 不会给任务容器加这个映射），用内网地址或 docker0 网关反代（`http://172.17.0.1:8080/v1`）；Pier 会把配置里的 URL 自动加入 allowlist（见 [`api-only-5bench-plan.md`](api-only-5bench-plan.md) §2）。

### 6.4 ProgramBench / Automation（不走 run_batch2.sh）

- ProgramBench：`mini-extra programbench ... --workers 1`（3 题串行）；命令与镜像/blob 预检见 [`company-day1-checklist.md`](company-day1-checklist.md) Step 5–6。
- Automation：`uv run auto-bench ... --domains sales --num-examples 100 --max-concurrent 5`（详见同清单 Step 4/6 与 [`stage2-automation-validation.md`](stage2-automation-validation.md) §4）。

### 6.5 PROFILE 依赖与回退

`offline/run_batch2_32c64g.sh` 依赖 `run_batch2.sh` 的 **PROFILE 补丁**：先 source `offline/env/company.env`，再 source `offline/config/$PROFILE.env`（后者**覆盖**前者同名变量）。补丁未合入时 wrapper 会**直接报错退出**（防止静默按默认冒烟参数 n=2/超时×0.05 跑正式评测）。临时替代（仅 TB4/oracle 可用）：

```bash
set -a; . offline/config/32c64g.env; set +a
./offline/run_batch2.sh tb4
```

注意 profile 的覆盖优先级：**冒烟参数不要通过 wrapper 传**（会被 profile 里的正式值覆盖），冒烟一律直接调 `./offline/run_batch2.sh`（见 §6.1/§6.2）。NL2Repo 并行（`NL2REPO_MAX_POOL>1`、`NL2REPO_PORT_BASE`）依赖并行补丁本身，说明见 `offline/nl2repo-harness/README.md`（随并行补丁交付）、[`offline/config/README.md`](../offline/config/README.md)。

---

## 7. 运行顺序：Day1 / Day2 / Day3

> 前提：到达公司当天按 [`company-day1-checklist-batch2.md`](company-day1-checklist-batch2.md) 完成「加载 → mcp 自检 → SOCK_OK → 端点/tool-call 验证」（约 2–2.5h），再按下面的节奏放量。

| 阶段 | 内容 | 预计耗时 |
| :-- | :-- | :-- |
| **Day1 上午/下午** | 接硬盘、`df -h` 检查 ≥250GB → `./offline/load_bundle.sh "$PWD"`（4 tar + mcp 逐镜像校验）→ `SOCK_OK`/工具链自检 → 配 `company.env`、curl 验端点与 tool-call | 2–2.5h |
| **Day1 晚上** | TB4：单题 oracle → 36 题 oracle（剔除不可用题）→ **启动 36 题正式跑 n=3**（tmux），过夜 | oracle 1–2h + 正式约 1 天 |
| **Day2 白天** | 收 TB4 结果（可能仍在跑，可查 `results/tb4/`）；TB4 未完成的题按 `TB4_TASKS` 补跑；**不要**同时开其它容器基准 | 0.5h 检查 + 视进度 |
| **Day2 下午** | NL2Repo 10 题（pool=3）：先单题 8 轮冒烟，再正式 | 1–3h |
| **Day2 晚上** | DeepSWE 10 题（3 并发，用 Pier YAML）过夜 | 3–9h |
| **Day3 上午** | 收 DeepSWE；ProgramBench 3 题串行 | 1.5–3h |
| **Day3 下午** | Automation sales 100（可与 ProgramBench 收尾穿插，纯 API） | 0.5–1h |
| **Day3 收尾** | 结果采集/归档、清理含 key 的运行时文件（`data/nl2repo/harness/config.json`、`workspaces/*/config.toml`、`offline/env/company.env`） | 0.5h |

**若 TB4 拖到 4 天**：把 Day2/Day3 的 NL2Repo/DeepSWE 依次后移即可——它们是独立入口，不依赖 TB4 完成；不要为了提前开始而把 TB4 并发提到 n=4（内存会超）。

---

## 8. 监控命令

```bash
# 1) 实时资源（最常用：看内存是否逼近 64GB）
docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}'

# 2) 容器清单（TB4 任务容器名含 tb4/terminal-bench；NL2Repo 是 openhands-app-*；
#    ProgramBench/DeepSWE 是 compose 出来的任务容器）
docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' \
  | grep -E 'bench-eval|openhands|tb4|terminal-bench|programbench|swe-bench'

# 3) 宿主内存 / 磁盘
free -h
df -h "$(docker info --format '{{.DockerRootDir}}')"

# 4) OOM 与异常退出（exit 137 = SIGKILL，常见于 OOM）
dmesg -T | grep -i 'killed process' | tail -5
docker inspect -f '{{.Name}} exit={{.State.ExitCode}}' $(docker ps -aq --filter name=bench-eval) 2>/dev/null

# 5) 磁盘回收（先清 build cache，别 system prune）
docker system df
docker builder prune -f
```

**日志/结果位置：**

| 基准 | 位置 |
| :-- | :-- |
| TB4（Harbor） | `results/tb4/<job>/<trial>/verifier/reward.txt`、`.../result.json`、`agent/`；汇总用 [`company-day1-checklist-batch2.md`](company-day1-checklist-batch2.md) Step 4 的 python 片段；另可 `harbor view jobs`（官方 CLI 命令，本仓库未实测） |
| NL2Repo | `data/nl2repo/harness/result/*.json`（每题一个）；进程输出用 `tee logs/nl2repo-full.log` 保存 |
| DeepSWE（Pier） | `<jobs_dir>/<job>/` 下的 `job.log`、`result.json`、每 trial 的 `trial.log`/`trial-result.json`（本机证据的同类结构见 [`results/deepswe-smoke/job-artifacts/`](results/deepswe-smoke/job-artifacts/)） |
| ProgramBench / Automation | `logs/` 下的 `tee` 文件与 `--export-json` 产物 |

---

## 9. 降级规则（统一原则：先 N-1，最低 1）

| 症状 | 判定 | 动作 |
| :-- | :-- | :-- |
| 宿主 `free` 掉到 <6GB，或 `dmesg` 出现 `Out of memory: Killed process`，或容器 exit 137 | 内存不够 | 该基准并发 **N-1**（TB4 3→2、NL2Repo 3→2、DeepSWE 3→2）；先停掉穿插的其它基准；确认不是 `live-database-cutover` 单题造成（见 §3.1 风险一） |
| `Bind for 0.0.0.0:3000 failed` / `port is already allocated`（OpenHands/NL2Repo） | 端口冲突 | `docker ps -a --filter 'name=openhands-app' -q \| xargs -r docker rm -f`（或本轮启动时加 `NL2REPO_CLEANUP=1`）；不重启整轮的话把 `NL2REPO_PORT_BASE` 后移到 3100/3200，再 N-1 |
| API 429 / `rate limit` / `insufficient_quota` 密集出现，或墙钟比 §4 估算显著变慢 | 端点限流 | Automation `--max-concurrent` 5→3；容器基准 N-1（减少并发请求）；错峰跑；重试会计入成本，记录次数 |
| TB4 某题 oracle 也拿不到 1 | 该题在本环境不可用（公网依赖/资源/sidecar 端口） | 剔除该题并记录，**不要**让 agent 去跑；报告写「剔除 N 题，剩余 36-N 题」 |
| 单题卡住、容器不退 | 任务容器死锁/网络挂起 | `docker ps` 找到容器 → `docker rm -f` → 单题重跑；不影响其它 trial |
| `docker build`/snapshot 报错或磁盘 <20GB | 磁盘紧张 | `docker builder prune -f` + 重启 docker；**不要** `docker system prune` |
| `RepeatedFormatError` / 反复格式错误 | 模型 tool-call 格式不兼容，与并发无关 | **不要**靠降并发解决；换支持原生 tool-calling 的模型或调 mini-swe `format_error_template`，记录后继续其它基准 |
| TB4 正式分数低但 oracle 全过 | 正常现象（模型能力），不是故障 | 不改并发/超时；按口径汇报（单题 8h 预算、k=1 与官方 k=5 不可直接比） |

**不许做的"优化"：** 为赶时间降 `TB4_AGENT_TIMEOUT_MULTIPLIER`（分数不可比）或把 n 提到 4（内存超限）——题没跑完就用 `TB4_TASKS` 分晚跑。

---

## 10. 成本：token 量级与估算口径

> 只给 token 量级；金额请按当时拿到的模型单价自行折算。价格日期/假设沿用仓库现有口径：**DeepSeek 官方价 2026-10-30，非高峰 cache miss 输入 $0.15/M、输出 $0.6/M**（[`research/harness/notes.md`](../research/harness/notes.md)；[`report/all_benchmarks.json`](all_benchmarks.json) 的 `cost.basis`）。

| 基准 | 一轮 token 量级 | 估算口径 |
| :-- | :-- | :-- |
| TB4 36 题 | **1–21 亿 tokens** | 官方榜单 330 trials 合计约 8.9 亿–194 亿 tokens（tbench.ai leaderboard JSON，2026-10-30）；按 36/330 折算 → 0.97–21.2 亿。含 agent + verifier 模型调用，不含失败重试 |
| NL2Repo 10 题 | **5–30M tokens** | 官方无 token 统计；单题规格文档均值约 18.8k tokens（[`benchmark-guide.md`](benchmark-guide.md) NL2Repo 段）+ OpenHands 数百轮多轮交互，按 0.5–3M/题估算 ×10。未实测 |
| DeepSWE 10 题 | **10–50M tokens** | 官方只公布每模型平均成本与输出 tokens（gpt-6-astra 30k、Opus 5 max 118k 输出/题，2026-10-30 博客口径）；按 agent 轨迹 input:output≈5–10× 估 1–5M/题 ×10。未实测 |
| ProgramBench 3 题 | 约 5–15M tokens；官方统计 **平均 $36.36 API 成本/题**（Opus 5.5） | 官方 Cost 列为每模型平均 API 成本（不是 token）；本机 `zoxide` 单题实测 1,654,554 prompt + 51,123 completion tokens（900s/40 步截断，[`first-batch-bundle.md`](first-batch-bundle.md) §8）→ 3 题 5–15M 量级 |
| Automation sales 100 | **约 1,500 万 input tokens**（+ 约 0.7M output） | 实测 simple 5 题 deepseek-v4-flash：输入 754,874 / 输出 35,387 tokens（[`stage2-automation-validation.md`](stage2-automation-validation.md) §6）→ 约 151k 输入/题 × 100 |

- **金额折算口径**：把上表 token 量级 × 实际模型单价即可；本仓库价格假设为 DeepSeek 官方价 2026-10-30（非高峰 cache miss 输入 $0.15/M、输出 $0.6/M）。其它基准的输入/输出比例、失败重试次数未知，本文不折算金额。
- 成本相关注意：429 重试、agent 失败重跑、`--max-concurrent` 过高导致的超时重试都会计入 token；NL2Repo 若不做轮数上限会烧到不可控（本预设固定 `NL2REPO_MAX_ITERATIONS=500`）；ProgramBench/DeepSWE 的官方成本数字是**别人模型的 API 账单**，只能当量级参考，不可作为我们模型的成本结论。

---

## 11. 与家庭 Windows 环境的差异提醒

| 差异 | 家里 Windows（构建端） | 公司 Linux（运行端） | 影响/对策 |
| :-- | :-- | :-- | :-- |
| docker.sock 兄弟容器路径 | Docker Desktop 的文件共享让「相对挂载」碰巧可用 | **必须容器内路径=宿主机路径**（OpenHands 已按此设计；Pier 的 jobs 目录同理） | batch2 runner 用 `-v "$BUNDLE:$BUNDLE"`；DeepSWE YAML 的 `jobs_dir`/`datasets.path` 改成离线包内绝对路径（本文 §6.3） |
| `host.docker.internal` | Docker Desktop 默认支持 | Linux 默认没有 | `run_batch2.sh` 已加 `--add-host host.docker.internal:host-gateway`；或 docker0 网关 `172.17.0.1` 反代 |
| 控制台编码 | GBK 会 `UnicodeEncodeError`（踩过） | UTF-8，无此问题 | 无需 `PYTHONUTF8=1`；日志直接 `tee` |
| Docker 磁盘 | Docker Desktop vhdx 只增不减，曾涨到 118.7GB / 写满导致 snapshot 损坏 | overlay2 正常回收 | Linux 仍要按 §5 留 ≥250GB；`docker builder prune -f` 定期清 |
| 资源 | 16C/16GB（DeepSWE 4 并发接近上限） | 32C/64GB | 公司可 3 并发；但**不要**把家里的"4 并发能跑"直接搬过来跨基准混跑 |
| 模型端点 | 火山方舟 Ark（`/api/plan/v1`） | 公司内网 OpenAI 兼容端点 | 只换 `company.env` 的 base/key/model；harness 参数不变（TB4/NL2Repo 均走 `OPENAI_API_BASE`） |
| 首次正式跑 | 未跑过 TB4 正式 agent 分数（单题 8h 预算） | 公司机器是**首次正式跑分** | Day1 必须先 oracle + 单题冒烟，确认链路再放量 |
| TTY | PowerShell 里可直接跑 | `run_batch2.sh` 用 `docker run -it`，`nohup` 会因无 TTY 失败 | 全程 `tmux`/`screen` |

---

## 12. 已知限制 / 待验证

1. **TB4 正式 agent 分数未在本机跑过**（本机只验证 oracle 与链路）；本文的 1 天是估算，实际以公司首跑为准。
2. **verifier 与 agent 环境是否重叠未验证**（§3.1 风险一）：首跑 `live-database-cutover` 时用 n=1–2 + `docker stats` 观察。
3. **DeepSWE 在 Linux 上的 jobs/bind 路径**：Windows 冒烟可用不代表 Linux 可用；首个 trial 前先单题验证（§6.3），若报宿主机路径不存在，确认 `jobs_dir`/`datasets.path` 与宿主机绝对路径一致。
4. **NL2Repo 并发的正确性**由并行补丁的验证负责（说明见 `offline/nl2repo-harness/README.md`，随补丁交付）；本文只给容量口径。
5. **ProgramBench 单题正式耗时未知**（官方无数据；本机 12min57s 是截断值），按 30–60min/题预留。
6. **内网端点 QPS/TPM 未知**：Automation 的 5 并发、TB4 的 n=3 都依赖端点扛得住；首跑用 §4 的保守值，遇到 429 按 §9 降级。
7. PROFILE 机制、NL2Repo 并行补丁都是本批新补丁：**跑之前先确认补丁已合入**（§6.5），否则按回退命令手动注入环境变量。

---

## 附：文档依据索引

| 事实 | 出处 |
| :-- | :-- |
| 4 tar 46.5GiB、124 镜像、时间轴 | [`company-day1-checklist-batch2.md`](company-day1-checklist-batch2.md) |
| TB4 36 题资源分布、最重题、sidecar、oracle 判据 | 本机解析 `E:\bench-bundle\data\tb4\tasks\*\task.toml`；[`second-batch-bundle.md`](second-batch-bundle.md) §10 |
| TB4 单题 8h 预算、n=2 时 2–4 天 | 同上（`task.toml [agent] timeout_sec=28800`） |
| 单 trial 平均 1,684–7,432 秒、整轮 token/cost 口径 | [`runbook.md`](runbook.md) Terminal-Bench 段；tbench.ai 榜单（2026-10-30） |
| DeepSWE 2C/8GB、单题 30min–数小时、3h 预算 | [`results/deepswe-smoke/README.md`](results/deepswe-smoke/README.md) |
| ProgramBench 默认 20C/60GB、run_args 覆盖、zoxide 实测 token | [`first-batch-bundle.md`](first-batch-bundle.md) §7/§8 |
| Automation simple 5 题实测 token/墙钟 | [`stage2-automation-validation.md`](stage2-automation-validation.md) §6 |
| 价格日期与假设 | [`research/harness/notes.md`](../research/harness/notes.md)；[`all_benchmarks.json`](all_benchmarks.json) `cost.basis` |
| PROFILE 机制 / NL2Repo 并行补丁 | 本批补丁：`offline/run_batch2.sh`（PROFILE）、`offline/nl2repo-harness/`（并行补丁 README + apply 脚本，随补丁交付） |
