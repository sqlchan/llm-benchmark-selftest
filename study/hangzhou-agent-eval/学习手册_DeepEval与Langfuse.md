# 学习手册：DeepEval 与 Langfuse（工程化评测 + 观测闭环）

> **定位**：这是 [四框架学习指南](四框架学习指南.md) 中 DeepEval / Langfuse 两章的展开版，目标是用 **7–10 天**把这两个框架从"会用"练到"能落地"。
> **顺序**：先 **DeepEval**（1–2 天，出成果快、直接进 CI）→ 再 **Langfuse**（2–3 天，平台能力、需要业务场景）。
> **与另两个框架的分工**：OpenCompass 管"通用能力离线评测"，SWE-bench 管"Coding Agent 判分"；DeepEval 管"业务效果单测化"，Langfuse 管"线上观测与版本回归"。

---

## 〇、先看清四个框架的边界（避免重复学习）

| 能力 | OpenCompass | SWE-bench | **DeepEval** | **Langfuse** |
|---|---|---|---|---|
| 跑 benchmark | 主力 | 主力（Coding） | 可跑（内置 benchmark，10 行代码） | 不做 |
| 业务用例断言 | 弱 | 不涉及 | **主力（pytest 风格）** | 中（judge 打分） |
| CI 门禁 | 弱 | 中（判分脚本） | **主力** | 中（CI/CD 实验） |
| 线上 trace 观测 | 不做 | 不做 | 有 tracing，但平台在 Confident AI | **主力** |
| 数据集实验对比 | 中 | 弱 | 中（`evaluate` 批量） | **主力** |
| 失败样本回流 | 不做 | 不做 | 弱 | **主力** |

> 一句话：**DeepEval 主场在"开发期/CI"，Langfuse 主场在"线上/实验"**。两者都做评测，但作用点不同；面试时能讲清这个分工是加分项。

---

## 一、DeepEval：把 LLM 效果评测写成"单测"

### 1.1 定位与学习目标

- 仓库：<https://github.com/confident-ai/deepeval>（19.2k★）· 文档：<https://deepeval.com/docs/getting-started>
- 本质：**LLM 应用的 pytest**。用 `LLMTestCase + Metric + threshold` 写断言，`deepeval test run` 执行，失败即阻断。
- 学完能做什么：给定一个 Agent/客服/RAG 应用，写出 10–20 条可回归的评测用例，接入 CI，并能解释每条指标评的是什么。

### 1.2 环境准备（10 分钟）

```bash
# 建议在 WSL2 / Linux；Windows 原生 Python 也可，但路径与 .env 注意区分
python -m venv ~/eval-lab/deepeval-venv
source ~/eval-lab/deepeval-venv/bin/activate
pip install -U deepeval
deepeval --help          # 预期：显示 test 等子命令
```

```bash
export OPENAI_API_KEY="sk-..."          # judge 与任务都可能用到
export OPENAI_BASE_URL="https://api.openai.com/v1"   # 兼容接口时改这里
```

> 注意：DeepEval **默认会自动读取当前目录的 `.env.local` 和 `.env`**；如果 key 混乱，优先检查这两个文件。

### 1.3 核心概念（必须能讲清）

1. **LLMTestCase**：`input` / `actual_output` / `expected_output` / `retrieval_context` / `tools_called` 等字段。
2. **Metric**：每个指标输出 0–1 分 + `reason`；`threshold` 决定 pass/fail。
3. **指标族**：
   - 通用：`GEval`（自定义标准）、`AnswerRelevancy`、`Hallucination`、`Bias`、`Toxicity`、`JSON Correctness`
   - RAG：`Faithfulness`、`Contextual Precision/Recall/Relevancy`
   - Agent：`Task Completion`、`Tool Correctness`、`Step Efficiency`、`Plan Adherence`、`Plan Quality`、`Tool Use`、`Argument Correctness`
   - 多轮：`Knowledge Retention`、`Turn Relevancy`、`Turn Faithfulness`、`Role Adherence` 等
4. **pytest 集成**：`assert_test(test_case, [metrics])` + `deepeval test run`。
5. **轨迹/tracing**：`@observe()` 记录 agent 决策路径，可做轨迹级评测。
6. **合成数据 / 数据集**：批量生成评测样本、跑 `evaluate`。

### 1.4 学习步骤

#### L1：跑通第一个用例（0.5 天）

```python
# test_ai_agent.py
import pytest
from deepeval import assert_test
from deepeval.metrics import GEval
from deepeval.test_case import LLMTestCase, SingleTurnParams

def test_case():
    metric = GEval(
        name="Correctness",
        criteria="判断 actual output 是否基于 expected output 正确回答",
        evaluation_params=[SingleTurnParams.ACTUAL_OUTPUT, SingleTurnParams.EXPECTED_OUTPUT],
        threshold=0.5,
    )
    case = LLMTestCase(
        input="鞋子不合脚怎么办？",
        actual_output="支持 30 天无理由退款。",
        expected_output="我们提供 30 天无理由退款。",
    )
    assert_test(case, [metric])
```

```bash
deepeval test run test_ai_agent.py
```

- **预期**：输出 pass/fail + score + reason；失败时打印哪条指标不过。
- **观察点**：改 `threshold`（0.5 → 0.8）看结果变化，理解"阈值决定敏感度"。
- **报错**：`401` → API key；`ModuleNotFoundError` → 环境没激活；测试未被发现 → 文件名 `test_*.py`、函数 `test_*`。

#### L2：写 10–20 条真实用例 + CI（2 天）

1. **选场景**：客服问答 / 财税咨询 / RAG 检索 / 一个 Agent 任务，四选一。
2. **选 2–3 个指标**（不要堆）：正确性用 `GEval`，相关性用 `AnswerRelevancy`，Agent 用 `TaskCompletion + ToolCorrectness + StepEfficiency`。
3. **覆盖三类用例**：正常路径、边界输入（拒答/超范围）、失败路径（工具报错/无检索结果）。
4. **接 CI**（GitHub Actions 示例）：

```yaml
# .github/workflows/eval.yml
name: llm-eval
on: [push]
jobs:
  eval:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: "3.11" }
      - run: pip install -U deepeval
      - run: deepeval test run tests/
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

5. **失败归因**：每个 fail 判"模型能力 / Prompt / 检索 / Judge 偏差"四类之一。

- **验收**：CI 里能看到评测 job；故意改坏 prompt 能触发 fail（证明门禁有效）。

#### L3（可选）：自定义指标 + 轨迹评测 + 合成数据（2–3 天）

- 自定义指标：继承 `BaseMetric`，实现 `measure` / `is_successful` / `__name__`（以官方 custom metrics 文档为准）。
- 轨迹评测：给 Agent 加 `@observe()`，用 `TaskCompletionMetric` 评整条轨迹。
- 合成数据：按官方文档生成单轮/多轮数据集，再批量 `evaluate`。
- 红队：按官方红队文档构造注入/越狱用例（成本可控，先小样本）。

### 1.5 常见坑

| 现象 | 原因 | 处理 |
|---|---|---|
| 指标分数忽高忽低 | judge 非确定性 | 同 case 跑 3 次看均值；固定 judge 模型与参数 |
| 所有 case 都过 | 阈值太低/指标不敏感 | 提高 threshold 或用更严格 criteria |
| judge 很贵 | 用例太多 | 分层：全量规则子集 + 抽样 judge |
| key 不生效 | `.env` 覆盖环境变量 | 检查 `.env/.env.local`；必要时 `DEEPEVAL_DISABLE_DOTENV=1` |
| 测试找不到 | pytest 命名规范 | 文件/函数 `test_` 前缀，或用 `deepeval test run -c` 配置 |

### 1.6 面试题（DeepEval 向）

1. 评测和传统单测的本质区别？→ 非确定性、阈值、Judge、方差。
2. 为什么先选 2–3 个指标而不是全上？→ 噪声、成本、可解释性。
3. 阈值怎么定？→ 人工标注部分样本，按可接受误判率反推。
4. 怎么证明 CI 门禁有效？→ 故意注入坏 change，确认能 fail。

---

## 二、Langfuse：观测 + 数据集实验 + 回归闭环

### 2.1 定位与学习目标

- 仓库：<https://github.com/langfuse/langfuse>（36.8k★）· 文档：<https://langfuse.com/docs>
- 本质：开源 AI 工程平台 = **trace 观测 + prompt 管理 + 评测（judge/代码评分/人工） + Dataset/Experiment**，基于 OpenTelemetry，可自托管。
- 学完能做什么：把一次 Agent 调用变成可诊断的 trace；把线上失败样本建成数据集；用 experiment 对比两个 prompt 版本并给出结论。

### 2.2 环境准备（30 分钟）

**方式 A：Cloud（推荐先跑通）**：注册 → 建项目 → 拿 `pk-` / `sk-`。
**方式 B：自托管**

```bash
git clone https://github.com/langfuse/langfuse.git
cd langfuse
# 修改 docker-compose.yml 中 # CHANGEME 的 secrets
docker compose up
# 2–3 分钟后访问 http://localhost:3000，Sign up 建首个用户/组织/项目
```

```bash
pip install -U langfuse
export LANGFUSE_PUBLIC_KEY="pk-..."
export LANGFUSE_SECRET_KEY="sk-..."
export LANGFUSE_HOST="http://localhost:3000"    # Cloud 不设，用默认
```

> 资源：自托管官方建议 VM ≥4 核 16GiB、≥100GiB 存储；本机内存不足会起不齐容器。架构：Web + Worker + Postgres + ClickHouse + Redis + S3/MinIO。

### 2.3 核心概念（必须能画出来）

1. **数据模型**：trace → observation（span / generation / event）→ session；score 可挂在 trace 或 observation 上。
2. **三种评分**：LLM-as-a-Judge、code evaluator（确定性规则）、人工标注（annotation）。
3. **Dataset + Experiment**：数据集版本化，跑实验对比模型/prompt 版本（UI 或 SDK）。
4. **Prompt Management**：版本化、label 部署、与 trace 关联。
5. **观测闭环**：线上 trace → 失败样本 → 数据集 → 回归实验 → 上线。
6. **成本/延迟**：按 trace 看 token、费用、耗时。

### 2.4 学习步骤

#### L1：第一条 trace（0.5 天）

```python
# trace_demo.py
from langfuse import observe, get_client

langfuse = get_client()

@observe()
def step(x):
    return x * 2

@observe()
def app(x):
    return step(x)

print(app(21))
langfuse.flush()     # 必须 flush，否则退出时 trace 可能丢失
```

- **预期**：UI → Traces 出现一条两级 span，能看到耗时。
- **观察点**：点开每个 span 看 input/output；对比去掉 `flush()` 的后果。
- **报错**：UI 无数据 → key/host 错、忘了 flush、容器未 Ready；401 → 环境变量没生效。

#### L2：接入真实 Agent + 数据集实验（2 天）

**1）接入带工具调用的 Agent**

```python
from langfuse.openai import OpenAI      # 官方包装，自动记录 LLM 调用
from langfuse import observe, get_client

langfuse = get_client()
client = OpenAI()

@observe()
def search_order(order_id: str) -> str:
    # 模拟工具；故意保留一个失败分支，用来练习 trace 定位
    if order_id == "bad":
        raise RuntimeError("tool timeout")
    return "已发货"

@observe()
def agent(question: str) -> str:
    ctx = search_order("A001")
    resp = client.chat.completions.create(
        model="<你的模型>",
        messages=[{"role": "user", "content": f"上下文：{ctx}\n问题：{question}"}],
    )
    return resp.choices[0].message.content

agent("我的订单到哪了？")
langfuse.flush()
```

- **预期**：trace 里能看到工具 span（含耗时）和 LLM generation（含 token/成本）。
- **练习**：故意触发失败分支，从 trace 定位"失败在哪个 span"。

**2）数据集 + 实验**

```python
from langfuse import get_client

langfuse = get_client()
langfuse.create_dataset(name="support-qa-v1")
for item in [
    {"input": "退款多久到账？", "expected_output": "3-5 个工作日"},
    {"input": "怎么修改收货地址？", "expected_output": "未发货前可在订单详情修改"},
]:
    langfuse.create_dataset_item(
        dataset_name="support-qa-v1",
        input=item["input"],
        expected_output=item["expected_output"],
    )
```

```python
# experiment.py（结构以官方 Experiments via SDK 为准）
from langfuse import get_client
from langfuse.openai import OpenAI

langfuse = get_client()
client = OpenAI()

def task(*, item, **kwargs):
    resp = client.chat.completions.create(
        model="<你的模型>",
        messages=[{"role": "user", "content": item["input"]}],
    )
    return resp.choices[0].message.content

result = langfuse.run_experiment(name="prompt-v1", data=[...], task=task)
print(result.format())
langfuse.flush()
```

- **预期**：UI → Experiments 出现一次运行；逐 item 可查输出。
- **练习**：改 prompt（v2）再跑，用 Compare Experiments 看差异；同一配置跑 3 次看波动。
- **报错**：data 结构不符 → 按官方 item 结构；无 trace → OTel/flush；并发过高 → 降并发。

**3）给实验加评分**：在 UI 配 LLM-as-a-Judge（用 rubric 提示词）或 code evaluator（exact match/JSON 校验），再对比两次实验的分数。

**4）线上失败回流**：从 trace 里找失败样本 → 加入 dataset → 下次回归自动覆盖（这就是 JD 里"线上 case 采集录制"的最小实现）。

#### L3（可选）：平台化深入（2–3 天）

- 自托管架构：看 Web/Worker/Postgres/ClickHouse/Redis/S3 分工与扩容点；
- code evaluator 与 annotation queue：把确定性检查和人工复核接进流程；
- CI/CD 实验：把 experiment 挂到 pipeline，PR 时自动对比基线；
- 看板/告警/API：按 trace 维度做成本、延迟、失败率监控。

### 2.5 常见坑

| 现象 | 原因 | 处理 |
|---|---|---|
| 容器起不齐/一直不 Ready | 内存不足 / ClickHouse 慢启动 | 加内存；`docker compose logs` 看依赖 |
| UI 无 trace | flush 缺失 / host 写错 | `langfuse.flush()`；核对 `LANGFUSE_HOST` |
| 401 | public/secret key 混用或未生效 | 重新 export；重启 shell/IDE |
| experiment 数据没进 UI | dataset/item 结构不符 | 按官方文档结构建 dataset |
| trace 断链 | 没在工具函数上加 span | 给工具/子步骤加 `@observe()` |

### 2.6 面试题（Langfuse 向）

1. Observability 与 Evaluation 的关系？→ 发现失败样本 → 沉淀数据集 → 回归。
2. 为什么基于 OpenTelemetry？→ 生态复用、避免锁定、统一 trace 模型。
3. 线上评测怎么做？→ 在线 judge + 人工抽检 + 失败样本回流 + 定期实验。
4. 自托管和 Cloud 怎么选？→ 数据合规/成本/运维能力权衡。

---

## 三、把两个框架串起来：2 周 mini 项目

**项目：客服 Agent 评测闭环**

| 步骤 | 工具 | 产出 |
|---|---|---|
| 1. 线上 trace 采集 | Langfuse | 20 条真实对话 trace，含 3–5 条失败 |
| 2. 失败样本沉淀 | Langfuse dataset | `support-qa-v1` 数据集（10–15 条） |
| 3. 用例单测化 | DeepEval | 每类失败至少 2 条 pytest 用例 |
| 4. CI 门禁 | DeepEval + GitHub Actions | 坏 prompt 能触发 fail |
| 5. 版本实验 | Langfuse experiment | prompt v1 vs v2 的分数对比 |
| 6. 报告 | 两者结合 | 失败模式分类 + 指标变化 + 结论 |

**目录建议**

```text
eval-lab/
├── deepeval/
│   ├── tests/test_support_agent.py
│   ├── metrics/custom_compliance.py
│   └── .github/workflows/eval.yml
└── langfuse/
    ├── trace_agent.py
    ├── seed_dataset.py
    └── run_experiment.py
```

**简历写法示例**：
> 用 Langfuse 采集 20 条客服 Agent 线上 trace 并沉淀 12 条失败样本；用 DeepEval 将失败模式转为 18 条 CI 评测用例（正确性/合规/轨迹三类指标）；对比 2 个 prompt 版本，定位 X 类失败并推动指标提升 Y%。

---

## 四、7–10 天计划表

| 天 | 任务 | 完成标志 |
|---|---|---|
| D1 | DeepEval 安装 + GEval 示例 + 改阈值实验 | test run 通过 |
| D2 | 10–20 条用例（3 类指标）+ 失败归因 | 本地全绿且有归因 |
| D3 | 接 GitHub Actions + 故意注入坏 change | CI 能 fail |
| D4 | Langfuse 部署（Cloud 或自托管）+ 首条 trace | UI 可见 trace |
| D5 | 工具调用 Agent trace + 失败 trace 定位 | 能指出失败 span |
| D6 | dataset + experiment（v1） | experiment 可见 |
| D7 | judge/code evaluator + v2 对比 | 两个版本分数对比 |
| D8–D10 | 串联 mini 项目 + 报告 | 项目 + 总结 |

---

## 五、自测清单（能全答上再进下一阶段）

**DeepEval**
- [ ] 能解释 LLMTestCase 各字段与 Metric 的 score/threshold 关系
- [ ] 能按场景选 2–3 个指标并说明理由
- [ ] 能写出自定义 metric 的最小实现
- [ ] 能把评测挂进 CI 并证明门禁有效
- [ ] 能区分"模型能力/Prompt/检索/Judge"四类失败原因

**Langfuse**
- [ ] 能画出 trace/observation/session/score 数据模型
- [ ] 能从一条失败 trace 定位到具体 span
- [ ] 能建 dataset 并跑 experiment
- [ ] 能配 judge/code evaluator 并对比两个版本
- [ ] 能说明"线上失败 → 数据集 → 回归"的闭环步骤

---

## 六、资料汇总

| 用途 | 链接 |
|---|---|
| DeepEval 入门 | <https://deepeval.com/docs/getting-started> |
| DeepEval 指标总览 | <https://deepeval.com/docs/metrics-introduction> |
| DeepEval 仓库 | <https://github.com/confident-ai/deepeval> |
| Langfuse 入门（tracing） | <https://langfuse.com/docs/observability/get-started> |
| Langfuse 数据模型 | <https://langfuse.com/docs/observability/data-model> |
| Langfuse 评估总览 | <https://langfuse.com/docs/evaluation/overview> |
| Langfuse 实验（SDK） | <https://langfuse.com/docs/evaluation/experiments/experiments-via-sdk> |
| Langfuse 自托管 | <https://langfuse.com/self-hosting/deployment/docker-compose> |
| CI/CD 实验 | <https://langfuse.com/docs/evaluation/experiments/experiments-ci-cd> |

> 提醒：这两个框架的 SDK 迭代都很快（DeepEval 指标名、Langfuse SDK 版本），代码以官方文档当前版本为准；学习时优先保证"概念 + 闭环"讲得清，而不是记住某个函数名。
