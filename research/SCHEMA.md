# 调研字段规范（v1，2026-10-30）

目标：为「自己测试模型」整理每个 benchmark 的可操作信息。**只写能核实的来源；不确定就标 unknown 并说明**。禁止编造 URL、命令、数字、日期。

## 每个 benchmark 必须填写（JSON，键名固定，供脚本合并）

```json
{
  "id": "kebab-case-id",
  "name": "Official Name (version)",
  "name_zh": "中文名/惯用叫法",
  "category": "reasoning | swe | coding | agent | nl2code | vision",
  "publisher": "发布机构",
  "release_date": "YYYY-MM / unknown",
  "homepage": "https://...",
  "paper": "arXiv/PDF URL 或 unknown",
  "repo": "GitHub/官方代码 URL 或 unknown",
  "leaderboard": "榜单 URL 或 none",
  "data_access": {
    "public": "yes | partial | no",
    "url": "数据/HF dataset/下载入口",
    "license": "许可证或 unknown",
    "size_tasks": 0,
    "size_note": "题量/子集说明（如 500 题、5 个领域）"
  },
  "what_it_tests": "测什么能力，2-4 句",
  "task_example": "一道题的输入/预期输出形态（可简述）",
  "scoring": {
    "metric": "准确率 / Pass@1 / resolve rate / Pass@5 / Elo ...",
    "judge": "exact-match | unit-tests | LLM-judge | human | unknown",
    "harness_official": "官方评测框架/命令入口",
    "alt_harnesses": ["可替代框架"],
    "pass_criteria": "判分规则一句话"
  },
  "requirements": {
    "tool_use": true,
    "code_exec": true,
    "vision": false,
    "docker": false,
    "gpu_required": false,
    "min_context_tokens": "unknown",
    "model_iface": "OpenAI 兼容 API / chat template / 自定义协议"
  },
  "cost": {
    "tokens_per_task": "粗估或 unknown",
    "usd_per_full_run": "粗估或 unknown",
    "wall_time_full_run": "粗估或 unknown",
    "basis": "估算依据（题量×单价×重试次数等）"
  },
  "self_test": {
    "feasibility": "easy | medium | hard | infeasible(仅榜单/无数据)",
    "quick_smoke_subset": "最小可跑子集（如 50 题抽样）",
    "setup_commands": ["可直接复制执行的命令，已验证才写"],
    "gotchas": "踩坑点：依赖、版本、并发、判分模型、费用"
  },
  "sources": [{"url": "https://...", "note": "这里支持哪个字段"}],
  "confidence": "high | medium | low（对数据/结论的把握）"
}
```

## 额外要求

1. `sources` 至少 1 条，且必须是你真正打开过的页面；读不到的写 `unreachable`。
2. `setup_commands` 里凡涉及具体 repo/包名/路径的，先核实存在；不确定就写 `# TODO verify`。
3. 中文 `notes.md`：给非专家看的 1-2 段说明 + 该 benchmark 适不适合「个人 1-2 张卡 / 有 API 预算」自测的判断。
4. 时间基准：2026-10-30。版本号以检索到的官方最新为准，注明检索到的版本。
