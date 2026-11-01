# 第三批补充包：扩大采购评测子集（2026-11-01）

> 目标：在不重打基线包（第一批 5.1GB + 第二批 40GB）的前提下，把「公司内网 API 模型采购评测」的题量与覆盖补到可用水平。
> 结果：**DeepSWE 10→20 题、NL2Repo 10→16 题、ProgramBench 3→5 题；TB4 仍 36 题但新增 `TB4_K` 重复参数**；新增 3 个 gzip 镜像 tar，基线镜像 tar 一个都不用重打。
> 构建机：Windows + Docker Desktop 29.9.2（Linux 容器）｜目标机：公司 Linux 32C/64G 离线 + 内网 OpenAI 兼容端点。

## 0. 结论速览

| 基准 | 基线包 | 补充后 | 新增镜像 | 单模型一轮增量（估算） | 增量成本（估算） |
| :-- | :-: | :-: | :-: | :-- | :-- |
| DeepSWE v1.1 | 10 题 | **20 题** | 10 个任务镜像（`supplement-deepswe.tar.gz`） | +3–9h | +$2–134 |
| NL2Repo-Bench | 10 题 | **16 题** | 6 个派生测试镜像（`supplement-nl2repo.tar.gz`） | +1–2h | +$5–40 |
| ProgramBench | 3 题 | **5 题** | 2 个派生镜像（`supplement-programbench.tar.gz`） | +1.5–3h | +约 $70（按 Opus 级官方均值） |
| Terminal-Bench 4.0 | 36 题 | 36 题（+ `TB4_K`） | 0 | `TB4_K=2` 时 ×2 | ×2 API |
| Automation-Bench | 公开 600 全量 | 不变 | 0 | — | — |

- 新增镜像体积合计约 **8.8 GB**（gzip tar；解压后更大）。
- 题量仍**不是官方全量**（20/113、16/104、5/200），但对「同 harness 同子集跨模型横评」足够；报告里必须写子集。

## 1. 补充了什么、为什么

### 1.1 DeepSWE +10 题（修正语言抽样偏差 + 补维护场景）

基线 10 题是「5 语言 × 2 题」，但 113 题池里 JS/Rust 各只有 5 题、各选了 2 题（占 40%），Python/TS/Go 各 34–35 题各只选 2 题，抽样偏。补充 10 题 = **6 个 bugfix/enhancement（维护场景）+ 4 个 feature**：

| 任务 | 语言 | 类别 | 补充理由 |
| :-- | :-- | :-- | :-- |
| `happy-dom-abort-pending-body-reads` | typescript | bugfix | 池里仅 4 个 bugfix 之一；中断/资源释放类修复 |
| `prometheus-typed-label-sorting` | go | bugfix | PromQL 真实项目；排序/类型边界 |
| `tengo-callable-instance-isolation` | go | bugfix | 闭包/隔离类修复 |
| `opa-template-string-reconstruction` | go | bugfix | OPA 真实项目；partial evaluation 输出 |
| `dateutil-rfc5545-timezone-interop` | python | enhancement | 时区/日历互操作，Python 大生态 |
| `oxvg-structural-selector-preservation` | rust | enhancement | 池里 Rust 少，补 1 题增强类 |
| `fastapi-deprecation-response-headers` | python | feature_request | 真实 FastAPI 仓库；HTTP 语义 |
| `httpx-streaming-json-iteration` | python | feature_request | 流式 JSON/网络库 |
| `drizzle-orm-window-function-builders` | typescript | feature_request | TS ORM 生态；类型化 SQL |
| `helm-array-merge-strategies` | go | feature_request | Helm 真实项目；配置合并 |

> 全部 113 题里只有 7 个非 feature 任务，本批把其中 6 个补进来了（第 7 个 `abs-module-cache-flags` 已在基线 10 题里）。

### 1.2 NL2Repo +6 题（补 Web / ML / 数据库 / 测试 / 数据分析的 Hard 题）

基线 10 题是 3 Easy + 5 Medium + 2 Hard，且全是小工具库。补充 6 题（官方难度、测试数）：

| 任务 | 难度 | 测试数 | 类别（按任务内容判断） |
| :-- | :-: | --: | :-- |
| `fastapi-users` | Hard | 556 | Web / 用户认证 |
| `stable-baselines3` | Hard | 798 | ML / 强化学习 |
| `dictdatabase` | Medium | 594 | 数据库 / 并发 JSON 存储 |
| `python-pytest-cases` | Hard | 1372 | 测试框架 |
| `ydata-profiling` | Hard | 2182 | 数据分析 / EDA |
| `flask-restful` | Medium | 362 | Web / REST |

> 难度分布来自官方仓库 `test_files/task_difficulty.csv`；测试数来自各任务 `test_case_count.txt`。

### 1.3 ProgramBench +2 题（补「经典中型程序」）

基线 3 题都是小型 CLI（cmatrix、zip-password-finder、zoxide）。补 2 题：

| 实例 | 是什么 | 理由 |
| :-- | :-- | :-- |
| `jqlang__jq.b33a763` | JSON 处理器 | 解析/序列化语义+测试丰富，程序重建的标杆题 |
| `burntsushi__ripgrep.3b7fd44` | 递归搜索工具 | 搜索语义+性能，知名 Rust 工具 |

> 避开 FFmpeg/duckdb/pandoc 这类超大程序（单题 6h 上限、镜像大、成本高）。

### 1.4 Terminal-Bench：不加题，加 `TB4_K`

- 基线 36/66 题（Software 18 + Operations 9 + Security 5 + Media 4），已排除 3 道 GPU 题、Science/ML/Hardware 30 题；对采购评测来说「36 题 × k=2~3 复跑」比扩题更划算（不占磁盘，只花 API）。
- 本批给 `run_batch2.sh` / `run_batch2_inner.sh` 增加 `TB4_K`（透传 Harbor `-k`，默认 1）；用法：`TB4_K=2 PROFILE=32c64g ./offline/run_batch2.sh tb4`。

## 2. 产物清单

### 2.1 新增镜像 tar（`E:\bench-bundle\images\`）

| 文件 | 大小 | SHA256 | 内容 |
| :-- | --: | :-- | :-- |
| `bench-images-supplement-deepswe.tar.gz` | 4.54 GB | `b02a00cf787395b938db1180655243d298064f97915c2622ddb4d9c7ebb80612` | 10 个 DeepSWE 任务镜像 |
| `bench-images-supplement-nl2repo.tar.gz` | 3.07 GB | `1fd72eeecbc2f35d9f7c22400d735233e59e8d7ae52dc911b15f447aca243eee` | 6 个 NL2Repo 派生测试镜像 |
| `bench-images-supplement-programbench.tar.gz` | 1.18 GB | `dae00486b3497f9471a1021119487d3edee62c69d6d02d4c0dc606c1fbb14117` | 2 个 ProgramBench 派生镜像（已做离线 eval 修复） |

- 每个 tar 旁有 `image-list-supplement-<group>.txt` 镜像清单。
- `load_bundle.sh` 已升级为同时加载 `*.tar` 与 `*.tar.gz`（本批 tar.gz 在基线 tar 之后加载）。

### 2.2 数据与配置改动（都在包内）

| 文件/目录 | 改动 |
| :-- | :-- |
| `data/deepswe_selected.json` | 10 → 20 项（含 task/lang/image）；旧版备份在 `data/deep-swe/deepswe_selected.10tasks.orig.json` |
| `data/deep-swe/README.md` | 追加「离线包选中的 20 题」章节 |
| `data/nl2repo/harness/test_files/<6 题>/test_commands.json` | 首条命令改为离线版 `pip install --no-build-isolation --no-index -e .` |
| `data/nl2repo/bundled_tasks.json` | 10 → 16 题（含 patched_commands） |
| `data/nl2repo/README.md` | 10 → 16 题说明 |
| `data/programbench_blobs/` | 新增 jq、ripgrep 两个实例的 tests blob（HF revision `5954a1957b5e0d770ec2c5523506abd212806315`） |
| `data/README-programbench-blobs.md` | 说明 5 个实例与镜像 tag |
| `offline/deepswe-pier-32c64g.yaml` | 10 → 20 题（`n_tasks: 20`） |
| `offline/config/32c64g.env` | `NL2REPO_TASKS` 10 → 16 题；新增 `TB4_K` 注释 |
| `offline/programbench-eval-fix/` | 随包附带（供以后扩 ProgramBench 时构建派生镜像） |
| `offline/load_bundle.sh` | 支持 `*.tar.gz` |
| `manifest.json` | 新增 `supplement_batch` 段与 3 个 `batches` 条目 |
| `docs/third-batch-bundle.md` | 本文 |

## 3. 公司端加载与运行

### 3.1 加载

```bash
cd /mnt/ssd/bench-bundle
./offline/load_bundle.sh "$PWD"     # 自动校验 SHA256 → 按文件名加载 7 个 tar/tar.gz → 打 TB4 mcp 补丁
docker images | grep -c -E 'swe-bench|nl2repobench|programbench'   # 期望：10 + 16 + 5 = 31（含基线）
```

### 3.2 跑补充子集

```bash
# DeepSWE 20 题（Pier；n_concurrent_trials=3）
mkdir -p "$PWD/jobs"
sed -e 's#REPLACE_ME_MODEL#<内网模型名>#' \
    -e 's#REPLACE_ME_OPENAI_API_BASE#http://<内网地址>/v1#' \
    -e "s#/workspace/jobs#$PWD/jobs#; s#/workspace/data#$PWD/data#" \
    "$PWD/offline/deepswe-pier-32c64g.yaml" > "$PWD/jobs/deepswe-20.local.yaml"
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD:$PWD" -w "$PWD" \
  -e OPENAI_API_KEY -e DOCKER_API_VERSION=1.41 bench-eval-runner:v2 \
  pier run -c "$PWD/jobs/deepswe-20.local.yaml"

# NL2Repo 16 题（默认 profile 已含 16 题；pool=3）
PROFILE=32c64g ./offline/run_batch2.sh nl2repo

# ProgramBench 5 题（串行；离线 eval 修复已内置）
mini-extra programbench --model "$MODEL_NAME" \
  --filter "ajeetdsouza__zoxide|abishekvashok__cmatrix|agourlay_zip|jqlang__jq|burntsushi__ripgrep" \
  --workers 1 -c <mini-swe 配置文件>

# TB4 36 题 × 2 次（稳定性复跑）
TB4_K=2 PROFILE=32c64g ./offline/run_batch2.sh tb4
```

## 4. 容量与工期增量（32C/64G）

| 基准 | 基线工期 | 补充后工期（估算） | 备注 |
| :-- | :-- | :-- | :-- |
| DeepSWE 20 题 | 3–9h（10 题） | **6–18h** | 每 trial 2C/8GB，n=3；顺序跑 |
| NL2Repo 16 题 | 1–3h（10 题） | **2–5h** | pool=3；单题波动大 |
| ProgramBench 5 题 | 1.5–3h（3 题） | **2.5–5h** | 串行；单题上限 6h |
| TB4 36 题×2 | 约 1 天（×1） | **约 2 天** | `TB4_K=2` |
| 磁盘 | 46.5GiB（4 tar） | **+8.8 GB（3 个 tar.gz）** | E: 需要 ≥ 约 55GB 空闲 |

> 混跑限制不变：基准之间顺序跑（TB4 最坏内存 56GB；DeepSWE 3 并发约 24GB；NL2Repo pool=3 约 12GB）。

## 5. 构建与验证记录（2026-11-01）

| 步骤 | 结果 |
| :-- | :-- |
| DeepSWE 拉取 10 个 ECR 镜像 | ✅ 10/10（部分镜像遇到 `unexpected EOF`，重试后成功；层可续传） |
| NL2Repo 拉取 6 个 ghcr 基础镜像 | ✅ 6/6（stable-baselines3 4.73GB 最大；有重试） |
| NL2Repo 派生镜像构建 | ✅ 6/6（`install_deps.py` 层已验证存在；dictdatabase/ydata-profiling 首次失败后重试成功） |
| ProgramBench 拉取 2 个镜像 | ✅ 2/2（Docker Hub registry 直连超时，改走 `docker.1ms.run` 镜像源并重新 tag） |
| ProgramBench 派生镜像（离线 eval 修复） | ✅ 2/2（最终方案用 COPY 预置 `pytest_timeout.py` + dist-info；该镜像里 `RUN pip install` 会返回成功但文件不落盘，已改用 COPY 并验证 `import pytest_timeout` 通过） |
| ProgramBench 测试 blob | ✅ jq 28MB / ripgrep 39MB（HF revision `5954a19`，与基线快照一致） |
| 打包（docker save + gzip + SHA256） | ✅ 3/3（nl2repo / programbench / deepswe；gzip 完整性 quick-check 通过） |
| **未做** | ❌ 真实模型端到端跑分（需公司内网端点首跑）；DeepSWE oracle 单题验证未在本机跑 |

## 6. 复现（有外网构建机）

1. 拉镜像：
   - DeepSWE 10 个 ECR 镜像见 `data/deepswe_selected.json`（第 11–20 项）；
   - NL2Repo 6 个 `ghcr.io/multimodal-art-projection/nl2repobench/<task>:1.0`；
   - ProgramBench 2 个：`programbench/jqlang_1776_jq.b33a763:task_cleanroom_v6`、`programbench/burntsushi_1776_ripgrep.3b7fd44:task_cleanroom_v6`（Docker Hub 直连不通时用 `docker.1ms.run/` 前缀 + `docker tag` 还原）。
2. NL2Repo 派生：`docker build --build-arg BASE_IMAGE=<img> -f offline/nl2repo-test-fix/Dockerfile -t <img> offline/nl2repo-test-fix`。
3. ProgramBench 派生：`docker build --build-arg BASE=<img> -f offline/programbench-eval-fix/Dockerfile -t <img> offline/programbench-eval-fix`。
4. ProgramBench blob：在 runner 容器里 `HF_HUB_OFFLINE=0 PROGRAMBENCH_HF_REVISION=5954a1957b5e0d770ec2c5523506abd212806315 programbench blob sync <instance>`，把 snapshot 内容（symlink 需 `cp -rL`）复制到 `data/programbench_blobs/<instance>/`。
5. 打包：`docker save` 每组镜像 → gzip → 更新 `images/SHA256SUMS`、根 `SHA256SUMS`、`image-list-supplement-*.txt`、`manifest.json`。

## 7. 已知限制

- 子集而非全量：DeepSWE 20/113、NL2Repo 16/104、ProgramBench 5/200；跨模型可比，但**不能对官方榜/模型卡数字**。
- NL2Repo 离线测试命令是改写版（`--no-build-isolation --no-index`），与官方口径有差异，报告需注明。
- ProgramBench 的主指标是 Resolved，模型卡数字是 Almost@1；本包 5 题只用于相对比较。
- TB4 部分任务依赖公网；公司端先跑 `oracle` 自检，剔除环境不通题。
- Docker Hub 直连限制只影响构建机；公司端是离线 `docker load`，不受影响。

## 8. 来源

- DeepSWE 任务定义：离线包 `data/deep-swe/tasks`（官方 repo commit `0b9fabbb`）；官方站 <https://deepswe.datacurve.ai/>
- NL2Repo：<https://github.com/multimodal-art-projection/NL2RepoBench>；难度 CSV 在 `test_files/task_difficulty.csv`
- ProgramBench：<https://programbench.com/>、HF `programbench/ProgramBench-Tests`（revision `5954a1957b5e0d770ec2c5523506abd212806315`）
- TB4：<https://www.tbench.ai/>、Harbor `@4.0.0`
- 基线包文档：[`first-batch-bundle.md`](first-batch-bundle.md)、[`second-batch-bundle.md`](second-batch-bundle.md)；并发/容量：[`company-32c64g-concurrency.md`](company-32c64g-concurrency.md)
