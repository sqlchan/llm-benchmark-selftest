# 离线（断网）环境跑 5 个基准：可行性与实施方案

> 场景：家里 PC 有外网；公司网络对外部网络受限，但可用 Docker；公司内部模型只能走 API。
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

## 2. 打包内容清单（按优先级）

| 优先级 | 内容 | 体积量级 | 说明 |
| :-: | :-- | --: | :-- |
| P0 | runner 镜像（Python3.12 + uv + docker CLI + 5 个 harness + 数据） | 3–8 GB | 一个镜像内含 Pier/Harbor/OpenHands/mini-swe/evalscope，任务数据一起 COPY 进去 |
| P0 | Automation-Bench 数据（仓库，无任务镜像） | <1 GB | 纯 API，最省事 |
| P0 | ProgramBench：选定 5–10 个任务镜像 + 测试 blob | 5–20 GB | 官方设计无网，离线最稳 |
| P1 | DeepSWE：选定 10 个任务的预构建镜像 + tasks 目录 | 5–15 GB | 任务定义在 GitHub；镜像需要预拉 |
| P1 | Terminal-Bench 4.0：数据集 + prebuilt 镜像 | 5–20 GB | 66 题镜像；3 题需 H100，离线包排除 |
| P2 | NL2Repo：OpenHands 0.56 双镜像 + 仓库 | 5–10 GB | 容器内调模型 + 无轮数上限，离线难度最高 |
| — | HF gated 数据集（DeepSWE parquet 等） | <1 GB | 打包时用 token 下载并烘进镜像，到公司不需要 HF 权限 |

> 全量 5 个基准的镜像总量可能 50–120GB，**不建议一次全带**；先做 MVP（Automation + ProgramBench 5 题 + DeepSWE 10 题），验证公司环境后再补包。

## 3. MVP 建议（第一次出行带什么）

| 基准 | 子集 | 预估包体积 | 为什么 |
| :-- | :-- | --: | :-- |
| Automation-Bench | simple 200 + sales 100 | ~1 GB | 无 Docker 任务、纯 API，先证明「端点通、判分通」 |
| ProgramBench | 固定 5 题（记录 instance ID） | ~8 GB | 断网设计，能离线跑通就说明整条链没问题 |
| DeepSWE | 10 题（sample-seed 0） | ~8 GB | 最贴近日常开发，官方支持确定性抽样 |
| 合计 | — | **~17 GB** | 外部 SSD 一次带走，1–2 天可跑完 |

TB4 与 NL2Repo 放到第二批：先在离线环境对 3–5 题做「断网可用性」验证，能过再补进包里。

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

## 5. 到公司：加载与运行

```powershell
# 1) 校验并加载（不联网）
.\offline\load_bundle.ps1 -Bundle E:\bench-bundle

# 2) 配置内网端点（configs/company.env，不提交 git）
#    OPENAI_API_BASE=http://host.docker.internal:8080/v1
#    OPENAI_API_KEY=<公司 key>
#    MODEL_NAME=<公司模型名>

# 3) 启动 runner（挂载宿主机 Docker，任务容器由宿主机 Docker 启动）
docker compose -f offline\docker-compose.yml --env-file offline\env\company.env up -d

# 4) 小样本自检：先 5 题，再放量
docker compose -f offline\docker-compose.yml exec runner bash /workspace/offline/run_stage1.sh
```

## 6. 公司内网模型接入

三种情况：

1. **容器能直连内网端点**（同网段/路由可达）：把 `OPENAI_API_BASE` 填内网地址即可。
2. **只有宿主机能访问**（常见）：在宿主机起一个反向代理，容器用 `host.docker.internal` 访问：
   ```bash
   # 示例：宿主机 8080 → 内网 10.x.x.x:8000（PowerShell 可用 nginx/Node 一行或 python -m http.server 走不了代理，建议 nginx）
   # 证书自签：把 CA 挂进 runner 容器 /usr/local/share/ca-certificates/ 并 update-ca-certificates
   ```
3. **公司禁止容器访问内网**：fallback 是把 harness 直接装在宿主机（第 7 节备选），只把任务容器交给 Docker。

另外：DeepSWE/Pier 的容器若 `allow_internet=false`，要把模型端点域名加入 Pier 的 allowlist；TB4 的 Harbor 同理检查网络配置。

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

## 10. 待确认（影响脚本最终形态）

1. 公司那台机器是不是**同一台 Windows 笔记本**？（决定用 Docker Desktop + PowerShell 还是 Linux/WSL2）
2. 公司是否允许挂载 `docker.sock` / 运行 privileged 容器？
3. 公司内网模型：OpenAI 兼容？Anthropic 兼容？地址与证书情况？
4. 公司是否允许外带硬盘/笔记本，是否有镜像白名单？
5. 优先保哪几个基准？（决定第一批包的内容）
