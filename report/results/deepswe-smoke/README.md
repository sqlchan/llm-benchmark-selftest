# DeepSWE 单题冒烟证据（abs-module-cache-flags）

## 结论

DeepSWE 官方 runner 是 **Pier + mini-swe-agent**，单题任务容器、模型调用、agent 执行均已跑通；
但单题真实耗时在 **30 分钟–数小时**（官方 agent 预算 3 小时），6 次有界冒烟都没能在时限内产出完整 patch + verifier 分数。

| 轮次 | 日志 | 结果 | 原因 | 修复 |
| :-: | :-- | :-- | :-- | :-- |
| 1 | `console/ds_smoke1.log` | `RuntimeError` | runner 镜像缺 `docker compose` 插件（Pier 用 compose 起任务环境） | apt 装 `docker-compose-v2` 重建镜像 |
| 2 | `console/ds_smoke2.log` | `ValueError`（API key 未设置） | CLI 多层引号把 `--ae`/`--ak` 参数破坏 | 改用 Pier YAML job 配置 |
| 3 | `console/ds_smoke3.log` | `NonZeroAgentExitCodeError` | Pier 对 `openai/` 前缀自动选 `litellm_response`（Responses API），Ark 不支持 | `model_class: litellm` |
| 4 | `console/ds_smoke4.log` | `NonZeroAgentExitCodeError` | mini-swe 环境缺 `mcp`（LiteLLM 懒加载） | `extra_python_packages: [mcp]` |
| 5 | `console/ds_smoke5.log` | `AgentTimeoutError`（15m35s） | 冒烟超时设 0.08（≈14min），agent 仍在正常推进 | 放宽 `agent_timeout_multiplier`（正式跑 0.5–1.0） |
| 6 | `console/ds_smoke6.log` | `RewardFileNotFoundError`（8m33s） | 加了 `step_limit: 60` 后提前结束、patch 为空 → verifier 无 reward | 正式跑不要压太低步数；或延长时限 |

**已验证**：Pier 通过 compose 构建/启动 DeepSWE 任务镜像、2 CPU/8GB 资源限制可被 `cpu/memory_enforcement_policy: ignore` 覆盖、agent 在沙箱内多步调用 Ark API、产出提交。

## 文件说明

| 目录/文件 | 说明 |
| :-- | :-- |
| `configs/pier_job_ds*.yaml` | 6 轮尝试使用的 Pier YAML 配置（从 CLI 迁移到 YAML 的演进） |
| `console/ds_smoke*.log` | 每轮控制台输出（Pier 汇总表 + 失败类型） |
| `job-artifacts/` | 最后一轮（第 6 轮）的现场：job/trial 结果 JSON、异常栈、trial 日志、config、lock、artifacts manifest |
| `job-artifacts/trial.log` | 包含 Pier 实际下发给 mini-swe 的完整命令（含 `-c model.model_class=litellm` 等） |

## 正式跑法（建议）

用仓库 [`offline/deepswe-pier-job.example.yaml`](../../../offline/deepswe-pier-job.example.yaml)：

```bash
docker run --rm --network host -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD/data:/workspace/data -v $PWD/jobs:/workspace/jobs \
  -e OPENAI_API_KEY -e OPENAI_API_BASE \
  bench-eval-runner:local pier run -c /workspace/deepswe-pier-job.example.yaml
```

- 冒烟：`agent_timeout_multiplier: 0.2`（≈36 分钟）
- 正式：`0.5–1.0`（1.5–3 小时/题），10 题按 `n_concurrent_trials: 2–4` 并行（注意本机/公司机器 CPU 与内存）
- 已知限制：本机 16 CPU / 16GB，DeepSWE 单任务 2 CPU / 8GB，4 并发接近上限
