# 主流 Benchmark 与评测框架全景清单

> **用途**：面试弹药库 + 选型速查。JD 点名的必须能讲清"评什么 / 怎么评 / 局限"；标注「延伸」的是业内主流但非这些 JD 硬要求，用于建立坐标感。
> **先分清两个词**：
> - **Benchmark** = 考什么：任务集 + 数据 + 评分规则（如 SWE-bench、GAIA）。
> - **评测框架/平台** = 怎么跑：批量执行、评分、调度、观测、出报告（如 lm-eval、OpenCompass、Langfuse）。
> 面试常见误区：把"框架"当"benchmark"报菜名。正确讲法是"用哪个框架跑哪个 benchmark、怎么适配、结果怎么信"。

---

## 一、JD 点名 · 必须掌握（15 个）

### 1. 通用知识与推理

| Benchmark | 评什么 | 评分机制 | 主要局限（面试加分点） |
|---|---|---|---|
| **MMLU** | 57 学科知识（STEM/人文/社科） | 4 选 1 准确率，常用 5-shot | 已趋饱和（高分区分度低）；题目公开、污染严重；考记忆 > 考推理 |
| **C-Eval** | 中文 52 学科知识 | 准确率 | 中文知识覆盖尚可，但题型单一、更新慢、易被训练集吸收 |
| **CMMLU** | 中文 67 主题知识 | 准确率 | 同 C-Eval；偏知识记忆，对推理/长文本能力不敏感 |
| **AGIEval** | 人类标准化考试（高考/SAT/法考/GMAT 等） | 准确率 | 贴近人类考试形式，但题目年份老、公开可背，需做污染检查 |
| **HLE（Humanity's Last Exam）** | 2,500 道专家级跨学科难题（2025 定稿，Nature 发表） | 答案匹配（多选 / 短答） | 难度高、前沿模型仍低分；已出现噪声上限，官方 2026-09 推出 **HLE-Diamond** 迁移版、2025-10 推出动态版 **HLE-Rolling** —— 正好对应 JD 的"动态评测集 / 抗污染" |

### 2. 对话与主观质量（Arena 类）

| Benchmark | 评什么 | 评分机制 | 主要局限 |
|---|---|---|---|
| **MT-Bench** | 多轮对话质量（80 道两轮题，覆盖写作/推理/编码等） | **GPT-4 单答案打分**（1–10 分），两轮平均 | Judge 偏差（位置/长度/风格/自我偏好）；参考系漂移；GPT-4 判分器本身换代导致分数不可跨期比较 |
| **Arena / LMArena** | 开放式对话偏好（人类盲测 pairwise） | Bradley-Terry / Elo 排名 | 人类偏好 ≠ 能力（偏爱长答案/格式）；投票人群与业务场景错位；题目保密性与采样策略影响公平性 |
| **Arena 对战评测**（JD 行 6 明确"优先"） | 任意两模型输出对比 | pairwise 胜负 → Elo/胜率 | 同上；需注意同口径、同 prompt、同采样参数 |
| 延伸：Arena-Hard、AlpacaEval 2.0 | 自动 pairwise / 长度控制胜率 | LLM judge + LC win rate | 自动裁判偏差更明显，适合做趋势而非绝对结论 |

### 3. 代码与工程

| Benchmark | 评什么 | 评分机制 | 主要局限 |
|---|---|---|---|
| **HumanEval** | 164 道函数级 Python 题（docstring → 代码） | **pass@k**（跑单元测试） | 已饱和；题小、单文件，与真实工程差距大 |
| **LiveCodeBench** | 按时间切分的竞赛编程题（持续更新） | pass@1，题目按发布时间隔离 | 抗污染做得好；但竞赛题 ≠ 仓库级工程能力 |
| **BigCodeBench** | 1,140 个真实库调用任务（139 个库） | pass@1（含完整/指令两档） | 更贴近实践；但环境依赖重、复现成本高 |
| **SWE-bench / SWE-bench Verified** | 真实 GitHub issue → 生成补丁仓库修复 | **% resolved**：应用 patch 后跑 FAIL_TO_PASS / PASS_TO_PASS 测试；Verified 为 500 道人工校验子集 | 测试用例设计偏差；可被针对性刷分；Docker 环境复现成本高；解法泄露风险（issue 评论里带答案） |
| **Terminal-Bench** | 真实终端 / CLI 长程任务（装环境、调依赖、跑命令） | Docker 隔离执行，**resolution rate**（任务解决率）。已迭代到 **4.0**，由 Stanford / Harbor / Laude Institute 维护 | 环境构建与判分成本高；任务可能被训练集吸收；不同 harness（Claude Code / Codex / OpenHands）分数不可直接比 |

### 4. Agent / 工具 / 环境

| Benchmark | 评什么 | 评分机制 | 主要局限 |
|---|---|---|---|
| **AgentBench** | 8 类交互环境（OS、数据库、知识图谱、卡牌游戏、网页购物/浏览等） | 各环境自有指标汇总（成功率等） | 环境异构、指标不统一；部分环境已过时 |
| **ToolBench** | 16k+ 真实 REST API 的工具调用与多步任务 | **pass rate + win rate**（ToolEval：模型裁判） | 工具集随 API 变动而过时；"调用成功"≠"任务完成" |
| **WebArena** | 自建 4 个真实网站（电商/论坛/代码托管/地图），812 个任务 | 功能性校验（检查最终状态），成功率 | 网页/环境漂移；可被规则或记忆刷分；任务多样性有限 |
| **OSWorld** | 真实操作系统上的电脑操作任务（369 个） | 执行后校验系统状态，成功率 | 环境不稳定、截图/坐标敏感性高；成本高 |
| **GAIA** | 466 道需要浏览/工具/多步推理的真实问题（3 个难度级） | **精确匹配**最终答案 | 答案格式敏感；部分题实质是搜索题；判分对表述要求严 |
| **AgentEval** | 面向 Agent 应用的评测方法：自动生成评分标准（rubric）并量化打分 | 评审器（critic/quantifier agent）生成标准 + 打分 | 评分标准质量依赖评审模型；可解释性与一致性需人工校准 |
| 延伸：BFCL（Berkeley 函数调用榜） | 单/多轮函数调用准确率 | AST 匹配 + 可执行校验 | 只测"调用对不对"，不测长程规划 |
| 延伸：τ-bench / τ²-bench（Sierra） | 工具 + 模拟用户的多轮业务对话（客服/电信/航空） | **pass^k**（多次一致性） | 模拟用户保真度决定上限；领域窄 |
| 延伸：SWE-Lancer、MLE-bench、PaperBench | 真实外包任务（按美元计分）/ Kaggle 工程 / 论文复现 | 收入、奖牌率、rubric | 成本极高，适合前沿实验室而非日常回归 |

### 5. 多模态

| Benchmark | 评什么 | 评分机制 | 主要局限 |
|---|---|---|---|
| **MMMU** | 大学级图文多学科理解（约 1.1 万题，6 大学科） | 准确率 | 考"看懂图"，不考生成；中文场景需 **CMMMU** 对照 |
| 延伸：MMBench、MathVista、DocVQA、ChartQA、Video-MME | 中文多模态 / 数学图表 / 文档 / 图表 / 视频 | 准确率 / 专用指标 | 各自领域偏差大，需组合使用 |

---

## 二、主流扩展清单（按能力维度 · 建立坐标感）

| 能力维度 | 主流 Benchmark |
|---|---|
| 通用知识 / 推理 | MMLU-Pro、GPQA（Diamond 198 题）、BBH、ARC-AGI-2、HLE、SuperGPQA、LiveBench（月度防污染） |
| 数学 | GSM8K、MATH、MATH-500、AIME 2024/2025（15 题/年）、HMMT、Omni-MATH |
| 指令遵循 | IFEval、Multi-IF（多轮）、InFoBench |
| 事实性 / 幻觉 | TruthfulQA、SimpleQA、HalluLens、FActScore |
| 长上下文 | LongBench v2、RULER、NIAH（大海捞针）、∞Bench |
| RAG / 检索 | Ragas（faithfulness、context precision/recall）、RGB、CRUD-RAG、MultiHop-RAG、MTEB（检索/嵌入） |
| 代码 | MBPP、HumanEval+ / MBPP+（EvalPlus）、RepoBench、CrossCodeEval、Aider Polyglot、SWE-bench Multimodal、Spider / BIRD（Text-to-SQL） |
| Agent / 工具 | AgentBench、ToolBench、BFCL、GAIA、WebArena、WebVoyager、BrowserGym、OSWorld、τ²-bench、AppWorld、WorkArena、BrowseComp、Multi-IF、Vending-Bench（长程商业模拟） |
| 多模态 | MMMU、CMMMU、MMBench、MathVista、DocVQA、ChartQA、Video-MME、MVBench、RealWorldQA、HEIM / VHELM（生成与 VLM 全维度） |
| 安全 / 对齐 / 红队 | ToxiGen、BBQ、HarmBench、JailbreakBench、AgentHarm、SafetyBench、StrongREJECT |
| 中文 | C-Eval、CMMLU、AGIEval、CLUE、SuperCLUE（月度榜单）、CMMMU、MMBench-CN、FinEval（金融）、CBLUE（医疗）、LexEval（法律） |
| 垂直领域 | HealthBench / MedQA / MedHELM（医疗）、FinanceBench / FinEval（金融）、LegalBench / LexEval（法律）、办公类 OSWorld/OfficeBench |

> JD 行 19 的"通用问答、代码生成、多模态理解、RAG 检索增强、Agent 智能体"五个方向，正好对应上表前五行 —— 建评测集时按这个维度拆。

---

## 三、榜单与生态（做题之外的"行业视野"）

| 榜单 | 覆盖 | 用途 |
|---|---|---|
| **LMArena** | 通用对话偏好 | 主观能力风向标 |
| **CompassRank**（OpenCompass） | 中英文、多模态、多能力 | 国内模型横评 |
| **Open LLM Leaderboard**（HuggingFace） | 开源模型标准任务 | lm-eval 生态入口 |
| **HELM Leaderboards** | 多指标、含安全/多模态/医疗 | 多维评测方法论范本 |
| **SWE-bench / Terminal-Bench / GAIA / τ-bench / BFCL** 官方榜 | Agent 与 Coding 前沿 | 看前沿能力边界 |
| **Artificial Analysis / llm-stats / LiveBench** | 综合/实时 | 快速横向对比（注意口径） |

> 面试提醒：**榜单分数 ≠ 评测结论**。一定要问版本、时间、harness、成本、是否同口径。JD 行 9 原话就是"理解其评测目标、任务设计、数据构成、评分机制及局限性"。

---

## 四、评测框架（分层速查，详见同目录《评测框架清单》）

| 层 | 框架（括号内为定位） |
|---|---|
| **执行框架** | lm-evaluation-harness（60+ 学术任务）、OpenCompass（100+ 数据集 + CompassRank）、HELM（holistic 多指标）、FastEval（轻量 vLLM）、LightEval（HuggingFace）、lmms-eval（多模态）、Inspect（英国 AISI，Agent + 沙箱）、OpenAI Evals |
| **Agent 评测基础设施 / 环境** | AgentCompass（OpenCompass 2026-09 发布，解耦 model/benchmark/harness/environment）、SWE-bench harness（Docker 判分）、Harbor（Terminal-Bench 运行框架）、OSWorld、WebArena / BrowserGym、τ-bench harness、MLE-bench |
| **应用评测库** | DeepEval、Ragas（RAG）、Pydantic Evals、promptfoo（prompt/红队） |
| **平台 / 观测** | Langfuse、Logfire、MLflow、LangSmith、W&B Weave、Arize Phoenix、Braintrust |
| **红队 / 安全** | garak、PyRIT、promptfoo、HarmBench 工具链 |

---

## 五、面试速答模板 + 必背 Top 10

### 四要素模板（每个 benchmark 30 秒）
1. **评什么能力**：知识 / 推理 / 代码 / Agent / 多模态 / 主观偏好
2. **任务与数据形态**：选择题？仓库修复？网页操作？多轮对话？
3. **评分机制**：准确率 / pass@k / % resolved / 执行校验 / 模型裁判 / pairwise Elo
4. **局限与风险**：污染、饱和、judge 偏差、环境不稳、可被刷、成本

> 例：SWE-bench —— 真实 issue 修 bug；给仓库和 issue 生成补丁；apply 后跑 FAIL_TO_PASS/PASS_TO_PASS 算 resolved 率；局限是测试用例偏差、环境复现贵、可被针对性优化，所以要看 Verified 子集和 harness 一致性。

### 这批 JD 必背 Top 10
1. SWE-bench / Verified（Coding Agent 核心） 2. Terminal-Bench（终端长任务，已到 4.0） 3. GAIA（工具+浏览多步） 4. WebArena / OSWorld（网页 / 电脑操作） 5. AgentBench / ToolBench（环境与工具调用） 6. MMLU / C-Eval / CMMLU（知识底座） 7. MT-Bench / LMArena（主观与偏好） 8. HLE（前沿难度，动态化趋势） 9. MMMU（多模态） 10. HumanEval / LiveCodeBench / BigCodeBench（代码能力谱系）

---

## 六、参考来源（关键事实核验）

- [Terminal-Bench 官网（当前 4.0，Harbor 框架，resolution rate）](https://www.tbench.ai/)
- [HLE 官网（2,500 题；HLE-Rolling 2025-10、HLE-Diamond 2026-09）](https://agi.safe.ai/)
- [OpenCompass README（100+ 数据集、AgentCompass 2026-09）](https://github.com/open-compass/opencompass)
- [lm-evaluation-harness README](https://github.com/EleutherAI/lm-evaluation-harness)
- [HELM 文档（2026-06-01 起维护模式）](https://crfm-helm.readthedocs.io/en/latest/)
- [GAIA 论文](https://arxiv.org/abs/2311.12983)、[SWE-bench 论文](https://arxiv.org/abs/2310.06770)、[WebArena 论文](https://arxiv.org/abs/2307.13854)、[OSWorld 论文](https://arxiv.org/abs/2404.07972)、[τ-bench 论文](https://arxiv.org/abs/2406.12045)、[AgentBench 论文](https://arxiv.org/abs/2308.03688)、[ToolBench 论文](https://arxiv.org/abs/2307.16789)、[HLE 论文](https://arxiv.org/abs/2501.14249)
- [AgentCompass（EMNLP 2026）](https://github.com/open-compass/AgentCompass)

> 说明：benchmark 生态迭代很快（版本、子集、榜单口径都在变）。面试时讲"我了解它的设计原理和局限"比背具体分数安全；具体分数只引用有日期和 harness 说明的来源。
