# TB4 mini-swe-agent 冒烟：两次失败现场（mcp 缺包发现过程）

本目录保存第二批打包末期用 Ark `deepseek-v4-flash` 跑 TB4 **agent 链路**的两次冒烟现场。
它们**不是模型分数**，而是暴露并定位了离线包的一个关键缺陷（缺 `mcp`），
修复方式见 `report/second-batch-bundle.md` §5.5 与 `offline/fix_tb4_images.sh`。

## 1. 两次尝试

| 尝试 | 结果 | 失败原因 |
| :-- | :-- | :-- |
| `jobs4-gbk-encoding/` | 未完成（job `n_running_trials=1`，无 trial result） | Windows 控制台 GBK 编码：Harbor 打印 agent 输出时 `'gbk' codec can't encode character '\u2771'`，trial 在判分前中止（Linux 公司环境不会出现） |
| `jobs5-mcp-missing/` | 完成但 errored：`NonZeroAgentExitCodeError`，reward 0.0 | agent 安装与**模型调用已发生**，随后 `ModuleNotFoundError: No module named 'mcp'`（LiteLLM 1.106 顶层导入触发） |

时间：2026-10-31 16:10–16:25（UTC+8）；框架 Harbor 0.25.0 + mini-swe-agent 2.4.6；
任务 `bun-sourcemap-leak`（派生 environment 镜像 `tb4off/environment:bun-sourcemap-leak`）；
模型端点 Ark `https://ark.cn-beijing.volces.com/api/plan/v1`。

## 2. 文件说明

### jobs4-gbk-encoding/

| 文件 | 内容 |
| :-- | :-- |
| `job.log` | job 日志：agent 安装命令、模型调用命令、失败输出 |
| `job-result-unfinished.json` | 未完成的 job 结果（`finished_at=null`，1 running trial） |
| `trial.log` | trial 日志：`'gbk' codec can't encode character '\u2771'` 中止现场 |

### jobs5-mcp-missing/

| 文件 | 内容 |
| :-- | :-- |
| `job.log` | job 日志：完整 agent 命令（含 base_url / 模型名 / 任务文本） |
| `job-result.json` | job 结果：`n_errored_trials=1`、`exception_stats.NonZeroAgentExitCodeError`、reward 0.0 |
| `trial-result.json` | trial 结果（15 KB） |
| `trial.log` | trial 日志：apt → uv tool install → mini-swe-agent 启动 → `Command failed` |
| `exception.txt` | 完整 traceback，含 `ModuleNotFoundError: No module named 'mcp'` 调用栈 |
| `trajectory.json` | mini-swe-agent 产出的轨迹（模型调用已发生） |
| `console-output.txt` | agent 控制台输出 |

### mcp-fix-build.log

对 15 个 TB4 派生镜像逐个追加 ~5.6 MB mcp 补丁层的构建日志（原始日志，已去除 ANSI 转义/UTF-16 转 UTF-8）。
本机结果：**12 个 `OK`，3 个 `FAIL`**（`live-database-cutover`、`nextjs-performance`、`html-js-filter`，
当时本机 Docker 因磁盘写满导致 snapshot 状态异常，构建报 `exec /bin/sh: exec format error`；
其中 html-js-filter 事后用 `docker commit` 手工验证补丁可生效）。末尾 `ALL DONE`。
公司干净环境加载后重跑 `offline/fix_tb4_images.sh` 即可把 3 个缺失的补齐。

## 3. 根因与修复（摘要）

- 根因：Harbor 0.25.0 安装 mini-swe-agent 的命令没有 `--with mcp`，而该环境里
  LiteLLM 1.106 顶层导入会加载 `mcp`；TB4 派生镜像复用 Harbor 安装结果，因此缺包。
- 修复：不重建载荷，只给 15 个派生镜像追加小补丁层
  （`offline/tb4-agent-payload/agent-extra.tar.gz` + `Dockerfile.agent-mcp-fix`），
  并加 `ENV LITELLM_LOCAL_MODEL_COST_MAP=True` 避免联网拉 cost map。
- 应用：`offline/fix_tb4_images.sh` 幂等（先 `--network none` 检查 `import mcp`，缺才构建）；
  `load_bundle.sh` 加载镜像后自动执行。
- 修复后验证：本机成功构建 12 个镜像；对 html-js-filter 派生镜像做过 `--network none` 下
  `import mcp` / `import litellm` 检查（通过，当时为交互执行、未另存日志文件）；
  另 3 个镜像因本机 Docker snapshot 异常构建失败，需在公司干净环境重跑脚本补齐（见本目录日志）。

## 4. 口径说明

- reward 0.0 是 **mcp 缺包导致 agent 进程非零退出**，不是模型能力结果；
  jobs4 的 GBK 失败是 Windows 控制台编码问题，与基准无关。
- 本机**没有** TB4 agent 正式分数（官方单题 agent 预算 8 小时）；
  正式跑分须在公司 Linux 上执行（见 `report/company-day1-checklist-batch2.md`）。
- 证据中的 base_url / 模型名为当时使用值；API key 未写入任何文件。
