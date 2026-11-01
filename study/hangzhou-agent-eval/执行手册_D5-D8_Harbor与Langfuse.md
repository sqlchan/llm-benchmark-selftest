# 执行手册 D5–D8：Harbor / Terminal-Bench + Langfuse

> **用途**：接续《执行手册 D1–D4》，完成 D5–D8：真实环境 Agent 评测（Harbor/Terminal-Bench）+ 评测平台与可观测（Langfuse）。
> **前置**：D1–D4 的 WSL2/云主机 + Docker + uv + API Key 已就绪。
> **每步格式**：目的 → 命令 → 预期输出 → 常见报错。
> **版本说明**：Harbor 文档已迁移到 docs.harborframework.com；Langfuse 自托管当前为 v4。命令以 `--help` 和官方文档为准。

---

## 〇、开始前检查（5 分钟）

```bash
docker run --rm hello-world            # Docker 正常
uv --version                           # uv 已安装（D1 若已装可跳过）
df -h                                  # 至少 50GB 空闲（Harbor 镜像 + Langfuse 容器）
free -g                                # Langfuse 自托管建议 ≥16GB；本机紧张就用云版
```

> 若 uv 未安装：`curl -LsSf https://astral.sh/uv/install.sh | sh`
> 目录建议：`mkdir -p ~/eval-lab && cd ~/eval-lab`

---

## 一、D5：Harbor + Terminal-Bench 跑通（约 1 天）

### Step 5.1 安装 Harbor

```bash
uv tool install 'harbor[modal]'    # 用 Modal 作为执行环境（推荐，免本地重环境）
# 或者只用本地 Docker：uv tool install harbor
uv run harbor --help
```

- **预期**：打印 `run` 等子命令帮助。
- **报错**：`uv: command not found` → 重开终端或 `source ~/.bashrc`；网络超时 → 重试/配置代理。

### Step 5.2 配置执行环境（Modal 或 Docker）

```bash
# 方案 A：Modal（推荐，需注册账号）
modal setup          # 浏览器授权；若命令不存在，用 python -m modal setup
# 方案 B：本地 Docker
# 不需要额外命令，运行时用 --env docker
```

- **预期**：`modal setup` 显示授权成功。
- **报错**：`modal: command not found` → `pip install modal`；授权失败 → 检查浏览器回调/网络。

### Step 5.3 跑 oracle，验证任务本身可完成（不花模型 token）

```bash
uv run harbor run -d terminal-bench/terminal-bench@latest \
  -k 5 --agent oracle --n-concurrent 500 --env modal
```

- **预期**：oracle 5 次全部通过（resolution 100%），说明环境与任务无 flaky。
- **报错**：oracle 偶发失败 → 先怀疑环境/网络，而不是 benchmark；Modal 额度不足 → 降并发或换 `--env docker`。
- **注意**：官方建议先在**自己的沙箱环境**跑 oracle 5 次，再跑真实 agent。

### Step 5.4 读一个任务，理解三件套（30 分钟）

- 在 Harbor Hub 浏览数据集：<https://hub.harborframework.com/datasets/terminal-bench/terminal-bench>
- 重点看一个 task 的：`Dockerfile`（环境）、指令（user prompt）、测试（判分依据）。
- 回答三个问题：任务如何判分？失败会以什么形式出现？agent 有哪些可用工具？

### Step 5.5 跑一个真实 agent（控制成本）

```bash
export ANTHROPIC_API_KEY="..."   # 若用 claude-code harness，换成对应 provider 的 key
uv run harbor run -d terminal-bench/terminal-bench@latest \
  --agent claude-code --model <model> \
  --n-concurrent 4 --env modal
```

- **预期**：输出 resolution rate、cost、tokens；`runs/` 下生成轨迹与日志。
- **控制成本**：
  - 先小并发（4 左右），别直接 100+；
  - 可用 `--ak` 传 agent 参数（官方 README 示例：`--ak reasoning_effort=max`）；
  - 任务筛选/子集参数以 `harbor run --help` 为准，先少量跑通再加量。
- **报错**：401 → agent 的 API key 不对；超时 → 网络/并发过高；环境起不来 → 回 Step 5.3 用 oracle 验证。

### Step 5.6 轨迹分析（D5 的核心产出）

```bash
ls runs/                                  # 查看本次运行目录
find runs -maxdepth 3 -name "*.log" | head
```

- 对失败任务逐条分类：**环境准备失败 / 命令用法错误 / 路径或权限问题 / 超时 / 最终测试未通过**。
- 记录：失败步骤、该步耗时、token/成本。

**D5 验收**：oracle 5 次稳定；1 次真实 agent 运行有结果；1 条轨迹有明确失败归因。

---

## 二、D6：Harbor 进阶与 harness 对比（约 0.5–1 天）

1. **换 harness 对比**：同一模型分别用两种 agent（如 `claude-code` 与 `codex`；只有一种时对比不同 `--ak reasoning_effort`）。记录：分数、成本、平均步数、典型失败。
2. **任务领域分布**：统计失败集中在哪些任务类型（配置、代码、系统操作…）。
3. **成本核算表**：每题 token / 美元 / 耗时；判断"高分是否靠堆步数"。
4. **可选**：读 task 贡献规范，给某个任务提 issue（发现 flaky/描述不清），就是一次真实的开源贡献。

**D6 验收**：一份《harness 对比小报告》（同模型不同 harness 的分数/成本差异 + 结论）。

---

## 三、D7：Langfuse 自托管 + trace 接入（约 1 天）

### Step 7.1 选部署方式

| 方式 | 适合 | 说明 |
|---|---|---|
| **Langfuse Cloud** | 只想快速体验 | 有免费额度，SDK 代码完全一样 |
| **Docker Compose 自托管** | 学"平台能力"、数据不出内网 | 需 Postgres + ClickHouse + Redis + S3/MinIO |

> 建议：**先 Cloud 跑通 SDK（30 分钟），再自托管**，避免一开始被基础设施卡住。

### Step 7.2 自托管（Docker Compose）

```bash
git clone https://github.com/langfuse/langfuse.git
cd langfuse
# 按官方要求修改 docker-compose.yml 中标记 # CHANGEME 的 secrets
docker compose up
```

- **预期**：2–3 分钟后 `langfuse-web-1` 打印 "Ready"；浏览器访问 <http://localhost:3000>，点 Sign up 创建首个用户/组织/项目。
- **资源**：官方建议 VM 至少 **4 核 16GiB、100GiB 存储**；本机 Docker 内存不足会导致容器起不齐。
- **报错**：
  - 端口 3000 被占用 → 改 `docker-compose.yml` 端口映射；
  - 容器 OOM → 加内存/改用 Cloud；
  - 一直不 Ready → `docker compose logs` 看缺哪个依赖（ClickHouse 慢启动常见）；
  - secrets 没改 → 按 CHANGEME 全部替换。

### Step 7.3 创建项目与 API Key

- UI 里创建 Organization → Project → Settings → API Keys，得到 `pk-...`（public）与 `sk-...`（secret）。

```bash
export LANGFUSE_PUBLIC_KEY="pk-..."
export LANGFUSE_SECRET_KEY="sk-..."
export LANGFUSE_HOST="http://localhost:3000"   # Cloud 用默认 host，不设即可
```

### Step 7.4 接入第一条 trace

```bash
pip install -U langfuse
```

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
langfuse.flush()     # 必须 flush，否则进程退出前 trace 可能丢失
```

- **预期**：UI 的 Traces 里出现一条两级 span 的 trace，含耗时。
- **报错**：401 → key/host 不匹配；看不到 trace → 忘了 flush、host 写错、或 Docker 容器未 Ready。
- **版本提示**：Langfuse Python SDK 版本迭代较快（v3→v4→v5 有 API 变化），上述 `@observe`/`get_client` 写法以官方 tracing 文档为准。

### Step 7.5 接入"带工具调用"的 Agent（关键）

1. 用 `from langfuse.openai import OpenAI`（官方文档示例）包装模型客户端，自动记录 LLM 调用；
2. 给每个工具函数加 `@observe()`，记录工具入参/耗时；
3. 故意制造一条失败 trace（工具抛异常），体验"从 trace 定位失败点"。

**D7 验收**：自托管可用（或 Cloud 可用）；1 条成功 trace + 1 条失败 trace；能定位到具体 span（模型/工具/异常）。

---

## 四、D8：数据集实验 + Judge + 版本回归（约 1 天）

### Step 8.1 建数据集（SDK 或 UI）

```python
from langfuse import get_client
langfuse = get_client()

langfuse.create_dataset(name="support-qa-v1")
items = [
    {"input": "退款多久到账？", "expected_output": "3-5 个工作日"},
    {"input": "怎么修改收货地址？", "expected_output": "订单未发货前可在订单详情修改"},
]
for it in items:
    langfuse.create_dataset_item(
        dataset_name="support-qa-v1",
        input=it["input"],
        expected_output=it["expected_output"],
    )
```

> 如果 SDK 方法名随版本变化，直接在 UI 里导入 CSV/JSON 建数据集同样可以，实验代码不变。

### Step 8.2 跑一次 experiment（当前推荐的 Experiment Runner）

```python
# 以官方《Experiments via SDK》为准，核心结构如下
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

result = langfuse.run_experiment(
    name="prompt-v1",
    data=[...],          # 本地列表或从 dataset 读取
    task=task,
)
print(result.format())
langfuse.flush()
```

- **预期**：UI 的 Experiments 里出现一次运行，可看到每个 item 的输出与耗时。
- **报错**：`data` 格式不对 → 按官方文档的 item 结构（input/expected_output）；trace 缺失 → 检查 OTel/flush；并发过高 → 调低。

### Step 8.3 加评分器（两种都要会）

| 类型 | 做法 | 适合 |
|---|---|---|
| **Code evaluator** | 在 UI 里写确定性检查（exact match / JSON schema / 关键词） | 有明确正确答案 |
| **LLM-as-a-Judge** | 模型按 rubric 打分 | 主观质量、语义正确性 |

- 抽 20 条人工复核，记录 judge 与人工的一致性（这是面试高频追问点）。

### Step 8.4 版本对比与稳定性

1. 改 prompt（v2）后重跑同一个 dataset；
2. 在 UI **Compare Experiments** 查看逐 item 差异；
3. 同一配置重复跑 3 次，算均值/波动，回答"差异多少才算真实提升"。

### Step 8.5 线上 case 回流（可选进阶）

- 从生产 trace 里挑失败样本 → 加进 dataset → 下一轮回归自动覆盖。
- 这就是 JD 里"线上 case 采集录制 + 评测闭环"的最小实现。

**D8 验收**：同一数据集的 2 个版本对比 + judge 分数 + 一致性抽检 + 1 条失败 case 回流。

---

## 五、D5–D8 时间盒

| 时段 | 任务 | 完成标志 |
|---|---|---|
| D5 上午 | 安装 Harbor + Modal 授权 + oracle 跑通 | oracle 5/5 通过 |
| D5 下午 | 读一个 task + 跑真实 agent + 轨迹分析 | 一条失败归因 |
| D6 上午 | harness 对比 / 任务分布 | 对比数据表 |
| D6 下午 | 成本核算 + 小报告 | 报告初稿 |
| D7 上午 | Langfuse 部署 + 项目/Key | UI 可访问，Key 就绪 |
| D7 下午 | SDK trace + 工具调用 trace + 失败 trace | 成功/失败各一条 |
| D8 上午 | dataset + experiment | 一次实验可查 |
| D8 下午 | judge + 版本对比 + 回流 | 对比结论 + 回流 1 条 |

---

## 六、报错速查

| 报错关键词 | 原因 | 处理 |
|---|---|---|
| `uv: command not found` | 未安装/未刷新 PATH | 重装 uv 后重开终端 |
| `modal setup` 失败 | 未安装/网络 | `pip install modal`；换网络/代理 |
| oracle 偶发失败 | 环境 flaky | 重跑；换 `--env docker`；报告 issue |
| agent 运行 401/403 | provider key 错误 | 检查对应环境变量与模型名 |
| Harbor 并发过高超时 | 网络/额度 | 降 `--n-concurrent`，分批 |
| Langfuse 容器不 Ready | ClickHouse/内存/S3 未就绪 | `docker compose logs`；加内存 |
| 端口 3000 占用 | 本机已有服务 | 改端口映射或停掉占用进程 |
| Langfuse 401 | Key/Host 不匹配 | 核对 `LANGFUSE_*` 环境变量 |
| Trace 不出现 | 未 flush/OTel 未初始化 | `langfuse.flush()`；检查初始化文档 |
| Experiment 报 data 结构错误 | item 字段不符 | 按官方文档的 input/expected_output 结构 |

---

## 七、D1–D8 打卡清单（直接勾）

### D1 OpenCompass 跑通
- [ ] 环境/conda/API Key 就绪
- [ ] `opencompass --help` 正常
- [ ] 最小评测跑通，`summary/*.csv` 出现
- [ ] 看懂 predictions 与分数

### D2 OpenCompass 进阶
- [ ] 配置化复现（`--dry-run` + 正式跑）
- [ ] 第二个数据集对比
- [ ] 自定义数据集可重复复现
- [ ] LLM-as-Judge 一致性抽检
- [ ] 重复评测看波动 + 5 个 badcase 归因

### D3 SWE-bench 判分
- [ ] 资源检查（x86/120GB/16GB）
- [ ] `swebench dataset check` 通过
- [ ] gold patch 单实例 resolved
- [ ] 生成预测并判分
- [ ] `swebench report` 出报告

### D4 SWE-bench 分析
- [ ] 5–10 实例子集实验
- [ ] 失败分类（定位/补丁/回归/环境/测试）
- [ ] D3–D4 评测记录模板完成

### D5 Harbor/Terminal-Bench
- [ ] Harbor 安装 + 环境（Modal/Docker）就绪
- [ ] oracle 跑 5 次稳定
- [ ] 读懂 1 个 task 三件套
- [ ] 真实 agent 运行有结果
- [ ] 1 条轨迹失败归因

### D6 Harbor 进阶
- [ ] 同模型换 harness/参数对比
- [ ] 成本核算表（token/美元/步数）
- [ ] harness 对比小报告

### D7 Langfuse 观测
- [ ] 自托管可用（或 Cloud）
- [ ] 项目 + API Key 创建
- [ ] 第一条 trace 可见
- [ ] 带工具调用的 Agent 成功/失败各 1 条 trace
- [ ] prompt 版本管理（可选）

### D8 Langfuse 实验
- [ ] dataset 建好（≥5 条）
- [ ] experiment 跑通
- [ ] code evaluator + LLM judge 各 1 个
- [ ] 两个 prompt 版本对比
- [ ] 1 条失败 case 回流（可选）
- [ ] 汇总：D1–D8 横向对比报告

---

## 八、成本与替代方案

- **Harbor**：oracle 不花模型 token；真实 agent 按模型计费，先小并发+少任务；Modal 有额度限制，注意用量。
- **Langfuse**：自托管只花机器资源；Cloud 有免费额度；judge/experiment 会调用模型，控制并发与样本量。
- **资源不够时**：Harbor 用 `--env docker` 本地跑；Langfuse 先用 Cloud 跑通 SDK，再补自托管。

---

## 九、参考链接

- Terminal-Bench：[官网](https://www.tbench.ai/) · [GitHub](https://github.com/harbor-framework/terminal-bench) · [Harbor Hub 数据集](https://hub.harborframework.com/datasets/terminal-bench/terminal-bench)
- Harbor：[GitHub](https://github.com/harbor-framework/harbor) · [文档](https://docs.harborframework.com/) · [官网](https://www.harborframework.com/)
- Langfuse：[文档](https://langfuse.com/docs) · [自托管 Docker Compose](https://langfuse.com/self-hosting/deployment/docker-compose) · [Experiments via SDK](https://langfuse.com/docs/evaluation/experiments/experiments-via-sdk) · [CI/CD 实验](https://langfuse.com/docs/evaluation/experiments/experiments-ci-cd)
