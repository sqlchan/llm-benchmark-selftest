# 离线（断网）环境跑 5 个基准：可行性与实施方案

> 场景：家里 PC（Windows）有外网；公司是 **Linux**，可用 Docker；公司内网模型同时支持 **OpenAI 兼容**与 **Anthropic 协议**，只能走 API。
> 目标：在家里把环境 + 数据全部打包进 Docker，带到公司离线运行，模型端点指向公司内网 API。
> 结论：**可行**，但有 4 个硬约束必须先解决（见第 1 节）。

## 0. 一句话方案

在一台有外网的机器上构建「离线评测包」：

```
bench-bundle/
├─ images/        # docker save 出来的所有镜像 tar（runner + 各基准任务镜像）
├─ data/          # 任务数据、HF parquet、测试 blob、仓库快照
├─ configs/       # 模型端点配置（家：Ark；公司：内网）
├─ compose/       # docker-compose + runner 镜像定义
├─ manifest.json  # 镜像清单 + 数据集版本 + 校验和
└─ verify.ps1     # 加载后自检
```

在公司：`docker load` 所有镜像 → 启动 runner 容器（挂载宿主机 docker.sock）→ 用内网端点跑小样本 → 放量。

## 1. 四个硬约束（决定方案边界）

| # | 约束 | 影响 | 对策 |
| :-: | :-- | :-- | :-- |
| 1 | **基准任务容器可能依赖外网** | TB4 / DeepSWE / NL2Repo 的 agent 会在容器里 `apt/pip/curl`；断网时这些题会失败而不是跳过 | 先做「断网实测」筛出可离线题；不可离线的题从对照集中剔除并在报告注明；ProgramBench 本身设计为无网，最稳 |
| 2 | **Docker 镜像体积** | 全量 5 个基准的任务镜像可能 100GB+ | 只打包选定子集（MVP 建议 10–25GB，见第 3 节）；用外部 SSD 搬运 |
| 3 | **公司 Docker 策略** | 可能禁止挂载 docker.sock / privileged | 需要「runner 容器 + 宿主机 Docker」模式（docker.sock 挂载）；若禁止，退化为在宿主机直接装 Python 环境（见第 7 节备选） |
| 4 | **内网模型端口** | 容器内不一定能访问公司内网 API（不同网段/证书/代理） | 用 `host.docker.internal` + 宿主机反向代理；证书自签时挂 CA；先 `curl` 验证 |

补充：DeepSWE/Pier、TB4/Harbor 的 agent 多数跑在任务容器内，模型 API 由容器发出；ProgramBench 与 Automation-Bench 的模型调用在宿主机进程（无此问题）。**这正是第 4 条约束要按基准分别处理的原因。**

### 1.1 术语解释：挂载 docker.sock vs 运行 privileged

Docker 是「客户端 + 守护进程」结构：`docker` 命令本身不干活，它把请求发给后台的 dockerd（有 root 权限）；两者通话的「门」就是 `/var/run/docker.sock`。

| 方式 | 做法 | 效果 | 风险 |
| :-- | :-- | :-- | :-- |
| **挂载 docker.sock**（我们需要的） | `docker run -v /var/run/docker.sock:/var/run/docker.sock ...` | 容器里的 docker 命令直接指挥**宿主机** dockerd，从而启动「兄弟容器」（任务容器） | 拿到这个 socket ≈ 拥有宿主机 root（可挂宿主目录、起特权容器）；属于高权限，但比 privileged 范围小 |
| **运行 privileged** | `docker run --privileged ...` | 容器获得几乎所有 capabilities 和设备访问，典型用于在容器里再跑一个 dockerd（DinD） | 几乎等同宿主机 root，安全策略通常禁止；我们的方案**不需要** |

判断公司是否允许（Linux 上依次执行）：
```bash
groups | grep docker          # 当前用户是否有 docker 组权限
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock bench-eval-runner:local docker ps
docker run --rm --privileged bench-eval-runner:local true   # 一般会失败，失败也没关系
```
- 第一条通过 → 方案可行（runner 容器用宿主 Docker 起任务容器）。
- 两条都失败 → 用第 7 节的退化方案：harness 直接装在宿主机，任务容器仍由宿主机 Docker 启动，不依赖 socket 挂载。
- 向 IT 申请时可以直接说明：「评测容器需要通过 `/var/run/docker.sock` 启动兄弟容器（Docker-outside-of-Docker），不申请 `--privileged`」。

## 2. 打包内容清单（按优先级）

| 优先级 | 内容 | 体积量级 | 说明 |
| :-: | :-- | --: | :-- |
| P0 | runner 镜像（Python3.12 + uv + docker CLI + 5 个 harness + 数据） | 3–8 GB | 一个镜像内含 Pier/Harbor/OpenHands/mini-swe/evalscope，任务数据一起 COPY 进去 |
| P0 | Automation-Bench 数据（仓库，无任务镜像） | <1 GB | 纯 API，最省事 |
| P0 | ProgramBench：选定 3–5 个任务镜像 + 测试 blob | **约 4.2 GB/题**（实测，5 题≈21 GB） | 官方设计无网，离线最稳；镜像命名形如 `programbench/<owner>_1776_<project>.<hash>:task_cleanroom_v6` |
| P1 | DeepSWE：选定 10 个任务的预构建镜像 + tasks 目录 | 5–15 GB | 任务定义在 GitHub；镜像需要预拉 |
| P1 | Terminal-Bench 4.0：数据集 + prebuilt 镜像 | 5–20 GB | 66 题镜像；3 题需 H100，离线包排除 |
| P2 | NL2Repo：OpenHands 0.56 双镜像 + 仓库 | 5–10 GB | 容器内调模型 + 无轮数上限，离线难度最高 |
| — | HF gated 数据集（DeepSWE parquet 等） | <1 GB | 打包时用 token 下载并烘进镜像，到公司不需要 HF 权限 |

> 全量 5 个基准的镜像总量可能 50–120GB，**不建议一次全带**；先做 MVP（Automation + ProgramBench 3–5 题 + DeepSWE 10 题），验证公司环境后再补包。ProgramBench 单题镜像实测约 4.2GB（`ajeetdsouza_1776_zoxide.67ca1bc`），这是体积估算的变化点。

## 3. 「第一批」是什么意思 / 第一批带什么

「分批」= 不是一次把 5 个基准的所有镜像都带走，而是**按「离线可行性 × 与你们开发场景相关性 × 单题成本」排优先级**，先用一个 MVP 包在公司把链路跑通、拿到第一版对比数据，再决定补不补第二批。

| 批次 | 带什么 | 预估体积 | 目的 |
| :-- | :-- | --: | :-- |
| **第一批（MVP）** | Automation-Bench（simple 200 + sales 100）+ ProgramBench 3–5 题 + DeepSWE 10 题 | **~20–30 GB**（ProgramBench 实测 4.2 GB/题） | 三个场景各一个代表（工具调用 / 从零实现 / 真实修 bug），体积可控，1–2 天跑完 |
| 第二批 | Terminal-Bench 4.0（先 10–20 题，排除 3 个 H100 题）+ NL2Repo 10 题 | +15–40 GB | 补「终端 Agent 能力」和「规格→仓库」；离线可用性需先验证 |
| 第三批（可选） | TB4 全量 66 题、ProgramBench 扩到 20–30 题、NL2Repo 全量 | +50–100 GB | 只在前面批次证明有意义、且公司环境允许时再做 |

选择第一批的判断标准：
1. **离线可行性最高**：Automation-Bench 无任务容器、ProgramBench 官方设计断网，DeepSWE 任务镜像预拉后大概率可跑；
2. **与软件开发公司最相关**：修 bug（DeepSWE）、从零实现（ProgramBench）、多步工具调用（Automation）；
3. **成本可控**：三个子集合计约 $50–400，先证明链路再花钱。

如果你们第一阶段只想要「给公司推荐模型」的快速结论，第一批足够；如果结论要覆盖「Coding Agent 在终端里干活」的能力，再加第二批的 TB4。

## 4. 在家构建（有外网）

### 4.1 准备
- 磁盘：预留 100GB 空闲（镜像 + save 出的 tar 约为原体积 1:1，另留 1.5 倍余量）。
- Docker Desktop 已登录且能拉镜像；有 HF token（gated 数据集）。
- 把 `offline/` 里的脚本复制到一台 Linux/WSL 或 Windows（PowerShell）机器上执行。

### 4.2 构建步骤
```powershell
# 1) 拉取并导出镜像（脚本读 images.manifest.txt，逐条 pull → save）
.\offline\build_bundle.ps1 -Bundle D:\bench-bundle -Subset mvp

# 2) 拉取数据：git clone 固定 commit + HF 数据集 + ProgramBench blob
#    同脚本内完成；gated 数据集需要 $env:HF_TOKEN

# 3) 构建 runner 镜像（内含 harness 与数据）
docker build -f offline\Dockerfile.runner -t bench-eval-runner:local .

# 4) 导出 runner 镜像并生成校验和
docker save -o D:\bench-bundle\images\bench-eval-runner.tar bench-eval-runner:local
Get-FileHash -Algorithm SHA256 (Get-ChildItem D:\bench-bundle\images\*.tar) | Export-Csv ...
```

### 4.3 在家先做「断网实测」（关键）
这一步决定到公司后是否会白跑：

1. 把电脑 Wi-Fi 关闭（或拔网线），**保持 Docker Desktop 运行**；
2. 跑 Automation simple 5 题、ProgramBench 1 题、DeepSWE 1 题；
3. 记录：
   - 模型 API 若走 Ark，断网会失败——这一步只验证**除模型 API 外的所有依赖**；可临时把 `api_base` 指到本地 mock（mini-swe-agent 支持 mock 模型，或用一个本机 1×1 服务）;
   - 任务容器里凡是需要外网的命令都会失败，逐题记录失败原因；
4. 把能离线跑通的题号写入 `offline/tasks.offline-ok.txt`，到公司只用这批题（同一批题跨模型对比仍公平）。

## 5. 到公司：加载与运行（Linux）

```bash
# 1) 校验并加载（不联网）
./offline/load_bundle.sh /mnt/ssd/bench-bundle

# 2) 验证 docker.sock 是否允许（可选，但强烈建议先测）
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock bench-eval-runner:local docker ps

# 3) 配置内网端点（offline/env/company.env，不提交 git）
export OPENAI_API_BASE=http://host.docker.internal:8080/v1
export OPENAI_API_KEY=<公司 key>
export MODEL_NAME=<公司模型名>

# 4) 启动 runner（挂载宿主机 Docker，任务容器由宿主机 Docker 启动）
docker compose -f offline/docker-compose.yml --env-file offline/env/company.env up -d

# 5) 小样本自检：先 5 题，再放量
docker compose -f offline/docker-compose.yml exec runner bash /workspace/offline/run_stage1.sh
```

> Linux 前置：当前用户在 `docker` 组；若 `docker.sock` 挂载失败但普通 Docker 可用，走第 7 节退化方案。

## 6. 公司内网模型接入（已确认：OpenAI 兼容 + Anthropic 双协议）

按协议选 agent，口径与官方一致：

| 协议 | 用哪个 agent | 适用基准 | 配置方式 |
| :-- | :-- | :-- | :-- |
| **OpenAI 兼容** | mini-swe-agent（模型无关、只需 bash） | DeepSWE（官方）、ProgramBench（官方）、Automation-Bench（官方 CLI）、NL2Repo（OpenHands 需要） | `model_kwargs.custom_llm_provider=openai` + `api_base`；Automation 用 `--base-url/--api-key` |
| **Anthropic 协议** | claude-code | Terminal-Bench 4.0（官方 agent 就是 `-a claude-code`）、DeepSWE 交叉验证 | `ANTHROPIC_BASE_URL` + `ANTHROPIC_AUTH_TOKEN`（Harbor/Pier 的 agent.env） |

其余两种网络情况：

1. **容器能直连内网端点**（同网段/路由可达）：`OPENAI_API_BASE` 填内网地址即可。
2. **只有宿主机能访问**（常见）：在宿主机起反向代理，容器用 `host.docker.internal` 访问：
   ```bash
   # 宿主机 8080 → 内网 10.x.x.x:8000（nginx/Node 均可）
   # 证书自签：把 CA 挂进 runner 容器 /usr/local/share/ca-certificates/ 并 update-ca-certificates
   ```
3. **公司禁止容器访问内网**：fallback 到第 7 节，harness 装在宿主机。

另外：DeepSWE/Pier 的容器若 `allow_internet=false`，要把模型端点域名加入 Pier 的 allowlist（Pier 会自动读取配置里的 URL）；TB4 的 Harbor 同理检查网络配置。

## 7. 备选：不用 docker.sock 的退化方案

如果公司禁止挂载 Docker socket 或运行 privileged：

- 宿主机直接装 Python 3.12 + uv（离线 wheelhouse：构建时 `pip download -d wheelhouse -r requirements.txt`，到公司 `pip install --no-index --find-links wheelhouse`）；
- 任务容器仍由宿主机 Docker 启动；harness 在宿主机进程里调用 `docker`；
- 数据放本地目录，`HF_HUB_OFFLINE=1`、`PIP_NO_INDEX=1`、`UV_OFFLINE=1` 环境变量控制；
- 缺点：Windows 上 OpenHands/Pier 的依赖安装更麻烦；Linux（WSL2）更顺。

## 8. 风险清单与对策

| 风险 | 概率 | 对策 |
| :-- | :-: | :-- |
| 任务容器断网后大量失败 | 高 | 先小样本断网实测，只保留可离线题并在报告注明 |
| 镜像包体积过大/搬运失败 | 中 | MVP 分批；`docker save` 分卷；外部 SSD |
| docker.sock 挂载被禁 | 中 | 备选方案第 7 节；或改在 WSL2 Linux 里跑 |
| 内网模型接口协议不兼容 | 中 | 先 `curl` Chat Completions；用 mini-swe-agent（不依赖原生 tool calling） |
| API key 泄露 | — | **不要把 key 写进仓库/镜像**；用 env file 并加入 `.gitignore`；key 已流出聊天记录的，立即轮换 |
| 公司安全审计不允许外带机器 | 中 | 走公司 IT 流程：用公司机器 + 同样的离线包（包本身与机器无关） |

## 9. 时间与成本

| 阶段 | 时间 | 说明 |
| :-- | :-- | :-- |
| 镜像/数据打包（含断网自测） | 1–2 天 | 取决于网速与镜像体积 |
| 公司首次加载 + 环境验证 | 半天 | docker load + 5 题自检 |
| MVP 三基准跑完 | 1–2 天 | 含重跑 |
| 第二批（TB4/NL2Repo）补包 | 1–2 天 | 前提是断网可用性验证通过 |

模型调用成本按 `report/api-only-5bench-plan.md` 的阶段预算；离线化不改变 API 成本。

## 10. 已确认 / 待确认

已确认：公司是 **Linux**；内网模型 **OpenAI 兼容 + Anthropic 双协议**；公司 Docker 可用；家里 PC 是 Windows（构建端）。

仍待确认（只影响最后一步放量，不影响打包）：
1. 公司是否允许挂载 `docker.sock`（用第 1.1 节的三条命令测；不行走第 7 节退化方案）。
2. 内网模型的具体地址、是否需要自签证书、限流（QPS/TPM）。
3. 公司是否允许外带硬盘/笔记本，是否有镜像白名单（走 IT 流程）。
4. 第一批是否就按 Automation + ProgramBench 5 题 + DeepSWE 10 题（默认建议）。

## 11. 第一批打包实测（2026-10-31）

- 产物：`E:\bench-bundle`（移动 SSD），整包 **5.06 GB**；`images/bench-images.tar` **5.01 GB**，含 14 个镜像。
- 关键点：**单 tar `docker save` 去重共享层**，否则逐个 save 会膨胀到 ~50GB。
- 镜像：runner + 3 个 ProgramBench 任务 + 10 个 DeepSWE 任务（public ECR）。
- 已验证：docker load / sha256 / 工具链 / docker.sock 兄弟容器 / `--network none` 下 AutomationBench+mock 完整跑通。
- 详见 [first-batch-bundle.md](first-batch-bundle.md)。

## 12. 第二批打包实测（2026-10-31）

- 范围：Terminal-Bench 4.0（v4.0.0，**15/66 题**，排除 3 个 H100 GPU 题）+ NL2Repo-Bench（**10/104 题**）。
- 产物（追加到同一离线包）：
  - `images/bench-images-batch2.tar`：40 个 TB4 镜像（15 派生 env + 15 verifier + 10 sidecar）+ OpenHands 0.56 双镜像 + 10 个 NL2Repo 派生测试镜像 + runner v2（**21.24 GB**，单 tar 去重；SHA256 `f91f4d9b…faba9`）。
  - `images/bench-images-runner-v2.tar`：单独的 runner 镜像（0.59 GB；SHA256 `1d167439…eb34`）。
  - `data/tb4/`：15 个已改写镜像引用的官方任务（107 MB）。
  - `data/nl2repo/`：patched harness + 104 题文档（8 MB）。
  - `offline/run_batch2.sh`、`offline/run_batch2_inner.sh`、`offline/Dockerfile.runner.v2`、`offline/patches/`。
- 新踩的坑与解法（详细见 [second-batch-bundle.md](second-batch-bundle.md)）：
  1. Harbor 安装 agent 依赖 `curl astral.sh` + `uv tool install` → **派生任务镜像预装载荷 + UV_OFFLINE**；
  2. Harbor `ca_certificates` 无条件 apt → **runner 内打补丁**；
  3. TB4 任务包用 `@sha256:` 引用镜像 → **改写为 release tag**；
  4. NL2Repo 原镜像域名 `docker.all-hands.dev` 已 **NXDOMAIN** → 换 `ghcr.io/all-hands-ai/*`；
  5. OpenHands 对 bind mount 要求宿主机绝对路径 → **runner 以相同绝对路径挂载离线包** + `NL2REPO_HOST_ROOT`；
  6. NL2Repo 评测 `pip install -e .` 需构建后端 → **派生测试镜像预装 + `--no-build-isolation --no-index`**。
- 已验证：TB4 oracle（官方镜像/派生镜像）reward=1；派生镜像断网 agent 安装成功；NL2Repo harness 端到端（容器/模型/挂载/评测）跑通。
- 打包末期发现的额外坑：LiteLLM 1.106 顶层导入依赖 `mcp`，而 Harbor 安装命令未带 `--with mcp` → TB4 agent 启动即退出。
  修复方式：给 15 个派生镜像追加 ~5.6MB 的 mcp 补丁层（`offline/fix_tb4_images.sh`，`load_bundle.sh` 自动执行）。
