# 杭州 Agent / LLM 评测工程师 · 岗位技能与要求资料库

> **归档副本**：本目录收录自私有仓库 [`sqlchan/hangzhou-agent-eval`](https://github.com/sqlchan/hangzhou-agent-eval)（commit `1932460`，2026-11-01）。
> 原仓库继续维护；本副本用于把「评测知识 + 本仓库实测资料」放在一起查阅。来源与收录差异见 [`PROVENANCE.md`](PROVENANCE.md)。
>
> 把杭州地区「Agent / LLM 评测工程师」相关岗位要求，整理成可复习、可执行、可持续更新的知识库。
>
> 数据来源：公开招聘信息收集（原始 JD 见 [`hangzhou_zhiweiyaoqiu.md`](hangzhou_zhiweiyaoqiu.md)）+ 各 Benchmark / 框架官方文档核验（截至 2026-11）。

## 📚 内容导航

| 文档 | 内容概要 | 什么时候看 |
|---|---|---|
| [技能与要求整理](杭州Agent评测工程师_技能与要求整理.md) | 5 类岗位画像、9+ 大能力模块、硬性要求与加分项、高频要求排行、能力自评清单、准备路径 | **先看这份**，建立全局认知 |
| [Benchmark 全景清单](杭州Agent评测工程师_Benchmark全景清单.md) | JD 点名 15 个必会 Benchmark（评什么/怎么评/局限）、按能力维度的扩展清单、榜单生态、必背 Top 10 | 准备面试、做选型 |
| [评测框架清单](杭州Agent评测工程师_评测框架清单.md) | 三层框架划分、4 个主推框架、公开框架推荐、两周上手路线、面试话术 | 动手搭建评测栈 |
| [深学清单：六大评测框架实战路径](深学清单_六大评测框架实战路径.md) | 6 组框架按 JD 对口度的学习顺序、动手步骤、验收标准、日程与面试话术 | 决定先学什么、怎么验收 |
| [四框架学习指南](四框架学习指南.md) | OpenCompass / SWE-bench / DeepEval / Langfuse 的定位、核心概念、三级学习任务、面试题、8 周日历与自测题库 | 系统学习这四个框架 |
| [学习手册：DeepEval 与 Langfuse](学习手册_DeepEval与Langfuse.md) | 两框架的详细学习步骤、代码示例、CI/实验闭环、7–10 天计划与自测清单 | 深入这两项工程化能力 |
| [源码深度解析：四框架原理与流程](源码深度解析_四框架原理与流程.md) | 基于真实源码（commit 级）的模块地图、执行流程、核心数据结构、扩展点、设计取舍与阅读路线 | 从"会用"到"读源码" |
| [执行手册 D1–D4](执行手册_D1-D4_OpenCompass与SWE-bench.md) | OpenCompass + SWE-bench 的逐条命令、预期输出、报错处理、时间盒与验收 | 动手时照着执行 |
| [执行手册 D5–D8](执行手册_D5-D8_Harbor与Langfuse.md) | Harbor/Terminal-Bench + Langfuse 的逐条命令、时间盒、报错与 D1–D8 打卡清单 | 动手时照着执行 |
| [星标收藏分析（评测）](星标收藏分析_评测.md) | 对 GitHub「评测」收藏夹 20 个项目的分类、覆盖度评估、取舍建议与缺口清单 | 盘家底、决定学什么 |
| [原始 JD 收集](hangzhou_zhiweiyaoqiu.md) | 21 段原始岗位描述（含招聘平台水印与重复片段，未清洗） | 溯源、核对原文 |

## 🚀 推荐阅读路径

- **求职速查（约 30 分钟）**：技能整理 → 「高频要求排行」+「硬性要求 vs 加分项」
- **面试冲刺（约 2 小时）**：Benchmark 全景清单 → 评测框架清单 → 两份文档里的面试题与话术
- **动手实践（约 2 周）**：评测框架清单「七、公开框架推荐」→ 按路线跑通 lm-evaluation-harness / Langfuse / SWE-bench harness

> 想直接跑本仓库已落地的离线工具包：看 [`report/eval-tools-offline-bundle.md`](../../report/eval-tools-offline-bundle.md)（DeepEval + Langfuse）与 [`report/opencompass-offline-bundle.md`](../../report/opencompass-offline-bundle.md)（OpenCompass）。

## 🗂 目录结构

```text
study/hangzhou-agent-eval/
├── README.md                                  # 本文件（仓库导航）
├── PROVENANCE.md                              # 来源、收录范围与差异说明
├── hangzhou_zhiweiyaoqiu.md                   # 原始 JD 收集（21 段）
├── 杭州Agent评测工程师_技能与要求整理.md         # 主文档：岗位画像 / 能力地图 / 要求
├── 杭州Agent评测工程师_Benchmark全景清单.md      # Benchmark 速查与面试必背
├── 杭州Agent评测工程师_评测框架清单.md          # 评测框架推荐与学习路线
├── 深学清单_六大评测框架实战路径.md             # 6 组框架的学习顺序与验收标准
├── 四框架学习指南.md                          # 四框架三级学习任务 + 面试题 + 8 周日历
├── 学习手册_DeepEval与Langfuse.md               # DeepEval/Langfuse 详细学习步骤 + 代码 + 计划
├── 源码深度解析_四框架原理与流程.md              # 基于 commit 级源码的架构/流程/扩展点解析
├── 执行手册_D1-D4_OpenCompass与SWE-bench.md     # D1–D4 逐条命令与报错处理
├── 执行手册_D5-D8_Harbor与Langfuse.md           # D5–D8 逐条命令 + D1–D8 打卡清单
└── 星标收藏分析_评测.md                        # GitHub「评测」收藏夹 20 个项目分析
```

## 🔄 来源与更新

- 原始仓库仍是**唯一维护源**：<https://github.com/sqlchan/hangzhou-agent-eval>（私有，更新用其自带的 `sync.ps1`）。
- 本目录是**归档副本**：需要更新时，从原仓库整篇复制并保持 LF 换行；不要只改副本，否则两边会漂移。
- 原仓库的 `sync.ps1` 未收录——它的 remote 指向原仓库，放进本仓库有误推风险。

## 📝 更新日志

| 日期 | 内容 |
|---|---|
| 2026-11-01 | 仓库初始化：上传原始 JD 收集 + 技能与要求整理 + Benchmark 全景清单 + 评测框架清单；新增仓库导航 README 与同步脚本 |
| 2026-11-01 | 新增《星标收藏分析（评测）》：GitHub「评测」收藏夹 20 个项目分类、覆盖度与缺口分析 |
| 2026-11-01 | 同步脚本升级：origin → SSH → HTTPS 双通道自动回退；origin 切换为 SSH |
| 2026-11-01 | 新增《深学清单：六大评测框架实战路径》（6 组框架学习顺序 + 验收标准 + 15 天日程） |
| 2026-11-01 | 新增《执行手册 D1–D4》（OpenCompass + SWE-bench 逐条命令、报错处理、时间盒与验收） |
| 2026-11-01 | 新增《执行手册 D5–D8》（Harbor/Terminal-Bench + Langfuse）及 D1–D8 每日打卡清单 |
| 2026-11-01 | 新增《四框架学习指南》（OpenCompass / SWE-bench / DeepEval / Langfuse 系统学习路径 + 8 周日历 + 20 题自测） |
| 2026-11-01 | 新增《学习手册：DeepEval 与 Langfuse》（详细步骤、代码示例、CI/实验闭环、7–10 天计划） |
| 2026-11-01 | 新增《源码深度解析：四框架原理与流程》（commit 级源码分析：架构、流程、核心结构、扩展点、阅读路线） |
| 2026-11-01 | 收录进 `llm-benchmark-selftest` 的 `study/hangzhou-agent-eval/`（归档副本，见 `PROVENANCE.md`） |

## ⚠️ 免责声明

- 本资料库为个人学习与求职准备用途，**不代表任何公司官方招聘要求**。
- JD 内容来自公开招聘渠道，存在重复片段、平台水印与时效性问题，请以原始岗位页面为准。
- Benchmark / 框架相关事实以官方文档为准（核验时间见各文档内标注），行业迭代较快，引用时请注明日期。
