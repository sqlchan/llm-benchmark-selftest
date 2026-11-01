# 杭州 Agent / LLM 评测工程师岗位：技能与要求全景整理

> **输入**：`hangzhou_zhiweiyaoqiu.md` —— 21 段岗位描述片段，约 15+ 个岗位（部分为同一岗位的不同版本或碎片，行 11 与行 13 高度重合）。原文混入了招聘平台水印字符（"kanzhun""BOSS直聘""来自BOSS直聘"等），已按语义还原。
> **目的**：回答两个问题 —— ① 需要掌握什么技能？② 有哪些硬性要求和加分项？
> **快速导航**：只看结论 → 第一节；看硬性门槛 → 第四节；看高频技能排行 → 第五节；准备面试/补短板 → 第三、六、七节。

---

## 一、一句话结论：这批岗位在找什么人

**"懂评测方法论 + 懂 Agent 原理 + 能自己写工程把评测跑起来 + 能从失败结果里归因"的复合型评测工程师。**

三条主线几乎贯穿所有 JD：

1. **评测体系设计** —— 把业务需求拆成可验证的「能力维度 → 任务类型 → 数据分布 → 评测指标 → 验收标准」，并定义评分方法与标准（Rubric / Grader / Judge / 规则）。
2. **评测工程化** —— 评测数据、自动化流水线、评测平台、可视化看板、可观测性、可复现实验，而不是靠人工跑脚本。
3. **结果归因与闭环** —— badcase / Failure Taxonomy / 轨迹归因，区分"是模型能力问题，还是数据、Prompt、Judge、环境、工具链的问题"，并推动迭代。

**一个明确信号**：几乎所有 JD 都要求"独立开发评测工具/流水线/平台"，纯"跑跑 benchmark、写写评测报告"的定位已经不够了。

从内容看，杭州这批需求集中在：**金融科技 Agent**（信贷、理财、票据、合规、风控）、**办公 Agent**（JD 中提到"千问办公"）、**Coding Agent / 代码智能**、**企业级 Agent 平台 / Harness** 几个方向。

---

## 二、岗位形态：5 类画像

| # | 岗位类型 | 核心职责 | 典型关键词 | 对应原文 |
|---|---|---|---|---|
| 1 | **大模型能力评测 / Benchmark 建设**（通用向） | 多维评测、评测标准与流程、评测平台开发、跟踪业界评测体系 | MMLU、C-Eval、MT-Bench、Arena、多模态、评测报告、badcase | 行 1、6、8、18、19、20 |
| 2 | **Agentic 评测与轨迹归因**（场景向，金融/办公/企业） | 全流程 Agent 评测（功能/性能/效果/稳定性）、轨迹分析、失败归因、Rubric/Checkpoint 沉淀 | ReAct、Planning、Tool Calling、Trajectory、SWE-bench、GAIA、Terminal-Bench | 行 4、9、11、13、15、21 |
| 3 | **Coding & Agent 评测体系 0→1**（代码智能向） | 从零设计 benchmark、能力维度拆解、难度分级、数据集构造、评分标准、抗污染 | SWE-bench、LiveCodeBench、BigCodeBench、WebArena、OSWorld、区分度、生态效度 | 行 12、17 |
| 4 | **Agent 测试开发 / 质量保障**（QA 向） | 测试用例自动生成、研发工具链集成、效果与稳定性评测、缺陷归因闭环 | LangGraph、MCP、Playwright、CI/CD、Langfuse、Logfire、Red Teaming | 行 5、10、14 |
| 5 | **Agent Harness / 评测平台工程**（基础设施向） | Harness 架构、Runtime、工具调用与沙箱、可观测性、会话/事件回放、以评测驱动工程迭代 | Agent Harness、MCP/Plugin/Skill、沙箱执行、Trace、OpenTelemetry | 行 7、16、18 |

> 现实中很多 JD 是**混合型**：既要做评测设计，又要写平台，还要做归因。类型 4、5 严格说是"评测相邻岗"，但对理解 Agent 底层机制非常有价值，也是差异化优势来源。

---

## 三、能力地图：9 大模块（含要求程度）

### A. 评测方法论与评分体系 ★★★★★（最核心）
| 要掌握什么 | 具体要求 | 原文依据 |
|---|---|---|
| 评测体系设计 | 把业务需求拆解为能力维度、任务类型、数据分布、评测指标、验收标准；制定评测标准与流程 | 行 9、12、15 |
| 自动化评分方法 | **Rule-based Evaluator、LLM-as-a-Judge、Rubric、Grader、Verifier、多 LLM 投票打分、few-shot 评测**；能分析各方法优缺点 | 行 9、11、19、21 |
| 人工 × 自动结合 | Human Evaluation、人工评审、标注一致性、裁判偏差处理 | 行 9、17、19 |
| 评测范式 | MT-Bench、**Arena 对战/pairwise**、Rubrics 评测、多 LLM 投票 | 行 1、6、11 |
| 评测可靠性 | 评分一致性、方差、抗刷分、**Judge Bias、数据泄漏、Prompt Hacking**、可靠性/鲁棒性验证 | 行 9、12、17、21 |
| 前沿范式 | RLHF/DPO 对齐数据驱动的新评估范式、后训练阶段评测、仿真环境、Agent 链路评测、动态评测集 | 行 3、11、12、21 |

### B. Benchmark 与评测集谱系 ★★★★★（必须能讲清"评测目标 / 任务设计 / 数据构成 / 评分机制 / 局限性"）
| 类别 | 必须认识的 Benchmark | 常考背景 |
|---|---|---|
| 通用知识与推理 | **MMLU、C-Eval、CMMLU、AGIEval、HLE** | 知识覆盖、中文能力、高难推理；理解榜单刷分与饱和问题 |
| 对话 / 主观质量 | **MT-Bench、Arena（LMArena）** | 多轮对话、对战 Elo、LLM-as-a-Judge 来源 |
| 代码 / 工程 | **HumanEval、SWE-bench、LiveCodeBench、BigCodeBench、Terminal-Bench** | 函数级解题 → 仓库级修复 → 终端操作，"解题"到"工程实践" |
| Agent / 工具 / 环境 | **AgentBench、ToolBench、WebArena、OSWorld、GAIA、AgentEval** | 工具调用、网页/系统操作、长程任务、环境交互 |
| 多模态 | **MMMU** | 图文理解评测 |
| 评测框架 | **OpenCompass、lm-eval-harness（LM Evaluation Harness）、HELM、FastEval** | 会使用，最好有贡献；理解框架抽象与适配方式 |

> 关键要求不是"背名字"，而是：**能说明每个 benchmark 的评测目标、任务设计、数据构成、评分机制及局限性**（行 9 原话），并能**本地化落地**（行 11：SWE-Bench、Terminal-Bench、GAIA 本地化落地）。

### C. Agent 架构与 Agentic 能力 ★★★★★（第二大核心）
1. **基础范式**：ReAct、Plan-and-Execute、Tool-use、Workflow、Multi-Agent（行 4、5、12）
2. **核心模块**：任务规划/编排、状态管理、工具调用、Memory、RAG、Sub-agent 委托、上下文管理、Agent Harness（行 5、7、10、16）
3. **执行轨迹五段**：Planning → Tool Calling → Environment Interaction → Execution → Final Answer（行 9 原话）
4. **评测维度**：任务完成率、步骤效率、工具调用准确率、推理链质量、响应准确性、稳定性/可靠性、长程任务（行 4、15、11）
5. **框架与协议**：**MCP**、LangGraph、LangChain、AutoGen、OpenAI Agents SDK、Browser/Computer Use（行 5、12、16）
6. **失败模式（必须能分类）**：循环调用、工具幻觉、规划偏差、检索供给错误、工具故障、Judge 误判、金融口径差异、意图澄清/拒答问题 → 能抽象成 **Failure Taxonomy**（行 4、11、13）
7. **环境与沙箱工程**：Mock API、沙箱文件系统、模拟数据库、环境沙箱搭建、代码执行环境、会话回放/事件重放（行 4、16、17）

### D. 数据构建与资产治理 ★★★★
- **多场景数据集**：通用问答、代码生成、多模态理解、RAG 检索增强、Agent 智能体（行 19）
- **构建全流程**：采集 → 清洗 → 标注 → 合成 → 难度分层 → 样本筛选 → 质量校验（行 3、9）
- **去重、降噪、分层**，样本分层策略（行 19）
- **污染检测与查重**、难度标定与校准、标注规范与一致性审核（行 12）
- **数据规范/质检规则/验证流程**，保证准确性、可追溯性、可复现性（行 9）
- **版本管理、持续维护**；从真实研发任务、产品反馈、失败案例反建评测集（行 3、17）
- **Golden Dataset / 标准测试集 / badcase 库 / 线上 case 采集录制**（行 14、21）

### E. 评测工程与平台 ★★★★★（区分"想法"和"落地"）
1. **工具开发**：数据处理、模型批量调用、评测执行、自动评分、结果分析、可视化（行 9）
2. **可复现 Pipeline**：多模型 / 多任务 / 多版本批量实验、结果对比；**执行隔离、配置记录、运行证据、失败分类、结果报告**（行 9、17、21）
3. **平台化**：评测任务适配、调度、规模化分析；Leaderboard / 内部评测服务 / 可视化指标看板（行 1、3、12、19）
4. **可观测性**：Langfuse、Logfire、OpenTelemetry、MLflow、日志与 Trace、调试面板、会话回放（行 14、16、18）
5. **研发链路集成**：Git、CI/CD、接口测试平台、自动化测试框架、缺陷管理；Docker、Kubernetes、Jenkins、GitLab CI；Selenium、Playwright、Appium（行 5）
6. **后端与数据**：评测相关后端服务、数据管道、API，把内部数据转成结构化格式（行 21）

### F. 编程与软件工程 ★★★★★（硬门槛）
- **Python 熟练**：数据处理、模型 API 调用、自动化脚本开发，能**独立完成评测实验和工具开发**（行 9、12）
- 统计分析与可视化能力（行 12）
- 了解主流 **LLM 推理服务的调用方式与工程约束**（行 12）
- **中大型项目开发经验**，能从一线开发者视角审视代码能力评测（行 12）
- 能通过代码、测试和执行记录定位问题（行 17）；系统设计追求可复现、可调试、可扩展（行 16）

### G. 统计与实验设计 ★★★★
- **指标**：Accuracy / Recall / F1-score / BLEU / ROUGE、pass@k、任务完成率、步骤效率、工具调用准确率（行 11、4）
- **方法**：A/B 实验、配对实验、对照实验、重复运行、分层分析、**置信区间、噪声基线、统计推断、统计显著性**（行 11、17、21）
- **判断力**：区分真实能力提升 / 随机波动 / 数据泄漏 / 样本偏差 / 评测漏洞（行 9 原话）
- 效果与成本的取舍（行 17）；方差、评分一致性（行 21）

### H. LLM 基础、训练与对齐 ★★★
- LLM 与 Agent 的技术原理与工程实现；模型对比、竞品评测（行 7、19）
- **RLHF / DPO / 对齐、后训练阶段**的基本认知（行 3、11、12）
- 能把评测信号反馈到数据集、Prompt、评分器、Agent 架构和训练策略（行 21、12 加分项）

### I. 业务抽象与软技能 ★★★★
- **业务 → 可验证维度**：把业务专家的分析逻辑、服务规范、合规规则沉淀为可泛化、可规模化的 Rubric/Checkpoint（行 13）
- **领域场景**：金融（信贷、理财、票据、风控、合规）、财税、办公、医疗、小程序/APP（行 10、11、13、20）
- **技术写作**：高质量评测报告与技术文档、评测设计思路讲清楚（行 12）
- **跨团队协作**：与模型训练/算法团队、工程团队、业务专家协同，推动问题闭环（行 12、9）
- **0→1 交付与收敛**：有限资源下收敛范围、与现有平台协作、形成真实产品采用（行 17）

### J. 软件测试与自动化测试框架（"Agent 测试开发"类岗位要求，评测岗可作加分）

| 测试层次 | 公认开源框架 | 说明 |
|---|---|---|
| 单元测试 | **pytest**（Python 事实标准，插件生态最大）、JUnit 5（Java）、Jest / Vitest（JS/TS） | 评测岗最常用 pytest 把"评测用例"写成单测 |
| Web E2E / UI | **Playwright**（微软，新项目首选，trace/自动等待）、**Selenium**（W3C WebDriver 标准，存量最大）、Cypress（前端调试体验好） | JD 行 5 点名 Selenium / Playwright |
| 移动端 | **Appium**（WebDriver 协议，iOS/Android） | JD 行 5 点名 |
| API / 接口 | REST Assured（Java）、Karate、Tavern（pytest 风格）、Schemathesis（OpenAPI 属性测试）、Newman（Postman 开源 CLI；客户端闭源） | 对应 JD 的"接口测试平台" |
| 性能 / 压测 | JMeter（Apache）、Locust（Python）、k6（JS，CI 友好）、Gatling | 对应 JD 的"性能压测" |
| 契约 / 属性测试 | Pact、Hypothesis、Schemathesis | 加分项 |
| Mock / 环境隔离 | WireMock、MockServer、Testcontainers（容器化集成测试） | 对应 Agent 评测的 Mock API / 沙箱 |
| 报告 / 看板 | Allure、ReportPortal | 对应"测试结果评估体系" |
| CI 集成 | Jenkins、GitLab CI、GitHub Actions（CI 工具，非测试框架） | JD 行 5 点名 Jenkins / GitLab CI |
| 混沌 / 故障注入 | Chaos Mesh、Toxiproxy | 稳定性测试加分 |

> 要求程度：pytest + Playwright/Selenium + Docker/CI 是"Agent 测试开发"岗的硬要求；其余按需。真正做效果评测时更常用 pytest + DeepEval/promptfoo + Langfuse（见《评测框架清单》七）。

---

## 四、硬性要求 vs 加分项

### 4.1 硬性门槛（"必须" / 各家共识）
1. **统招本科及以上**，计算机、人工智能、软件工程、数学、统计等相关专业优先（优秀候选人专业不限）—— 行 9 明确列为"必须"。
2. **Python + 数据处理 + 模型 API 调用 + 自动化脚本**，能独立完成评测实验和工具开发（行 9，多处重复出现）。
3. **真实的大模型评测 / Benchmark / 数据构建 / 模型训练或模型分析经验**，并能完整讲清一个项目：**任务设计 → 数据构建 → 评测执行 → 结果分析 → 迭代优化**（行 9 原话，面试大概率照此追问）。
4. **理解 LLM-as-a-Judge、Rubric、Grader、Verifier、Rule-based Evaluation、Human Evaluation** 等评测方法及其优缺点（行 9）。
5. **对 Agentic Evaluation 有较深理解**：任务规划、工具调用、环境交互、执行轨迹及最终结果评估（行 9）。
6. **基本实验设计与统计分析能力**，能区分真实能力提升、随机波动、数据泄漏、样本偏差及评测漏洞（行 9）。
7. **较强的问题拆解和归因能力**，能从失败案例中抽象出能力维度、Failure Mode 和优化方向（行 9）。
8. **熟悉 Agent 架构**（ReAct、Plan-and-Execute、Tool-use、Memory、RAG、Workflow、Harness 等）（行 4、5、7、10、12）。
9. **熟悉主流 Benchmark 与评测框架**（行 6、9、12、18）。
10. **技术写作与沟通能力**（行 12）。

> 注：全文**没有出现经验年限要求**（如"3 年以上"），学历是显性门槛，其余全看项目经验与工程能力 —— 对转岗/年轻候选人相对友好，但"能拿出一个完整评测项目"是硬通货。

### 4.2 加分项（原文明确写"优先 / 加分 / 者优先"）
- **主导或核心参与过业界知名开源评测项目 / Benchmark 建设**（行 3）；开源评测框架使用或贡献经验：**FastEval、OpenCompass、lm-eval-harness、HELM**（行 1、8、11）
- **Rubrics 评测、Arena 对战评测**等评测方法的实践经验（行 6）
- 代码智能 / Agent 评测领域**学术发表或开源项目贡献**（如参与 SWE-bench、BigCodeBench 建设）（行 12）
- **评测数据污染检测、动态评测集构建**的研究或工程经验（行 12）
- **竞赛编程 / 开源社区深度参与**，对代码能力分层评估有直觉（行 12）
- **评测能力产品化**经验：评测平台、Leaderboard、内部评测服务（行 12）
- **对模型训练流程有基本了解**，能把评测信号与训练策略对齐（行 12）
- 多模态评测经验（行 9、19）；**Red Teaming / 对抗性测试**经验（行 14）
- 金融 / 财税 / 办公等**垂直领域经验**（行 10、11、13、20）
- 熟悉 C-Eval、CMMLU、HumanEval、AGIEval（行 11、19）

### 4.3 隐含要求（JD 未明说，但面试会筛）
- 对"什么是好的代码能力 / 什么是好的 Agent 能力"有**独立判断力**，能转化成可量化维度（行 12）
- 能**独立负责 0→1**，而不是只执行指令
- 有**竞品 / 行业评测视野**，能对评测方向演进给出专业判断
- 能把"不稳定、不透明、难复现"的模糊问题，变成可诊断的工程问题（行 16 的表述很有代表性）

---

## 五、高频要求排行（按 21 段原文覆盖度统计）

> 口径：统计 21 段中命中该主题的段落数；行 11 与行 13 为同一岗位两版，含重复计数，实际去重后略低。

| 排名 | 能力主题 | 覆盖段落 | 热度 |
|---|---|---|---|
| 1 | Agent 架构与 Agentic 评测（ReAct / 规划 / 工具调用 / Memory / Harness / 多智能体） | 13 | ██████████ |
| 2 | 评测指标、评测体系与标准设计（能力维度、评分标准） | 12 | ██████████ |
| 3 | 效果 / 稳定性 / 鲁棒性等量化指标与能力画像 | 12 | ██████████ |
| 4 | 失败分析、badcase 归因、缺陷定位 | 11 | █████████▌ |
| 5 | 评测平台 / 自动化流水线 / 工具 / 看板 | 11 | █████████▌ |
| 6 | Benchmark 谱系与评测集认知 | 10 | █████████ |
| 7 | Python / 数据处理 / API 调用 / 工程实现 | 10 | █████████ |
| 8 | Coding 能力与代码评测（SWE / 仓库级 / 调试） | 9 | ████████▌ |
| 9 | 数据构建与治理（清洗 / 标注 / 合成 / 去重 / 污染） | 8 | ████████ |
| 10 | 统计与实验设计（A/B、配对、置信区间、显著性） | 8 | ████████ |
| 11 | 安全与对抗（Red Teaming、Prompt 注入、抗刷分） | 8 | ████████ |
| 12 | 技术写作、沟通协作、0→1 闭环 | 8 | ████████ |
| 13 | 评测方法论（Judge / Rubric / Grader / Verifier） | 7 | ███████ |
| 14 | 成本 / 性能 / 延迟 / 压测 | 7 | ███████ |
| 15 | 领域业务（金融、财税、办公、医疗） | 6 | ██████ |
| 16 | 模型训练与对齐（RLHF / DPO / 后训练） | 5 | █████ |
| 17 | 模拟环境 / 沙箱 / Mock API | 5 | █████ |
| 18 | MCP 与 Agent 框架 / 协议 | 5 | █████ |
| 19 | 可观测性与 DevOps（Langfuse / Logfire / OTel / K8s） | 4 | ████ |
| 20 | 轨迹分析 / Trajectory 归因 | 4 | ████ |
| 21 | 开源评测框架（OpenCompass / lm-eval-harness / HELM） | 4 | ████ |
| 22 | 数据泄漏 / 污染 / 抗刷分（单独强调） | 4 | ████ |
| 23 | 开源贡献 / 学术发表 / 评测产品化 | 4 | ████ |
| 24 | 多模态评测 | 2 | ██ |

---

## 六、能力自评清单（可直接对照打勾）

> 用法：每项给自己 0 = 不了解 / 1 = 能讲清 / 2 = 有项目实践。**目标：核心项（标 ★）至少到 2。**

### 评测方法论
- [ ] ★ 能完整设计一套评测方案：能力维度 → 任务类型 → 数据分布 → 指标 → 验收标准
- [ ] ★ 能解释 LLM-as-a-Judge 的原理、偏差来源与缓解手段（位置偏差、长度偏差、自我偏好、风格偏好）
- [ ] ★ 能设计 Rubric 并保证评分一致性；知道何时用规则 / 模型裁判 / 人工
- [ ] ★ 能说明如何验证"评测方法本身"的可靠性（一致性、方差、抗刷分）
- [ ] 了解 Arena / pairwise 对战评测与 MT-Bench
- [ ] 了解 RLHF / DPO 与后训练阶段评测的目标

### Benchmark
- [ ] ★ 能对 SWE-bench、GAIA、WebArena、AgentBench、Terminal-Bench 讲清任务形式、评分机制与局限
- [ ] ★ 能对 MMLU / C-Eval / HumanEval / HLE 讲清其饱和、污染、刷分问题
- [ ] 有 OpenCompass 或 lm-eval-harness 实际跑过、改过评测任务的经历
- [ ] 有过一次 benchmark 本地化落地经验

### Agent
- [ ] ★ 能画出 ReAct / Plan-and-Execute 的执行流程，并说明各自的失败模式
- [ ] ★ 能分析一条 Agent 轨迹：Planning、Tool Calling、Environment Interaction、Execution、Final Answer 各环节的问题
- [ ] ★ 能给出 Failure Taxonomy（循环调用、工具幻觉、规划偏差等）并做归因
- [ ] 了解 MCP、LangGraph、AutoGen 等框架/协议
- [ ] 搭过 Mock API / 沙箱环境 / 模拟数据库
- [ ] 了解 Harness、上下文管理、会话与事件流、Sub-agent 委托、记忆机制

### 工程
- [ ] ★ Python：能写批量模型调用 + 自动评分 + 结果分析 + 可视化的完整脚本
- [ ] ★ 能设计可复现的评测 Pipeline（多模型 / 多任务 / 多版本、配置记录、执行隔离）
- [ ] 能搭一个评测平台或 Leaderboard（哪怕小规模）
- [ ] 会 Langfuse / Logfire / OpenTelemetry / MLflow 中至少一个
- [ ] 熟悉 Git、CI/CD、Docker、K8s
- [ ] 能写后端服务 / 数据管道 / API（评测结果服务化）

### 数据与统计
- [ ] ★ 做过评测数据构建：采集、清洗、标注、去重、难度分层、质检
- [ ] ★ 能做污染检测 / 查重 / 难度标定
- [ ] ★ 能独立设计 A/B 或配对实验，并用置信区间、噪声基线判断版本变化是否真实
- [ ] 能区分统计误差与模型真实缺陷
- [ ] 能做数据分布分析与无效样本发现

### 领域与软技能
- [ ] 有金融 / 办公 / 财税等垂直场景经验（至少能讲清一个业务口径）
- [ ] 写过结构化评测报告（结论 + 数据 + 归因 + 建议）
- [ ] 推动过一次"评测 → 优化 → 复测"的闭环
- [ ] 有 0→1 项目交付经历

---

## 七、准备路径建议

### 7.1 优先级
| 优先级 | 补什么 | 原因 |
|---|---|---|
| **P0（不补直接挂）** | Python 工程能力、一个完整的评测项目、核心方法论能讲透、Agent 基础架构 | 行 9 的"必须"项 + 几乎所有 JD 的共同要求 |
| **P1（拉开差距）** | Judge 工程化、统计分析、轨迹归因 / Failure Taxonomy、开源评测框架实操 | 决定你是"会跑分"还是"会评测" |
| **P2（决定上限）** | 0→1 Benchmark 设计、评测平台 / 可观测性、垂直领域知识、Red Teaming | 对应高薪 / 资深岗与加分项 |

### 7.2 三个能撑起简历的项目
1. **0→1 Agent 评测集（最推荐）**：选一个真实场景（如"办公 Agent 的工具调用"或"代码修复"），完成能力维度拆解 → 任务设计 → 数据构建（含污染检测、难度分层）→ Rubric/Verifier → 自动评测流水线 → 结果报告与迭代。直接对标行 12 的"从 0 到 1 打造高区分度评测集"。
2. **评测平台 / Leaderboard**：支持多模型、多任务、多版本批量评测，自动评分 + 置信区间 + 可视化看板 + 失败案例库。对标行 9、21、1。
3. **Agent 轨迹归因报告**：采集 30~50 个失败样本，做 Failure Taxonomy，区分模型 / 数据 / Prompt / Judge / 环境 / 工具归因，并给优化建议与复测结果。对标行 11、17、20。

> 额外加分：给 OpenCompass / lm-eval-harness 提一个评测任务或指标的 PR（行 1、3、8、12 都吃这个）。

### 7.3 项目叙事五段式（面试必问，行 9 原话）
> 任务设计 → 数据构建 → 评测执行 → 结果分析 → 迭代优化

每一段都要能给出**数字和取舍**：为什么这样拆能力维度？数据从哪来、怎么去重和防污染？用什么评分方法、为什么？结果怎么证明不是噪声？迭代后指标变化多少、成本多少？

### 7.4 高频面试题预演
1. 什么是"好的 Agent 能力"？怎么把它拆成可量化维度？（行 12）
2. SWE-bench / GAIA / WebArena 的评分机制和局限性是什么？如果搬到你们业务要改什么？（行 9、12）
3. LLM-as-a-Judge 有哪些偏差？怎么检测和缓解？如何证明你的 Judge 可信？（行 9、17）
4. 模型版本涨了 3 分，怎么判断是真实提升还是噪声 / 泄漏？（行 11、17）
5. Agent 常见失败模式有哪些？给你一条轨迹，怎么定位到是模型、环境还是 Judge 的问题？（行 4、11）
6. 如何防止评测集被刷分 / 数据污染？动态评测集怎么设计？（行 9、12）
7. 设计一个 Coding Agent 的端到端评测方案，任务、数据、评分、环境分别怎么定？（行 12）
8. 怎么搭一个可控的 Agent 评测环境（Mock API、沙箱、模拟数据库）？（行 4）
9. 如何把 Rubric 做到可规模化、可泛化（金融合规场景）？（行 13）
10. 你做过的最有代表性的评测项目，完整讲一遍五段式。（行 9）

### 7.5 简历关键词包
`Python`、`大模型评测`、`Benchmark 建设`、`Agentic Evaluation`、`LLM-as-a-Judge`、`Rubric`、`Grader/Verifier`、`Agent Trajectory`、`Failure Taxonomy`、`SWE-bench`、`Terminal-Bench`、`GAIA`、`WebArena`、`AgentBench`、`OpenCompass`、`lm-eval-harness`、`MCP`、`ReAct`、`Harness`、`数据污染检测`、`A/B 实验`、`置信区间`、`评测平台`、`Leaderboard`、`Langfuse`、`可观测性`、`Red Teaming`

---

## 八、附录

### 8.1 原文 21 段 → 岗位方向映射
> 原文行 2 为空行，故下表未列出。
| 行 | 内容主题 | 判断 |
|---|---|---|
| 1 | 多维评测、评测标准与流程、评测平台开发、MT-Bench/Arena/MMLU/AgentEval、FastEval/OpenCompass/lm-eval-harness | 通用评测岗（职责+要求混排） |
| 3 | 前沿评测范式（RLHF/DPO、仿真环境、Agent 链路）、Benchmark 与数据资产建设、开源 Benchmark 建设 | 资深 / 平台向 |
| 4 | Mock 环境与工具集、Agent 评测维度、AgentBench/ToolBench/WebArena/OSWorld、失败模式 | Agent 评测专项 |
| 5 | 测试用例自动生成、研发工具链集成、测试结果评估体系、LangGraph/LangChain/AutoGen/MCP、Selenium/Playwright、Docker/K8s/Jenkins | Agent 测试开发 |
| 6 | 大模型评测体系设计与落地、Rubrics/Arena 经验 | 金融/企业向要求片段 |
| 7 | Agent Harness、上下文管理、工具调用 | 要求片段 |
| 8 | OpenCompass、llm-evaluation-harness、HELM | 要求片段 |
| 9 | **最完整的一条**：能力维度拆解、业界 Benchmark 谱系、Judge/Rubric/Grader/Verifier、轨迹评测、数据构建、失败归因、工具平台、明确的"必须"项 | 大模型能力评测与 Benchmark 建设（主对标） |
| 10 | Harness 各模块专项测试、财税/业务运营/决策场景、ReAct/任务编排/状态管理/Sub-agent/多智能体 | Agent Harness 测试（企业场景） |
| 11 | SWE/Terminal/GAIA 本地化、Agentic 评测与轨迹归因、评测工程与工具平台、A/B 与置信区间、前沿探索 | 金融行业 Agent 评测 |
| 12 | Coding & Agent 评测体系 0→1、能力维度/难度分级/数据构造/评分标准、抗污染、代码评测任务谱系、明确的加分项 | 代码智能评测（0→1） |
| 13 | AI 客户经理/风险经理/金融管家、信贷/理财/票据 Rubric/Checkpoint、与行 11 高度重合 | 金融智能体评测（行 11 完整版/同岗） |
| 14 | Langfuse 评测流水线、Logfire 全链路观测、Prompt 调优与 Red Teaming | Agent 测试工程师 |
| 15 | 多维 Agent 能力评估标准、内部 Benchmark 对标 AgentBench/ToolBench | 要求片段 |
| 16 | 千问办公 Agent Harness 架构、Runtime、MCP/Plugin/Skill、沙箱、可观测性、以评测驱动工程迭代 | Harness 工程（评测相邻） |
| 17 | 真实任务建评测集、编译测试+规则+模型裁判+人工、对照实验、执行隔离与结果报告、Coding Agent | Coding Agent 评测与产品化 |
| 18 | 技术选型（OpenTelemetry、LangChain、AutoGen、OpenDevin、MLflow）、MT-Bench/AgentBench/SWE-bench/GAIA | 评测平台技术负责人 |
| 19 | 多场景评测数据集、离线/线上实验、badcase、自动化工具与看板、多维度指标 | 通用大模型评测 |
| 20 | 对抗性分析、错误归因、能力边界挖掘（金融/医疗/小程序 APP） | 评测洞察片段 |
| 21 | 模型行为评测、自动化探索、持续评测与健康监控、评测系统全生命周期、数据管道与 API | 评测平台/模型行为评测（最体系化） |

### 8.2 原文出现的全部专有名词（查漏用）
- **通用评测集**：MMLU、C-Eval、CMMLU、AGIEval、HLE、MMMU、HumanEval
- **对话/对战**：MT-Bench、Arena、LMArena
- **代码**：SWE-bench（SWE Bench）、LiveCodeBench、BigCodeBench、Terminal-Bench（Terminal Bench）
- **Agent**：AgentEval、AgentBench、ToolBench、WebArena、OSWorld、GAIA
- **评测框架**：FastEval、OpenCompass、lm-eval-harness（llm-evaluation-harness、lm-evaluation-harness）、HELM
  > 各框架的定位、优先级排序与两周上手路线，见同目录 `杭州Agent评测工程师_评测框架清单.md`；
  > 各 Benchmark 的评测目标、评分机制、局限与必背清单，见同目录 `杭州Agent评测工程师_Benchmark全景清单.md`。
- **Agent 框架/协议**：MCP、LangGraph、LangChain、AutoGen、OpenAI Agents SDK、OpenDevin
- **工程/观测**：Docker、Kubernetes、Jenkins、GitLab CI、Git、CI/CD、Langfuse、Logfire、OpenTelemetry、MLflow、Selenium、Playwright、Appium
- **方法与概念**：LLM-as-a-Judge、Rubric、Grader、Verifier、Rule-based Evaluator、Human Evaluation、Arena 对战、pairwise、多 LLM 投票、few-shot、RLHF、DPO、Failure Taxonomy、Golden Dataset、Red Teaming、Prompt 注入/越狱、数据泄漏、Judge Bias、Prompt Hacking、抗刷分、生态效度

### 8.3 统计口径说明
- 原文 21 段并非 21 个独立岗位，混合了职责段、要求段、碎片；行 11 与行 13 高度重合。
- 第五节频次为"命中段落数"，仅用于判断相对重要性，不代表精确岗位数量。
- 部分文字被招聘平台水印切碎（如"BOSS直聘""kanzhun"插在词中间），已按语义拼接还原。
