# 五个基准全量题面中文翻译

> 本目录是**全量**逐题翻译：`report/model-eval/` 里 5 个代码/Agent 基准的每一道题（`report/model-eval/zh/` 下的 5 份分册是导读版，只逐题翻译了原文收录的 33 道题例）。
> 题面全部来自**官方公开源**，按版本锁定（见 §1）。不附英文原文以控制体积；需要核对时按题名去 §1 的仓库/路径查 `instruction.md` / `start.md`。
> 翻译规则：中文正文；基准名、指标名、harness 名、API/函数/字段名、命令、路径、邮箱、金额、日期、阈值保持英文原样；不编造、不省略技术细节。

## 1. 来源与版本锁定

| 基准 | 官方源 | commit | 题数 | 题面文件 |
| :-- | :-- | :-- | --: | :-- |
| Terminal-Bench 4.0 | `harbor-framework/terminal-bench` | `4031b48384a5946ba2c5b3c5fa59246ce8d47d92` | **66** | `tasks/<id>/instruction.md` |
| DeepSWE v1.1 | `datacurve-ai/deep-swe` | `0b9fabbb63b9104d678fe965e1632f2dd9eaa2ea` | **113** | `tasks/<id>/instruction.md` |
| NL2Repo-Bench | `multimodal-art-projection/NL2RepoBench` | `781a1da1ee41fb8edb0bed22f586d69111610edf` | **104** | `test_files/<id>/start.md` 的「Natural Language Instruction」段 |
| ProgramBench | `facebookresearch/ProgramBench` + HF `ProgramBench-Tests` | `895f65916bc5ba34a915d36da321fde0301125ad` | **200** | ⚠️ 无自然语言题面（二进制 + 文档） |
| Automation-Bench v1.0.6 | `zapier/AutomationBench` | `4a8e1061254004d9dac807054eed33fad7d1ff14` | **806** | `automationbench/domains/<domain>/tasks.py` 的 user prompt |

> Automation-Bench 的题数：6 个计分域（finance/hr/marketing/operations/sales/support）各 100 条，其中 **sales 上游实际有 106 条**；再加 `simple` 200 条（不计分），合计 **806** 条。官方文档写「公开 600 题」，与上游代码的 606 条有 6 条差异（sales 域多 6 题），本目录按上游代码全量翻译并在 `05-automation/README.md` 标注。
> ProgramBench 的 200 个实例没有「一段英文题面」——模型拿到的是二进制 + 文档，详见 [`04-programbench/README.md`](04-programbench/README.md)。

## 2. 目录与题数

| 目录 | 内容 | 题数 |
| :-- | :-- | --: |
| [`01-terminal-bench-4/`](01-terminal-bench-4/README.md) | 4 个 part（17/17/17/15） | 66 |
| [`02-deepswe/`](02-deepswe/README.md) | 15 个 part | 113 |
| [`03-nl2repo/`](03-nl2repo/README.md) | 18 个 part | 104 |
| [`04-programbench/`](04-programbench/README.md) | 200 实例中文索引 + 无题面说明 | 200 |
| [`05-automation/`](05-automation/README.md) | 7 个域文件（finance/hr/marketing/operations/sales/simple/support）+ 全量索引 | 806 |

每个目录下有 `README.md` 索引（题号 → 任务 id → 所在文件），可直接按题号跳转。

## 3. 与 `report/model-eval/zh/` 导读版的关系

| | 导读版（`zh/00-总览.md` + `01–05 分册`） | 全量版（本目录） |
| :-- | :-- | :-- |
| 目标 | 讲清「测什么、怎么测、分数怎么算」 | 把每一道题面译成中文 |
| 题面覆盖 | 原文收录的 33 道题例（英文原文 + 中文翻译 + 判分点） | 66 + 113 + 104 + 806 = **1089 道题面**（ProgramBench 200 实例无题面） |
| 来源 | 仓库内原文件（`bench-bundle` 转录） | 官方仓库 @ 固定 commit |

## 4. 口径提醒

- 三个语言题面基准（TB4/DeepSWE/NL2Repo）与 Automation 的题面翻译只解决「看得懂题」，**不改变任何判分口径**：版本、harness、scaffold、采样、子集仍然必须锁死（见 [`../00-总览.md`](../00-总览.md) 第 4 节）。
- Automation 官方榜用**私有 held-out 集**；这里译的是公开集，只能出 public-set 结果。
- ProgramBench 的题面/文档随镜像分发，本目录只给实例索引；要读文档请进 cleanroom 容器或上游仓库。
- 题目里出现的所有 `# TODO verify` / `unknown` 类不确定项在翻译中保持原样，不做「修正」。

## 5. 校验

- 题数：66 / 113 / 104 / 200 / 806，与 §1 的来源逐一对齐；各目录 `README.md` 索引的「缺失」计数为 0。
- 编号：TB4 1–66、DeepSWE 1–113、NL2Repo 1–104、Automation 按域 1–100（sales 1–106）/simple 1–200，连续无重复。
- 编码：UTF-8（无 BOM）、LF 换行。
