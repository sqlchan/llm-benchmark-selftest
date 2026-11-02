# Terminal-Bench 4.0 全题中文翻译 · Part 3（第 35–51 题）

> 来源：官方仓库 `harbor-framework/terminal-bench` @ commit `4031b483`，`tasks/<task-id>/instruction.md`；本文件只含中文译文，原文可按题名在仓库核对。
> 覆盖：`live-database-cutover`、`math-eval-grader`、`medical-claims-processing`、`mp-checkpoint-consolidation`、`music-harmony`、`mvcc-lsm-compaction`、`nextjs-performance`、`ontology-kg-querying`、`payments-pipeline-fix`、`photonic-waveguide-routing`、`pretrain-shard-corruption`、`production-planning`、`protein-autointerp-disulfide`、`react-lead-form`、`retro-console-soc`、`risk-scorer-replay`、`roy-polymorph-cn`（17 题）。

## 35. `live-database-cutover`（Software/Databases）

**中文题面**

我们在本地 `http://main:8080` 运行着一个电商应用 API 服务器，目前后端是 MySQL。我们想把它改为使用 PostgreSQL。

迁移必须在零停机（没有失败的客户请求）与零过期或不一致读取的前提下完成。迁移期间客户会持续发起读写请求。API 对外可观察的行为不得改变：对任意给定请求，响应（状态码与响应体）必须与以 MySQL 为后端的基线一致。客户端请求超时为 5s。迁移后，每个端点的 p95 API 响应延迟与 MySQL 基线相比必须保持在 10ms 以内。迁移后应用不应再使用 MySQL，包括在全新容器中的后续部署。

将运行你的代码所需的任何 Python 包固定到 `/app/api/requirements.txt` 中。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：在持续读写流量与 5s 客户端超时下完成 MySQL→PostgreSQL 零停机迁移，要求逐请求响应一致、p95 延迟差 ≤10ms，且后续新容器不再依赖 MySQL。

## 36. `math-eval-grader`（ML/Evaluation）

**中文题面**

`/paper/problems.jsonl` 包含 AIME 整数答案题与混合 LaTeX 答案题。

`/data/pdfs/` 包含与之匹配的答案键 PDF。

`/paper/grader_dev.jsonl` 包含判分器的带标注样例，覆盖每种答案类型（`stratum`），并给出被接受与被拒绝的用例。

对 `Qwen/Qwen2.5-Math-1.5B-Instruct`（rev `aafeb0fc6f22`）做零样本评测：`tokenizer.apply_chat_template([{"role":"user","content": problem_text + "\n\nPlease reason step by step, and put your final answer within \\boxed{}."}], add_generation_prompt=True, tokenize=False)`。使用已安装的 `transformers`/`torch` 以 `torch.float16` 权重，一次一道题地运行 `model.generate(**inputs, do_sample=False, max_new_tokens=1024)`。

通过复制 `/paper/problems.jsonl` 的每一行并添加抽取出的 `gold` 字段，写出 `/app/extracted.jsonl`。

编写 `/app/grader.py`，其中 `grade(model_output: str, gold: str) -> bool`：从完整生成结果中抽取最终答案，并返回它是否与 gold 答案在数学上等价，每次调用 ≤2s。只使用 `sympy` 与标准库。判分器必须匹配 `/paper/grader_dev.jsonl` 的每一行，并泛化这些行所体现的规则。

编写 `/app/results.json`，内容为 `{"n_problems": 48, "accuracy": <float>, "predictions": {"<id>": {"raw": "<full model output>", "correct": <bool>}, ...}}`，其中每个 `raw` 是在上述配方下模型实际的完整解码生成结果，且 `correct = grade(raw, gold)`。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：按固定零样本配方复现生成、从答案 PDF 抽取 gold，并写出 ≤2s/次、只用 `sympy` 且能泛化的数学等价判分器。

## 37. `medical-claims-processing`（Operations/Claims）

**中文题面**

工作区 `http://workspace:18073` 中有等待处理的 GOÄ 医疗发票。请像理赔审核员一样处理它们。

`/shared/engine/engine.py` 中的 CRP 引擎目前还不可信。请使用 `/shared/reference/` 中的 `T-*` 用例及其在重新 seed 后应得的标志，弄清引擎哪里有问题。计费规则与代码表在 `/shared/rules/`。工作区运行着它自己的一份引擎副本：把源码 POST 到 `/api/admin/engine` 以安装你的版本，然后用 `POST /api/admin/reseed` 重新生成标志。完成修改后，每条发票行最多只能暴露一个 CRP 标志。

对于 `R-*` 用例，提交行级判定与报销金额：批准（approve）、削减（reduce）或拒绝（reject）。当工作区中的发票图像与结构化数据不一致时，以发票图像为准。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：依据 `T-*` 参考用例定位并修复 GOÄ 理赔 CRP 引擎（每条发票行最多一个标志），再按发票图像对 `R-*` 用例做批准/削减/拒绝判定与报销金额计算。

## 38. `mp-checkpoint-consolidation`（ML/Inference）

**中文题面**

某团队用修改过的 Megatron-LM 分支训练了一个 GPT 风格 MoE 模型，采用 4 路 Tensor Parallel、2 路 Pipeline Parallel 与 2 路 Expert Parallel（共 4 个专家）。训练在 `/app/checkpoints/` 下产出 16 个 checkpoint 分片文件，按各自的并行 rank 命名。

保存 checkpoint 的代码属于一套专有训练流水线，现已无法访问。留存下来的是：

- 该分支的框架源码位于 `/app/framework/` —— 包含并行配置、张量切分工具与 kernel 文档，但不包含 checkpoint 写入器本身
- 标准单设备 HuggingFace 模型定义位于 `/app/reference_model/model.py`，其配置在 `/app/reference_model/config.json`

编写一个脚本，把全部 16 个分片合并为单个文件 `/app/output/model.safetensors`。当它被加载进该 HuggingFace 模型后，必须在 `/app/reference_output/input_ids.pt` 的输入 token 上产生与 `/app/reference_output/logits.pt` 中的参考完全相同的 logits。

输出的参数键集合必须与 `/app/reference_output/expected_keys.json` 完全一致；不要把绑定权重（例如 `lm_head.weight`）保存为单独的键。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：从 4×2×2 并行切分的 16 个 Megatron 分片（含 MoE 专家与流水线切分）还原单文件 safetensors，使参考模型 logits 逐值一致、键集合精确匹配且不重复存绑定权重。

## 39. `music-harmony`（Media/Music）

**中文题面**

`/app/Harmony.pdf` 提供了一段音乐片段。请以巴赫众赞歌的风格完成四声部（SATB）的和声配置。用恰当的罗马数字标注和声。补写上三声部，保持四声部的声部织体（不接受非和弦音、延留音或半音化进行）。把解答写为 `/app/harmony.mxl`。

罗马数字标注必须作为 `<harmony>` 元素嵌入 MusicXML，并使用其 `<function>` 子元素。例如，一个原位属七和弦：

```xml
<harmony>
  <function>V</function>
  <kind>dominant</kind>
  <inversion>0</inversion>
</harmony>
```

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：在给定片段上完成巴赫众赞歌风格的 SATB 四声部和声（严格声部进行、无半音化），并把罗马数字和声标注以 `<harmony>/<function>` 写入 MusicXML（`mxl`）。

## 40. `mvcc-lsm-compaction`（Software/Databases）

**中文题面**

一次存储引擎压力测试任务在崩溃后验证期间发现了数据可见性故障。事故报告保存在 `/app/crash_report.txt`，`/app` 中包含受影响 MVCC LSM 代码的一个精简 C++ 模型。

诊断根因，修复 `/app/include/mvcc_lsm/` 与 `/app/src/` 下的模型，并在 `/app/tests/regression_test.cc` 中新增一个确定性回归测试，使这一失效模式持续被覆盖。修复必须保留 compaction 行为；永久保留每一个已废弃版本是不可接受的。常规回归套件通过 `make -C /app test` 运行，报告中的精简崩溃复现程序通过 `make -C /app repro` 运行。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：从崩溃报告定位 MVCC LSM compaction 的数据可见性根因并修复，同时补充确定性回归测试，且不得靠永久保留旧版本规避垃圾回收。

## 41. `nextjs-performance`（Software/Frontend）

**中文题面**

提升 `/app` 中仓库管理 Web 应用的性能与响应速度。

务必保留现有的公开路由、端点与 `data-testid` 属性。应用外观应保持可见地一致。
调度、拣货批次、库存、发运、异常与审计记录等工作流必须可用。

解决方案必须在现有的调度（`/`）、拣货批次（`/pick-batches`）、库存（`/inventory`）、发运（`/shipments`）、异常（`/exceptions`）与审计记录流程中降低页面加载与交互延迟。只优化一条路由或一个明显的瓶颈是不够的。
留意服务端等待、页面加载或交互时不必要的 JavaScript，以及任何拖慢客户端交互的因素。

验证器以生产版 Next.js 应用为基准衡量成功，并检查页面加载、交互 UI 与变更（mutation）响应。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：对多路由 Next.js 应用做系统性性能优化（服务端等待、JS 体积、交互路径），在保持路由、`data-testid` 与外观不变的前提下降低加载与交互延迟。

## 42. `ontology-kg-querying`（Software/Data engineering）

**中文题面**

ArcRail 协调办公室发布了用于铁路报告的共享 OWL 本体，各成员国提交 RDF/Turtle 摘录，这些摘录应当遵循该本体，并包含其系统所能提供的尽可能多的信息。

在 `/app` 中给出了两个带日期的数据包。`/app/2024-q2/` 是你的解决方案必须处理的当前数据包。`/app/2024-q1/` 包含遵循同一本体与同一报告思路的更早提交；只把它当作同类目标目录的示例使用。

创建以下文件：

- `/app/pipeline.py`
- `/app/cross_border_operational_points.rq`
- `/app/qualified_cross_border_points.rq`
- `/app/requirements.txt`

`/app/pipeline.py` 必须是一个可运行的脚本，恰好接受一个命令行参数：目标目录的路径（例如：`python /app/pipeline.py /app/2024-q2`）。对选定的目标目录，它应读取其中的文件，并把生成的 `unified.ttl` 写入同一目标目录，且不修改源文件。生成的图必须保留本体文件与数据提交文件中的每一个 RDF 三元组。当源数据支持且 `/app/cross_border_operational_points.rq` 与 `/app/qualified_cross_border_points.rq` 需要时，它也可以包含额外的 RDF 三元组，但任何此类新增三元组只能使用所提供本体文件中已定义的类与属性，或该数据包源 RDF 数据中已出现的类与属性。这两个 SPARQL 查询文件必须直接运行在 `unified.ttl` 之上，无需额外推理或 Python 侧的查询辅助。

如果你的解决方案需要额外的第三方 Python 包，请在 `/app/requirements.txt` 中列出，以便在验证前安装。如果你不需要任何额外的包，请让 `/app/requirements.txt` 保持为空。

假设每个目标目录都包含本体文件 `ontology_core.owl`、`ontology_network.owl` 与 `ontology_vehicle.owl`，以及其他文件中任意数量的成员国提交 `.ttl` 文件。本体文件在各数据包之间保持不变。未来的目标目录可能有不同数量的 `.ttl` 文件，以及不同的文件名、IRI、标签、缺失的可选字段、profile 声明、授权计数、时间戳与取值，但它们会遵循与所提供数据包相同的总体结构。

对本任务，把当前日期视为 `2024-10-01`。

`/app/cross_border_operational_points.rq` 必须是一个 SPARQL 查询，为每一个物理跨境运营点返回一行，即使多个成员国提交都引用了它。报告其纬度、经度、关联国家数与直接相连的线路区段数。若某个物理运营点的纬度或经度不可用，该坐标返回 `-200.0`。使用的列必须恰好为：`latitude`、`longitude`、`countryCount`、`adjacentSectionCount`。按 `?latitude`、再按 `?longitude`、再按运营点标识符排序。

`/app/qualified_cross_border_points.rq` 必须是一个 SPARQL 查询，为每一个与至少一个合格线路区段直接相连的物理跨境运营点返回一行。合格线路区段指牵引供电系统至少为 `15.0` kV 且拥有超过 3 种不同授权车辆的区段。报告运营点标识符、关联国家数、合格相邻区段上的不同授权车辆数、其中不同高速车辆数，以及合格相邻区段中的最大标称电压。使用的列必须恰好为：`opId`、`countryCount`、`vehicleCount`、`highSpeedCount`、`maxVoltageKv`。按 `?opId` 排序。

信息冲突时，以最新的提交为准。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：用 OWL 本体对齐多国 RDF/Turtle 提交并生成保真（保留全部三元组、不引入本体外词表）的 `unified.ttl`，再写出两个可直接运行在该图上、含聚合与「冲突取最新」的 SPARQL 查询。

## 43. `payments-pipeline-fix`（Software/Systems）

**中文题面**

加快金融交易处理流水线的 worker 启动速度，使透支通知正确——既不被漏发也不被重复——并在全新容器中的 worker 重启与滚动部署期间于 5s 内到达。

把任何额外的 Python 包加入 `/app/src/worker/requirements.txt`。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：缩短支付流水线 worker 启动时间，消除启动竞态导致的透支通知丢失或重复，保证重启与滚动部署下 5s 内送达。

## 44. `photonic-waveguide-routing`（Software/Algorithms）

**中文题面**

对 `/app/layout_spec.json` 中描述的光子波导进行布线，并把路径点结果写入 `/app/routing_result_1.json`。使用规格文件中的布局几何、物理约束与代价权重。

结果必须包含 `net_00` 到 `net_08`。每个 net 是一条中心线路径点路径，从其精确起点坐标到其精确目标坐标：

```json
{
  "nets": {
    "net_00": {"waypoints": [[x1, y1], [x2, y2]]},
    "net_01": {"waypoints": [[x1, y1], [x2, y2]]}
  }
}
```

轴对齐的路径点线段是水平或垂直的直线波导段。两条相互垂直的直线段之间的拐角是半径为 50 um 的 90 度圆弧弯，占用拐角每侧 50 um 的直线长度；相邻的圆弧弯不得重叠。非轴对齐线段表示一段保持进入方向的 s-bend（s 形弯）。对横向偏移 `d`，s-bend 仅在 `0 < |d| < 2 * bend_radius` 时有效，其扫角为 `theta = arccos(1 - |d| / (2 * bend_radius))`，在进入方向上的前向跨度为 `2 * bend_radius * sin(theta)`。斜向路径点线段对其横向偏移必须恰好具有该前向跨度。

物理波导路径（包括圆弧弯与 s-bend 弧）必须留在板内、避开障碍物间隙区域、避免自相交，并满足每一对 net 之间的最小间距。把 `/app/layout_spec.json` 中的 `net_width`、`clearance` 与 `min_separation` 应用到物理中心线上。

得分是所有 net 上加权路径代价之和的负值。每个 90 度弯把相邻直线长度中的 `2 * bend_radius` 替换为长度为 `pi * bend_radius / 2` 的四分之一圆弧；每段 s-bend 的弧长为 `2 * bend_radius * theta`。使用 `/app/layout_spec.json` 中的代价权重最小化总加权路径代价。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：在板边界、障碍间隙、最小间距与弯/斜接几何约束下为 9 条光子波导布线，并按解析弧长最小化加权路径代价。

## 45. `pretrain-shard-corruption`（ML/Training）

**中文题面**

在 `/app` 中，训练能成功完成，但验证损失显著高于预期：

```
$ bash /app/run_pretrain.sh
[rank 0] Starting training, 2 processes
step    0 | loss 10.5259
step    10 | loss 10.3958
step    20 | loss 10.2838
step    30 | loss  9.9375
step    40 | loss  9.6909
step    50 | loss  9.4412
...
Dataset exhausted at step 404. Stopping.
Training complete. Computing val loss on held-out set...
Training complete. Val loss (held-out clean set): 6.4911
```

上周同一启动器与训练脚本未经改动即可正常工作，并稳定达到约 **6.4** 的验证损失。请恢复原先预期的训练运行，而不是改动训练配方、丢弃样本，或用重复样本来替换以凑到目标指标。最终状态应恢复上一次良好运行所使用的预期训练样本；即使能得到接近目标的验证损失，统计上相似、生成式或其他近似的替代输入也是不可接受的。诊断根因并修改 `/app`，使 `bash /app/run_pretrain.sh` 运行至完成、写出一个 checkpoint，并产生接近 **6.4** 的验证损失。

- 不要减小 `/app/train_pretrain.py` 中的 `MAX_STEPS`；它只是一个上界。数据集在 500 步之前自然耗尽属于预期现象，也不要仅仅为了凑满 500 步而改变迭代行为。
- 不要修改 `/app/run_pretrain.sh`
- 不要修改 `/app/data/train/index.json`
- 不要通过打印一个伪造的损失值来伪造结果，必须由一次真实的训练运行合法地产出具有指定损失的 checkpoint。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：定位使验证损失升高的数据侧根因（题名指向训练分片损坏），恢复上次良好运行的真实样本，使预训练跑完并达到约 6.4 的验证损失，禁止改配方、丢样本或伪造指标。

## 46. `production-planning`（Operations/Supply chain）

**中文题面**

使用 `/app/data/README_DBGW.md` 中的文档、`/app/data/config/connections.yaml` 中的配置，以及所提供的网关工具 `/app/data/dbgw.py`，检查可用的数据库，并产出一份从 2025-06-17 到 2025-06-22 的、有效的 5 天滚动生产计划。

对于同一 run_id 的有效生产计划，你应在 ERP 系统的 planning_runs 表下插入一条记录，涵盖 run_id、created_at、horizon_start、horizon_end 与 freeze_hours。你还应在 planned_work_orders 表下插入计划工单，涵盖 wo_id、run_id、sku、qty、due_dt、planned_start_dt、planned_end_dt、line_id、status 与 parent_wo_id。在 MES 系统中，你应在 dispatch_queue 表下插入一条调度记录，涵盖 run_id、line_id、seq、wo_id、op_seq、qty、planned_start_dt、planned_end_dt 与 status。对每条产线，序号必须从 1 开始、以 1 递增且无空缺。在 WMS 系统中，你应在 inventory_reservations 表下插入物料预留命令，涵盖 resv_id、run_id、wo_id、component_sku、lot_id、qty 与 status。

把 ERP、MES 与 WMS 的回写写成独立的 SQL 文件：`/app/output/erp_writeback.sql`、`/app/output/mes_writeback.sql` 与 `/app/output/wms_writeback.sql`，然后通过已批准的网关应用它们，使 `/app/output/audit.log` 记录这次回写。冻结窗口覆盖计划期的前 24 小时。计划必须包含至少 10 个在计划期结束前到期的非 WIP 销售订单，只使用已工程发布的 SKU 且用在合格产线上，使用含 setup 的工艺路线时长，使包括 WIP_CONT 在内的每个调度都保持在冻结窗口之外，避开停机时段，落在 `available_minutes > 0` 的班次日历区间内，并在同一产线上相邻调度之间留出所需的墙钟换线间隔。现有 WIP 必须在其当前产线上优先运行，且在 ERP 与 MES 中 status = 'WIP_CONT'。当 PASS 关键库存或有限产线产能无法覆盖全部合格需求时，按业务优先级、再按更早到期日、再按更大满足数量来最大化可行满足的需求；订单只有在能被完全预留并在其到期日之前完成时才可行，且可行的优先级 1 与优先级 2 需求必须被体现。每个非 WIP 工单必须使用 status = 'PLANNED'，以其销售订单 ID 作为 `parent_wo_id`，且不得拆分或重复一个销售订单。每个计划工单恰好创建一行 MES 调度记录，保持 ERP/MES/WMS 行相互一致，并且只预留通过 IQC 且在工单计划结束时间前仍未过期的批次，同时遵守批次数量、替代组与唯一预留 ID。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：通过 DB 网关勘察 ERP/MES/WMS 三库，产出满足冻结窗口、产能、班次、换线间隔、优先级与 IQC 批次约束的 5 天滚动计划，并写成可审计的 SQL 回写。

## 47. `protein-autointerp-disulfide`（Science/Biology）

**中文题面**

给你 11 条氨基酸「训练」序列，它们构成一个蛋白质或蛋白质的一部分。对每条序列，给出该序列中所有具有某一特定功能特征的残基的 1 基索引位置。该功能特征未知，但在所有样例中是同一特征。部分示例序列没有任何具有该特征的残基（用空列表表示）。

你的任务：对一组新的、留出的「查询」序列，识别包含该功能特征的确切残基位置。

- 训练序列：`/root/data/training_examples.json`
- 未标注的查询序列：`/root/data/query_sequences.json`

把最终答案写入 `/app/predicted_features.json`，为 JSON，把每个查询 `example_id` 映射到一个整数残基位置列表。每个查询示例恰好包含一次。若该特征不存在，则使用空列表。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：从 11 条带位置标注的序列中反解未知残基功能特征（题名指向二硫键相关模式），并在留出的查询序列上精确预测位置、按序输出完整 JSON。

## 48. `react-lead-form`（Software/Frontend）

**中文题面**

`/app` 中的 React 与 TypeScript 线索收集应用有一个损坏的共享提交流程。修复表单、校验、规范化、确定性时间戳、台账核对与 CRM 导出流程。一切都在 `/app` 中运行；不要修改 `/app/src/data/lead_input.json`。

规范性的本地规格位于 `/app/src/spec/lead_schema.json`、`/app/src/spec/lead_policy.json` 与 `/app/src/spec/business_calendar.json`。你需要从 `/app/src/lib/submitLead.ts` 导出一个名为 `submitLead` 的函数，其 API 按 `/app/src/spec/lead_schema.json` 所述。React 表单与 `npm run submit` 必须使用同一个共享流水线入口——不得使用并行实现或直接写产物的实现。

被接受的线索应写出 `/app/output/submission.json`、`/app/output/crm_leads.json`、`/app/output/lead_sources.json` 与 `/app/output/reconciliation.json`。可联系但不完整的线索应写出 `/app/output/incomplete_leads.json`、`/app/output/lead_sources.json` 与 `/app/output/reconciliation.json`，且不写出被接受的提交。无效线索应安全失败、删除任何过期的 `/app/output/submission.json`，并保持已有台账不变。

已存在的被接受 CRM 记录是不可变的审计记录。重复线索、旧 schema 线索、Facebook webhook 线索、从不完整到完整的提升、格式错误的现有台账、来源分组与输出时间戳，都必须遵循本地规格。`/app/output/lead_sources.json` 是权威台账 `crm_leads.json` 与 `incomplete_leads.json` 的派生视图，必须按 `sourceGrouping` 契约与它们保持一致；从「不完整」提升为「完整」的线索必须按 `promotion` 契约保留其首次接触的审计时间戳。身份与已有记录匹配的提交并不总是良性重复：要按 `matchedSubmission` 契约处理，包括拒绝与已记录的规范字段相矛盾的提交，而不是改动这条不可变记录。若 `crm_leads.json`、`incomplete_leads.json` 或 `lead_sources.json` 格式错误，则安全恢复，并按 `/app/src/spec/lead_schema.json` 中的 `{ path, reason }` 形状把该格式错误的台账记录到 `/app/output/rejected_ledgers.json`。多文件输出更新必须是全有或全无：若任一目标输出路径无法写入，则不得改变任何现有台账。`/app/src/data/lead_input.json` 可能包含单条线索记录，也可能是记录的 JSON 数组；数组按 `/app/src/spec/lead_schema.json` 中的 `batchSubmission` 契约作为一次原子批量提交处理。

用户提交表单且线索被拒绝后，表单仍应可见且可编辑。用户输入的任何内容都应保留在字段中，而不是被清空。
表单字段必须带有文本严格为以下内容的标签与占位符：Full Name、Email、Phone、Service Needed、City 与 State。
同意复选框的标签必须为 Consent。
仅当共享的 submitLead 流水线返回被接受的结果时，表单才应显示 Thank you 成功状态。若线索被拒绝或需要复核，则不应显示成功状态。
任务完成时，常规的 `npm test`、`npm run build` 与 `npm run submit` 包命令应可正常工作。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：修复 React/TS 线索收集的单一共享提交流水线（校验、规范化、确定性时间戳、匹配去重与冲突拒绝、台账派生一致性、全有或全无写入），并保证表单被拒时保留用户输入且不误显成功态。

## 49. `retro-console-soc`（Hardware/RTL）

**中文题面**

用可综合的 Verilog 实现一个复古 8 位片上系统，把源码放在 `/app/src`。其架构必须与 1980 年代一家知名日本游戏公司最流行的主机完全相同。示例 ROM 位于 `/app/data/test_rom.hex`。

你必须实现所有主要子系统，包括 CPU 核心与 PPU，且你的设计必须满足以下要求：

  - 使用 Verilog 2005 或 SystemVerilog
  - 可综合到硬件 FPGA
  - 综合无错误地完成
  - 能放进一片 Lattice ECP5-12K FPGA
  - 达到至少 33 MHz 的 FMax
  - 能准确渲染使用 UNROM 映射的测试 ROM 的视频输出
  - 用 Verilator 编译并仿真测试 ROM，产生与测试 ROM 参考输出逐像素一致的结果

你的实现必须为顶层 `console_system` 模块使用严格如下的模块接口：

```verilog
module console_system (
    input  wire        clk,           // 主时钟（posedge 有效）
    input  wire        rst_n,         // 低电平有效的同步复位

    // PRG ROM 接口（64KB 平坦地址空间）
    output wire [15:0] prg_addr,      // PRG ROM 地址（64KB）
    input  wire [ 7:0] prg_data,      // PRG ROM 数据

    // CHR RAM 接口（8KB，由 PPU 直接寻址）
    output wire [12:0] chr_addr,      // CHR RAM 地址（8KB）
    input  wire [ 7:0] chr_rd_data,   // CHR RAM 读数据
    output wire [ 7:0] chr_wr_data,   // CHR RAM 写数据
    output wire        chr_wr_en,     // CHR RAM 写使能

    // 视频输出
    output wire [ 5:0] pixel_color,   // 调色板索引（0-63）
    output wire        pixel_valid,   // 可见像素期间为高（256x240）
    output wire [ 8:0] pixel_x,       // 像素列（0-255）
    output wire [ 8:0] pixel_y,       // 像素行（0-239）
    output wire        frame_done     // 帧结束时在 clk 上脉冲为高一个周期
);
```

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：用可综合 Verilog/SystemVerilog 实现 NES 级 8 位 SoC（CPU 核心 + PPU + UNROM 映射），满足 ECP5-12K 资源、≥33 MHz FMax 与 Verilator 逐像素一致的视频输出。

## 50. `risk-scorer-replay`（ML/Evaluation）

**中文题面**

你在 `/app` 的模型风险迁移工作区中工作。命令 `/app/rebuild_parity_report.sh` 应能从 `/app/data/incidents/parity-2026-10` 重建一份旧版评分器一致性包，并写出 `/app/output/parity_scores.csv`、`/app/output/parity_summary.json` 与 `/app/output/scorer_audit.sqlite`。

`/app/parityctl` 中的离线评估器是按一份过期的模型卡实现的，已不再与生产评分器匹配。在修复评估器的过程中，你可以使用安装在 `PATH` 中的诊断黑盒命令 `legacy-score` 来探测生产行为。在最终实现中，不要在运行时调用或复制 `legacy-score`，因为验证器会在运行你修复后的代码之前删除该诊断二进制。

修复 `/app/parityctl`，使其能从清单选定的源工件、`/app/docs/migration_ticket.md` 中的输出契约与迁移说明、`/app/docs/review_ops_digest.md` 中的复核运营摘要，以及你从任何可用 trace/probe 推断出的生产行为来重建输出。在调查期间把 `legacy-score` 视为评分器行为的规范。如果一次修复能把同 schema 的探测转化为普通的独立源码实现，即视为正确。为同 schema 数据包保留 CLI 入口 `python -m parityctl rebuild --packet <incident-packet> --out <output-dir>`。`/app/rebuild_parity_report.sh` 可以为默认数据包调用它。你的实现还必须适用于验证器提供的、具有相同请求 schema、复核事件词表与输出契约的事故数据包。这些数据包可能在取值、顺序、重复、清单路径、部分 trace 与缺失/默认字段上有所不同，但不会要求新的特征列、新的事件类型或仅验证器使用的业务规则。对同一数据包重复重建必须产生确定性输出。不要修改任何事故数据包中的原始输入文件，包括验证器提供的数据包，也不要向 `/app`、`/tmp`、`/var/tmp` 或 `/dev/shm` 添加编译好的可执行文件或二进制载荷。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：把 `legacy-score` 黑盒当作行为规范重写离线评分器，使其在移除该二进制后仍能仅凭清单工件与文档确定性重建三个一致性产物。

## 51. `roy-polymorph-cn`（Science/Chemistry）

**中文题面**

我在研究 5-methyl-2-((2-nitrophenyl)amino)thiophene-3-carbonitrile（ROY）的十二种多晶型。对每种构象体，我们有 SCXRD 几何结构、观测到的颜色以及实测的腈基 C≡N 伸缩波数。

几何结构位于 `/app/data/conf1.mol` 到 `/app/data/conf12.mol`。颜色与波数测量值位于 `/app/data/TB3_Conf_Properties.csv`。

请通过拟合物理上合适的功能形式，为构象与光谱行为之间的连续关系建模。使用你推导出的模型报告以下内容：
a) 腈基 C≡N 伸缩波数达到最大值时的 S–C–N–C 二面角。
b) 腈基 C≡N 伸缩波数达到最小值时的 S–C–N–C 二面角。
c) S–C–N–C 二面角为 70° 时的腈基 C≡N 伸缩波数。
d) S–C–N–C 二面角为 140° 时的腈基 C≡N 伸缩波数。
e) S–C–N–C 二面角为 160° 时的腈基 C≡N 伸缩波数。
f) 多晶型 conf11（`conf11.mol`）的预测颜色。

把答案以名为 `TB3_Conf_Answers.csv` 的 CSV 文件提供，并保存在 `/results/` 内。它必须只包含一列，第一行表头严格为 `Answers`，随后各行按上面要求的准确顺序给出 (a)–(f) 的答案。答案 (a)–(e) 必须为整数（四舍五入到最接近的整数）。答案 (f) 必须为小写颜色名。

你有 28800 秒完成本任务。不要使用针对本任务的在线解答或提示作弊。

**考点**：用 12 个 ROY 多晶型的 SCXRD 二面角与光谱数据拟合物理上合理的二面角–波数关系，外推指定角度取值并预测 conf11 颜色，按严格格式输出 CSV。
