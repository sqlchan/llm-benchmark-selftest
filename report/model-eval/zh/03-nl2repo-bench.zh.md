# NL2Repo-Bench：中文精读（测什么 · 怎么测）

> 版本：arXiv v2（2026-01-08）｜官方题量：**104 题 / 9 类 Python 库**｜官方 harness：**仓库自带 `main.py` 驱动 OpenHands 0.56 headless**｜官方口径：**平均测试通过率（average test pass rate，0–100%）**；论文另报 Pass@1 count（[原文件 L3](../03-nl2repo-bench.md#L3)）
> 离线包现状：**16/104 题**（10 基线 + 6 补充），3 并发，离线派生测试镜像已预装构建依赖（[原文件 L4](../03-nl2repo-bench.md#L4)）
> 本分册整理自 [../03-nl2repo-bench.md](../03-nl2repo-bench.md)，数字可在原文逐条核对。

---

## 1. 它到底测什么

**一句话**：只给模型一份**自然语言规格**（约 18.8k tokens）和一个**空工作区**，让它从 0 到 1 写出一个完整、可安装的 Python 库；然后用**原仓库上游的 pytest** 判分，分数 = 通过的测试用例占比（[原文件 L9](../03-nl2repo-bench.md#L9)）。

这不是一道「写个函数」的题，而是一次**从规格到整个仓库**的工程交付。它真正压的是三件事：

| 被考的能力 | 在 NL2Repo 里的具体表现 | 为什么必须靠它才拿分 |
| :-- | :-- | :-- |
| **长程规划** | 一份规格里同时有环境版本、目录树、几十个 API、行为约束；模型要先拆成「先搭骨架 → 再填核心 → 再补边界」的顺序，否则写到一半就互相矛盾 | 单轮 prompt 无法承载 18.8k tokens 的多目标；必须持续自我编排 |
| **多文件工程** | 要产出可 `pip install` 的包：`pyproject.toml`、包目录、`__init__.py` 导出、子模块分工、类型注解 | 单文件脚本拿不到分；测试按模块 import |
| **自己跑测试修错** | OpenHands 在沙箱里循环「读规格 → 写文件 → 跑命令 → 看报错 → 再改」，没有轮数上限（[原文件 L13](../03-nl2repo-bench.md#L13)） | 只在最后一刻交卷的 scaffold 一定低分；它奖励「自测—修复」闭环 |

**明确不考的东西**：

- **不考单点算法**。没有 LeetCode 式的最优解题；考的是「把规格里的 API 一个不落地实现到能 import、能跑测试」。
- **不是 LLM judge**。判分完全由上游 pytest 结果决定，没有模型当裁判（[README L21](../README.md#L21)）。
- **不考「猜需求」**。规格写得相当细（目录树、依赖版本、`API Usage Guide`），考的是执行力而非需求发现。

### 1.1 与 DeepSWE 的区别（最容易混的一对）

| 维度 | DeepSWE v1.1 | NL2Repo-Bench |
| :-- | :-- | :-- |
| 起点 | **已有真实仓库** @ base commit | **空工作区**，只有一份规格 |
| 任务形态 | 在别人的代码里做原创长程改动 | 从规格从零造出整个仓库 |
| 交付物 | 一个 git commit | 整个可运行仓库 |
| 判分 | 隐藏 `test.patch` + F2P/P2P 白名单 | 上游 pytest 通过率 |
| 隐喻 | 接手维护老项目 | 外包一个新项目从立项到交付 |

原文件把这条差异讲得很直接：DeepSWE 是「已有仓库上改」，NL2Repo 是「什么都没有，从规格开始造」——更接近真实外包/新项目启动（[原文件 L11](../03-nl2repo-bench.md#L11)）。

### 1.2 与 ProgramBench 的区别

NL2Repo 给的是**完整自然语言规格**（有目录树、依赖版本、API 说明）；ProgramBench 只给**一个二进制 + 文档**，要求重建程序行为（[原文件 L11](../03-nl2repo-bench.md#L11)）。前者考「按文档造库」，后者考「黑盒逆向 + 行为复刻」。

## 2. 测试集规模（题量 / 测试数据 / 时间 / 成本）

### 2.1 题量与分类

| 项目 | 数值 | 出处 |
| :-- | :-- | :-- |
| 官方题量 | **104 题**，覆盖 **9 类 Python 库** | [原文件 L3](../03-nl2repo-bench.md#L3) |
| 离线包可跑题量 | **16/104**（10 基线 + 6 补充） | [原文件 L4](../03-nl2repo-bench.md#L4) |
| 单题规格长度 | 约 **18.8k tokens**（`start.md` 示例 49 KB） | [原文件 L9](../03-nl2repo-bench.md#L9)、[L23](../03-nl2repo-bench.md#L23) |
| 单题测试数范围 | **27 – 2182** 条 | [原文件 L224-L236](../03-nl2repo-bench.md#L224-L236) |
| 单题轮数上限 | **无轮数上限**（模板默认 `max_iterations = 500`） | [原文件 L13](../03-nl2repo-bench.md#L13)、[L82](../03-nl2repo-bench.md#L82) |
| 单题时长 | 可达**数小时**（交互可达数百轮） | [原文件 L13](../03-nl2repo-bench.md#L13) |
| 官方整轮口径 | 104 题的**平均测试通过率** | [原文件 L111](../03-nl2repo-bench.md#L111) |

### 2.2 各题测试数（`test_case_count.txt` 实测值）

| 任务 | 测试数 | 难度（官方 CSV） | 类别 |
| :-- | --: | :-- | :-- |
| `jsonlines` | 27 | Easy | JSON Lines 读写库 |
| `python-slugify` | 82 | Easy | Unicode → URL slug + CLI |
| `tinydb` | 204 | Medium | 纯 Python 文档数据库 |
| `aiofiles` | 211 | Medium | 异步文件库 |
| `flask-restful` | 362 | Medium | REST 框架层 |
| `fastapi-users` | 556 | Hard | Web / 用户认证 |
| `stable-baselines3` | 798 | Hard | 强化学习库 |
| `python-pytest-cases` | 1372 | Hard | 测试框架 |
| `ydata-profiling` | 2182 | Hard | 数据分析 / EDA |

> 数据来自各任务 `test_case_count.txt`（[原文件 L224-L236](../03-nl2repo-bench.md#L224-L236)）。测试数跨度接近 **81 倍**（27 → 2182），这是 NL2Repo 单题成本方差极大的根因：`ydata-profiling` 要模型从零写出能过 2182 个测试的数据分析库，单题跑几百轮、几个小时很正常（[原文件 L238](../03-nl2repo-bench.md#L238)）。

### 2.3 时间与成本

| 项目 | 实际情况 | 说明 |
| :-- | :-- | :-- |
| 单题墙上时间 | 数小时（无上限） | 模型越笨越慢；`max_iterations` 决定天花板（[原文件 L251-L252](../03-nl2repo-bench.md#L251-L252)） |
| 冒烟耗时 | 1 题 × 8 轮 ≈ **10–20 分钟** | 只验证链路，不代表正式时长（[原文件 L275](../03-nl2repo-bench.md#L275)） |
| 并发建议 | 32C/64G 建议 pool=**3** | 离线包已打并行补丁（[原文件 L255](../03-nl2repo-bench.md#L255)） |
| 单轮 token 成本 | 规格 ~18.8k tokens 输入 + 数百轮交互 | 交互轮数不封顶 → 成本**极不稳定** |
| 官方美元成本 | **unknown** | 原文件未给出金额估算；`# TODO verify`（需按端点价格 × 实测 token 自行核算） |

> 成本是「轮数 × 单轮上下文」的函数，而轮数没有上限，所以**同一题不同模型可能差一个数量级**。做预算时不能按「固定时长 × 单价」估，必须实测若干题后再外推。

---

## 3. 单题结构：给什么 → 做什么 → 交什么 → 怎么判

### 3.1 全景表

| 环节 | 内容 |
| :-- | :-- |
| **给什么** | 一份 `start.md`（介绍 + 自然语言需求 + 环境版本 + 目录树 + `API Usage Guide`），以及一个空 workspace。**不给测试代码** |
| **做什么** | 按规格实现整个 Python 库，保证「最终产物能在当前目录直接运行」，运行方式必须符合文档的 `<API Usage Guide>` 一节 |
| **交什么** | **整个仓库**（不是 patch、不是单个文件），要可 `pip install -e .`、可被 pytest 收集 |
| **怎么判** | 把仓库放进官方测试镜像，执行 `test_commands.json` 里的命令（安装 + pytest），取 `passed / total` 作为单题通过率 |
| **辅助文件** | `test_files.json`（测试相关文件清单）、`test_case_count.txt`（测试用例数） |

### 3.2 每题的数据目录（`test_files/<task>/`）

```
test_files/aiofiles/
├─ start.md              # 49 KB 的规格：介绍 + 自然语言需求 + 环境版本 + 目录树 + API 说明
├─ test_files.json       # 测试相关文件清单
├─ test_commands.json    # 判分要执行的命令（安装 + pytest）
└─ test_case_count.txt   # 测试用例数（aiofiles = 211）
```

（结构见 [原文件 L21-L27](../03-nl2repo-bench.md#L21-L27)）

`test_commands.json` 在离线包里长这样（原文）：

```json
["pip install --no-build-isolation --no-index -e .",
 "pytest --continue-on-collection-errors tests"]
```

（[原文件 L31-L34](../03-nl2repo-bench.md#L31-L34)；注意这是**离线改写版**，官方版本没有 `--no-build-isolation --no-index`）

### 3.3 「给什么」的三个关键约束

1. **规格是唯一的输入**。模型只拿到 `start.md`；上游仓库、测试代码、参考实现全都不可见（[原文件 L242-L243](../03-nl2repo-bench.md#L242-L243)）。
2. **规格里给了环境版本**，例如 `aiofiles` 题的 Python 3.11.7、pytest 8.4.1、pytest-asyncio 1.1.0（[原文件 L139](../03-nl2repo-bench.md#L139)）。这意味着不能靠「猜当前环境」蒙混，必须按指定版本写。
3. **`API Usage Guide` 是硬约束**。harness 下发的固定指令明确要求「运行要求应遵循文档的 `<API Usage Guide>` 一节」（[原文件 L76-L80](../03-nl2repo-bench.md#L76-L80)）。

### 3.4 「交什么」判定的是可运行仓库

交付物不是一个 diff、不是一段代码片段，而是**整个 workspace 目录**。harness 的验收动作只有两步：先 `pip install -e .` 装得上，再被 pytest 收集得到用例。装不上 → 整题贴近 0 分；装上了但 import 大面积失败 → 靠 `--continue-on-collection-errors` 保住剩余用例的分。

### 3.5 「怎么判」只看上游 pytest

判分器不读代码、不评风格、不请模型当裁判，只解析 pytest 输出里的 `passed / failed / errors / skipped / total / success_rate`（[原文件 L86](../03-nl2repo-bench.md#L86)）。所以「代码写得丑但测试过」= 得分，「代码优雅但只过一半」= 半分。

## 4. 怎么测：一次评测的完整流程

官方 harness 是**仓库自带的 `main.py`**，用 **OpenHands 0.56 headless** 驱动，本地 Docker only（`docker_self/` 用 python-on-whales 管理）（[原文件 L3](../03-nl2repo-bench.md#L3)、[L44-L46](../03-nl2repo-bench.md#L44-L46)）。

### 4.1 harness 组件

| 文件/目录 | 作用 |
| :-- | :-- |
| `main.py` | 入口：读 `config.json`，起容器、跑任务、写结果 |
| `openhands/openhands_app.py` | 起 OpenHands app 容器、下发任务、收集结果 |
| `openhands/post_processor.py` | 结束后处理：打包 workspace → 构建测试镜像 → 跑测试命令 → 解析 pytest |
| `docker_self/` | 用 python-on-whales 管理 Docker（本地 Docker only） |
| `template/config.toml` | OpenHands 配置模板（`max_iterations` 等） |

（[原文件 L40-L46](../03-nl2repo-bench.md#L40-L46)）

### 4.2 两个容器镜像

| 镜像 | 作用 |
| :-- | :-- |
| `ghcr.io/all-hands-ai/openhands:0.56` | OpenHands app（模型代理 + 前端 shell） |
| `ghcr.io/all-hands-ai/runtime:0.56-nikolaik` | agent 的执行沙箱（bash / 编辑器） |
| `ghcr.io/multimodal-art-projection/nl2repobench/<task>:1.0` | 官方测试镜像，后处理时作为基础镜像 |

（[原文件 L50-L53](../03-nl2repo-bench.md#L50-L53)、[L84](../03-nl2repo-bench.md#L84)）

> 注意：原地址 `docker.all-hands.dev/all-hands-ai/*` 已 **NXDOMAIN**（域名下线），离线包改用 `ghcr.io/all-hands-ai/*`（[原文件 L55](../03-nl2repo-bench.md#L55)）。复现时要按这个替换，否则拉不到镜像。

### 4.3 八步生命周期

**第 1 步：写配置**（`config.json`）：

```json
{
  "startPro": [{
    "moduleName": "openai/<模型名>",
    "baseUrl": "http://<内网地址>/v1",
    "sk": "<API key>",
    "proNameList": ["aiofiles"]
  }],
  "max_pool_size": 1
}
```

（[原文件 L59-L71](../03-nl2repo-bench.md#L59-L71)；`max_pool_size` 就是并发池大小）

**第 2 步：起 app 容器**。harness 起 `openhands-app-<port>`，把 `workspaces/<task>/`（含 `start.md`）挂进容器，端口映射 `3000 -> base+序号`（[原文件 L73](../03-nl2repo-bench.md#L73)）。

**第 3 步：下发固定指令**（原文）：

> According to the start.md in the workspace, implement the entire project as per the requirements specified in the document, ensuring that the final product can be directly run in the current directory. The running requirements should comply with the `<API Usage Guide>` section of the document. Please complete this task step by step.

**中文翻译**：

> 根据工作区里的 `start.md`，按文档要求实现整个项目，确保最终产物能在当前目录直接运行。运行要求应遵循文档的「API Usage Guide」一节。请一步一步完成这个任务。

（[原文件 L74-L80](../03-nl2repo-bench.md#L74-L80)）

**第 4 步：模型干活**。OpenHands 在 runtime 沙箱里循环「读规格 → 写文件 → 跑命令 → 看报错 → 再改」。**没有轮数上限**（模板默认 `max_iterations = 500`；冒烟时特意调成 8 控制时长）（[原文件 L82](../03-nl2repo-bench.md#L82)）。

**第 5 步：结束**。模型自己说完成，或达到迭代上限；harness 把 `/workspace` 打包成 `workspace.zip`（[原文件 L83](../03-nl2repo-bench.md#L83)）。

**第 6 步：后处理构建测试镜像**。以官方测试镜像为基础（`FROM ghcr.io/multimodal-art-projection/nl2repobench/<task>:1.0`），把模型写的仓库放进去，构建出 `python-test-<task>` 镜像（[原文件 L84](../03-nl2repo-bench.md#L84)）。

**第 7 步：跑测试命令**。在测试容器里依次执行 `test_commands.json` 里的命令（安装 + pytest），拿到 pytest 输出（[原文件 L85](../03-nl2repo-bench.md#L85)）。

**第 8 步：解析与落盘**。从 pytest 输出里解析 `passed / failed / errors / skipped / total / success_rate`，写进 `result/<task_uuid>.json`（[原文件 L86](../03-nl2repo-bench.md#L86)）。

### 4.4 并行与端口隔离

官方 harness 只支持本地 Docker，多机要 NFS 共享；单机可以并发，但**每个任务要独立端口、独立 state 目录、独立测试镜像/容器**（[原文件 L254-L255](../03-nl2repo-bench.md#L254-L255)）。离线包已打并行补丁：

| 参数 | 作用 |
| :-- | :-- |
| `max_pool_size` | 配置文件里的并发池大小 |
| `NL2REPO_PORT_BASE` | 每个 app 容器端口基数（`3000 -> base+序号`） |
| `NL2REPO_MAX_POOL` | 环境变量形式的并发上限 |

32C/64G 建议 **pool=3**；再高会因 OpenHands 容器 + 测试镜像构建叠加而内存抖动。

### 4.5 离线包对官方流程的 5 处改动

| 改动 | 原因 |
| :-- | :-- |
| 镜像源 `docker.all-hands.dev` → `ghcr.io/all-hands-ai/*` | 原 registry NXDOMAIN |
| `NL2REPO_HOST_ROOT`：runner 以「相同绝对路径」挂载离线包 | OpenHands 对 volume 路径做正则校验，必须是 `/` 开头的宿主机路径 |
| 启动命令改 `bash -c` + `shlex.quote` | 任务文本含空格，list 形式会被拆成多个 argv |
| 16 个派生测试镜像预装构建依赖 + `pip install --no-build-isolation --no-index -e .` | 断网时 `pip install -e .` 会失败 |
| 并行补丁：per-port 端口/state/容器名，`NL2REPO_MAX_POOL` | 单进程内安全并发 2–3 题 |

（[原文件 L283-L291](../03-nl2repo-bench.md#L283-L291)）

### 4.6 实际跑法

```bash
# 冒烟：1 题 8 轮（约 10–20 分钟）
BUNDLE_DIR=$PWD NL2REPO_TASKS=aiofiles NL2REPO_MAX_ITERATIONS=8 \
  ./offline/run_batch2.sh nl2repo

# 正式：16 题，3 并发
PROFILE=32c64g ./offline/run_batch2.sh nl2repo
```

（[原文件 L274-L281](../03-nl2repo-bench.md#L274-L281)）

---

## 5. 判分机制与分数怎么算

### 5.1 单题分 = `success_rate` = `passed / total`

harness 里直接取后处理结果（原文代码）：

```python
pytest_results = post_process_result['pytest_results']
test_score = pytest_results['passed'] if pytest_results['total'] > 0 else 0
```

（[原文件 L92-L95](../03-nl2repo-bench.md#L92-L95)）

> 注：上面这行是 harness 原始代码的**字面照录**——它把 `test_score` 赋成 `passed`（通过数，不是比例），所以别直接采信 `test_score`。正式口径是同一个 JSON 里的 `pytest_results.success_rate`（[原文件 L113](../03-nl2repo-bench.md#L113)，详见 §7.3）。

我们实测的 result JSON（`results/nl2repo-smoke/result-aiofiles_bo1.json`）字段长这样：

```json
"post_process_result": {
  "status": "success",
  "test_results": {
    "pytest_results": {"passed": 1, "failed": 20, "errors": 12, "total": 211,
                       "success_rate": 0.004739336492890996}
  }
}
```

（[原文件 L99-L107](../03-nl2repo-bench.md#L99-L107)）

注意：这是**冒烟产物**（官方骨架镜像 + 联网失败），**不是模型分**，只用来展示字段形状（[原文件 L300](../03-nl2repo-bench.md#L300)）。

### 5.2 公式

```
单题通过率  rate_i = passed_i / total_i        （total_i > 0；否则该题记 0）
整轮主指标  avg   = (1/N) · Σ_{i=1..N} rate_i    （N = 104，结果 ×100% 记 0–100）
论文附加    Pass@1 count = #{ i : rate_i == 1.0 } （通过率 100% 的题数）
```

（口径见 [原文件 L109-L111](../03-nl2repo-bench.md#L109-L111)）

- **主指标是连续值**（0–100%），不是 0/1，也不是「全过的题数」。
- **Pass@1 count 是论文另报的辅助指标**，单位是「题」，不要和「通过率」混在一张表里。
- `errors`（collection error）单独计数，**不中断整题**；`--continue-on-collection-errors` 保证其余用例照跑（[原文件 L110](../03-nl2repo-bench.md#L110)）。

### 5.3 算例

**单题算例**：某题 `total = 362`（`flask-restful`），通过 **300** 条：

```
rate = 300 / 362 = 0.8287... ≈ 82.9%
```

如果同轮另有 `jsonlines` 过 20/27（= 74.1%）、`tinydb` 过 100/204（= 49.0%），三题平均：

```
avg = (82.87% + 74.07% + 49.02%) / 3 ≈ 68.7%
```

**整轮算例（示意）**：若 104 题平均通过率是 42.3%，且其中 3 题达到 100%，则主指标记 `42.3%`，Pass@1 count 记 `3`。两者不能互换。

### 5.4 分数不是模型能力本身

同一个模型换 scaffold、换 `max_iterations`、换端点，通过率都会变。原文件明确警告：`max_iterations` 影响分数，冒烟用 8 会**低估**，正式跑必须用默认 500 或更大值（[原文件 L297](../03-nl2repo-bench.md#L297)）。

---

## 6. 真实题面（英中对照翻译）

> 以下 5 道题例来自 `E:\bench-bundle\data\nl2repo\harness\test_files\` 的真实产物（[原文件 L5](../03-nl2repo-bench.md#L5)）。英文为规格原文节选，中文为翻译/要点整理；`# TODO verify` 表示原文件未收录该字段。

### 6.0 题例速览

> 五道题共用**同一条 harness 模板指令**（「按 `start.md` 实现整个项目……请一步一步完成」，原文与翻译见 §4.3 第 3 步），差异只在各自的 `start.md` 规格；因此下面每题只列「规格原文」，模板指令不重复。

| 任务 | 测试数 | 难度（官方 CSV） | 一句话 |
| :-- | --: | :-- | :-- |
| `jsonlines` | 27 | Easy | JSON Lines 读写库，最小 |
| `python-slugify` | 82 | Easy | Unicode → URL slug + CLI |
| `tinydb` | 204 | Medium | 纯 Python 文档数据库 |
| `aiofiles` | 211 | Medium | 异步文件库 |
| `flask-restful` | 362 | Medium | 完整 REST 框架层 |

（[原文件 L226-L232](../03-nl2repo-bench.md#L226-L232)）

### 6.1 `aiofiles`（Medium，211 个测试）

**一句话背景**：把一个真实的 asyncio 异步文件库从规格重写一遍——考的是「线程池 + 事件循环 + 异步协议」这类不好凭直觉写对的工程细节。

**英文题面原文**（`start.md` 开头节选）：

> **Introduction and Goals of the aiofiles Project**
>
> aiofiles is a Python library **for asynchronous file operations**, providing asynchronous processing capabilities for local disk files in asyncio applications. This library is licensed under the Apache 2 license. It delegates blocking file I/O operations to separate threads through a thread pool executor, thus avoiding blocking the asyncio event loop...

（[原文件 L121-L123](../03-nl2repo-bench.md#L121-L123)）

**中文翻译**：

> **aiofiles 项目的介绍与目标**
>
> aiofiles 是一个做**异步文件操作**的 Python 库，为 asyncio 应用提供本地磁盘文件的异步处理能力，采用 Apache 2 许可。它通过线程池 executor 把阻塞式文件 I/O 委派到独立线程，从而避免阻塞 asyncio 事件循环……

**规格里的 9 条要求**（原文件以中文整理、术语保留英文，[原文件 L127-L137](../03-nl2repo-bench.md#L127-L137)）：

1. **异步文件操作核心**：异步 open/read/write，支持文本与二进制，提供 `read()`、`write()`、`readline()`、`readlines()`、`writelines()` 的异步版本。
2. **线程池 executor 集成**：通过 asyncio 线程池把阻塞 I/O 放到独立线程，支持自定义 loop 和 executor。
3. **异步迭代**：文件对象实现异步迭代器协议，支持 `async for` 逐行读。
4. **异步临时文件模块**：`TemporaryFile`、`NamedTemporaryFile`、`SpooledTemporaryFile`、`TemporaryDirectory`，都支持 `async with`。
5. **异步 OS 操作**：`stat`、`mkdir`、`makedirs`、`rename`、`remove`、`symlink`、`listdir`、`scandir` 等全部异步化。
6. **异步标准输入输出**：`stdin`、`stdout`、`stderr` 及其 bytes 版本。
7. **接口设计**：清晰的 API、`async with`、异步迭代、错误处理。
8. **示例与测试**：完整示例代码与测试用例。
9. **核心文件要求**：必须有可 `pip install` 的 `pyproject.toml`、`src/aiofiles/__init__.py`，导出 `aioopen`、`wrap`、`stdin`、`stdout` 等。

规格还给环境版本（Python 3.11.7、pytest 8.4.1、pytest-asyncio 1.1.0 等）和目录树（[原文件 L139](../03-nl2repo-bench.md#L139)）。

**判分点**：

| 项目 | 值 |
| :-- | :-- |
| `test_case_count.txt` | **211** |
| 测试命令（离线版） | `pip install --no-build-isolation --no-index -e .` + `pytest --continue-on-collection-errors tests` |
| 覆盖行为 | 异步读写/迭代、临时文件、OS 操作异步化、标准流、`async with` 协议、线程池 executor 行为、包可安装性 |

**为什么这样判**：211 个测试是上游仓库的真实测试集，覆盖「异步协议实现是否正确」而不是「API 名字是否齐全」。spec 里明确要「示例与测试」，但判分不看你写的测试，只看上游测试——这防止了「自己写宽松测试自证正确」。

### 6.2 `jsonlines`（Easy，27 个测试）——最小的题之一

**一句话背景**：最小的冒烟题，27 个测试；但规格密度很高，考「把一堆边界条件一个不漏地实现」。

**规格原文**（节选）：

> jsonlines is a Python library **designed for processing data in the JSON Lines (line-by-line JSON) format**, aiming to simplify the reading and writing operations of .jsonl/ndjson files. This tool supports efficient line-by-line reading and writing of large-scale JSON data...
>
> Please create a Python project named 'jsonlines' to implement an efficient JSON Lines format data processing library. The project should include the following functions:
>
> 1. **JSON Lines file read and write**
> 2. **Streaming processing**: supports efficient streaming processing of large files
> 3. **Data type support**: fully supports all JSON standard data types
> 4. **Error handling**: Provide robust error handling mechanisms
> 5. **Encoding processing**: supports multiple character encodings
> 6. **Iterator Interface**
> 7. **Context Manager**: Supports with statement
> ...
> In jsonlines.py, a Reader class is required to support reading JSON Lines data from a file object or an iterable object, providing a read() method ... and supporting typed reading (type parameter), null value handling (allow_none), empty line skipping (skip_empty), and invalid line skipping (skip_invalid). A Writer class is required ... supporting compact output (compact), key sorting (sort_keys), buffer flushing (flush), and custom serialization (dumps). An open() function is required ... automatically handling file encoding (UTF-8) and UTF-8 BOM detection ... A SKIPPABLE_SINGLE_INITIAL_CHARS constant is required ... supporting the RFC7464 text sequence format ... Multiple JSON libraries need to be supported ... prioritizing orjson (if available), then ujson, and finally falling back to the standard library json.

（[原文件 L143-L157](../03-nl2repo-bench.md#L143-L157)）

**中文翻译**（要点）：

> jsonlines 是处理 JSON Lines（逐行 JSON）格式的 Python 库，简化 `.jsonl`/`.ndjson` 的读写，支持大文件流式处理。
>
> 要实现的库包含：读写、流式处理、全 JSON 类型、健壮错误处理、多编码、迭代器接口、上下文管理器；核心文件要提供 `Reader`（支持 `read()`/`iter()`、`type`、`allow_none`、`skip_empty`、`skip_invalid`）、`Writer`（`write()`/`write_all()`、`compact`、`sort_keys`、`flush`、`dumps`）、`open()`（按 `'r'/'w'/'a'/'x'` 返回 Reader/Writer，处理 UTF-8 与 BOM）、`Error`/`InvalidLineError`（错误信息带行号和原始行）、`SKIPPABLE_SINGLE_INITIAL_CHARS`（`\x1e` 与 BOM，支持 RFC7464）、`ReaderWriterBase`、`DumpsResultConversion`、`repr_for_fp()`；JSON 库优先 orjson，其次 ujson，最后标准库 json；要完整的类型注解（泛型、Union、Literal、`@overload`，能过 mypy）。

（[原文件 L161-L163](../03-nl2repo-bench.md#L161-L163)）

**判分点**：

| 项目 | 值 |
| :-- | :-- |
| `test_case_count.txt` | **27** |
| 测试命令 | `# TODO verify`（原文件未收录该题的 `test_commands.json`） |
| 覆盖行为 | 读写、类型化读取（`type`）、空行/非法行跳过、BOM、三种 JSON 库后端、上下文管理器、类型注解 |

**为什么这样判**：27 属于 104 题里测试最少的一档（有 5 题的测试数比它还少），适合验证链路；但要求并不少——27 个测试覆盖读写、类型化读取、空行/非法行、BOM、三种 JSON 库后端、上下文管理器、类型注解（[原文件 L165](../03-nl2repo-bench.md#L165)）。测试少 ≠ 题简单，只意味着**判分反馈粒度粗**：少过一个测试就掉 3.7 个百分点。

### 6.3 `tinydb`（Medium，204 个测试）——规格自己写明了测试规模

**一句话背景**：纯 Python 文档数据库，规格罕见地直接告诉模型「有几个测试文件、多少测试」，考「按给定测试规模对齐实现深度」。

**规格原文**（节选）：

> TinyDB is a **lightweight document-oriented database** designed specifically for small applications. It aims to provide a local storage solution implemented purely in Python without external dependencies...
>
> - **Document-based storage**: Each piece of data is stored in a dict format...
> - **Pure Python implementation**: No third-party dependencies...
> - **Simple and easy to use**: It includes 7 test files, a total of **141 test functions** and **204 test cases**, covering multiple aspects such as data insertion, querying, updating, multi-table management, storage backends, operation functions, and type tools.
> - **Powerful extensibility**: custom storage backends and middleware
> - **High-quality assurance**: 100% unit test coverage

（[原文件 L171-L177](../03-nl2repo-bench.md#L171-L177)）

**中文翻译**：

> TinyDB 是面向小应用的轻量文档数据库，纯 Python、无外部依赖；数据以 dict 存储；**7 个测试文件、141 个测试函数、204 个测试用例**，覆盖插入、查询、更新、多表管理、存储后端、操作函数、类型工具；支持自定义存储后端和中间件；100% 单元测试覆盖。

（[原文件 L179-L181](../03-nl2repo-bench.md#L179-L181)）

**判分点**：

| 项目 | 值 |
| :-- | :-- |
| `test_case_count.txt` | **204**（与规格里写的 204 一致） |
| 测试命令 | `# TODO verify`（原文件未收录该题的 `test_commands.json`） |
| 覆盖行为 | 数据库核心、表管理、`doc_id` 语义、查询/更新/删除、存储后端、中间件 |

**为什么这样判**：这是少数「规格直接告诉你测试规模」的题（[原文件 L183](../03-nl2repo-bench.md#L183)）。204 个用例的密度逼着模型把 `doc_id` 语义、多表、存储后端都写对——只实现 CRUD 表面 API 大概只能过一半。规格里的「204 test cases」和 `test_case_count.txt` 的 204 对齐，也说明这一题的规格是从上游仓库元信息反写出来的。

### 6.4 `flask-restful`（Medium，362 个测试）——完整 Web 框架层

**一句话背景**：复刻一个完整的 Flask 扩展层（路由 + 解析 + 序列化 + 内容协商 + CORS + 加密），API 覆盖面在 16 题里位居前列。

**规格原文**（节选）：

> Flask-RESTful is an extension library based on Flask, designed to help developers quickly and concisely build REST APIs. It provides one-stop capabilities such as resource abstraction, parameter parsing, data serialization, error handling, content negotiation, CORS, and encryption tools...
>
> 1. Resource and Route Management: Support defining RESTful resources by inheriting from the `Resource` class. Support multiple routes, path parameters, endpoint naming, and Blueprint integration.
> 2. Parameter Parsing and Validation: Support `reqparse.RequestParser` ... type conversion, default values, required fields, choices, actions, trimming, nullability, and file uploads.
> 3. Data Serialization and Field Definition: Support `fields` ... `String`, `Integer`, `Float`, `Boolean`, `DateTime`, `Url`, `Nested`, `List`, `Raw`, `Fixed`, `Arbitrary`, `FormattedString`.
> 4. Response Format and Content Negotiation: JSON and XML; automatic negotiation based on `Accept`; custom JSON serialization.
> 5. Error Handling ... `abort`, custom error responses, signal chains.
> 6. CORS Support via `crossdomain`.
> 7. Encryption Tools: AES.
> 8. Input Types and Validation: regex, ranges, booleans, dates, natural numbers, positive numbers.
> ...
> - `flask_restful/__init__.py` ... **must export** `Api`, `Resource`, `fields`, `reqparse`, `inputs`, `marshal`, `marshal_with`, `abort`, `utils` ...

（[原文件 L189-L200](../03-nl2repo-bench.md#L189-L200)）

**中文翻译**（要点）：

> Flask-RESTful 是基于 Flask 的扩展库，用于快速构建 REST API，提供资源抽象、参数解析、序列化、错误处理、内容协商、CORS、加密等能力。
>
> 要实现：Resource/路由（多路由、路径参数、endpoint、Blueprint）；`reqparse`（类型转换、默认值、必填、choices、actions、trim、可空、文件上传）；`fields`（String/Integer/Float/Boolean/DateTime/Url/Nested/List/Raw/Fixed/Arbitrary/FormattedString）；JSON/XML 响应与 `Accept` 协商；`abort`/自定义错误/信号链；`crossdomain` CORS；AES 加密；inputs 校验；`flask_restful/__init__.py` 必须导出 `Api`、`Resource`、`fields`、`reqparse`、`inputs`、`marshal`、`marshal_with`、`abort`、`utils`，并在 `__version__.py` 提供版本号。

（[原文件 L202-L206](../03-nl2repo-bench.md#L202-L206)）

**判分点**：

| 项目 | 值 |
| :-- | :-- |
| `test_case_count.txt` | **362** |
| 测试命令 | `pytest --continue-on-collection-errors`（**不带 `tests` 路径**，跑仓库默认收集） |
| 覆盖行为 | 路由/Blueprint、`reqparse` 全参数、`fields` 12 种字段、JSON/XML 协商、`abort`/错误处理、`crossdomain`、AES、inputs 校验 |

**为什么这样判**：这题要复刻一个完整的 Web 框架层，API 覆盖面在 16 题里位居前列（[原文件 L208](../03-nl2repo-bench.md#L208)）。注意它的测试命令**不带路径**，意味着 pytest 按仓库默认规则收集——模型如果把测试文件放错位置或改了 `pytest.ini`，收集结果会直接变化。这也是「测试命令是判分契约的一部分」的典型例子。

### 6.5 `python-slugify`（Easy，82 个测试）——Unicode → URL slug

**一句话背景**：小体量、高确定性的转换库，适合作为 NL2Repo 的第一道冒烟题；考「Unicode 映射表 + 边界规则 + CLI」三件事同时对齐。

**规格原文**（节选）：

> Python-Slugify is a Python library **for slugifying Unicode strings**, capable of intelligently converting text in various languages (including Chinese, Russian, French, etc.) into URL-friendly slug formats... (for example, converting "影師嗎" to "ying-shi-ma" and "C'est déjà l'été." to "c-est-deja-l-ete" through the slugify() function).

（[原文件 L214](../03-nl2repo-bench.md#L214)）

**中文翻译**：

> Python-Slugify 是把 Unicode 字符串转成 URL slug 的库，能把中文、俄语、法语等文本智能转成 ASCII slug，例如 `"影師嗎"` → `"ying-shi-ma"`、`"C'est déjà l'été."` → `"c-est-deja-l-ete"`。

（[原文件 L216-L218](../03-nl2repo-bench.md#L216-L218)）

规格还要求：HTML 实体/十进制/十六进制编码解析；`slugify()` 支持自定义分隔符、最大长度、词边界截断、停用词过滤；引号/数字/标点处理；自定义替换规则（如 `[['|', 'or'], ['%', 'percent']]`）与正则过滤；完整 CLI（`--separator`、`--max-length`、`--word-boundary`、`--stopwords`、`--replacements`、`--allow-unicode`）；`slugify/__init__.py` 导出 `slugify`、`DEFAULT_SEPARATOR`、`smart_truncate`；`special.py` 里要有 `PRE_TRANSLATIONS`、`CYRILLIC`、`GERMAN`、`GREEK` 等常量（[原文件 L220](../03-nl2repo-bench.md#L220)）。

**判分点**：

| 项目 | 值 |
| :-- | :-- |
| `test_case_count.txt` | **82** |
| 测试命令 | `pytest --continue-on-collection-errors test.py`（**目标是 `test.py` 而不是 `tests/`**） |
| 覆盖行为 | Unicode 转换表（中/俄/法）、HTML 实体解码、分隔符/长度/词边界/停用词、替换规则、CLI 参数、常量导出 |

**为什么这样判**：这题小，但「Unicode 转换表 + 边界规则 + CLI」都得对，适合作为 NL2Repo 的第一道冒烟题（[原文件 L222](../03-nl2repo-bench.md#L222)）。测试命令指向**单个文件** `test.py`，说明这一题的上游测试是单文件结构——模型必须产出同名可导入模块，否则收集阶段就失败。

## 7. 口径陷阱与已知问题

### 7.1 四个必记陷阱

| # | 陷阱 | 后果 | 正确做法 |
| --: | :-- | :-- | :-- |
| 1 | **官方 harness + 全量 104 题 vs 离线 16 题改写测试命令** | 两边不可比；离线版把 `pip install -e .` 改成 `--no-build-isolation --no-index`，且只跑 16 题 | 报告里必须写「16/104 子集 + 离线改写命令 + 内网端点」，不得对官方榜 |
| 2 | **collection error 记 error 不归零** | 一个 import 错误不会让整题 0 分，但会让该文件所有用例变成 error，分数虚低 | 看 `errors` 字段定位「装得上但 import 崩」；别把低分全归因于模型 |
| 3 | **无轮数上限 → 成本极不稳定** | 同一题不同模型可能差一个数量级；`max_iterations=8` 的冒烟分严重低估 | 正式跑用默认 500 或更大；预算按实测 token 外推 |
| 4 | **模型看不到测试** | 不能靠「读测试反推 API」；规格漏写的细节只能靠常识猜 | 评估时接受「规格不完备」是题目的一部分，不要人工补规格 |

### 7.2 已知问题清单（原文件 §8）

1. **无 LICENSE**：仓库没有 LICENSE 文件（GitHub API 也是 null），严格说再分发/商用前需联系作者（[原文件 L295](../03-nl2repo-bench.md#L295)）。
2. **离线测试命令是改写版**（`--no-build-isolation --no-index`），与官方口径有差异，报告需注明（[原文件 L296](../03-nl2repo-bench.md#L296)）。
3. **`max_iterations` 影响分数**：官方模板默认 500，冒烟用 8；正式跑必须用默认/更大值，否则会低估（[原文件 L297](../03-nl2repo-bench.md#L297)）。
4. **结果无汇总**：`result/` 按 UUID 落盘，官方没有汇总脚本，平均通过率要自己算（[原文件 L298](../03-nl2repo-bench.md#L298)）。
5. **子集（16/104）**：横评可以，对榜不行（[原文件 L299](../03-nl2repo-bench.md#L299)）。
6. **冒烟分数不可用**：`results/nl2repo-smoke/` 里那次的 pytest 分数是「官方骨架镜像 + 联网失败」导致的，不是模型分（[原文件 L300](../03-nl2repo-bench.md#L300)）。

### 7.3 容易踩的字段坑

result JSON 里还有 `score` / `test_score` 字段，那是 harness 的原始字段（冒烟里是 1），**不要**把它当基准成绩；正式口径看 `pytest_results.success_rate`（[原文件 L113](../03-nl2repo-bench.md#L113)）。

### 7.4 与模型卡对比的正确姿势

不能直接比。模型卡用的是官方 harness + 特定模型/端点 + 全量 104 题；离线包是 16 题子集 + 内网端点，且测试命令是离线改写版（[原文件 L269-L270](../03-nl2repo-bench.md#L269-L270)）。要对比只能「同版本 + 同 harness + 同子集 + 同采样」。

## 8. 来源

### 8.1 本仓库内的原文件与证据

| 来源 | 用途 |
| :-- | :-- |
| [../03-nl2repo-bench.md](../03-nl2repo-bench.md) | 本分册的唯一底稿；所有数字均可在此逐条核对 |
| [../README.md](../README.md) | 五基准总览、5 层部件概念、跨基准口径警告 |
| [../../benchmark-guide.md](../../benchmark-guide.md) §3.5 | 主报告中的 NL2Repo 条目 |
| [../../second-batch-bundle.md](../../second-batch-bundle.md) §5 | 离线补丁（镜像源、volume 路径、并行）记录 |
| [../../third-batch-bundle.md](../../third-batch-bundle.md) | +6 题的补充记录 |
| `report/results/nl2repo-smoke/` | 端到端冒烟产物（**分数不可用**） |
| `report/results/nl2repo-parallel-smoke/` | 2 题并发机制验证 |

### 8.2 官方来源

| 来源 | 说明 |
| :-- | :-- |
| <https://github.com/multimodal-art-projection/NL2RepoBench> | 官方仓库（`test_files/`、`workspaces/`、`docker_self/`） |
| arXiv v2（2026-01-08） | 平均测试通过率与 Pass@1 count 的口径（[原文件 L305](../03-nl2repo-bench.md#L305)） |
| 官方 harness 源码 | `openhands/openhands_app.py`、`openhands/post_processor.py`、`main.py` |
| 官方测试镜像 | `ghcr.io/multimodal-art-projection/nl2repobench/<task>:1.0` |
| OpenHands 镜像 | `ghcr.io/all-hands-ai/openhands:0.56`、`ghcr.io/all-hands-ai/runtime:0.56-nikolaik` |

### 8.3 任务数据位置

```
E:\bench-bundle\data\nl2repo\harness\test_files\<task>\
├─ start.md
├─ test_files.json
├─ test_commands.json
└─ test_case_count.txt
```

（离线包不在本机时无法打开，本分册所有引文以原文件转录为准）

### 8.4 关键行号索引

| 主题 | 原文件位置 |
| :-- | :-- |
| 版本/题量/harness/口径 | [L3](../03-nl2repo-bench.md#L3) |
| 离线包现状 16/104 | [L4](../03-nl2repo-bench.md#L4) |
| 测什么（18.8k tokens 规格） | [L9](../03-nl2repo-bench.md#L9) |
| 与 DeepSWE / ProgramBench 区别 | [L11](../03-nl2repo-bench.md#L11) |
| 单题数据结构 | [L21-L27](../03-nl2repo-bench.md#L21-L27) |
| `test_commands.json` | [L31-L34](../03-nl2repo-bench.md#L31-L34) |
| collection error 说明 | [L36](../03-nl2repo-bench.md#L36) |
| harness 组件表 | [L40-L46](../03-nl2repo-bench.md#L40-L46) |
| 容器镜像 | [L50-L53](../03-nl2repo-bench.md#L50-L53) |
| 8 步生命周期 | [L59-L86](../03-nl2repo-bench.md#L59-L86) |
| 判分代码与字段 | [L92-L113](../03-nl2repo-bench.md#L92-L113) |
| 5 道题例 | [L117-L222](../03-nl2repo-bench.md#L117-L222) |
| 题例速览表 | [L224-L238](../03-nl2repo-bench.md#L224-L238) |
| 常见问题 Q1–Q10 | [L240-L270](../03-nl2repo-bench.md#L240-L270) |
| 离线跑法 | [L272-L291](../03-nl2repo-bench.md#L272-L291) |
| 口径陷阱 | [L293-L300](../03-nl2repo-bench.md#L293-L300) |
| 来源 | [L302-L309](../03-nl2repo-bench.md#L302-L309) |

> `# TODO verify`：① 各题官方 `test_commands.json` 原文（本分册只确认了 aiofiles / flask-restful / python-slugify 三题的命令形态，jsonlines 与 tinydb 未收录）；② 官方成本金额（原文件未给，需实测）；③ 9 类 Python 库的完整分类名单（原文件只给「9 类」，未逐类列出）。
