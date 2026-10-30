#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""从合并后的 JSON 生成 report/runbook.md（每个基准的复现命令清单）。

用法: python scripts/render_runbook.py
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPORT = os.path.join(ROOT, "report")

PUBLIC_ZH = {"yes": "公开", "partial": "部分公开", "no": "不公开"}

CATEGORY_ORDER = [
    ("reasoning", "通用推理"),
    ("swe", "代码修复（SWE）"),
    ("coding", "代码生成"),
    ("nl2code", "自然语言 → 代码/仓库"),
    ("agent", "Agent / 自动化"),
    ("vision", "多模态视觉"),
]


def dig(obj, path, default="unknown"):
    cur = obj
    for part in path.split("."):
        if not isinstance(cur, dict) or part not in cur:
            return default
        cur = cur[part]
    return cur


def main():
    with open(os.path.join(REPORT, "all_benchmarks.json"), encoding="utf-8") as fh:
        benches = json.load(fh)
    with open(os.path.join(REPORT, "harnesses.json"), encoding="utf-8") as fh:
        harnesses = json.load(fh)

    lines = []
    lines.append("# 复现命令清单（Runbook）\n")
    lines.append("> 自动生成自 `report/all_benchmarks.json`。所有命令来自调研阶段核实的官方文档，"
                 "**均未在本机实际执行**，涉及具体 provider/model slug 的命令请先小样本试跑。\n")
    lines.append("> 通用前提：Harbor / Pier / ALE 需要 Python ≥ 3.12（用 `uv tool install` 隔离）；"
                 "Docker 需运行中；模型侧建议使用 OpenAI 兼容端点或 Anthropic Messages 端点。\n")

    for cat, label in CATEGORY_ORDER:
        items = [b for b in benches if b.get("category") == cat]
        if not items:
            continue
        lines.append(f"\n## {label}\n")
        for b in items:
            lines.append(f"### {b['name']}\n")
            lines.append(f"- **测什么**：{b.get('what_it_tests', '')}")
            public = dig(b, "data_access.public")
            lines.append(f"- **数据**：{PUBLIC_ZH.get(public, public)}；"
                         f"题量 {dig(b, 'data_access.size_tasks')}；"
                         f"许可 {dig(b, 'data_access.license')}")
            lines.append(f"- **数据入口**：{dig(b, 'data_access.url')}")
            lines.append(f"- **指标/判分**：{dig(b, 'scoring.metric')}；judge={dig(b, 'scoring.judge')}")
            lines.append(f"- **官方 harness**：{dig(b, 'scoring.harness_official')}")
            lines.append(f"- **自测难度**：{dig(b, 'self_test.feasibility')}；"
                         f"快速子集：{dig(b, 'self_test.quick_smoke_subset')}")
            cost = str(dig(b, "cost.usd_per_full_run")).rstrip("。；; ")
            lines.append(f"- **整轮成本**：{cost}；"
                         f"耗时：{dig(b, 'cost.wall_time_full_run')}")
            lines.append("\n命令：\n")
            lines.append("```bash")
            for cmd in dig(b, "self_test.setup_commands", []) or []:
                lines.append(cmd)
            lines.append("```")
            lines.append(f"\n坑：{dig(b, 'self_test.gotchas')}\n")
            srcs = b.get("sources", [])
            lines.append("官方来源：")
            for s in srcs[:6]:
                lines.append(f"- <{s.get('url', '')}>")
            lines.append("")

    lines.append("\n## 框架与工具链\n")
    lines.append("| 名称 | 类型 | 支持基准 | 安装 | 接口 | 已核实 | 链接 |")
    lines.append("|---|---|---|---|---|---|---|")
    for h in harnesses:
        supports = h.get("supports_benchmarks") or []
        if isinstance(supports, list):
            supports = "、".join(str(s) for s in supports)
        cells = [
            h.get("name", ""), h.get("type", ""), supports,
            h.get("install", ""), h.get("interface", ""),
            h.get("verified", ""), h.get("url", ""),
        ]
        cells = [str(c).replace("|", "\\|").replace("\n", " ") for c in cells]
        lines.append("| " + " | ".join(cells) + " |")

    out = os.path.join(REPORT, "runbook.md")
    with open(out, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")
    print(f"已生成 {out}：{len(benches)} 个基准, {len(harnesses)} 个框架")
    return 0


if __name__ == "__main__":
    sys.exit(main())
