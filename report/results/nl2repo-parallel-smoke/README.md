# NL2Repo 并行补丁：2 题并发冒烟证据（2026-10-31，家里 Windows 宿主）

本目录是 NL2Repo-Bench harness 并行补丁（`offline/patches/nl2repo_parallel.patch`）的
机制验证证据归档。补丁说明见 [`offline/nl2repo-harness/README.md`](../../../offline/nl2repo-harness/README.md)；
容量/工期口径见 [company-32c64g-concurrency.md](../../company-32c64g-concurrency.md)。

## 结论

- ✅ **并发机制通过**：`max_pool_size=2` 时两个任务真正同时运行——两个 app 容器
  （`openhands-app-3100` / `openhands-app-3101`）生命周期重叠 10.139s、两条线程交错处理、
  per-port OpenHands state 目录（`.openhands-3100/3101`）隔离、workspace 与 result JSON
  互不冲突、post-process（评测镜像 + pytest）并发执行、`NL2REPO_CLEANUP=1` 清理生效。
- ⚠️ **模型分数不可用**：本次用本地 mock 模型，且 Windows 宿主上 OpenHands 0.56 的
  `finalize_config()` 不接受 `D:/...:/workspace:rw` 盘符挂载（上游限制，与补丁无关），
  mock → agent → runtime 路径未跑通。公司 Linux 宿主路径以 `/` 开头，不存在该问题；
  正式分数需在公司 Linux 上以真实内网模型跑（建议先 2 题确认再放量）。

详细摘要见 [`concurrency-summary.md`](concurrency-summary.md)，运行配置见 [`run-meta.json`](run-meta.json)。

## 完整证据在哪

- **离线包（公司可看）**：`results/nl2repo-parallel-smoke/`——含 `README.md`、
  `concurrency-summary.md`、`run_parallel.log`（完整 harness 日志）、`docker-ps-snapshots.log`、
  `run-meta.json`、`windows-openhands-app-error.log`、`mock-server.log` 等。
- **开发机（不入 git）**：`sandbox/nl2repo/parallel-test/evidence/`（原始日志与脚本）。

## 复现（公司 Linux，离线包根目录）

```bash
# 正式：10 题、pool=3、端口 3000-3002（profile 注入）
./offline/run_batch2_32c64g.sh nl2repo

# 单题冒烟：串行 + 8 轮，且不要经 wrapper（profile 会覆盖成正式值）
NL2REPO_TASKS=aiofiles NL2REPO_MAX_ITERATIONS=8 NL2REPO_MAX_POOL=1 \
  ./offline/run_batch2.sh nl2repo
```
