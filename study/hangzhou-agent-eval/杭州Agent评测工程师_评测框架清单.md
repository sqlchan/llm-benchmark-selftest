# 评测框架清单：需要掌握哪些、优先级怎么排

> **依据**：`hangzhou_zhiweiyaoqiu.md` 中明确出现过的框架 + 2026-10-31 各项目官方文档现状核验。
> **一句话结论**：JD 里的"评测框架"其实分三层，别混着学 —— 执行层（跑分）优先占一个、平台层（Langfuse）必须动手、Agent 框架层会一个就够。
> **配套**：各 Benchmark 的评测目标、评分机制与局限，见同目录 `杭州Agent评测工程师_Benchmark全景清单.md`。

---

## 〇、先分清三层"框架"

| 层 | 是什么 | 对应 JD 提到的 | 掌握目标 |
|---|---|---|---|
| **1. 评测执行框架**（离线跑分） | 定义 benchmark 任务、批量推理、评分汇总 | OpenCompass、lm-evaluation-harness、HELM、FastEval | 至少**精通 1 个**：能新增自定义任务、改评分器、接多模型 |
| **2. 评测与观测平台**（平台/流水线） | trace 采集、在线评测、prompt 管理、数据集实验、看板 | Langfuse、Logfire、MLflow、OpenTelemetry | **至少会 1 个**（Langfuse 优先）：能接入、能搭 eval pipeline |
| **3. Agent 框架与协议**（被评测对象/环境） | 构造 Agent、工具调用、Harness | LangGraph、LangChain、AutoGen、OpenAI Agents SDK、MCP、OpenDevin | 各了解，**至少 1 个动手**；能针对其设计评测 |

> 面试官问"你熟悉哪些评测框架"，期待的是"能讲清评测链路和局限"，不是报菜名（JD 原话：理解评测目标、任务设计、数据构成、评分机制及局限性）。

---

## 一、评测执行框架（4 个，JD 明确点名）

| 框架 | 定位 | JD 出处 | 要求程度 | 重点学什么 | 2026-10 现状 |
|---|---|---|---|---|---|
| **OpenCompass**（上海 AI Lab） | 一站式评测平台：100+ 数据集、HF/LMDeploy/vLLM 后端、规则评测 + LLM-as-Judge、分布式调度、CompassRank 榜单；集成 VLMEvalKit 做多模态 | 行 1、8 | **优先**：使用或贡献经验 | 三件套抽象：config（模型/数据集）→ inferencer → evaluator；自定义数据集与 judge；CompassRank 对齐 | 活跃。2026-09 推出 **AgentCompass**（Agent 评测基础设施，解耦 model/benchmark/harness/environment，支持 Claude Code、Codex、OpenHands 等 10+ harness） |
| **lm-evaluation-harness**（EleutherAI） | 60+ 学术 benchmark 的统一执行框架，HF Open LLM Leaderboard 的后端；vLLM/SGLang/API 全支持 | 行 1、8、11 | **优先**：使用或贡献经验 | task YAML（dataset/prompt/metric 四段式）、`--log_samples`、插件机制、自定义 task | 活跃。2026-09 支持 entry-point 插件；2025-12 CLI 重构及轻量安装（后端按需装） |
| **HELM**（Stanford CRFM） | "Holistic" 多维评测：场景 × 指标 × 模型矩阵，含效率、偏见、毒性等非准确率指标；Web UI + leaderboard | 行 8、11 | 了解思想 | 多指标矩阵式评测方法论、可复现/透明评测设计、场景抽象（RunEntry 配置） | **2026-06-01 起进入维护模式**（官方标注）。可学方法论，别作为新项目底座 |
| **FastEval** | 轻量快速评测：vLLM 加速，覆盖 MT-Bench（GPT-4 judge）、HumanEval+、DS-1000、CoT(GSM8K/MATH/BBH/MMLU)，结果可 web 查看 | 行 1 | 了解即可 | "最小评测闭环"：模型 prompt 模板、批量推理、结果落盘、逐样本对比看板 | 作者明确声明：**不再加新功能，主要修 bug**。学习价值 > 长期技术栈价值 |

### 只学一个的话选谁？

- **想要最低门槛积累开源贡献** → `lm-evaluation-harness`：代码结构清晰，加一个 task / metric 的 PR 门槛低，生态引用广。
- **目标国内大厂 / 杭州上海岗位** → `OpenCompass`：中文数据集全、榜单影响力大、现在又出了 AgentCompass，和这批 JD 的 Agent 评测方向直接对口。
- **HELM / FastEval** → 只需能讲清"它的设计思路与被取代的原因"，不必深投。

---

## 二、评测与观测平台（4 个，别和"跑分框架"混为一谈）

| 平台 | 定位 | JD 出处 | 要求 | 重点学什么 |
|---|---|---|---|---|
| **Langfuse** | 开源 AI 工程平台：Tracing + Prompt 管理 + Evaluation（LLM-as-judge / code evaluator / 人工标注 / Dataset + Experiment），基于 OpenTelemetry 可自托管 | 行 14（明确"会使用） | **必须动手** | 自托管部署；Python SDK 接一条 Agent trace；建 dataset 跑 experiment；配 LLM-as-judge；看 trace 定位延迟/工具异常 |
| **Logfire**（Pydantic） | OpenTelemetry 观测平台：traces/logs/metrics + LLM/Agent 观测，配套开源 **Pydantic Evals** 做评测 | 行 14（全链路观测与故障溯源） | 会接入 | OTel 数据模型、span 层级、LLM 调用/工具调用 instrumentation；与 Pydantic AI 配合的观测闭环 |
| **MLflow** | 3.x GenAI 能力："Evaluation-Driven Development"：datasets + scorers/judges + tracing + 回归测试 + CI/CD | 行 18（技术选型） | 了解 + 能跑通 | `mlflow.genai.evaluate`、scorer 体系、dataset 管理、与 CI 集成 |
| **OpenTelemetry** | 可观测性标准（不是评测框架） | 行 18（技术选型） | **建议掌握概念** | trace/span/attribute 模型、语义约定；Langfuse/Logfire/MLflow 都建立在它之上，会它 = 通吃 |

> 这一层对应 JD 里的"评测工程与工具平台 / 可观测性 / 全链路故障溯源"，是**区分"会跑分"和"会建评测体系"**的关键，行 14 更是直接把它写成岗位要求。

---

## 三、Agent 框架与协议（不是评测框架，但必须懂）

| 框架/协议 | 作用 | JD 出处 |
|---|---|---|
| **MCP** | 工具/上下文协议，Agent 工具接入的事实标准 | 行 5、12、16 |
| **LangGraph** | 图式 Agent 编排、状态管理 | 行 5 |
| **LangChain** | 链路编排 | 行 5、18 |
| **AutoGen** | 多智能体协作 | 行 5、18 |
| **OpenAI Agents SDK** | 官方 Agent 框架 | 行 5 |
| **OpenDevin / OpenHands** | 代码/终端类 Agent 与执行环境 | 行 18（OpenDevin）；也是 AgentCompass 支持的 harness |
| **AgentCompass**（新） | Agent 评测基础设施：解耦 model / benchmark / harness / environment | 不在原文，但属 OpenCompass 生态，和这批 JD 的 Agent 评测方向高度相关 |

**目的不是造 Agent，而是**：能针对这些框架设计评测场景、看懂 trace、定位"是模型、工具、环境还是编排的问题"。

---

## 四、优先级总表

| 优先级 | 框架 | 理由 | 掌握标准（可验证） |
|---|---|---|---|
| **P0** | lm-evaluation-harness **或** OpenCompass | JD 出现频率最高、"开源评测框架使用或贡献经验"是加分项 | 跑通 + 新增 1 个自定义任务 + 改过 1 个评分逻辑 |
| **P0** | Langfuse | 行 14 明确要求；平台能力的抓手 | 自托管 + Agent trace 接入 + dataset experiment |
| **P1** | OpenTelemetry | Langfuse/Logfire/MLflow 共同底座 | 能解释 trace/span 结构并手工埋点 |
| **P1** | MCP + 任一 Agent 框架（LangGraph/AutoGen） | JD 行 5/12/16 明确 | 写过 1 个带工具调用的最小 Agent 并评测它 |
| **P2** | HELM、MLflow、Logfire、FastEval | 方法论 / 企业选型 / 特定岗位 | 能讲清定位与局限，能跑通 demo |
| **加分** | 给 lm-eval 或 OpenCompass 提 PR | 直接命中"开源贡献"加分项 | 一个被合并的 task/metric PR |

---

## 五、两周动手路线（每步都有可写进简历的产出）

1. **Day 1–2｜lm-evaluation-harness**：装 `lm_eval[hf,vllm,api]`，跑通 2 个任务；仿照 `lm_eval/tasks/` 新增一个自定义 task（YAML + prompt + metric），用 `--log_samples` 导出逐样本结果。
2. **Day 3–5｜OpenCompass**：跑通一个 API 模型评测；接一个中文数据集；配置 `GenericLLMEvaluator` 做 LLM-as-judge；记录与 lm-eval 在同一任务上的分数差异（这本身就是很好的面试素材）。
3. **Day 6–8｜Langfuse**：docker 自托管；用 SDK 接入一个最小 Agent；建 dataset 跑 experiment；配 judge 评测；对比两次 prompt 版本的指标。
4. **Day 9–10｜OpenTelemetry/Logfire**：给同一 Agent 加 OTel 埋点，观察 trace 里工具调用的耗时与失败 span。
5. **Day 11–14｜沉淀**：写一篇《3 个评测框架在同一任务上的对比报告》（指标口径、prompt 模板差异、judge 稳定性），或给上游提一个 PR。**产出 > 学习记录**。

---

## 六、面试怎么讲（避免只报菜名）

一个高分回答的结构（约 90 秒）：

1. **分层**：我把它分成执行框架、平台、Agent 框架三层。
2. **选型理由**：离线跑通用 lm-eval/OpenCompass，因为 X；线上效果监控与回归用 Langfuse，因为 trace 和 dataset experiment 打通。
3. **一条链路**：模型接入 → 任务配置 → 批量推理 → 评分（规则/Judge/人工）→ 结果分析 → 回归。
4. **局限与改进**：比如 HELM 维护模式、FastEval 停更，所以只借鉴思想；Judge 有偏差，所以要用规则 + 人工抽检校准。
5. **我改过什么**：自定义 task / 修 prompt 模板 / 加评分器 / 提 PR。

---

## 七、公开框架推荐（开源可自托管，按目标选）

> 原则：**先跑通一条链路，再扩框架**。不要一上来装 5 个框架、跑 20 个 benchmark。

### 7.1 主推 4 个（这批 JD 性价比最高）

| 框架 | 为什么推荐 | 第一个练习 |
|---|---|---|
| **[lm-evaluation-harness](https://github.com/EleutherAI/lm-evaluation-harness)** | 生态最广、代码最易读、"加一个 task"就是 PR 门槛最低的开源贡献；HF Open LLM Leaderboard 的后端 | 装 `lm_eval[hf]`，跑 GSM8K + 仿照 docs/new_task_guide 加一个自定义 task |
| **[OpenCompass](https://github.com/open-compass/opencompass) + [AgentCompass](https://github.com/open-compass/AgentCompass)** | 国内岗位认可度高（CompassRank）、中文数据集全；AgentCompass（2026-09）专做 Agent 评测基础设施，解耦 model/benchmark/harness/environment | 用 API 跑一个模型 + 接一个中文数据集；再跑 AgentCompass 的一个 harness |
| **[Langfuse](https://github.com/langfuse/langfuse)** | JD 行 14 明确要求；自托管后一次覆盖 trace → dataset → judge → experiment → 看板，是"平台能力"最好的证据 | docker 自托管 + SDK 接一条 Agent trace + 用 dataset 跑一次 experiment |
| **[SWE-bench harness](https://github.com/SWE-bench/SWE-bench) / [Terminal-Bench（Harbor）](https://github.com/harbor-framework/terminal-bench)** | Coding/终端类 Agent 评测的事实标准，能理解"测试驱动判分"的完整链路 | 本地跑通 1 个任务的 F2P/P2P 判分，记录环境复现的坑 |

### 7.2 值得了解（按场景取用）

| 框架 | 什么时候用 |
|---|---|
| [Inspect](https://github.com/UKGovernmentBEIS/inspect_ai)（英国 AISI） | 要做带**沙箱隔离**的 Agent 评测、安全评测；文档质量高 |
| [LightEval](https://github.com/huggingface/lighteval)（HuggingFace） | 想要比 lm-eval 更轻、更快接 HF 生态 |
| [lmms-eval](https://github.com/EvolvingLMMs-Lab/lmms-eval) | 多模态评测（lm-eval 生态分支） |
| [DeepEval](https://github.com/confident-ai/deepeval) / [Ragas](https://github.com/explodinggradients/ragas) | 应用层指标：RAG 忠实度/召回、对话质量、pytest 风格单测 |
| [promptfoo](https://github.com/promptfoo/promptfoo) | Prompt 版本对比 + 红队/越狱测试，轻量好上手 |
| [MLflow](https://github.com/mlflow/mlflow) / [Arize Phoenix](https://github.com/Arize-ai/phoenix) | 目标公司已在用（JD 行 18 点名 MLflow）；Phoenix 开源可自托管 |
| [Pydantic Evals](https://pydantic.dev/docs/ai/evals/evals/) + Logfire | 用 Pydantic AI 栈的团队；与 Logfire 观测天然打通 |
| [Argilla](https://github.com/argilla-io/argilla) / [distilabel](https://github.com/argilla-io/distilabel) | 评测数据标注 / 合成数据（对应 JD 的"数据构建"） |
| [garak](https://github.com/NVIDIA/garak) / [PyRIT](https://github.com/Azure/PyRIT) | 红队与安全评测进阶 |

### 7.3 三套组合（直接抄）

- **入门 / 转岗（约 2 周）**：lm-evaluation-harness + Langfuse + promptfoo
- **求职冲刺（约 1 个月）**：上一套 + OpenCompass/AgentCompass + SWE-bench harness（或 Terminal-Bench）
- **平台 / 研究向（长期）**：上一套 + Inspect + lmms-eval + MLflow/Phoenix + Argilla/distilabel

### 7.4 避坑清单

- **HELM 已进维护模式（2026-06）、FastEval 已停止加新功能**：学思想可以，别当技术栈。
- **OpenCompass 别一上来装 `[full]`**：依赖容易打架，先用 `[api]` 或轻量安装跑通。
- **商业闭源平台**（如 LangSmith、Braintrust）：公司用可以学，自己练优先开源可自托管。
- **开源 ≠ 可随意商用**：动手前看一眼仓库 LICENSE。
- **别刷榜**：跑透 1 个任务的完整链路（数据 → prompt → 判分 → 归因），比跑 20 个 benchmark 更有说服力。
- **注意污染与 canary**：很多 benchmark 带 canary 字符串，严禁进训练数据；自建评测集时同样要设计防污染机制。

### 7.5 第一个 PR 从哪提

| 框架 | 低门槛切入点 |
|---|---|
| lm-evaluation-harness | 修 prompt 模板/指标实现的 bug、新增 task YAML（按 `docs/new_task_guide.md`）；先跑 `pytest` |
| OpenCompass | 新增数据集/模型配置、修 evaluator 与 judge prompt（有 contribution guide） |
| AgentCompass | 新项目，benchmark / harness 适配缺口多，介入机会大 |

---

## 八、信息来源（2026-10-31 核验）

- [OpenCompass README（含 AgentCompass 发布说明）](https://github.com/open-compass/opencompass)
- [lm-evaluation-harness README](https://github.com/EleutherAI/lm-evaluation-harness)
- [HELM 文档（首页标注 2026-06-01 进入维护模式）](https://crfm-helm.readthedocs.io/en/latest/)
- [FastEval README（项目状态：不再加新功能）](https://github.com/mayflower/FastEval)
- [Langfuse Docs（Observability / Evaluation）](https://langfuse.com/docs)
- [Pydantic Evals 发布说明（Logfire 生态的开源评测框架）](https://pydantic.dev/articles/q1-2025-summary)
- [MLflow LLM & Agent Evaluation 文档](https://mlflow.org/docs/latest/genai/eval-monitor/)

> 延伸（非这些 JD 的硬要求，但业内常见）：DeepEval、Ragas（RAG 评测）、promptfoo（prompt/红队测试）、LightEval（HuggingFace）、Inspect（英国 AI 安全研究院）、OpenAI Evals。建议先把 P0 学完再扩展。
