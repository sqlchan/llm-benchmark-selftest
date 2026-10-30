#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""合并 research/*/benchmarks.json + harnesses.json，校验后输出 report/all_benchmarks.json 与 report/benchmarks.csv。

用法: python scripts/merge_benchmarks.py
"""
import csv
import glob
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "report")
SOURCES = [
    "research/coding-agent/benchmarks.json",
    "research/reasoning-agent/benchmarks.json",
    "research/vision/benchmarks.json",
]
REQUIRED = [
    "id", "name", "category", "publisher", "data_access", "scoring",
    "requirements", "self_test", "sources", "confidence",
]

CSV_COLUMNS = [
    ("id", "id"),
    ("name", "名称"),
    ("name_zh", "中文名"),
    ("category", "类别"),
    ("publisher", "发布方"),
    ("release_date", "发布"),
    ("data_access.public", "数据公开"),
    ("data_access.size_tasks", "题量"),
    ("scoring.metric", "指标"),
    ("scoring.judge", "判分"),
    ("scoring.harness_official", "官方harness"),
    ("requirements.tool_use", "需工具"),
    ("requirements.code_exec", "需执行代码"),
    ("requirements.vision", "需视觉"),
    ("requirements.docker", "需Docker"),
    ("requirements.min_context_tokens", "最小上下文"),
    ("cost.usd_per_full_run", "整轮估价(USD)"),
    ("cost.wall_time_full_run", "整轮耗时"),
    ("self_test.feasibility", "自测可行性"),
    ("self_test.quick_smoke_subset", "快速子集"),
    ("homepage", "主页"),
    ("repo", "代码"),
    ("paper", "论文"),
    ("leaderboard", "榜单"),
]


def dig(obj, path):
    cur = obj
    for part in path.split("."):
        if not isinstance(cur, dict) or part not in cur:
            return ""
        cur = cur[part]
    return cur


def main():
    problems, merged = [], []
    seen = set()
    for rel in SOURCES:
        path = os.path.join(ROOT, rel)
        if not os.path.exists(path):
            problems.append(f"缺少文件: {rel}")
            continue
        try:
            with open(path, encoding="utf-8") as fh:
                items = json.load(fh)
        except Exception as exc:  # noqa: BLE001
            problems.append(f"{rel} JSON 解析失败: {exc}")
            continue
        if not isinstance(items, list):
            problems.append(f"{rel} 顶层不是数组")
            continue
        for item in items:
            bid = item.get("id", "<no-id>")
            missing = [k for k in REQUIRED if k not in item]
            if missing:
                problems.append(f"{rel}: {bid} 缺字段 {missing}")
            if bid in seen:
                problems.append(f"id 重复: {bid}")
            seen.add(bid)
            merged.append(item)

    harness_path = os.path.join(ROOT, "research/harness/harnesses.json")
    harnesses = []
    if os.path.exists(harness_path):
        try:
            with open(harness_path, encoding="utf-8") as fh:
                harnesses = json.load(fh)
        except Exception as exc:  # noqa: BLE001
            problems.append(f"harnesses.json 解析失败: {exc}")

    order = ["reasoning", "swe", "coding", "agent", "nl2code", "vision"]
    merged.sort(key=lambda b: (order.index(b.get("category", "zzz")) if b.get("category") in order else 99,
                               b.get("name", "")))

    os.makedirs(OUT_DIR, exist_ok=True)
    with open(os.path.join(OUT_DIR, "all_benchmarks.json"), "w", encoding="utf-8") as fh:
        json.dump(merged, fh, ensure_ascii=False, indent=2)
    with open(os.path.join(OUT_DIR, "harnesses.json"), "w", encoding="utf-8") as fh:
        json.dump(harnesses, fh, ensure_ascii=False, indent=2)

    csv_path = os.path.join(OUT_DIR, "benchmarks.csv")
    with open(csv_path, "w", encoding="utf-8-sig", newline="") as fh:
        writer = csv.writer(fh)
        writer.writerow([label for _, label in CSV_COLUMNS])
        for item in merged:
            writer.writerow([dig(item, key) for key, _ in CSV_COLUMNS])

    print(f"合并 {len(merged)} 个 benchmark, {len(harnesses)} 个 harness")
    if problems:
        print("存在问题:")
        for p in problems:
            print(" -", p)
        return 1
    print("校验通过: report/all_benchmarks.json, report/benchmarks.csv")
    return 0


if __name__ == "__main__":
    sys.exit(main())
