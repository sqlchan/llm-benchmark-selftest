# ProgramBench 离线评测修复

## 问题

断网时 `programbench eval` 对每个任务分支报：

```
results_read_failed
Error response from daemon: Could not find the file /workspace/eval/results.xml
```

根因：官方 `eval/run.sh` 第一行是 `pip install pytest pytest-timeout pytest-xdist -q`（`set -e`），
离线环境 pip 失败 → 缺 `pytest-timeout` → pytest 报 `unrecognized arguments: --timeout=30` → 没有 results.xml。

## 修复

对每个用到的 ProgramBench 任务镜像做派生镜像：

```bash
docker build --build-arg BASE=programbench/<instance>:task_cleanroom_v6 -t pb-fix -f Dockerfile .
docker tag pb-fix programbench/<instance>:task_cleanroom_v6
```

派生镜像做了两件事：
1. 预装 `pytest-timeout`（wheel 在 `wheels/`）；
2. 写 `/etc/pip.conf`（`no-index` + `find-links=/opt/pip-wheels`），让 eval 里的 `pip install ...` 在离线时成功返回。

## 验证（2026-10-31）

修复后对 Ark `deepseek-v4-flash`（max_tokens=16384、step_limit=40）在
`ajeetdsouza__zoxide.67ca1bc` 上的提交评测成功：

```
Evaluation Summary
 ajeetdsouza__zoxide.67ca1bc   Score 56  (531 tests)
```

> Score=56 表示部分测试通过，任务未 resolved（ProgramBench 主指标是 Resolved：全部测试通过）。
