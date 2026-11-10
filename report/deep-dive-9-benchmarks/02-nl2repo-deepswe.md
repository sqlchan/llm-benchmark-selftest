# 02 · NL2Repo-Bench 与 DeepSWE v1.1 深读

> 调研日期 2026-11-10。数字性质分三档标注：**[论文]**=基准方论文/仓库、**[厂商]**=模型卡自报、**[本地]**=本仓库实测。
> `unknown` = 检索后仍无可信来源；`unreachable` = 本网络打不开（已注明现象）。
> 本文件回答的核心问题在 §C：为什么论文分（DeepSWE GPT-5.5 70.0；NL2Repo Sonnet4.5 40.2）与 2026 厂商自报（77.0 / 68.2）差这么多。

---

# A. NL2Repo-Bench

## A1. 定位与能力坐标

给**一份自然语言需求文档 + 一个空工作区**，让 agent 从 0 到 1 写出可 `pip install` 的完整 Python 库，再用**上游仓库原始 pytest** 打分。
能力坐标：从零造仓库（阶梯最右端，与 Terminal-Bench 的"终端通办"、DeepSWE 的"仓库内修补"互补）。不给脚手架、不给函数签名、不给测试。

## A2. 出处与版本

| 项 | 值 | 来源 |
| --- | --- | --- |
| 论文 | 《NL2Repo-Bench: Towards Long-Horizon Repository Generation Evaluation of Coding Agents》arXiv:2512.12730 | <https://arxiv.org/abs/2512.12730> |
| 版本 | **v1 2025-12-14 / v2 2026-01-08，无更新版**（submission history 只有两条） | 同上 |
| 发布方 | ByteDance Seed + M-A-P + 2077AI + Humanlaya + 南大/北大/北邮/北航 | 论文首页 affiliation |
| 仓库 | <https://github.com/multimodal-art-projection/NL2RepoBench>（12 commits，**最后提交 2026-05-13**，无 release，193 stars） | 仓库 commits.atom / 页面 |
| 官方 harness | OpenHands 0.56 **headless batch**（`main.py` + `config.json`，python-on-whales 管容器，**仅支持本地 Docker**，多机需 NFS） | 仓库 readme.md（`raw.githubusercontent.com/.../main/readme.md`，HTTP 200） |
| 官方镜像 | `docker.all-hands.dev/all-hands-ai/openhands:0.56` + `runtime:0.56-nikolaik` | 同上；原域名现已 NXDOMAIN，本地改用 `ghcr.io/all-hands-ai/*` |

⚠️ 论文正文（arXiv HTML）页眉日期显示 "August 24, 2026"，与提交记录（2025-12 / 2026-01）不一致；**原因 unknown**，不改写上方版本结论。

## A3. 题源与构造

| 维度 | 事实 | 来源 |
| --- | --- | --- |
| 题量 | **104 题 / 9 类 Python 库**（Table 1：Web 开发 10、测试 13、工具库 11、系统工具 24 …合计 104） | [论文] Table 1 |
| 难度分层 | **Easy ≤1500 LOC = 26；Medium 1500–4000 = 46；Hard ≥4000 = 32** | [论文] Table 2 |
| 选题门槛 | ≥10 GitHub stars、必须带 pytest 套件且**官方版本能全绿**、300–120k LOC、三年内更新 | [论文] §3.1 |
| 规格生成 | **反向工程**：把代码库写成 4 节文档 —— Project Description / Support Information / API Usage Guide / Implementation Nodes，**平均 18,800 tokens** | [论文] §3 + Appendix C |
| 防不可解 | **AST 辅助标注 + 静态覆盖校验**：用 AST 抽取全部类/函数/签名，逐条核对"每个被测试调用的 API 都在文档里写清楚" | [论文] §3"Static Coverage Verification"（本地档案称"AST 覆盖检查"，核实成立） |
| 是否原创 | 题不是新造的，是**把真实库反向写成规格**；代码库本身公开，这是污染与"作弊可抄"的根源 | 同上 + 本地 §A8 |

## A4. 判分契约

| 项 | 内容 |
| --- | --- |
| 判分器 | 上游仓库**原始 pytest 套件**（藏在测试镜像 `/workspace/tests`，agent 看不到） |
| 单题分 | **Score = passed / total（平均通过率，0–100%）**；论文另报 **Pass@1 Count = 整库全绿的题数** |
| 整轮指标 | 104 题 Score 的宏平均；Pass@1 Count 单列（论文最强 5/104） |
| 采集失败处理 | 测试命令带 `--continue-on-collection-errors`：[本地] `test_commands.json` 原文 `["pip install -e .", "pytest --continue-on-collection-errors tests"]`；论文设计意图是"一个 import 错不把整题归零" |
| 假阳风险 | **有，且很大**：① agent 自写 tests 若未被删会被计入（[本地] 曾出现假 131/26，修 workspace 目录名后 26/26）；② pip/git clone 上游源码（见 A8） |
| 假阴风险 | 部分分口径本身抗"半成品"，但**文档反向工程的信息量远大于真实需求**，反过来也会掩盖"没真从零设计" |

三档分数不可混：**Score（平均通过率）不能与 SWE 类"解决率"相减**，Pass@1 Count 才是"解决率"。

## A5. 执行协议（官方）

| 项 | 值 |
| --- | --- |
| scaffold | OpenHands 0.56（CodeActAgent）+ Docker runtime 双镜像 |
| 下发指令 | 固定一句英文：「According to the start.md in the workspace, implement the entire project… comply with the `<API Usage Guide>` section…」 |
| 轮数上限 | 主实验**不设上限**（模板默认 `max_iterations=500`）；论文实测平均 **181.6 轮**（Sonnet4.5，max 394），DeepSeek-V3.2 254.3 轮（max 822），GPT-5 仅 78.4 轮 |
| 时限 | `unknown`（论文未给墙钟上限） |
| 联网 | 论文未显式禁网；但**必须禁 `pip download` / `git clone` 目标库**，否则等于给答案（Qwen 评测时这么禁；本地仅 system prompt 软禁） |
| 上下文 | 文档 18.8k tokens + 生成 10k–50k tokens + 180 轮累计 ~90k tokens 会话历史 → 论文结论是"顶配全是长上下文模型" |

## A6. 数据可得性与许可

- 题目与 harness 全公开（`test_files/` 104 个任务目录 + 每题一个 `ghcr.io/multimodal-art-projection/nl2repobench/<task>:1.0` 公共镜像）。
- **无 LICENSE 文件**（[论文/仓库] 仓库根目录列表无 LICENSE，GitHub API `license=null`）→ 严格说再分发/商用前需联系作者。
- 无官方排行榜（只有论文 Table 3）→ 任何"榜单口径"的说法对 NL2Repo 都不成立。

## A7. 成本与时长

| 项 | 值 | basis |
| --- | --- | --- |
| 单题墙钟 | ~31 分钟（120 轮） | [本地] light scaffold，`agent_elapsed_s=1875` |
| 单题 token | prompt 累计 **6.95M**（重复上下文）+ completion 153k | [本地] 同一条 trial 的 usage |
| 单题判分 | 20–30s + 一次 ~1GB 测试镜像 build（锁竞争下 2–10 分钟） | [本地] |
| 全量一轮 | 25 条串行 ≈13h / 并发 4 ≈3.5h；真正瓶颈是**执行时间**与 docker build 独占，不是网关配额（与 SWE 类相反） | [本地] 估算，basis=上述单题值外推 |
| 美元成本 | `unknown`（论文与仓库均未给；⚠️ 本地档案 `notes.md` 也写 unknown） | — |

## A8. 已知缺陷与争议

1. **抄源码作弊路径没有任何硬隔离**：agent 有 bash，`pip download <目标包>` / `git clone` 即可拿到参考实现。官方环境有外网，这个洞天然存在；[本地] 唯一完成的一条 trial 就是这么把 26/26 刷出来的（`unittest-parametrize`，轨迹里从内网 PyPI 拉了上游 sdist）。
2. **做题可"看测试"的敏感度极高**：论文 Table 8 实测，把全部测试用例给 agent：Sonnet4.5+Claude Code 从 **40.2% → 59.4%**，Pass@1 从 **3 → 18**，Hard 25.1→35.6。任何放了测试/放了上游仓库的 harness 都会得到高得多的分。
3. **轮数上限的敏感度只在下限段**：50→200 轮持续上升，**≥200 轮后饱和**（论文 §4.4.1）→ 把 `max_iterations` 设成 8/120 会低估，设成 500 不会高估。
4. **环境快照漂移**：[本地] `structlog` 的 gold（上游 main）只有 795/828=0.96，因为题目镜像基于 2025-08 快照 → **oracle 门禁不过的题必须标 `invalid_environment` 并剔出分母**。
5. **论文自身有数字不一致**：Table 3 里 DeepSeek-V3.2 = 27.6，但 Table 6 同一列写 22.2；结论段写 Sonnet4.5 "39.6%"而表里是 40.2。量级不影响结论，但引用要认表。
6. **无汇总脚本**：结果按随机 UUID 落 `result/<uuid>.json`，平均分要自己算。

## A9. 分数怎么读

**论文主表（[论文] Table 3，Overall Pass Rate % / Pass@1 Count，单次运行）**

| 模型/agent | Score | Pass@1 | Easy | Medium | Hard |
| --- | --- | --- | --- | --- | --- |
| Claude-Sonnet-4.5 + **Claude Code** | **40.2** | 3 | 51.8 | 44.5 | 25.1 |
| Claude-Sonnet-4.5 + **OpenHands** | 39.9 | 3 | 55.3 | 43.0 | 21.4 |
| Claude-Sonnet-4.5 + **Cursor** | 39.2 | 4 | 52.9 | 41.4 | 24.8 |
| Claude-Sonnet-4（OpenHands） | 37.0 | **5** | 53.1 | 41.3 | 16.1 |
| Gemini-3-pro（Cursor） | 34.2 | 3 | 44.9 | 40.9 | 16.8 |
| DeepSeek-V3.2（OpenHands） | 27.6 | 1 | 43.1 | 29.1 | 12.9 |
| Kimi-k2 / DeepSeek-V3.1 / GPT-5 / Qwen3-Instruct | 22.7 / 22.2 / 21.7 / 17.9 | 3/1/1/1 | — | — | — |

三种口径要分开：

| 口径 | 值 | 可比的边界 |
| --- | --- | --- |
| **论文（2026-01）** | 头部 40.2；Pass@1 全绿 3–5/104 | 唯一有公开表的来源；**没有官方榜** |
| **厂商自报（2026-11）** | NL2Repo-Bench 68.2（DS-1017；同表 Opus 5 **75.3**、DS-V4.1-Flash 65.4、K3 58.0、GLM-5.3 58.0、GPT-5.6 Sol 56.8） | 模型卡脚注**只写了 TB4 与 DeepSWE 的 harness，NL2Repo 的 harness/turns/k/子集均未说明** → 不可与论文表对齐 |
| **[本地] light scaffold** | markdownify（Easy，83 测试）：Qwen3.7-Plus **45/83=54.2%**、DeepSeek-Pro 44/83、DeepSeek-Flash 42/83，GLM-Flash/GLM-Pro/Qwen3.8-Max **0/83** | 自写 scaffold，**明确声明不可与公开榜比较**；只作"模型肯不肯写完整仓库"的定性证据 |

噪声：论文未报 CI；Pass@1 Count 在 104 题上只有个位数事件 → ±1 题就 ±1pp 的是 Score，不是 Count（Count 的波动是 0–5 这种量级）。[本地] 单题子集的方差更大，**不能拿 1 题说能力**。

## A10. 可信度与自测建议

- **机制可信度：中高**。判分是真测试、非 LLM judge；上游 pytest 是权威第三方资产；论文给了 AST 覆盖校验与两组消融。
- **数字可比性：低**。无排行榜、无 LICENSE、harness 各家不同、抄源码路径未堵。
- **评级：中**（机制干净，但生态欠缺：无榜、无许可、无汇总脚本）。
- **自测性价比**：只适合"1–3 题定生死"。先跑 **oracle 门禁**（gold workspace 要求 passed==total），选 `markdownify`（83/83 干净）或 `jsonlines`（27 测试，最小）；再跑 `aiofiles`（211）看中等规模。**必做**：判分容器禁 `pip download/git clone` 目标包，确认 `test_files.json` 里要删的路径被真删（否则 agent 自写 tests 会算分）。预期 1 题 = 30–60 分钟 + 一次 1GB 镜像。

---

# B. DeepSWE v1.1

## B1. 定位与能力坐标

在**真实开源仓库**里做**原创的、长程的**功能改动/修 bug，用**手写行为 verifier** 判分。
能力坐标：仓库内修补（与 SWE-bench Pro 同格），但针对 SWE 系两个结构性缺陷下药：① 题目会被背（挖公开 PR）；② 判分被继承测试绑死。

## B2. 出处与版本

| 项 | 值 | 来源 |
| --- | --- | --- |
| 论文 | 《DeepSWE: Measuring Frontier Coding Agents on Original, Long-Horizon Engineering Tasks》arXiv:2607.07946 | <https://arxiv.org/abs/2607.07946> |
| 版本 | 论文 **v1 2026-07-08**（仅一版）；基准 **v1.1 自 2026-06-14**（仓库 commit 时间线），仓库最新活动 2026-08-26 | abs 页 + `github.com/datacurve-ai/deep-swe/commits/main.atom` |
| 发布方 | Datacurve AI | 论文/仓库 |
| 仓库 / 数据 | <https://github.com/datacurve-ai/deep-swe>（113 个任务目录）；HF `datacurve/deep-swe` **gated=auto**（`huggingface.co/api/datasets/datacurve/deep-swe` 匿名返回 **200 元数据**，但 parquet/轨迹需登录同意条款；页面原文 "You need to agree to share your Hugging Face information to access this dataset"）；Harbor Hub `datacurve/deep-swe`（SPA，只有 `harbor run -d datacurve/deep-swe`，**无榜单数值**） | 我已实测上述三个入口 |
| 官方榜 | <https://deepswe.datacurve.ai/> —— **unreachable**（本网络 URL 过滤拦截，`web_fetch` 亦 `fetch failed`），故本文所有"官方榜"数值转引本地档案，标 [本地] | 实测 |
| 官方 harness | README 原文：*"All leaderboard scores were produced with Pier running mini-swe-agent on Modal"*；Pier 要求 `>0.3.0`（v1.1 起） | 仓库 README |

## B3. 题源与构造

| 维度 | 事实 | 来源 |
| --- | --- | --- |
| 题量 | **113 题 / 91 个活跃仓库 / 5 语言**（TypeScript、Go、Python、JavaScript、Rust；[本地] 档案细分 TS 35 / Go 34 / Python 34 / JS 5 / Rust 5） | [论文] §3.2 + [本地] |
| 是否原创 | **从零手写**，参考解**永不合并回上游**，题面与讨论不进公开语料 | [论文] §3.3 |
| 防污染 | 容器只带 **base commit 的 shallow clone**（无完整 `.git`，堵"从 git 历史捞 gold patch"）；每个仓库中位只贡献 1 题 | [论文] §3.3/§5.2 |
| 规模 | prompt 平均 **~2,000 字符**（约为 SWE-bench Pro 一半）；参考解改动行数是 Pro 的 **5.5×**、输出 token 约 **2×**（Pro 平均约 120 行/题 → DeepSWE 约 660 行）。[本地] 档案另有"约 668 行、跨约 7 文件"（转引官方站，本次未能核实） | [论文] §1/§3.1/§3.3 |
| 质量门 | 每个 verifier 作者侧跑 3 次，结果漂移即判 flaky 打回；v1.1 的导火索正是独立审计发现 4 道 gold patch 过不了自己的 verifier | [本地] 档案（转引博客） |

## B4. 判分契约（v1 vs v1.1）

| 维度 | v1（pin `c33fa70e`） | v1.1（pin `0b9fabbb`，当前默认） |
| --- | --- | --- |
| Harbor schema | 1.1 | **1.3**（兼容 1.1） |
| 判分信号 | 测试进程 exit code | **test node id 白名单**（f2p / p2p） |
| 验证容器 | 复用 agent 容器 | **全新 verifier 环境**（`environment_mode="separate"`、`no-network`） |
| 提交捕获 | `tests/test.sh` 抓 `model.patch` | **`[[verifier.collect]]`**：`git diff --binary <base> HEAD`（**300s** 超时） |
| reward | 二值 `reward.txt` | `reward.json`（binary）+ `ctrf.json` + `f2p/p2p/partial` 诊断 |
| agent 超时 | **9,000s**（论文口径） | **10,800s**（`task.toml`） |

来源：v1.1 契约逐条见第三方基建文档 [AgentCompass `deepswe.mdx`](https://raw.githubusercontent.com/open-compass/AgentCompass/main/docs/en/user_guide/modules/benchmarks/deepswe.mdx)（原文："All 113 tasks in the pinned v1.1 revision declare `verifier.collect`, with a 300-second command timeout and a 10800-second agent timeout"）；本地 `task.toml` 实例与之一致。

**判分规则（本地 `grader.py` 原文口径）**：缺席=失败（防删测试）、skipped=失败、同一测试多报告取最差、`reward=1` 当且仅当「f2p 非空 + 全 f2p 通过 + 零 p2p 失败」；`partial=(f2p_passed+p2p_passed)/(总数)` **只作诊断**。patch 为空或 apply 失败 → 0 分并记 `apply_failed`。此外 `test.sh` 只"记录不判负"两类作弊信号：改依赖清单/vendor/自加 `TestMain`、改动修复范围外目录。

## B5. 执行协议

| 项 | 官方 | [本地] 实际 |
| --- | --- | --- |
| scaffold | **mini-swe-agent**（论文 pin commit `adfe2023`，单一 bash 工具 + 共享 prompt，无 per-vendor 编辑原语）；官方榜用 **Pier + mini-swe-agent on Modal**；AgentCompass 复刻榜时用 `mini-swe-agent==2.4.2`（默认 2.4.5） | 自建 `LocalBashAgent`（ECR 镜像无 tmux，terminus-2 起不来） |
| 采样 | 论文：每配置每任务约 **4 次** rollout（428–452 条/配置，共 **7,174** 条），报 **pass@1 = 各题通过率的宏平均** 与 **pass@4** | 16 题 × 6 模型 = 96 条，单次 |
| 时限 | 论文 9,000s（仅 0.9% rollout 触顶）；v1.1 `task.toml` 10,800s | 5,400s + **60 步上限** |
| 步数上限 | 不设（论文明确"no step or cost cap"） | 60 步（官方平均 29–166 步） |
| 联网 | run 阶段与验证阶段均 `no-network`；只白名单模型端点 | 本机无外网，把 113 条 `allow_internet` 改成 true（等价） |
| 失败排除规则 | **基础设施/模型侧错误（provider error、verifier error、网络抖动）从分子分母同时剔除**，不重采样 | 早期把超时按 0 计 → 与论文口径相反 |

## B6. 数据可得性与许可

- 题目定义（`instruction.md` / `task.toml` / `tests/` / `solution/`）在 GitHub **公开**；镜像在 `public.ecr.aws`，需自己拉。
- HF 轨迹/parquet **gated(auto)**：元数据匿名可读，数据文件需登录同意（**匿名 401/需同意属预期，不是缺陷**）。
- 仓库 license：`unknown`（本次未取到 LICENSE 明文；商用前需确认）。

## B7. 成本与时长

| 项 | 值 | basis |
| --- | --- | --- |
| 单题美元 | **$0.24–$13.41**（模型间差 56×） | [本地] 档案转引官方站（该站本次 unreachable）→ **二手** |
| 全量 113 题 | **约 $27–$1,515** | 同上（二手） |
| 单题墙钟 | 官方无固定值；论文 2.5h 上限只有 0.9% 触顶；[本地] 单 trial ~7.6 分钟/16 题批 | [论文]/[本地] |
| 论文总算力 | 7,174 条 rollout × 16 配置体系 | [论文] §5.4 |

## B8. 已知缺陷与争议

1. **判分分歧率 1.4% 的分子只有 2 假阳 + 8 假阴（735 条审计）**，论文自述"这是分歧率，不是真值错误率"，且**单一 judge**（GPT-5.5 xhigh，跑成 Codex CLI agent，**能看隐藏参考解**），而 GPT-5.5 本身是被测模型之一 → 同源偏置不可排除。审计样本 = 每基准 30 题 × 9 配置 × 3 次；作者说"per-tag 低于数个百分点只作示意"。详见 §C4。
2. **单一 harness**：全部 mini-swe-agent；论文自认"绕开模型原生的 `apply_patch`/`str_replace` 编辑原语，可能把某些模型家族压在原生上限之下"。另有一处 comparability caveat：16 个配置的 reasoning effort 部分是显式设、部分是 provider 默认，**未做扫描**。
3. **binary reward 无部分分**：差一条要求与根本编译不过同分。
4. **[本地] 四类"环境假 0"**（不是模型失败）：`network_mode='no-network'` 不支持 → 改 `allow_internet`；脚本 CRLF（339 个）+ patch CRLF（449 个）→ 转 LF；**ECR 镜像无 tmux** → 换宿主侧 bash agent；聚合器把 job 名当任务名。全部修好后 **oracle 判 1.0、空 patch 判 0**，判别器双向正确。
5. **[本地] 六模型 96 条 trial 只解出 3 条**（Qwen3.8-Max 2/16=12.5%、DeepSeek-Pro 1/16=6.2%，其余 4 个 0/16）。对照实验显示 DeepSeek-Flash **`write_file` 调用 0 次、`model.patch` 0 字节**（能 grep 到相关代码、读懂了但不写），加"空 diff 拒收 + nudge"仍 0 次 → 归因于工具使用行为，不是判分 bug。**但这仍是本机口径下的下界**（60 步 vs 官方平均 29–166 步、scaffold 非官方），不可对官方榜。

## B9. 分数怎么读

| 口径 | 值 | 边界 |
| --- | --- | --- |
| **论文（2026-05 采集，16 配置）** | GPT-5.5 **70.0** [67.2,72.9]；GPT-5.4 55.5 [53.4,57.7]；Opus 4.7 54.2 [49.5,58.9]（后两者 CI 重叠，**统计上不可分**） | pass@1 = 约 4 次 rollout 的宏平均；同一套 mini-swe-agent；run-to-run CI |
| **厂商自报（2026-11，模型卡 77.0）** | DeepSWE v1.1：DS-1017 **77.0**、DS-V4.1-Flash 74.2、Opus 5 74.0、GPT-5.6 Sol 73.0、K3 67.5、GLM-5.3 66.9；harness = **Mini-SWE-V2**（技报定义为 mini-swe-agent commit `04d809ce` 的移植版） | 厂商表；各行子集/k 未披露 |
| **另一个厂商表（同期，横向转载）** | GPT5.6 Sol 73.0、Fable5 70.0、Opus4.8 **59.0**、Qwen3.8-Max 56.6 | 与上行"Opus 5 = 74.0"并存 → **两家厂商表之间本身就不能横比** |
| **[本地] 16 题子集** | Qwen3.8-Max 12.5%、DeepSeek-Pro 6.2%、其余 0% | 下界，非官方口径 |

噪声量级：论文 4 次 rollout 的 95% CI 约 ±2.8pp（GPT-5.5）；**单次全量 113 题的 Wilson 区间更宽（[65.6,74.1]）**；10 题子集完全不可用——论文自己举的例子是"4/10 的 95% Wilson 区间约 [17,69]%"。

## B10. 可信度与自测建议

- **机制可信度：高**。原创题 + shallow clone + 白名单 node id + 独立 verifier 容器 + 缺席即失败，是当前 SWE 类里最干净的判分设计之一；v1.1 是主动"因为 4 道 gold 挂了而改契约"的自我修正。
- **数字可信度：中高**。论文有 CI、有排除规则、审计样本全量发布；扣分项是**判官同源 + 单 harness + 官方榜只在自家站点**。
- **评级：高**（判分）/ 中（跨来源对齐）。
- **自测性价比**：**首选 DeepSWE 作唯一可负担的 SWE 类横评**。跑官方抽样 `--n-tasks 10 --sample-seed 0`（确定性、可复现），成本约 $2.4–$134/10 题；要出可比数就上全量 113 题。**必做**：① 先 `-a oracle` 门禁（reward 必须 1.0）② 用官方 `mini-swe-agent` + `task.toml` 的 10,800s，不要自己砍步数 ③ infra 失败必须剔出分母，不能按 0 分算。

---

# C. 核心问题：论文分 vs 2026 厂商自报，差在哪？

## C0. 先纠正一个前提

**这两组数都不是"同一模型"**，所以严格说不是"同一把尺子量出两个值"：

| 对比 | 论文侧 | 厂商侧 | 是否同模型 |
| --- | --- | --- | --- |
| DeepSWE | GPT-5.5 **70.0**（2026-05 采集） | DS-1017 **77.0**（2026-11 模型卡） | ❌ 不同模型（甚至不同厂商） |
| NL2Repo | Sonnet 4.5 **40.2**（2026-01） | DS-1017 **68.2** | ❌ 不同模型，差约 14 个月 |

因此正确的问法不是"谁错了"，而是：**这 7pp / 28pp 里，有多少能归到尺子（版本/scaffold/k/子集/判分），多少是模型本身？**

## C1. DeepSWE：7pp 里口径能解释的 ≤5pp，其余是模型

| 排除项 | 证据 | 对 70.0→77.0 的贡献 |
| --- | --- | --- |
| **版本** | 论文 HTML v1 全文**不含 "v1.1" 字样**；v1.1 是 2026-06-14 起的契约变更；官方重评口径 0.509→0.518（[本地]转引博客，**该博客 unreachable，二手**） | **≈ +0.9pp**（全榜） |
| **scaffold** | 论文全用 mini-swe-agent（pin `adfe2023`）；厂商用 Mini-SWE-V2（mini-swe-agent `04d809ce` 移植版）——**同源移植，不是换流派**。技报 Table 4 给出同模型换 harness：Claude Code 69.8 vs mini-SWE 74.2（[本地]转引，二手） | **≤ ~4.4pp**，方向还是 mini-SWE 更高 |
| **k / 采样** | 论文 pass@1 = 每题约 4 次 rollout 的宏平均（无偏估计，仅降方差）；官方榜 Pass@1 = 单次 | **≈ 0（点估计无偏）**，只影响噪声 |
| **子集** | 论文跑满 113 题；官方榜跑满 113；厂商行**未披露** | `unknown`，无法排除 |
| **判分口径** | 两边都是 f2p/p2p 白名单 + binary reward；论文已排除 infra 错误 | **≈ 0** |
| **预算** | 论文 9,000s（0.9% 触顶）；v1.1 10,800s | **< +1pp** |
| **模型** | GPT-5.5（2026-05）→ DS-1017（2026-11），跨厂商换代 | **剩余部分，最可能是主项** |

**判断**：DeepSWE 的 70.0 vs 77.0 **主要是"换了模型"，不是"换了尺子"**。可核查的口径项加起来 ≤5pp，且其中 harness 一项的方向还是对厂商有利（mini-SWE 系普遍高于原生 CLI）。真正不能核实的是厂商那一行的**子集与 k**——没有这两个数，77.0 只能当"厂商自报，v1.1 契约，Mini-SWE-V2 移植 harness"。

## C2. NL2Repo：28pp 里"测试可见"这一个开关就值 +19.2pp

| 排除项 | 证据 | 结论 |
| --- | --- | --- |
| **版本** | arXiv 无更新版（仅 v1/v2）；仓库 12 commits，**最后提交 2026-05-13**，readme 仍写 104 tasks，无 release | **≈ 0**，不是版本问题 |
| **指标口径** | 论文 Score = 平均通过率；若 68.2 被理解成 Pass@1 Count，则意味着 **71/104 个仓库全绿**，而论文最强只有 3–5/104（差一个量级） | **只能是 Score（平均通过率）**，同名同义，口径 ≈0 |
| **scaffold** | 论文自身给了同模型三 scaffold：Claude Code **40.2** / OpenHands **39.9** / Cursor **39.2** → 极差 **1.0pp** | **≈ 1pp**，不是主因 |
| **轮数上限** | 50→200 轮持续上升，**≥200 轮饱和**；论文主实验不设上限（均值 181.6 轮） | 只会让低预算 harness **低估**，不会高估 |
| **测试可见性** | 论文 Table 8 实测：给全部测试 → **40.2→59.4（+19.2pp）**，Pass@1 **3→18** | **唯一有实测支撑的大杠杆** |
| **模型代际** | Sonnet 4.5（2025-09）→ DS-1017（2026-11），且这是**未饱和**基准（论文头部 40%，不是 90%） | 合理且量级可能很大 |
| **harness / k / 子集** | 模型卡脚注只写了 TB4（Claude Code）与 DeepSWE（Mini-SWE-V2）的 harness，**NL2Repo 一行什么都没写** | **全部 `unknown`** |

另有一条结构性证据：厂商表 NL2Repo 整列（K3 58.0、GLM-5.3 58.0、GPT-5.6 Sol 56.8、DS-V4.1-Flash 65.4、DS-1017 68.2、Opus 5 75.3）**六个模型全部高出论文全表 20–35pp**。
单一旗舰上移可以解释成"模型变强"；**整列上移 20–35pp 更像尺子变了**。但注意：该列里没有一个模型出现在论文 2026-01 的表里，所以无法判定"整列上移"是模型代际还是 harness —— 这一条只能作为**可疑信号**，不能作为结论。

**判断**：NL2Repo 的 68.2 **不具备可比性**。28pp 里，能被论文实测解释的最大单项是「测试可见」（+19.2pp）；版本≈0、指标≈0、scaffold≈1pp、轮数只会低估。剩下的 8.8pp 必须是模型代际 + 未披露的 harness/k/子集三者之和。**引用时必须写："厂商自报、harness 未披露、与论文 40.2 不同代不同模型，不可相减。"**

## C3. 一句话对照

| | DeepSWE | NL2Repo |
| --- | --- | --- |
| 差距 | 70.0 → 77.0（+7.0） | 40.2 → 68.2（+28.0） |
| 口径能解释 | ≤5pp，且主要由"换模型"占掉 | 版本/指标/scaffold 全部≈0；最大实测杠杆「测试可见」+19.2pp |
| 判断 | **尺子基本没变，换了模型** | **尺子可能变了，但变了什么没有披露** |
| 最该追问厂商的 | 子集（是否 113 全量）、k、Mini-SWE-V2 与官方 Pier 配置的差异 | **harness 是什么、轮数上限、是否放测试、k、子集** |

## C4. 判分分歧率 1.4% vs 32.4%：能引用什么，不能引用什么

**事实（[论文] §3.4 + §7，原文核对）**：独立 LLM judge 重审已判分 rollout —— DeepSWE **735 条里 2 假阳 + 8 假阴 = 1.4%**，Clopper–Pearson 95% CI **[0.7%, 2.5%]**；SWE-bench Pro **789 条里 67 假阳 + 189 假阴 = 32.4%**，CI **[29.2%, 35.8%]**。两区间相距很远，这一点成立。

**不能当成"真值错误率"的四条理由**：

1. **分子太小**：1.4% 建立在 **2 和 8 两个事件**上，论文自己写 "rest on single-digit event counts"、"individual rates carry wide uncertainty"，per-tag 低于数个百分点"只作示意"。CI 下界 0.7% 意味着真实值可能只有观测值的一半。
2. **审计是单一 judge**：判官 = **GPT-5.5 xhigh，跑成 Codex CLI agent**，**能看到隐藏参考解**，而 GPT-5.5 本身在 16 个被测配置里且排第一 → 判官与被测同源，"分歧率低"可能是判官与 verifier 的**共识**而非真值。
3. **样本与范围有限**：每基准 **30 题 × 9 配置 × 3 rollout**（每模型至多 ~90 条），只覆盖 9/16 个配置；作者明确"不能把小差异当显著"。
4. **不是独立第三方**：verifier 作者与审计设计者同一批人；SWE-bench Pro 侧还是本论文自建轨迹自跑 verifier。**目前没有第二家机构复现这组分歧率**。

**正确引用句式**：「在作者自建的 LLM-judge 审计里，DeepSWE 的功能 verifier 与判官的分歧率比 SWE-bench Pro 的继承测试低一个量级（1.4% vs 32.4%，n=735/789，单一判官、作者自审）；这支持'功能 verifier 比继承测试更不依赖实现细节'，**不支持**'SWE-bench Pro 有 32.4% 判错'。」

---

## 附：本次未能核实（unknown / unreachable）

| 项 | 状态 |
| --- | --- |
| `deepswe.datacurve.ai` 官方榜数值与 v1.1 博客 | **unreachable**（本网络 URL 过滤 + `web_fetch fetch failed`）→ 文中官方榜数字均转引本地档案，标二手 |
| HF `datacurve/deep-swe` 轨迹数据 | **gated**：元数据匿名 200，数据文件需同意条款，未下载 |
| DS-1017 在 DeepSWE/NL2Repo 的具体子集、k、NL2Repo harness | **unknown**（模型卡与技报均未给 NL2Repo 设置） |
| DeepSWE 仓库 LICENSE | **unknown**（未取到明文） |
| NL2Repo 单题美元成本 | **unknown**（论文/仓库/本地档案均无） |
| DeepSWE 官方站 "$0.24–$13.41/题" 原始出处 | 二手（本地档案转引，源站不可达） |
