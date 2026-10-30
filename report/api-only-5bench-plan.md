# 5 个基准的 API-only 执行方案（研发团队模型选型）

> 适用：模型只能走 API，评测工具在本地/云 Linux 运行。基准：**DeepSWE v1.1、Terminal-Bench 4.0、NL2Repo-Bench、ProgramBench、Automation-Bench v1.0.6**。
> 依据：2026-10-30 核实的官方文档与仓库；命令来自官方但**未在本机执行**，涉及 endpoint/model 的字段需按你的网关填。金额为量级估算。

## 0. 结论

| 问题 | 答案 |
| :-- | :-- |
| 这 5 个都能只走 API 吗？ | **能**。5 个都是「harness 跑在本地容器、模型调用走 API」；ProgramBench 的断网限制只针对任务容器，模型调用由宿主机 harness 发起，不受影响。 |
| 哪个先跑？ | **DeepSWE**（最贴近日常修 bug、官方支持 10 题确定性抽样）→ **Automation-Bench**（无需 Docker、最便宜）→ **Terminal-Bench 4.0**（agent 能力，贵且评分有争议）→ **NL2Repo-Bench**（链路重）→ **ProgramBench**（amd64 + 6h/题，最贵）。 |
| 一个模型跑完要多久？ | 见第 5 节：筛选 3–5 天；5 个基准全量 3–6 周（含排队与重跑）。 |
| 预算量级？ | 筛选 $50–400；短名单 $1,000–5,000；全量+复跑 $5,000–20,000（取决于模型单价，Opus 级最贵）。 |

## 1. 5 个基准的定位与评分权重建议

| 基准 | 对应研发场景 | 建议权重 | 关键限制 |
| :-- | :-- | --: | :-- |
| DeepSWE v1.1 | 修 bug、跨文件维护、真实仓库改动 | **30%** | 113 题；HF 轨迹库 gated（题目在 GitHub 公开）；Pier >0.3.0 |
| Terminal-Bench 4.0 | Coding Agent 在终端里完成工程任务 | **25%** | 66 题、3 题需 H100；Epoch 复核 30/66 题有评分缺陷；用 k=1 小样本 |
| Automation-Bench v1.0.6 | 多步工具调用、业务流程自动化 | **20%** | 公开 600 题 + simple 200；官方榜用私有 held-out 集，本地分不可直接对榜 |
| NL2Repo-Bench | 规格 → 完整仓库生成 | **15%** | 104 题；OpenHands 0.56 双镜像；无轮数上限、极易烧钱 |
| ProgramBench | 只看二进制+文档从零重建程序 | **10%** | 200 题；linux/amd64、6h/题、1000 步、断网；平均 $36/题 |

> 权重可按团队实际工作分布调整；纯维护型团队可把 DeepSWE 提到 40%，平台/基建团队把 Terminal-Bench 提到 30%。

## 2. API-only 接入矩阵

模型调用路径分两类：**宿主机调用**（harness 在宿主进程里请求 API，任务容器只跑代码）和**沙箱内调用**（agent 跑在容器里，自己请求 API）。后者遇到 `allow_internet=false` 任务需要网络放行。

| 基准 | Agent 运行位置 | API 接入方式 | 需要放行 API 域名？ |
| :-- | :-- | :-- | :-- |
| DeepSWE v1.1 | Pier 沙箱（docker/modal） | Pier 的 agent 配置：`model_name` + `agent.env` + mini-swe 的 `config_yaml`（可写 `model_kwargs.api_base`） | **是**（Pier 会把配置里的 URL 自动加入 allowlist） |
| Terminal-Bench 4.0 | Harbor 沙箱 | `-a claude-code` 走 Anthropic Messages；`-a mini-swe-agent` 走 OpenAI 兼容；Harbor 提供 `--base-url/--api-key-name/--api-format` | **是**（若任务禁网，需 Harbor 网络配置） |
| Automation-Bench | 宿主机（纯 API） | `uv run auto-bench --model <m> --base-url <url> --api-key <k> --api-key-var OPENAI_API_KEY` | 否（无容器） |
| NL2Repo-Bench | OpenHands 容器 | 仓库 `config.json`：`startPro[].moduleName/baseUrl/sk` | **是**（OpenHands 容器要能访问端点） |
| ProgramBench | mini-swe-agent 宿主进程 | `mini-extra programbench --model <m>` + 自定义 config 文件注入 `model_kwargs.api_base` | 否（模型调用在宿主机） |

**统一 scaffold 建议**：用 **mini-swe-agent** 作为统一 agent（模型无关、不依赖原生 tool-calling、线性历史便于审计），DeepSWE / ProgramBench 官方就是它；TB4 也可用 `-a mini-swe-agent` 保持口径一致。只有在拿到 Anthropic 协议 API 时，才用 `-a claude-code` 做一次交叉验证。

## 3. 配置模板（见 `configs/`）

### 3.1 任意 OpenAI 兼容端点 → mini-swe-agent

`configs/mini-swe-model.example.yaml`：

```yaml
model:
  model_name: your-model-name
  model_kwargs:
    custom_llm_provider: openai
    api_base: https://your-gateway.example.com/v1
  cost_tracking: ignore_errors   # 未在 LiteLLM registry 注册时避免 cost 报错
```

使用：
```bash
export OPENAI_API_KEY=<key>
# mini-swe-agent 系 harness 引用该 config（各入口的 -c/--config 参数）
```

> 需要在轨迹里看到成本时，改用 LiteLLM registry 注册模型（参考 mini-swe-agent 文档 `models/local_models`），把 `input_cost_per_token`/`output_cost_per_token` 填对；否则用 `ignore_errors` 并自行按 token 计价。

### 3.2 NL2Repo-Bench

`configs/nl2repo-config.example.json`（字段名已核实自官方 `config.json`）：

```json
{
  "startPro": [
    {
      "moduleName": "your-model-name",
      "baseUrl": "https://your-gateway.example.com/v1",
      "sk": "your-api-key",
      "proNameList": ["aiofiles", "math-verify"]
    }
  ],
  "max_pool_size": 2
}
```

> `baseUrl` 是否需要 `/v1` 后缀由 OpenHands 0.56 的 OpenAI client 决定，**TODO verify**；先用 1 题跑通。`proNameList` 留 1–2 个任务就是小样本。

### 3.3 Automation-Bench

无需配置文件，CLI 参数即可（选项已核实）：

```bash
uv run auto-bench --model <model> \
  --base-url https://your-gateway.example.com/v1 \
  --api-key-var OPENAI_API_KEY \
  --domains sales --num-examples 20 \
  --max-concurrent 8 \
  --input-cost <usd/token> --output-cost <usd/token>
```

## 4. 模型候选与预筛

按「可采购到的 API」填 3–5 个候选；建议结构：一个低价主力 + 1–2 个旗舰 + 1 个国产备选。

| 候选 | 定位 | 可查到的公开锚点 |
| :-- | :-- | :-- |
| DeepSeek-V4.1-Flash-1017 | 低价主力，适合高并发/日常 | 模型卡自报：DeepSWE 77.0、TB4 42.3、NL2Repo 68.2、ProgramBench 29.1、Automation 60.5（均为自报，口径见第 6 节） |
| Claude Opus 5 | 旗舰，代码/终端能力上限 | 模型卡：TB4 51.8、ProgramBench 37.0、NL2Repo 75.3；DeepSWE 官方约 $11.84/题；AutomationBench 公开集 50.3% |
| GPT-5.6 Sol | 旗舰备选 | 模型卡：TB4 39.9、ProgramBench 23.0、NL2Repo 56.8；AutomationBench 公开集 45.83% |
| Kimi K3 | 性价比备选 | AutomationBench 公开集 46.67%；模型卡 TB4 12.6（异常低，建议实测确认） |
| GLM-5.3 / 5.3-flash | 极低价档 | AutomationBench GLM 5.2 为 26.17%；DeepSWE 官方 glm-5.3-flash 约 $0.24/题 |

**预筛原则**：先用公开榜/模型卡把明显不合适的砍掉，但**不要用跨来源数字直接排名**（第 6 节）。真正的排序必须来自同一 harness 的实测。

## 5. 三阶段执行计划

### 阶段 1：管道验证 + 粗筛（3–5 天，$50–400）

目标：确认每个基准的「数据→容器→判分→成本统计」链路通，拿到第一版粗分。全部模型都跑同样的子集。

| 顺序 | 基准 | 子集 | 命令要点 | 预计成本 |
| :-: | :-- | :-- | :-- | --: |
| 1 | DeepSWE | 10 题 | `pier run -p deep-swe/tasks --agent mini-swe-agent --n-tasks 10 --sample-seed 0` | $2–134 |
| 2 | Automation-Bench | simple 20 + sales 20 | `uv run auto-bench --domains simple --num-examples 20`（再 `--domains sales`） | $2–15 |
| 3 | Terminal-Bench | 5 题、k=1 | `harbor run -d terminal-bench/terminal-bench@4.0.0 -a mini-swe-agent -k 1 --n-concurrent 2`（子集用 `task_names`） | $10–150 |
| 4 | NL2Repo | 2 题 | `config.json` 只留 aiofiles、math-verify，`max_pool_size=2` | $2–15 |
| 5 | ProgramBench | 2 题 | `mini-extra programbench --slice 0:2 --workers 2 -c <custom-config>` | $20–250 |

> 阶段 1 不追求数字准确，追求「链路能跑 + 成本能测」。每个基准记录：是否跑通、失败原因、单题 token/耗时、单题成本。

### 阶段 2：短名单实测（1–2 周，$1,000–5,000）

| 基准 | 规模 | 备注 |
| :-- | :-- | :-- |
| DeepSWE | 全量 113 题 | 固定 `mini-swe-agent`、固定采样；每模型跑 1 次（可选 top-2 复跑） |
| Automation-Bench | 全量 600 题 | 报「public-set pass rate」，**不要**称与官方榜可比 |
| Terminal-Bench | 20–30 题、k=1 | 避开 3 个 GPU 任务或单独标记；不跑官方 k=5（太贵） |
| NL2Repo | 10 题 | 每次运行设成本/轮数上限（脚本无上限，必须自己盯） |
| ProgramBench | 5 题 | 固定同一批实例 ID，便于跨模型对比 |

阶段 2 产出：每模型每基准的 pass rate、P50 单题耗时、单题成本、失败模式分类。淘汰到 2 个模型。

### 阶段 3：决赛 + 稳定性（2–4 周，$5,000–20,000）

- 决赛模型 × 5 个基准全量（TB4 可只跑 66 题 ×3 次，不追 k=5）；
- 每模型每基准重复 3 次（至少 DeepSWE + Automation），报均值与波动；
- 加做「同 provider 不同时段」的稳定性（限流、超时、降级）；
- 汇总加权分（第 1 节权重）→ 采购建议。

## 6. 口径与公平性规则（必须写进汇报）

1. **跨来源数字不可直接排名**：模型卡是厂商标称、Benchmark 官方榜是另一套 harness/数据（部分私有 held-out）、你的本地跑分是第三套。只能同源比较。
2. **视觉三项的 w/tools 教训在这里同样适用**：同一模型换 agent/scaffold（mini-swe-agent vs claude-code）、换 reasoning effort、换步数上限，分数会大幅变化。必须固定：agent + 版本、采样参数、max steps、超时、重试策略。
3. **Terminal-Bench 4.0 的评分缺陷**：Epoch AI 复核 30/66 题存在奖励 hack/答案泄漏/假阴假阳。它适合做「agent 能不能跑通」的信号，不适合做精细排序；结论里要注明。
4. **Automation-Bench 私有 held-out**：公开 600 题只能出「public-set 分」，与官方榜不可 1:1 对齐；跨模型比较仍然有效（同集同 harness）。
5. **ProgramBench 指标是 Resolved**（单题全部隐藏测试通过），不是通过率；模型卡 29.1 与官方榜 Resolved（最高约 18.5%）口径不同。
6. **NL2Repo 无轮数上限**：必须监控成本/时长，否则单题可能烧掉几十美元；先小样本标定。
7. **版本锁**：TB4 `@4.0.0`、Pier `>0.3.0`、AutomationBench `1.0.6`、NL2Repo 镜像 `openhands:0.56` + `runtime:0.56-nikolaik`。
8. **模型版本漂移**：API 模型会静默更新，记录调用日期 + 模型快照名（若有），阶段 2/3 之间不要换版本。

## 7. API-only 的额外工程注意点

- **协议适配**：mini-swe-agent 走 LiteLLM，不依赖原生 tool-calling；Harbor 的 claude-code 只吃 Anthropic Messages。自定义网关多数只支持 OpenAI Chat Completions → 优先用 mini-swe-agent 系。
- **避免 `openai/` 前缀陷阱**：Pier 的 mini-swe 适配器按前缀分流，`openai/...` 会走 Responses API 端到端；很多网关不支持 Responses，改用自定义模型名 + `model_kwargs.custom_llm_provider=openai`。
- **限流**：把各 harness 并发压到 provider 的 RPM/TPM 以下（DeepSWE/Pier 的 `--workers`、Automation 的 `--max-concurrent`、Harbor 的 `--n-concurrent`）；遇到 429 时 harness 会重试，重试会计入成本。
- **长上下文**：agent 轨迹会持续增长，选模型时确认上下文窗口 ≥ 128k，并设置 `max_tokens`；超限会被 harness 记为失败而非跳过。
- **成本统计**：未在 LiteLLM registry 注册的模型需要 `cost_tracking: ignore_errors` + 自行按 token 计价（Automation-Bench 用 `--input-cost/--output-cost`）。
- **合规**：DeepSWE/ProgramBench/NL2Repo 只用公开仓库/规格，不涉及公司代码；若阶段 3 要加内部任务集，先确认厂商 API 的「不用于训练」条款与数据驻留。

## 8. 记录模板（每个模型 × 每个基准一行）

```
模型/版本：         <provider/model + snapshot + 调用日期>
基准/版本：         DeepSWE v1.1 / TB4 @4.0.0 / NL2Repo(openhands 0.56) / ProgramBench(task_cleanroom_v6) / AutomationBench 1.0.6
agent：             mini-swe-agent v2.x（或 claude-code）
参数：              temperature / top_p / max_tokens / reasoning effort / max steps / timeout
子集：              题号列表或抽样种子（如 sample-seed 0, n=10）
结果：              pass rate（分子/分母）、P50 耗时、单题成本、总成本
失败模式：          例子 + 归类（编译失败/测试不过/超时/格式错/限流）
备注：              与官方数字的差异原因
```

## 9. 待核实项（TODO verify）

1. Pier 给 mini-swe-agent 注入 `api_base` 的确切字段（通过 `kwargs.config_yaml` 还是 `agent.env`，以 `pier run --help` 与实验配置为准）。
2. Harbor 的 `--api-format` 与 `--base-url` 对 mini-swe-agent 组合是否生效（官方文档示例主要给 claude-code）。
3. NL2Repo 的 `baseUrl` 是否要 `/v1` 后缀。
4. ProgramBench 自定义 config 文件的合并方式（`-c` 是整份替换还是覆盖；官方 default config 在 `minisweagent/config/benchmarks/programbench.yaml`）。
5. 各 provider API 的模型快照命名与限流参数（按实际网关填）。

## 10. 来源

- DeepSWE：<https://deepswe.datacurve.ai/run>、<https://github.com/datacurve-ai/deep-swe>、<https://github.com/datacurve-ai/pier>
- Terminal-Bench / Harbor：<https://www.tbench.ai/run>、<https://github.com/harbor-framework/terminal-bench>、<https://docs.harborframework.com>
- NL2Repo-Bench：<https://github.com/multimodal-art-projection/NL2RepoBench>、<https://arxiv.org/abs/2512.12730>
- ProgramBench：<https://programbench.com/>、<https://github.com/facebookresearch/ProgramBench>、<https://mini-swe-agent.com/latest/usage/programbench/>
- Automation-Bench：<https://github.com/zapier/AutomationBench>、<https://zapier.com/benchmarks>、<https://arxiv.org/abs/2604.18934>
- mini-swe-agent 自定义端点：<https://mini-swe-agent.com/latest/models/local_models/>、<https://mini-swe-agent.com/latest/advanced/global_configuration/>
- 模型卡与价格：<https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash-1017>、<https://api-docs.deepseek.com/quick_start/pricing>
