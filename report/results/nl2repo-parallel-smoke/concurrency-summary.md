# NL2Repo 2 题并发冒烟证据摘要

- harness: `sandbox/nl2repo/parallel-test/smoke`（复制自打过并行补丁的 `sandbox/batch2/nl2repo/harness`）
- 时间: 2026-10-31 20:29:42.774 → 2026-10-31 20:30:03.354（20.6s），python 退出码 0
- 配置: max_pool_size=2, port_base=3100, cleanup=True, tasks=[['aiofiles', 'humanize']]
- 模型: mock（OpenAI 兼容本地 mock server），**分数不代表模型能力**

## 判定

**并发机制：通过**（2 个 app 容器并存=True，日志线程并发=True，两 result JSON=True，app 容器生命周期重叠=10.139s）

## 任务/端口/容器/线程

| 任务 | 线程 | 宿主端口 | app 容器 | 首条日志 | 末条日志 | post-process |
|---|---|---|---|---|---|---|
| aiofiles_bo1 | ThreadPoolExecutor-0_0 | 3100 | `openhands-app-3100` | 2026-10-31 20:29:44.524 | 2026-10-31 20:30:03.297 | True |
| humanize_bo1 | ThreadPoolExecutor-0_1 | 3101 | `openhands-app-3101` | 2026-10-31 20:29:44.524 | 2026-10-31 20:30:03.169 | True |

## app 容器生命周期（来自 harness 日志）

| 容器 | 启动 | 结束（auto_remove） |
|---|---|---|
| `openhands-app-3100` | 2026-10-31 20:29:45.112 | 2026-10-31 20:29:55.347 |
| `openhands-app-3101` | 2026-10-31 20:29:45.208 | 2026-10-31 20:29:55.454 |

两个 app 容器同时存续窗口：**10.139 秒**

## docker ps 轮询证据

- 快照数：10；同时存在 openhands-app-* 最多的快照：2 个
- 首次出现 2 个 app 容器的快照：2026-10-31 20:29:45.153 → ['openhands-app-3100', 'openhands-app-3101']
- post-process 测试容器同时最多 2 个（两个任务并发 post-process 的证据）：['python-test-aiofiles_bo1', 'python-test-humanize_bo1']
- 原始快照：`sandbox/nl2repo/parallel-test/evidence/docker-ps-snapshots.log`

## result JSON

| 文件 | task_uuid | status | score | port | container | saved_at |
|---|---|---|---|---|---|---|
| aiofiles_bo1.json | aiofiles_bo1 | completed | 1 | 3100 | `openhands-app-3100` | 2026-10-31 20:30:03 |
| humanize_bo1.json | humanize_bo1 | completed | 0 | 3101 | `openhands-app-3101` | 2026-10-31 20:30:03 |

## 并发隔离检查

- 日志中的 OpenHands state 目录（per-port）：['.openhands-3100', '.openhands-3101']
- 磁盘上的 state 目录：['.openhands-3100', '.openhands-3101']
- workspaces：['aiofiles_bo1', 'humanize_bo1']
- 端口集合：[3100, 3101]（= port_base + 任务序号）
- NL2REPO_CLEANUP 日志：["NL2REPO_CLEANUP 已开启：检查 4 个本批次残留容器名: ['openhands-app-3100', 'openhands-app-3101', 'python-test-aiofiles_bo1', 'python-test-humanize_bo1']", 'NL2REPO_CLEANUP 完成：本次清理 2 个残留容器']

## 模型调用路径（mock）

- mock server `GET /v1/models` 次数：6（本机探活）；`POST /v1/chat/completions` 次数：0
- **本次 Windows 宿主未跑通「mock 模型 → agent → runtime」路径**：OpenHands 0.56 的
  `finalize_config()` 不接受 Windows 盘符挂载格式 `D:/.../workspace:/workspace:rw`（要求正好 3 段），app 容器启动后立即以 ValueError 退出，因此 mock 没收到 chat/completions 请求。
- 该限制来自 OpenHands 上游的挂载解析（与并行补丁无关），复现日志见 `evidence/windows-openhands-app-error.log`；公司 Linux 宿主上的路径是 `/...`，不存在该问题。
- 结论口径：**并发机制已验证；模型/分数不可用（Windows 宿主限制 + mock 模型）**，正式分数需在公司 Linux 宿主上用真实模型跑。

## 说明/限制

- 使用本地 mock 模型（固定返回「不调用工具、直接结束」），agent 不会真正实现代码，因此分数/通过率**不可用**；本次只验证并发机制：线程池、per-port 容器与 state 目录、进程退出、post-process 与 result JSON 生成。
- mock server 由宿主机 0.0.0.0:8765 提供，容器经 `host.docker.internal` 访问。
