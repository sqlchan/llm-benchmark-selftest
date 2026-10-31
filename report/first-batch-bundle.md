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
