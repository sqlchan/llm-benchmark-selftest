# NL2Repo-Bench 端到端冒烟证据（aiofiles）

本目录保存 **NL2Repo-Bench（10 题离线子集）** 在本机跑通 harness 全流程的原始产物。
用途：证明「OpenHands 容器启动 → 模型调用 → workspace 挂载 → 后处理构建评测镜像 → pytest 执行 → result JSON 落盘」链路可用；
**本目录的分数不是正式分数**（原因见第 3 节）。

## 1. 这次跑的是什么

| 项 | 值 |
| :-- | :-- |
| 日期 | 2026-10-31（本地 UTC+8） |
| 任务 | `aiofiles`（官方 104 题之一，测试用例 211 个） |
| 模型 | Ark `deepseek-v4-flash`（`https://ark.cn-beijing.volces.com/api/plan/v1`） |
| harness | NL2RepoBench 官方 harness（已打离线补丁：ghcr 镜像源 / `NL2REPO_HOST_ROOT` / `bash -c` 启动 / 离线评测命令） |
| OpenHands 镜像 | `ghcr.io/all-hands-ai/openhands:0.56` + `ghcr.io/all-hands-ai/runtime:0.56-nikolaik` |
| agent 轮数 | `max_iterations = 8`（官方模板默认 500；冒烟特意调小以控制时长） |
| 宿主 | Windows + Docker Desktop；harness 用 python-on-whales 经 docker.sock 启动容器 |
| 结束状态 | `status=completed`、`exit_code=0`、`All tasks completed!` |

## 2. 文件说明

| 文件 | 内容 |
| :-- | :-- |
| `result-aiofiles_bo1.json` | harness 输出的任务结果（25 KB）：状态、容器、后处理、pytest 输出、`result/` 落盘内容的原始 JSON |
| `harness-app.log` | harness 应用日志（62 KB）：从启动到 `All tasks completed!` 的完整过程 |
| `workspace-postprocess.log` | 后处理日志（24 KB）：构建测试镜像、`pip install -e .`、pytest 执行与结果分析 |
| `workspace.zip` | 冒烟结束时对 `/workspace` 打的快照（含任务 `start.md`） |
| `task-Dockerfile` | harness 为评测生成的测试镜像 Dockerfile（`FROM ghcr.io/multimodal-art-projection/nl2repobench/aiofiles:1.0`） |
| `config.json` | harness 任务配置（API key 已脱敏为 `<REDACTED>`） |
| `run-config.toml` | 本次任务的 OpenHands 配置模板（含 `volumes = "/run/desktop/mnt/host/d/…/workspace:/workspace:rw"`，API key 已脱敏） |

## 3. 关键观察与口径

1. **链路全部打通**：容器启动、模型调用、workspace bind mount、后处理 `docker build`、
   `docker exec` 跑 pytest、`result/aiofiles_bo1.json` 落盘都成功。
2. **本次 pytest 得分低是已知原因，不是模型分数**：
   冒烟时用的还是**官方测试镜像**（只有骨架，`pip install -e .` 需要联网装构建后端），
   因此 `pip install -e .` 退出码 1、pytest 结果为 1 passed / 20 failed / 8 skipped / 6 errors。
   之后才构建了 10 个离线派生测试镜像（预装 `build-system.requires` + 项目依赖，
   评测命令改为 `pip install --no-build-isolation --no-index -e .`）；
   **派生镜像未做端到端复跑**，只验证了构建可用。公司端正式跑分使用的是派生镜像。
3. **workspace 挂载另有单独验证**：本目录未包含「模型写文件」的直接输出；
   当时另做了一次 mount 写入检查（宿主 `workspace/hello.txt` 可见），该文件在
   `workspace.zip` 快照之后生成，故不在 zip 内。
4. **原始字段**：`status=completed`、`score=1`、`test_score=1` 为 harness 原始字段，
   不要据此解读为基准成绩；正式口径以官方 pass@1（按题通过率）为准。
5. `max_iterations=8` 与官方默认 500 不同；正式跑分需用默认/更大值，并接受单题成本与时长波动。

## 4. 复现（公司 Linux + 离线包）

```bash
./offline/load_bundle.sh "$PWD"
cp offline/env/example.env offline/env/company.env && vi offline/env/company.env

# 冒烟：1 题 8 轮（约 10–20 分钟）
BUNDLE_DIR=$PWD NL2REPO_TASKS=aiofiles NL2REPO_MAX_ITERATIONS=8 \
  ./offline/run_batch2.sh nl2repo

# 正式：3 题串行、默认轮数（端口 3000 固定，max_pool=1）
BUNDLE_DIR=$PWD NL2REPO_TASKS=aiofiles,humanize,sqlparse NL2REPO_MAX_ITERATIONS=500 \
  ./offline/run_batch2.sh nl2repo
# 结果：data/nl2repo/harness/result/*.json
```

> 本次冒烟在 Windows 上用 `/run/desktop/mnt/host/d/...` 形式的宿主路径；
> 公司端 `run_batch2.sh` 以「容器内路径 = 宿主机路径」挂载整个离线包，无需该转换。
