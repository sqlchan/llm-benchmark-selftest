#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""生成 report/benchmarks.xlsx（面向「自己测模型」的对比表）。

输入:
  report/all_benchmarks.json   (scripts/merge_benchmarks.py 产出)
  report/harnesses.json
  report/plan.json             (三档自测方案, 见文件末尾注释)
输出:
  report/benchmarks.xlsx
"""
import json
import os
import sys

from openpyxl import Workbook
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPORT = os.path.join(ROOT, "report")

HEADER_FILL = PatternFill("solid", fgColor="1F3864")
HEADER_FONT = Font(name="微软雅黑", size=10, bold=True, color="FFFFFF")
BODY_FONT = Font(name="微软雅黑", size=10)
TITLE_FONT = Font(name="微软雅黑", size=14, bold=True, color="1F3864")
THIN = Side(style="thin", color="BFBFBF")
BORDER = Border(left=THIN, right=THIN, top=THIN, bottom=THIN)
WRAP = Alignment(wrap_text=True, vertical="top")
CENTER = Alignment(horizontal="center", vertical="center", wrap_text=True)

FEAS_FILL = {
    "easy": PatternFill("solid", fgColor="C6EFCE"),
    "medium": PatternFill("solid", fgColor="FFEB9C"),
    "hard": PatternFill("solid", fgColor="FFC7CE"),
    "infeasible": PatternFill("solid", fgColor="D9D9D9"),
}


def load(name, default):
    path = os.path.join(REPORT, name)
    if not os.path.exists(path):
        return default
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def dig(obj, path, default=""):
    cur = obj
    for part in path.split("."):
        if not isinstance(cur, dict) or part not in cur:
            return default
        cur = cur[part]
    return cur


PUBLIC_ZH = {"yes": "公开", "partial": "部分公开", "no": "不公开"}


def yn(value):
    if value is True:
        return "✓"
    if value is False:
        return "—"
    return str(value) if value not in ("", None) else "?"


def style_header(ws, ncols, row=1):
    for col in range(1, ncols + 1):
        cell = ws.cell(row=row, column=col)
        cell.fill = HEADER_FILL
        cell.font = HEADER_FONT
        cell.alignment = CENTER
        cell.border = BORDER


def write_table(ws, headers, rows, widths=None, center_cols=()):
    ws.append(headers)
    style_header(ws, len(headers))
    for row in rows:
        ws.append(row)
    for r in range(2, ws.max_row + 1):
        for c in range(1, len(headers) + 1):
            cell = ws.cell(row=r, column=c)
            cell.font = BODY_FONT
            cell.border = BORDER
            cell.alignment = CENTER if c in center_cols else WRAP
    ws.freeze_panes = "B2"
    ws.auto_filter.ref = f"A1:{get_column_letter(len(headers))}{ws.max_row}"
    for idx, width in enumerate(widths or [], start=1):
        ws.column_dimensions[get_column_letter(idx)].width = width
    ws.row_dimensions[1].height = 30


def sheet_overview(wb, benches):
    ws = wb.active
    ws.title = "Benchmark 总览"
    headers = [
        "Benchmark", "中文名", "类别", "发布方", "发布", "数据公开", "题量",
        "指标", "判分方式", "官方 harness", "工具", "代码执行", "视觉", "Docker",
        "最小上下文", "整轮估价(USD)", "整轮耗时", "自测可行性", "快速子集",
        "主页", "代码", "论文", "榜单", "置信度",
    ]
    rows = []
    for b in benches:
        public = dig(b, "data_access.public")
        rows.append([
            b.get("name", ""), b.get("name_zh", ""), b.get("category", ""),
            b.get("publisher", ""), b.get("release_date", ""),
            PUBLIC_ZH.get(public, public), dig(b, "data_access.size_tasks"),
            dig(b, "scoring.metric"), dig(b, "scoring.judge"),
            dig(b, "scoring.harness_official"),
            yn(dig(b, "requirements.tool_use", "")),
            yn(dig(b, "requirements.code_exec", "")),
            yn(dig(b, "requirements.vision", "")),
            yn(dig(b, "requirements.docker", "")),
            dig(b, "requirements.min_context_tokens"),
            dig(b, "cost.usd_per_full_run"), dig(b, "cost.wall_time_full_run"),
            dig(b, "self_test.feasibility"), dig(b, "self_test.quick_smoke_subset"),
            b.get("homepage", ""), b.get("repo", ""), b.get("paper", ""),
            b.get("leaderboard", ""), b.get("confidence", ""),
        ])
    widths = [24, 14, 10, 16, 9, 9, 8, 14, 12, 26, 6, 8, 6, 7, 10, 16, 12, 11, 30,
              34, 34, 34, 30, 8]
    write_table(ws, headers, rows, widths, center_cols=set(range(3, 19)) | {24})
    for r in range(2, ws.max_row + 1):
        feas = ws.cell(row=r, column=18).value
        if feas in FEAS_FILL:
            ws.cell(row=r, column=18).fill = FEAS_FILL[feas]
    return ws


def sheet_harness(wb, harnesses):
    ws = wb.create_sheet("Harness 工具链")
    headers = ["名称", "类型", "支持的 Benchmark", "安装", "接口 / 用法", "核实状态", "链接"]
    rows = []
    for h in harnesses:
        supports = h.get("supports_benchmarks") or []
        if isinstance(supports, list):
            supports = "、".join(str(s) for s in supports)
        rows.append([
            h.get("name", ""), h.get("type", ""), supports,
            h.get("install", ""), h.get("interface", ""),
            h.get("verified", ""), h.get("url", ""),
        ])
    write_table(ws, headers, rows, [22, 16, 46, 44, 54, 12, 40], center_cols={6})


def sheet_plan(wb, plan):
    ws = wb.create_sheet("自测方案")
    ws["A1"] = "三档自测方案（按预算从低到高）"
    ws["A1"].font = TITLE_FONT
    ws.merge_cells("A1:F1")
    row = 3
    for tier in plan.get("tiers", []):
        ws.cell(row=row, column=1, value=f"{tier.get('name', '')}｜{tier.get('budget', '')}")
        ws.cell(row=row, column=1).font = Font(name="微软雅黑", size=11, bold=True, color="1F3864")
        row += 1
        headers = ["顺序", "Benchmark", "跑什么子集", "为什么", "预计耗时", "预计成本"]
        for c, h in enumerate(headers, start=1):
            cell = ws.cell(row=row, column=c, value=h)
            cell.fill = HEADER_FILL
            cell.font = HEADER_FONT
            cell.alignment = CENTER
            cell.border = BORDER
        row += 1
        for item in tier.get("items", []):
            for c, key in enumerate(["order", "benchmark", "subset", "reason", "time", "cost"], start=1):
                cell = ws.cell(row=row, column=c, value=item.get(key, ""))
                cell.font = BODY_FONT
                cell.alignment = WRAP if c in (2, 3, 4) else CENTER
                cell.border = BORDER
            row += 1
        row += 1
    widths = [6, 26, 40, 60, 18, 18]
    for idx, width in enumerate(widths, start=1):
        ws.column_dimensions[get_column_letter(idx)].width = width
    notes = plan.get("notes", "")
    if notes:
        row += 1
        ws.cell(row=row, column=1, value="备注").font = Font(name="微软雅黑", size=11, bold=True)
        row += 1
        cell = ws.cell(row=row, column=1, value=notes)
        cell.font = BODY_FONT
        cell.alignment = WRAP
        ws.merge_cells(start_row=row, start_column=1, end_row=row, end_column=6)
        ws.row_dimensions[row].height = 120
    return ws


def sheet_sources(wb, benches):
    ws = wb.create_sheet("数据来源")
    headers = ["Benchmark", "来源链接", "支撑内容"]
    rows = []
    for b in benches:
        for src in b.get("sources", []):
            rows.append([b.get("name", ""), src.get("url", ""), src.get("note", "")])
    write_table(ws, headers, rows, [26, 78, 60])


def main():
    benches = load("all_benchmarks.json", [])
    if not benches:
        print("没有数据: report/all_benchmarks.json 不存在或为空")
        return 1
    harnesses = load("harnesses.json", [])
    plan = load("plan.json", {"tiers": []})

    wb = Workbook()
    sheet_overview(wb, benches)
    sheet_harness(wb, harnesses)
    sheet_plan(wb, plan)
    sheet_sources(wb, benches)
    wb.properties.title = "DeepSeek V4.1 Flash 1017 基准自测指南"
    wb.properties.creator = "bench research"

    out = os.path.join(REPORT, "benchmarks.xlsx")
    wb.save(out)
    print(f"已生成 {out} ({len(benches)} 个 benchmark, {len(harnesses)} 个 harness)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
