# 学习资料（study/）

> 本目录收录**评测框架与方法论**的学习资料，属于个人整理，**不属于**模型卡 11 个基准，也不参与 `research/` → `report/` 的生成链。
> 目前只有一个来源：[`hangzhou-agent-eval/`](hangzhou-agent-eval/README.md)（自私有仓库 `sqlchan/hangzhou-agent-eval` 归档）。

## 1. 这里有什么

| 主题 | 文档 | 适合 |
| :-- | :-- | :-- |
| 岗位与能力地图 | [技能与要求整理](hangzhou-agent-eval/杭州Agent评测工程师_技能与要求整理.md) | 先建立全局认知 |
| Benchmark 清单 | [Benchmark 全景清单](hangzhou-agent-eval/杭州Agent评测工程师_Benchmark全景清单.md) | 快速过一遍业界基准 |
| 框架选型 | [评测框架清单](hangzhou-agent-eval/杭州Agent评测工程师_评测框架清单.md) | 决定搭哪套栈 |
| 学习路线 | [深学清单：六大评测框架实战路径](hangzhou-agent-eval/深学清单_六大评测框架实战路径.md) | 排学习顺序 |
| 四框架系统学 | [四框架学习指南](hangzhou-agent-eval/四框架学习指南.md) | OpenCompass / SWE-bench / DeepEval / Langfuse |
| 工程化细节 | [学习手册：DeepEval 与 Langfuse](hangzhou-agent-eval/学习手册_DeepEval与Langfuse.md) | CI 回归与观测落地 |
| 源码级理解 | [源码深度解析：四框架原理与流程](hangzhou-agent-eval/源码深度解析_四框架原理与流程.md) | 读源码、看扩展点 |
| 动手执行 | [执行手册 D1–D4](hangzhou-agent-eval/执行手册_D1-D4_OpenCompass与SWE-bench.md) / [D5–D8](hangzhou-agent-eval/执行手册_D5-D8_Harbor与Langfuse.md) | 逐条命令照做 |
| 求职向 | [原始 JD 收集](hangzhou-agent-eval/hangzhou_zhiweiyaoqiu.md)、[星标收藏分析](hangzhou-agent-eval/星标收藏分析_评测.md) | 溯源与盘点 |

## 2. 和 report/ 怎么配合

| 你想做的事 | 看哪里 |
| :-- | :-- |
| 直接**跑起来**（离线包、命令、验证） | [`report/eval-toolchain-offline.md`](../report/eval-toolchain-offline.md)、[`report/eval-tools-offline-bundle.md`](../report/eval-tools-offline-bundle.md)、[`report/opencompass-offline-bundle.md`](../report/opencompass-offline-bundle.md) |
| **系统学**框架原理与路径 | 本目录（尤其四框架学习指南、源码深度解析） |
| **选型结论**与口径 | [`report/benchmark-guide.md`](../report/benchmark-guide.md)、[`report/api-only-5bench-plan.md`](../report/api-only-5bench-plan.md) |
| 面试/岗位要求 | 本目录的「技能与要求整理」「Benchmark 全景清单」 |

## 3. 注意事项

- 内容为个人学习与求职准备资料，**不代表任何公司官方要求**；JD 来自公开招聘渠道，含平台水印与重复片段。
- 本目录是**归档副本**，源仓库仍是唯一维护源；更新请整篇替换，避免漂移（见 [PROVENANCE](hangzhou-agent-eval/PROVENANCE.md)）。
- 本仓库为公开仓库，收录内容对外可见。
- 与 11 基准的关系：只作背景与方法论参考，**不改变** `research/*.json`、`report/plan.json` 与生成物。
