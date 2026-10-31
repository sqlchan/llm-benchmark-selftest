# 到公司后第二批操作清单（Terminal-Bench 4.0 + NL2Repo-Bench）

> 承接 [`company-day1-checklist.md`](company-day1-checklist.md)（第一批：Automation-Bench / ProgramBench / DeepSWE）。
> 本清单只覆盖**第二批**：TB4 15 题 + NL2Repo 10 题，以及两批共用的加载与收尾。
> 适用介质：`E:\bench-bundle`（两批合计约 **25.6 GB**，其中第二批镜像 21.24 GB）。
> 目标：约 **1.5–2 小时**内完成「加载 → mcp 自检 → TB4 oracle → TB4 单题 agent → NL2Repo 单题」，
> 当晚启动正式跑分。

## 0. 出发前确认（缺一不可）

- [ ] 公司 Linux 磁盘空闲 **≥ 60 GB**（两批 tar 合计 25.6 GB；加载后镜像会再占空间，另需 15 个 mcp 补丁层、任务/评测容器与 build cache）
- [ ] 允许容器挂载 `docker.sock`（runner 要以兄弟容器方式启动 TB4/OpenHands 容器）
- [ ] 内网模型端点**从 Docker 容器网络可达**（不只是宿主机可达；见 Step 3 的验证方法）
- [ ] 拿到内网模型的 `OPENAI_API_BASE` / `OPENAI_API_KEY` / `MODEL_NAME`
- [ ] 当前用户在 `docker` 组；架构为 linux/amd64

## 1. 时间轴

| 时间 | 做什么 | 完成标志 |
| :-- | :-- | :-- |
| 0–5 min | 接 SSD、检查路径/磁盘/Docker | `df -h` ≥ 60G，`docker info` OK |
| 5–20 min | `load_bundle.sh`：3 个 tar + 自动打 mcp 补丁 | SHA OK + 67 个镜像 tag + 15 个 TB4 镜像补丁完成 |
| 20–30 min | docker.sock / harbor / buildx / python-on-whales 自检 | `SOCK_OK` + 版本号 |
| 30–45 min | 配 `company.env`、验证端点与 tool-call 格式 | curl 返回 200；容器内也通 |
| 45–60 min | TB4 oracle 单题（html-js-filter） | reward=1 |
| 60–90 min | TB4 agent 单题冒烟（5% 预算） | job 完成、无 `NonZeroAgentExitCodeError` |
| 90–120 min | NL2Repo 单题冒烟（8 轮） | `All tasks completed!` + result JSON |
| 当晚 | 正式跑：TB4 15 题 + NL2Repo 10 题 | 后台任务已启动 |

> 建议全程用 `tmux`/`screen`：`run_batch2.sh` 用 `docker run -it`，直接 `nohup` 会因没有 TTY 失败。
> ```bash
> tmux new -s bench     # 断开：Ctrl-b d；重连：tmux attach -t bench
> ```

---

## Step 0（0–5 min）接入与检查

```bash
# 挂载点各发行版不同
lsblk -o NAME,SIZE,MOUNTPOINT | grep -i zx1 || df -h | grep -Ei 'media|mnt'
cd /media/<user>/ZX1/bench-bundle     # 换成实际路径

df -h .                     # 期望 Avail ≥ 60G
docker info --format 'docker {{.ServerVersion}}'   # 期望有版本号
ls -la                      # README.md / manifest.json / images / data / offline / results / docs
```

## Step 1（5–20 min）校验 + 加载镜像

```bash
./offline/load_bundle.sh "$PWD"
# 1) sha256sum -c（优先 images/SHA256SUMS）→ 3 个 tar 全 OK
# 2) 按文件名排序加载：bench-images.tar → bench-images-batch2.tar → bench-images-runner-v2.tar
# 3) 自动进入 "== 2.5 TB4 派生镜像 mcp 补丁 =="，逐个 [ok]/构建，最后 "TB4 mcp 补丁完成。"
```

镜像数量自检（期望：第二批 53 个 tag，两批合计 67 个）：

```bash
docker images --format '{{.Repository}}:{{.Tag}}' > /tmp/imgs.txt
grep -c '^tb4off/environment:' /tmp/imgs.txt              # 15
grep -c '^harborframework/terminal-bench:' /tmp/imgs.txt  # 25（15 verifier + 10 sidecar）
grep -c '^ghcr.io/' /tmp/imgs.txt                         # 12（OpenHands×2 + NL2Repo 测试镜像×10）
grep -c '^bench-eval-runner:' /tmp/imgs.txt               # 2（local + v2）
grep -c '^programbench/' /tmp/imgs.txt                    # 3（第一批）
grep -c '^public.ecr.aws/' /tmp/imgs.txt                  # 10（第一批 DeepSWE）
wc -l < /tmp/imgs.txt                                     # 67（若机器原有其他镜像，以分类计数为准）
```

**mcp 逐镜像验证**（这是第二批最容易踩的坑，必须 15 个全 OK）：

```bash
for t in $(grep '^tb4off/environment:' /tmp/imgs.txt | cut -d: -f2); do
  docker run --rm --network none --entrypoint python "tb4off/environment:$t" -c 'import mcp' >/dev/null 2>&1 \
    && echo "OK $t" || echo "MISSING $t"
done
```

- 若出现 `MISSING`：`BUNDLE_DIR=$PWD ./offline/fix_tb4_images.sh` 重跑一次（幂等，只补缺的）。
- 若 `docker build` 报 `BuildKit is enabled but the buildx component is missing`：
  `DOCKER_BUILDKIT=0 BUNDLE_DIR=$PWD ./offline/fix_tb4_images.sh`（或用已装 buildx 的 docker 环境）。

## Step 2（20–30 min）Docker 能力与工具链自检

```bash
# 1) docker.sock：runner 里能操作宿主 Docker
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  bench-eval-runner:v2 docker ps >/dev/null && echo SOCK_OK

# 2) 工具链（harbor 跑 TB4；buildx 给 NL2Repo 后处理构建评测镜像；python-on-whales 跑 NL2Repo harness）
docker run --rm bench-eval-runner:v2 bash -lc '
  harbor --version &&
  docker buildx version &&
  /opt/nl2repo-venv/bin/python -c "import python_on_whales; print(\"whales OK\")" &&
  mini-swe-agent --help 2>&1 | head -2'
# 期望：harbor 0.25.0、buildx 版本行、whales OK、mini-swe-agent 2.4.6 版本行
```

> `SOCK_OK` 不出现 → 公司策略禁止挂载 socket，本批两个基准**都无法运行**（都需要起兄弟容器），
> 只能退回第一批的宿主机直装方案。

## Step 3（30–45 min）配置内网模型 + 端点可达性

```bash
cp offline/env/example.env offline/env/company.env
vi offline/env/company.env
#   OPENAI_API_BASE=http://<内网模型地址>/v1
#   OPENAI_API_KEY=<公司 key>
#   MODEL_NAME=<公司模型名>
#   可选：TB4_AGENT_TIMEOUT_MULTIPLIER=1.0  TB4_N_CONCURRENT=2  NL2REPO_MAX_ITERATIONS=500
```

端点验证分两步：**宿主 shell** 和 **容器网络**（TB4 任务容器/OpenHands 容器都要直接访问模型端点）。

```bash
set -a; . offline/env/company.env; set +a

# a) runner 容器内（同时测 host.docker.internal 映射）
docker run --rm --add-host host.docker.internal:host-gateway \
  -e OPENAI_API_BASE -e OPENAI_API_KEY -e MODEL_NAME bench-eval-runner:v2 bash -lc '
  curl -sS -m 20 "${OPENAI_API_BASE%/}/chat/completions" \
    -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" \
    -d "{\"model\":\"$MODEL_NAME\",\"messages\":[{\"role\":\"user\",\"content\":\"ping\"}],\"max_tokens\":8}" | head -c 300'
# 期望：返回 JSON，含 choices

# b) 普通 bridge 容器（模拟 TB4 任务容器的网络位置；没加 host-gateway 映射）
docker run --rm -e OPENAI_API_BASE -e OPENAI_API_KEY -e MODEL_NAME bench-eval-runner:v2 bash -lc '
  curl -sS -m 20 "${OPENAI_API_BASE%/}/chat/completions" \
    -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" \
    -d "{\"model\":\"$MODEL_NAME\",\"messages\":[{\"role\":\"user\",\"content\":\"ping\"}],\"max_tokens\":8}" | head -c 200'
# b 不通而 a 通 → 公司内网端点只对宿主可达：用 docker0 网关做反代（如 http://172.17.0.1:8080/v1），
#   不要把 OPENAI_API_BASE 写成 host.docker.internal（Harbor 不会给任务容器加这个映射）。

# c) tool-call 格式（决定 TB4 mini-swe-agent 能否稳定跑）
docker run --rm -e OPENAI_API_BASE -e OPENAI_API_KEY -e MODEL_NAME bench-eval-runner:v2 bash -lc '
  curl -sS -m 30 "${OPENAI_API_BASE%/}/chat/completions" \
    -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" \
    -d "{\"model\":\"$MODEL_NAME\",\"messages\":[{\"role\":\"user\",\"content\":\"get weather in Beijing\"}],\"tools\":[{\"type\":\"function\",\"function\":{\"name\":\"get_weather\",\"parameters\":{\"type\":\"object\",\"properties\":{\"city\":{\"type\":\"string\"}}}}}],\"tool_choice\":\"auto\"}" | head -c 400'
# 期望 finish_reason=tool_calls；纯文本则记录，TB4 可能触发 RepeatedFormatError（见常见问题）
```

> 两批共用 `offline/env/company.env`；第一批 compose 命令也读同一份配置。

## Step 4（45–60 min）TB4 oracle 自检（不需要模型）

先单题，确认环境没问题（约 3–5 分钟）：

```bash
TB4_TASKS=html-js-filter ./offline/run_batch2.sh oracle
# 期望 job 完成，n_errored_trials=0
cat results/tb4/*/html-js-filter__*/verifier/reward.txt    # 期望 1
```

单题通过后，跑全部 15 题 oracle（约 30–60 分钟，放 tmux 里）：

```bash
mkdir -p logs
TB4_TASKS= ./offline/run_batch2.sh oracle 2>&1 | tee logs/tb4-oracle.log
```

汇总（在离线包根目录执行）：

```bash
python3 - <<'PY'
import pathlib
root = pathlib.Path("results/tb4")
rows = {}
for job in sorted(root.iterdir()):
    if not job.is_dir(): continue
    for trial in job.iterdir():
        r = trial / "verifier" / "reward.txt"
        if trial.is_dir() and r.exists():
            task = trial.name.split("__")[0]
            rows.setdefault(task, []).append(float(r.read_text().strip()))
for task, vals in sorted(rows.items()):
    print(f"{task:28s} n={len(vals)} rewards={vals} mean={sum(vals)/len(vals):.3f}")
PY
```

**判定**：oracle 拿不到 1 的题，说明该题在你们的网络/环境里不可用（常见原因：题目本身需要公网、
sidecar 端口冲突、资源不足）——把这类题**剔除并记录**，不要让 agent 去跑；正式报告中注明「剔除 N 题，剩余 15-N 题」。

## Step 5（60–90 min）TB4 agent 单题冒烟

```bash
# 单题 + 5% 预算（8h × 0.05 = 24 分钟）
TB4_TASKS=html-js-filter \
TB4_AGENT_TIMEOUT_MULTIPLIER=0.05 \
TB4_N_CONCURRENT=1 \
./offline/run_batch2.sh tb4
```

**完成标志**（不是分数）：

- job `result.json` 的 `n_completed_trials=1`、`exception_stats` 为空（没有 `NonZeroAgentExitCodeError`）
- 有 `results/tb4/<job>/html-js-filter__*/verifier/reward.txt`（0 或 1 都算通过）
- `agent/` 下有轨迹文件；`stats.n_input_tokens` 非 0（说明模型真的被调用了）

**失败对照**：

| 现场 | 处理 |
| :-- | :-- |
| `ModuleNotFoundError: No module named 'mcp'` | mcp 补丁没打上：`BUNDLE_DIR=$PWD ./offline/fix_tb4_images.sh` 后重跑 |
| `NonZeroAgentExitCodeError` 且输出有 `RepeatedFormatError` / JSON 解析失败 | 模型 tool-call 格式不兼容：换支持原生 tool-calling 的模型，或调 mini-swe-agent 的 `format_error_template`（记录后继续其他基准） |
| agent 立刻退出、无轨迹 | 端点 `base_url` 写错 / `OPENAI_API_KEY` 未传入；用 Step 3 的 b/c 命令复测 |
| job 卡住、容器不退 | `docker ps` 看 TB4 任务容器；`docker rm -f` 后重跑单题 |

## Step 6（当晚）TB4 正式跑

```bash
TB4_AGENT_TIMEOUT_MULTIPLIER=1.0 TB4_N_CONCURRENT=2 \
  ./offline/run_batch2.sh tb4 2>&1 | tee logs/tb4-full.log
```

- 15 题 × 单题 agent 预算 **8 小时**（`task.toml [agent] timeout_sec=28800`），并发 2：多数题会提前结束，现实工期约 **1–2 天**（若全部跑满上限约 60 小时）。
- 若时间不够：先跑 8 题（`TB4_TASKS=` 填前 8 个）过夜，第二天补另外 7 题；不要降超时倍数，否则分数不可比。
- **注意**：`run_batch2.sh` 默认 `TB4_AGENT_TIMEOUT_MULTIPLIER=0.05`（冒烟值），正式跑必须显式设为 `1.0`。

## Step 7（90–120 min）NL2Repo 单题冒烟

```bash
# 端口固定 3000、max_pool 必须为 1；先确认没有残留容器
docker ps -a --filter 'name=openhands' --format '{{.Names}} {{.Status}}'
docker rm -f openhands-app-3000 2>/dev/null || true

NL2REPO_TASKS=aiofiles NL2REPO_MAX_ITERATIONS=8 ./offline/run_batch2.sh nl2repo
# 期望：日志出现 "All tasks completed!"；data/nl2repo/harness/result/aiofiles_bo1.json 生成
```

**完成标志**：

- `data/nl2repo/harness/result/aiofiles_bo1.json` 存在，`status=completed`、`exit_code=0`
- 后处理能 `docker build` 出测试镜像（`docker images | grep python-test-aiofiles`）
- 后处理里 `pip install`（离线参数 `--no-build-isolation --no-index`）**退出码 0**（离线包用的是预装构建后端的派生测试镜像；若为 1 → 镜像不对，见常见问题）

> 冒烟 `max_iterations=8` 分数很低属正常（模型只跑 8 轮）；它只验证链路，不作为分数上报。

## Step 8（当晚起）NL2Repo 正式跑

```bash
NL2REPO_TASKS=aiofiles,humanize,sqlparse,tenacity,cerberus,tinydb,markupsafe,jsonlines,freezegun,python-slugify \
NL2REPO_MAX_ITERATIONS=500 NL2REPO_MAX_POOL=1 \
./offline/run_batch2.sh nl2repo 2>&1 | tee logs/nl2repo-full.log
```

- 串行（端口 3000 固定），10 题预计 **2–8 小时**，单题可能 10 分钟到 2 小时，波动大。
- 结果：`data/nl2repo/harness/result/*.json`（每题一个）。
- 中断后重跑：先 `docker rm -f openhands-app-3000`，再重跑；`result/` 里已有的题会被覆盖。

## Step 9 结果采集与归档

```bash
mkdir -p export
cp -r results/tb4 export/
cp -r data/nl2repo/harness/result export/nl2repo-result
tar czf export/batch2-raw-$(date +%F).tar.gz export
(cd export && sha256sum batch2-raw-*.tar.gz > SHA256SUMS)
```

- TB4 汇总：用 Step 4 的 python 片段（读 `results/tb4/*/*/verifier/reward.txt`）。
- NL2Repo 汇总：逐题读 `result/*.json` 的 `status` / 后处理 pytest 统计；**不要**直接用 `score` 字段当基准分。
- 口头汇报建议同时给：题目数、有效题数、通过题数、平均 reward；NL2Repo 另附测试通过率口径。

## Step 10 收尾（离开公司前必做）

```bash
# 1) 清掉含公司 key 的运行时文件（都在离线包内，别带回）
rm -f data/nl2repo/harness/config.json
rm -f data/nl2repo/harness/workspaces/*/config.toml
rm -f offline/env/company.env          # 或改回 example.env 占位

# 2) 清理容器与缓存
docker rm -f openhands-app-3000 2>/dev/null || true
docker ps -a --filter 'name=terminal-bench' --format '{{.Names}}'   # 有残留就删
docker system df                        # 确认磁盘没被评测镜像吃满
```

## 验收清单（6 个证据）

- [ ] `sha256sum -c images/SHA256SUMS` 三个 tar 全 OK（包完整）
- [ ] `SOCK_OK`（容器能用宿主 Docker）
- [ ] 15 个 TB4 派生镜像 `import mcp` 全 OK（mcp 补丁已生效）
- [ ] TB4 oracle 单题 `reward.txt = 1`（环境+判分链路通）
- [ ] TB4 agent 单题 job 完成、无 `NonZeroAgentExitCodeError`（模型链路通）
- [ ] NL2Repo 单题 `status=completed` + result JSON 落盘（OpenHands 链路通）

## 常见问题速查

| 现象 | 处理 |
| :-- | :-- |
| `docker: unknown command: docker buildx` | 用的是旧 runner；确认 `bench-images-runner-v2.tar` 最后加载（`bench-eval-runner:v2`） |
| `ModuleNotFoundError: No module named 'mcp'` | `BUNDLE_DIR=$PWD ./offline/fix_tb4_images.sh`，确认 15 个 `import mcp` 全 OK |
| `ValueError: Invalid mount format in sandbox.volumes: ...` | 宿主机路径必须以 `/` 开头；本包要求「容器路径 = 宿主机路径」，用 `run_batch2.sh` 的默认挂载即可 |
| OpenHands `unrecognized arguments` / `No module named 'dotenv'` | harness 启动必须用 `bash -c`，不要用 `bash -lc`（login shell 会丢 `/app/.venv/bin` 的 PATH；包内已修好） |
| NL2Repo 后处理 `pip install -e .` 失败、缺构建后端 | 加载的不是派生测试镜像：`docker run --rm ghcr.io/multimodal-art-projection/nl2repobench/aiofiles:1.0 bash -c 'pip list 2>/dev/null | grep -Ei "hatch|setuptools|wheel"'` 应能看到构建相关包 |
| NL2Repo 报 `port is already allocated` / 3000 被占 | 上一轮残留容器：`docker rm -f openhands-app-3000`；`NL2REPO_MAX_POOL` 必须为 1 |
| TB4 agent 报 `RepeatedFormatError` 或反复格式错误 | 模型 tool-call 格式不兼容（第一批 ProgramBench 也踩过）：换模型或改 mini-swe `format_error_template`，记录后继续 |
| 容器 `curl` 内网端点超时、宿主正常 | 用 docker0 网关反代（`http://172.17.0.1:<端口>/v1`）并确认端点监听 `0.0.0.0` |
| `docker build` 失败 / snapshot 报错 / 磁盘满 | `docker builder prune -f` + 重启 docker；**不要用 `docker system prune`**（会删掉已加载的离线镜像）；磁盘空闲 < 20G 时先清评测容器 |
| TB4 某题 oracle 也拿不到 1 | 该题在本环境不可用（公网依赖/资源/sidecar），剔除并记录，不要算进模型分数 |

> 真实 key 只写在 `offline/env/company.env`（已 gitignore）；离线包内的 `data/nl2repo/harness/` 会在运行时写入含 key 的配置，离开公司前按 Step 10 清理。
