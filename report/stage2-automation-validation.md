# 第 2 步验证记录：Automation-Bench 链路（本机，mock 端点）

> 日期：2026-10-31 ｜ 环境：Windows + Python 3.13.13（uv 管理）+ AutomationBench 1.0.6
> 目的：在不依赖真实模型的前提下，先证明「数据 → 环境 → 模型请求 → 判分 → 导出」整条链路可用。

## 1. 做了什么

1. 克隆官方仓库 `zapier/AutomationBench`（v1.0.6，`requires-python >=3.13`）；
2. `uv sync --python 3.13` 创建隔离环境（Python 3.13.13，118 个依赖）；
3. 用 `offline/tools/mock_openai_server.py` 起本地 OpenAI 兼容 mock（返回「不调用工具、直接结束」）；
4. 跑 `--domains simple --num-examples 2 --max-steps 3`，完整走通评测与导出。

## 2. 结果

```
Average score (partial credit): 0%
Pass rate (100% only): 0%
  Task 1 (simple.email_sf_contact_phone_update): FAIL
  Task 2 (simple.email_sf_contact_email_update): FAIL

Results exported to: ..\mock_simple2b.json
✓ mock_simple2b.json: already clean (0 aborts) — nothing to do
exit=0
```

> 0 分是预期结果（mock 不调用任何工具，断言必然不过）；关键是**流程完整、判分执行、JSON 导出成功、退出码 0**。

导出 JSON 结构（后续评分/汇报直接用这些字段）：

```
meta      : timestamp / model / toolset / domains / total_tasks / duration_seconds /
            benchmark_version / reasoning_effort / max_steps
summary   : avg_score / pass_rate / passed_count / failed_count /
            total_input_tokens / total_output_tokens / total_cached_input_tokens /
            total_reasoning_tokens / total_tool_calls / total_model_time_s /
            total_tool_time_s / total_cost / aborted_tasks
tasks[]   : id / name / score / passed / assertions_total / assertions_passed /
            assertion_results[]（type / passed / params）
usage_by_task
```

## 3. 踩到的坑

| 现象 | 原因 | 解决 |
| :-- | :-- | :-- |
| 跑完导出后进程退出码 1，报 `UnicodeEncodeError: 'gbk' codec can't encode character '✓'` | Windows 控制台 GBK，rich 打印勾号崩溃；发生在**导出之后**，数据没丢 | 设 `PYTHONUTF8=1`、`PYTHONIOENCODING=utf-8`（公司 Linux 无此问题） |
| `uv sync` 首次退出码 1（但环境已建好） | 安装末尾的某个后置步骤失败，重跑即通过 | 重跑 `uv sync --python 3.13` 确认 exit=0 |
| 控制台中文/进度条乱码 | 同样是 GBK 终端 | 同上，或使用 Windows Terminal + UTF-8 |

## 4. 真实模型怎么跑（待有效 Ark key）

```powershell
# 1) 新开终端，设置（不要把 key 写进命令或文件）
$env:OPENAI_API_KEY = "<有效的 Ark API Key>"
$env:PYTHONUTF8 = "1"

# 2) 进入 AutomationBench
cd sandbox\AutomationBench

# 3) 先 5 题（deepseek-v4-flash）
uv run auto-bench --model deepseek-v4-flash `
  --base-url https://ark.cn-beijing.volces.com/api/plan/v1 `
  --api-key-var OPENAI_API_KEY --api chat_completions `
  --domains simple --num-examples 5 --max-concurrent 4 `
  --export-json ..\ark_deepseek_v4_flash_simple5.json

# 4) 再 5 题（glm-5.3-flash），每条命令只换 model 与输出文件
uv run auto-bench --model glm-5.3-flash `
  --base-url https://ark.cn-beijing.volces.com/api/plan/v1 `
  --api-key-var OPENAI_API_KEY --api chat_completions `
  --domains simple --num-examples 5 --max-concurrent 4 `
  --export-json ..\ark_glm_5_3_flash_simple5.json
```

注意事项：
- Ark 的模型名如果需要 **endpoint ID**（`ep-...`），以控制台为准；401 是 key 问题，404/400 才是模型名问题。
- 想让成本进报告：用 `--input-cost/--output-cost`（每 token 美元），否则未知模型可能提示无法计价。
- `--tasks <task_name>` 可精确锁定题目；`--export-json` 便于跨模型对比。

## 5. 已解决：Ark 端点不是 `/api/v3`

- 用同一把 key 探测发现：`POST https://ark.cn-beijing.volces.com/api/v3/chat/completions` 返回 **401**，但 **`POST https://ark.cn-beijing.volces.com/api/plan/v1/chat/completions` 返回 200**。
- 即 ArK 的 OpenAI 兼容 base 是 **`https://ark.cn-beijing.volces.com/api/plan/v1`**（用户最初给的 `/api/plan` 是正确前缀）。
- 两个模型都验证可用：`deepseek-v4-flash`（支持 tool_calls）、`glm-5.3-flash`（推理型，注意给足 max_tokens）。

## 6. 真实 Ark 实测结果（2026-10-31）

| 模型 | simple 5 题 | 输入/输出 tokens | 工具调用 | 墙钟 | 错误 |
| :-- | :-- | :-- | --: | --: | --: |
| deepseek-v4-flash | **5/5 (100%)** | 754,874 / 35,387 | 90 | 489.6 s | 0 |
| glm-5.3-flash | **5/5 (100%)** | 352,978 / 11,422 | 77 | 322.6 s | 0 |

完整对比与分析见 [`report/ark-simple5-comparison.md`](ark-simple5-comparison.md)，原始 JSON 在 [`report/results/`](results/)。

## 7. 下一步

1. 换有区分度的域：`--domains sales --num-examples 20`（两模型各一轮）；
2. 补 Ark 单价（`--input-cost/--output-cost`）后写成本列；
3. 开始打包第一批离线包（ProgramBench 5 题 + DeepSWE 10 题）；Docker Desktop 已启动（daemon 29.9.2）。
