# AGENTS.md

本文件面向在 **llm-benchmark-selftest** 仓库中工作的 AI Agent（也适用于人类维护者）。目标：任何新改动都不破坏「结论可追溯、数据可复现、口径不混淆」这三条底线。

---

## 1. 仓库是什么

DeepSeek-V4.1-Flash-1017 模型卡上 **11 个 LLM 基准**的自测资料包：官方来源、数据可得性、判分协议、复现命令、成本估算与踩坑。

- 主报告：`report/benchmark-guide.md`（面向读者）
- 机读数据：`report/all_benchmarks.json`（由 `research/` 合并生成）
- 交付表格：`report/benchmarks.xlsx`（总览 / Harness / 自测方案 / 数据来源 4 sheet）
- 命令清单：`report/runbook.md`（由数据自动生成）
- 证据源：`research/`（调研原始产出，**不是**生成物）

## 2. 数据流（改数据必须按这个方向）

```
research/coding-agent/benchmarks.json
research/reasoning-agent/benchmarks.json      ──┐
research/vision/benchmarks.json                 ├─► scripts/merge_benchmarks.py
research/harness/harnesses.json               ──┘        │
                                                          ├─► report/all_benchmarks.json
                                                          ├─► report/benchmarks.csv
                                                          └─► report/harnesses.json
                                                                   │
report/plan.json（人工维护的三档方案）────────────────────────────┤
                                                                   ├─► scripts/render_runbook.py → report/runbook.md
                                                                   └─► scripts/make_xlsx.py      → report/benchmarks.xlsx
```

规则：
1. **`report/` 下的生成物不要手改**（`benchmark-guide.md` 与 `plan.json` 除外）。改 `research/*.json` 或 `plan.json` 后重新生成。
2. 字段规范以 `research/SCHEMA.md` 为准，键名必须完全一致；`scripts/merge_benchmarks.py` 会校验必填字段（`id/name/category/publisher/data_access/scoring/requirements/self_test/sources/confidence`）并在缺字段、id 重复、JSON 非法时返回非 0。
3. `report/plan.json` 是三档自测方案的唯一人工来源，`make_xlsx.py` 直接读取；改方案只改这里。

## 3. 常用命令

```bash
# 依赖：Python 3.11+，生成 xlsx 需要 openpyxl
pip install openpyxl

# 全量重建（顺序固定）
python scripts/merge_benchmarks.py   # 校验 + 合并 → report/all_benchmarks.json / benchmarks.csv / harnesses.json
python scripts/render_runbook.py     # → report/runbook.md
python scripts/make_xlsx.py          # → report/benchmarks.xlsx

# 单独校验 JSON 合法性
python -c "import json;d=json.load(open('report/all_benchmarks.json',encoding='utf-8'));print(len(d))"
```

重建后必须检查：11 个 benchmark、20 个 harness、`report/benchmarks.xlsx` 可被 openpyxl 重新打开且 4 个 sheet 齐全。

## 4. 事实与证据规则（最高优先级）

- **每条事实都要有可打开的来源**：`sources[]` 至少 1 条；打不开的页面写 `unreachable` 并说明；`# TODO verify` 保留原样，不要为了「好看」删掉。
- **禁止编造**：URL、版本号、题量、金额、命令一律不得臆测。查不到写 `unknown` 并说明检索过程。
- **区分数字性质**：厂商自报（模型卡）／第三方复现（如 Epoch 复核）／官方榜（no-tools、私有 held-out）。写进报告时必须标注，不得混用。
- **口径优先于数字**：引用分数前先确认「数据集版本 + harness + agent/scaffold + judge + 采样 + tools/no-tools」。已知必须保留的警告：视觉三项的 `w/tools` 与官方 no-tools 不可比；HLE 42.6（全集）vs 44.0†（纯文本 2,158 题）；Automation-Bench 公开集 vs 官方私有 held-out 集。
- **成本是估算**：必须保留 `cost.basis` 里的假设与价格日期（DeepSeek 官方价，2026-10-30）；不要把估算写成报价。
- **命令未实测**：`runbook` 中的命令来自官方文档但未在本机执行，`setup_commands` 里的 `# TODO verify` 必须保留，除非你实际跑通并更新状态。

## 5. 修改任务速查

### 5.1 更新某个基准的信息
1. 打开该基准官方页面核实（日期以 `date` 或文中标注为准）。
2. 只改对应 `research/<组>/benchmarks.json` 的字段，并在 `sources` 增补新来源。
3. 若题量/指标/成本变化，同步检查 `report/plan.json` 是否有引用（三档方案中的题量、预估时间）。
4. 跑第 3 节三条命令，`git diff` 确认只改了预期内容。
5. 更新 `report/benchmark-guide.md` 中对应的正文段落（它不在自动生成范围内）。

### 5.2 新增一个基准
1. 在 `research/SCHEMA.md` 规定的字段下补全对象（含 `sources`、`confidence`）。
2. 放入正确的组文件（`coding-agent` / `reasoning-agent` / `vision`），id 用 kebab-case 且全局唯一。
3. 如有官方 harness，追加到 `research/harness/harnesses.json`。
4. 重建；在 `report/benchmark-guide.md` 第 1、2、3、11 节补条目；必要时更新 `report/plan.json`。

### 5.3 只改文档/措辞
直接改 `report/benchmark-guide.md`、`README.md`；若涉及数字，仍要回到 `research/` 核对，不要只改一处。

## 6. 风格约定

- 正文用**中文**；基准名、指标名、协议名保留英文原文（如 no-tools、Pass@5、Harness）。
- 表格优先于长段落；每个基准至少覆盖：测什么 / 数据与许可 / 指标与判分 / 官方 harness / 成本 / 坑 / 建议。
- 难度用 `easy | medium | hard | infeasible`，与 schema 一致，不要自造分级。
- 文件编码 UTF-8、换行 LF（`.gitattributes` 已配置）；二进制（png/webp/xlsx）不做文本转换。
- 不要重命名被 `README.md`、报告链接引用的文件；若必须重命名，同步更新所有引用。

## 7. Git 约定

- 提交前必须跑第 3 节全量重建 + 校验，且 `git status` 无未预期文件。
- 提交信息用 `<type>: <描述>`：`data:`（数据更新）、`docs:`（文档）、`fix:`（修正）、`chore:`（脚本/配置）；一次提交只做一类事。
- 不提交：API key / token、临时文件（`_*.txt`、`.tmp_*`）、`__pycache__`（`.gitignore` 已覆盖）。
- 不 force-push `main`；仓库默认分支就是 `main`。

## 8. 完成标准（checklist）

- [ ] `merge_benchmarks.py` 退出码 0，无缺字段/id 重复告警
- [ ] 11 个基准、20 个 harness 数量未意外变化
- [ ] `report/benchmarks.xlsx` 能用 openpyxl 打开，4 个 sheet、11 行总览
- [ ] 新增/变更的数字都能在 `sources` 找到对应链接
- [ ] `report/benchmark-guide.md` 与生成物一致，未残留旧数字
- [ ] `git diff` 只包含本次预期改动，提交信息符合第 7 节

## 9. 不要做的事

- ❌ 手改 `report/all_benchmarks.json`、`report/benchmarks.csv`、`report/harnesses.json`、`report/runbook.md`、`report/benchmarks.xlsx`（会被下次重建覆盖）。
- ❌ 删除 `research/*/notes.md` 或 `sources/` 里的证据存档。
- ❌ 把「厂商自报数字」写成「官方评测结果」。
- ❌ 声称跑过未实际执行过的命令。
- ❌ 把 `Apex Bench v1.1` 与 MathArena Apex、Mercor APEX/APEX-Agents 混为一谈。
