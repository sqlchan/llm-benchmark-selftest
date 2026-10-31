# ProgramBench 单题实测证据（zoxide）

## 结论

| 项 | 值 |
| :-- | :-- |
| 任务 | `ajeetdsouza__zoxide.67ca1bc`（ProgramBench，镜像 tag `task_cleanroom_v6`） |
| 模型 | Ark `deepseek-v4-flash`，base `https://ark.cn-beijing.volces.com/api/plan/v1` |
| 评测结果 | **Score 56 / 531 tests**（测试通过比例；**未 resolved**，官方主指标 Resolved 要求全部通过） |
| Agent | mini-swe-agent 2.4.6，`max_tokens=16384`，`step_limit=40`，墙钟 900s（到步数上限自动提交） |
| 运行 | 2026-10-31，92 次模型调用，prompt 1,654,554 tokens，completion 51,123（reasoning 36,463），约 13 分钟 |

> Score=56 是「测试通过比例」，不是 ProgramBench 官方榜的 Resolved（0/1）。该实例未完全解决。

## 文件说明

| 文件 | 说明 |
| :-- | :-- |
| `eval.json` | `programbench eval` 的完整输出：531 个测试用例的逐条状态、分支错误、日志 |
| `trajectory.json` | agent 轨迹（mini-swe 格式）：每步模型响应、tool_calls、reasoning_content |
| `submission.tar.gz` | agent 提交的整个 workspace（被打分对象） |
| `minisweagent.log` | agent 运行日志 |
| `exit_statuses.yaml` | 该轮 agent 的退出状态（`LimitsExceeded`，到步数上限自动提交） |
| `console/pb_smoke*.log` | 7 次控制台输出（按时间顺序）：资源限制、programbench 同环境、mcp、凭据、输出截断、eval 缺 pytest-timeout 等问题的现场记录 |

## 复现命令（首页有网络时）

```bash
# 1) 构造 mini-swe 模型配置（放到容器可读路径）
cat > /tmp/model.yaml <<EOF
model:
  model_name: openai/deepseek-v4-flash
  model_kwargs:
    api_base: https://ark.cn-beijing.volces.com/api/plan/v1
    max_tokens: 16384
    drop_params: true
  cost_tracking: ignore_errors
EOF

# 2) 跑 agent（宿主 docker.sock + 离线包数据）
docker run --rm --network host -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD/jobs:/workspace/jobs -v $PWD/data:/workspace/data \
  -e OPENAI_API_KEY -e PROGRAMBENCH_BLOB_DIR=/workspace/data/programbench_blobs \
  bench-eval-runner:local bash -lc 'cd /workspace/jobs && mini-extra programbench \
    --model openai/deepseek-v4-flash -c /tmp/model.yaml \
    --filter "ajeetdsouza__zoxide" --workers 1'

# 3) 评测
RUN_DIR=$(ls -d /workspace/jobs/programbench_results_* | tail -1)
programbench eval "$RUN_DIR" --workers 1 --docker-cpus 8
```

## 关键前提（缺一不可）

1. ProgramBench 任务镜像需做派生修复（预装 `pytest-timeout` + 本地 wheelhouse），否则 eval 报 `results_read_failed`；见仓库 `offline/programbench-eval-fix/`。
2. 任务容器默认要 20 CPU / 60GB，小机器需覆盖 `environment.run_args` 去掉资源限制。
3. `mini-extra programbench` 需要 `programbench` 与 `mini-swe-agent` 在同一 Python 环境（runner 镜像已用 `--with` 安装）。
4. LiteLLM 需要 `mcp` 包（runner 镜像已装）。
