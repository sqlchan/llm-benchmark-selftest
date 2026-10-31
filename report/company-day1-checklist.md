# 到公司后 30 分钟操作清单

> **第二批（TB4 + NL2Repo）见 [`company-day1-checklist-batch2.md`](company-day1-checklist-batch2.md)**；
> 本清单保持第一批（Automation-Bench / ProgramBench / DeepSWE）内容不变。

> 适用：带着 `E:\bench-bundle`（ZX1 移动固态，整包约 46.8 GiB，其中第一批 tar 5.04 GiB）到公司 Linux 机器，用内网模型跑第一批基准。
> 目标：30 分钟内完成「加载 → 环境验通 → 模型验通 → 第一道真实判分」，并在结束前启动可过夜的长任务。

## 出发前已有条件（确认过）

- 公司 Linux + Docker 可用，**允许容器挂载 docker.sock**
- 内网模型同时支持 OpenAI 兼容 / Anthropic 协议（有 base_url、key、模型名）
- 目标机器磁盘空闲 ≥ 15 GB；当前用户在 `docker` 组
- **Docker 版本**：若为 CentOS 7（Docker 版本低/未装），先用离线包 `docker-el7/` 安装 Docker CE 20.10.24
  （见 [`centos7-docker-offline.md`](centos7-docker-offline.md)）。旧 daemon 的 API 兼容问题已处理：
  `offline/docker-compose.yml` 默认给 runner 传 `DOCKER_API_VERSION=1.41`，`run_batch2.sh` 自动探测宿主 API。

## 时间轴

| 时间 | 做什么 | 完成标志 |
| :-- | :-- | :-- |
| 0–3 min | 插 SSD、确认路径与磁盘 | `df -h` 剩余 ≥ 15G |
| 3–8 min | 校验 + `docker load` 14 个镜像 | `sha256sum -c` 全 OK |
| 8–12 min | docker.sock / compose / 工具链自检 | `SOCK_OK` + 版本号输出 |
| 12–16 min | 配内网端点、启动 runner、curl 验通 | curl 返回 200 |
| 16–25 min | Automation-Bench 跑 1 题（含判分） | 导出 JSON、exit 0 |
| 25–30 min | ProgramBench/DeepSWE 环境预检 + 启动长任务 | oracle 跑通 / 任务已后台启动 |

---

## Step 0（0–3 min）接入与检查

```bash
# 找到 SSD 挂载点（不同发行版可能不同）
lsblk -o NAME,SIZE,MOUNTPOINT | grep -i zx1 || df -h | grep -Ei 'media|mnt'
cd /media/<user>/ZX1/bench-bundle     # 替换为实际路径

df -h .            # 剩余空间 ≥ 15G
ls -la             # README.md / images / data / offline / SHA256SUMS
```

## Step 1（3–8 min）校验 + 加载镜像

```bash
sha256sum -c SHA256SUMS
# 期望：images/bench-images.tar: OK

time docker load -i images/bench-images.tar       # 约 2–3 分钟
docker images --format '{{.Repository}}:{{.Tag}}' \
  | grep -E 'bench-eval-runner|programbench|swe-bench' | wc -l
# 期望：14
```

## Step 2（8–12 min）Docker 能力与工具链自检

```bash
docker compose version                                  # 期望 v2.x
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  bench-eval-runner:local docker ps >/dev/null && echo SOCK_OK

docker run --rm bench-eval-runner:local bash -lc \
  "harbor --version; pier --version; programbench --version; uv --version"
# 期望：0.25.0 / 0.3.1 / 1.2.5 / uv
```

> 如果 `SOCK_OK` 不出现：公司策略可能禁止挂载 socket → 改宿主机直装 Python 的退化方案（见仓库 offline-airgap-plan 第 7 节），今天就先只跑 Automation-Bench。

## Step 3（12–16 min）配置内网模型 + 启动 runner

```bash
cp offline/env/example.env offline/env/company.env
vi offline/env/company.env
#   OPENAI_API_BASE=http://host.docker.internal:8080/v1   ← 若容器不能直连内网，见下方反代
#   OPENAI_API_KEY=<公司 key>
#   MODEL_NAME=<公司模型名>

docker compose -f offline/docker-compose.yml --env-file offline/env/company.env up -d

# 端点连通性（在 runner 容器里测，模拟真实调用路径）
docker compose -f offline/docker-compose.yml exec runner bash -lc \
  'curl -sS -m 20 "${OPENAI_API_BASE%/}/chat/completions" \
     -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" \
     -d "{\"model\":\"$MODEL_NAME\",\"messages\":[{\"role\":\"user\",\"content\":\"ping\"}],\"max_tokens\":8}" | head -c 300'
# 期望：返回 JSON（有 choices）

# 工具调用能力（关键：决定 ProgramBench/DeepSWE 能否跑）
docker compose -f offline/docker-compose.yml exec runner bash -lc \
  'curl -sS -m 30 "${OPENAI_API_BASE%/}/chat/completions" \
     -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" \
     -d "{\"model\":\"$MODEL_NAME\",\"messages\":[{\"role\":\"user\",\"content\":\"get weather in Beijing\"}],\"tools\":[{\"type\":\"function\",\"function\":{\"name\":\"get_weather\",\"parameters\":{\"type\":\"object\",\"properties\":{\"city\":{\"type\":\"string\"}}}}}],\"tool_choice\":\"auto\"}" | head -c 400'
# 期望：finish_reason=tool_calls（若是纯文本，ProgramBench/DeepSWE 需调 scaffold）
```

**宿主机反代（仅当容器访问不到内网端点时）**：

```bash
# 宿主机 8080 → 内网模型网关
sudo apt-get install -y nginx   # 或用已有 nginx
# /etc/nginx/conf.d/llm.conf:
# server { listen 8080; location / { proxy_pass http://<内网模型地址>; proxy_set_header Host $host; } }
sudo nginx -s reload
# company.env 里 OPENAI_API_BASE=http://host.docker.internal:8080/v1
```

## Step 4（16–25 min）Automation-Bench 跑 1 题：第一道真实判分

```bash
docker compose -f offline/docker-compose.yml exec runner bash -lc '
  cd /opt/AutomationBench && uv run --offline auto-bench \
    --model "$MODEL_NAME" --base-url "$OPENAI_API_BASE" \
    --api-key "$OPENAI_API_KEY" --api chat_completions \
    --domains simple --num-examples 1 --max-steps 30 --max-concurrent 1 \
    --input-cost 0 --output-cost 0 \
    --export-json /workspace/logs/day1_automation.json'
```

**完成标志**：输出 `Results exported to ...`、exit 0，`/workspace/logs/day1_automation.json` 存在且包含 `summary.pass_rate`。

**如果出现 `RepeatedFormatError`/空响应**：把 `--max-steps` 提到 50、确认模型 `max_tokens ≥ 8192`；仍失败则换非推理模型或支持原生 tool-calling 的模型（先记录，不影响其他基准）。

## Step 5（25–30 min）ProgramBench / DeepSWE 环境预检

```bash
# ProgramBench：3 个镜像在不在 + blob 能离线解析（不跑 agent）
docker images | grep -c programbench          # 期望 3
docker compose -f offline/docker-compose.yml exec runner bash -lc \
  'programbench blob sync ajeetdsouza__zoxide.67ca1bc'
# 期望：Blobs cached at /workspace/data/programbench_blobs/...

# DeepSWE：用 oracle（参考解）验证 任务环境 + verifier，不花模型 token
docker compose -f offline/docker-compose.yml exec runner bash -lc '
  cd /workspace && pier run -p /workspace/data/deep-swe/tasks \
    -i "abs-module-cache-flags" -a oracle \
    --cpus ignore --memory ignore -o /workspace/logs/oracle -n 1'
# 期望：Trials 1 / Mean 1.0（说明 compose + 任务镜像 + verifier 都正常）
```

## Step 6（30 min 后，可选）启动长任务过夜

```bash
# 20 题 Automation（约 1–2 小时）
docker compose ... exec runner bash -lc 'cd /opt/AutomationBench && uv run --offline auto-bench ... --domains sales --num-examples 20 --max-concurrent 2 --export-json /workspace/logs/night_automation.json'

# ProgramBench 3 题（约 40–60 分钟，含 eval 修复）
docker compose ... exec runner bash -lc '
  cd /workspace && mini-extra programbench --model "$MODEL_NAME" \
    --filter "ajeetdsouza__zoxide|abishekvashok__cmatrix|agourlay_zip" --workers 1'

# DeepSWE 10 题（数小时，用仓库 offline/deepswe-pier-job.example.yaml 改 n_tasks: 10 + 超时倍数 0.5–1.0）
docker compose ... exec runner bash -lc 'cd /workspace && pier run -c /workspace/offline/deepswe-pier-job.yaml'
```

## 30 分钟结束时的「4 个证据」

- [ ] `sha256sum -c` 全 OK（包完整）
- [ ] `SOCK_OK`（容器能用宿主 Docker）
- [ ] 端点 curl 返回 200 且 `finish_reason=tool_calls`（模型可用）
- [ ] `/workspace/logs/day1_automation.json` 存在（判分链路通）

## 常见问题速查

| 现象 | 处理 |
| :-- | :-- |
| `docker load` 报 no space | 清理镜像/换盘；包 5GB+，预留 15GB |
| `SOCK_OK` 不出现 | 走退化方案：宿主机装 Python，仅 Automation-Bench |
| 容器 curl 超时 | 宿主 nginx 反代 + `host.docker.internal`；自签证书挂 CA |
| `finish_reason` 不是 tool_calls | 换支持 tool-calling 的模型；或调 mini-swe `format_error_template` |
| ProgramBench eval 报 `results_read_failed` | 确认用包内已修复镜像（pytest-timeout 已预装） |
| Pier 报 `unknown flag: --project-name` | runner 镜像是旧版；用今天打包的 tar |
| DeepSWE 很久没结果 | 正常：单题 30 分钟–数小时，用 `n_concurrent_trials` 并行 + 过夜 |

> 真实 key 只写在 `offline/env/company.env`（已 gitignore）；不要提交到任何仓库。
