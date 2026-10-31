# Automation-Bench 首轮实测：deepseek-v4-flash vs glm-5.3-flash（simple 5 题）

> 日期：2026-10-31 ｜ 基准：AutomationBench v1.0.6 ｜ 域：`simple` ｜ 5 题单轮 ｜ 端点：火山方舟（Ark）
> 结论：两个模型都 **5/5 全对**；simple 是官方不计分的基线集，天花板效应明显，需要换更有区分度的域继续。

## 1. 测试条件

| 项 | 值 |
| :-- | :-- |
| 框架 | 官方 `auto-bench`（AutomationBench v1.0.6，Python 3.13.13，uv 环境） |
| API | `chat_completions`（OpenAI 兼容） |
| Base URL | **`https://ark.cn-beijing.volces.com/api/plan/v1`**（注意：不是 `/api/v3`） |
| 模型 | `deepseek-v4-flash`、`glm-5.3-flash` |
| 任务 | `simple` 域前 5 题（`--num-examples 5`） |
| 并发 | `--max-concurrent 2` |
| 采样 | 未指定（框架默认） |
| 单题上限 | 默认 50 步 |

## 2. 结果

| 指标 | deepseek-v4-flash | glm-5.3-flash |
| :-- | --: | --: |
| 通过率（100% only） | **5/5 = 100%** | **5/5 = 100%** |
| 平均部分分 | 1.000 | 1.000 |
| 输入 tokens | 754,874 | 352,978 |
| 输出 tokens | 35,387 | 11,422 |
| 缓存命中 tokens | 704,512（93.3%） | 344,000（97.5%） |
| 工具调用次数 | 90 | 77 |
| 模型耗时 | 595.9 s | 505.0 s |
| 工具耗时 | 1.8 s | 3.3 s |
| 墙钟总时长 | 489.6 s | 322.6 s |
| 错误 / 空回答 / 中止 | 0 / 0 / 0 | 0 / 0 / 0 |
| 成本 | N/A（未提供 Ark 单价） | N/A（未提供 Ark 单价） |

明细（两模型相同，均 1/1 断言通过）：`email_sf_contact_phone_update`、`email_sf_contact_email_update`、`email_sf_contact_title_update`、`email_sf_contact_city_update`、`email_sf_contact_account_update`。

原始结果（含轨迹与断言）：
- [`results/ark_deepseek_v4_flash_simple5.json`](results/ark_deepseek_v4_flash_simple5.json)
- [`results/ark_glm_5_3_flash_simple5.json`](results/ark_glm_5_3_flash_simple5.json)

## 3. 初步解读

1. **simple 是基线集，不参与官方分数**（README 明确：200 道 1–2 步基础任务，用于验证模型会不会用工具）。两者都满分说明「工具调用链」没问题，但无法区分能力高下。
2. **成本差异明显（按 token 量级）**：同样 5 题，deepseek 用了 2.1× 输入、3.1× 输出；glm 墙钟快 ~34%。若 Ark 计价相近，glm 这 5 题显著便宜。
3. **缓存命中率都很高**（93–97%），说明多步 agent 场景下缓存对成本影响很大，评估成本时要用「缓存命中价」而不是全价。
4. **无 reasoning tokens 字段**：Ark 这两个模型返回的是 `reasoning_content`，框架未计入 reasoning token 统计；跨模型比较时注意口径。
5. `glm-5.3-flash` 是推理型模型：用 `max_tokens=16` 测试时会因 reasoning 占满而返回空 content（`finish_reason=length`），实际评测要给足输出预算。

## 4. 口径提醒

- 这是**公开集的 simple 子集**，官方 AutomationBench 榜用的是**私有 held-out 集**且不含 simple；本地分数只能做同条件跨模型对比，不能与官方榜对齐。
- 单轮、单次、`--max-concurrent 2`，未做重复实验；差异 <1 题时不要下强结论。
- 成本未计入（Ark 未提供价格）；如需成本，用 `--input-cost/--output-cost`（每 token 美元）重跑，或让框架按 `tokens × 单价` 事后计算。

## 5. 下一步

1. **换有区分度的域**：`--domains sales --num-examples 20`（或 marketing/operations），同样两模型各跑一轮；
2. 记录 Ark 单价后补成本列（公式：输入 tokens×缓存/非缓存价 + 输出 tokens×输出价）；
3. 第一批离线包：ProgramBench 5 题 + DeepSWE 10 题（Docker Desktop 已启动，daemon 29.9.2 就绪）。
