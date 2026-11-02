# ProgramBench：中文精读（测什么 · 怎么测）

> 版本：2026-10-22 更新 ｜ 官方题量：**200 个实例 / 24.8 万+ 条行为测试** ｜ 官方 harness：**`programbench` CLI + mini-SWE-agent** ｜ 官方口径：主指标 **Resolved**（完全解出比例），辅助 **Almost resolved**（≥95%）与平均通过率（[原文件 L3](../04-programbench.md#L3)）
> 本分册整理自 [../04-programbench.md](../04-programbench.md)，数字可在原文逐条核对。

本分册只做「整理 + 翻译 + 口径对照」，不新增事实。`E:\bench-bundle` 离线包不在本机，所有测试片段与断言均转录自原文件；凡原文标 `# TODO verify` 的地方，本分册原样保留。

---

## 1. 它到底测什么

一句话：**只给一个编译好的可执行文件 + 它的文档，让 agent 从零写出一个行为等价的程序。**

官方定义（英文原文）：

> Given only a compiled binary and its documentation, agents must architect and implement a complete codebase that reproduces the original program's behavior.
> （[原文件 L9](../04-programbench.md#L9)）

中文：**仅给定一个已编译的二进制及其文档，agent 必须自行设计架构、实现完整代码库，复现原程序的行为。**（[原文件 L10](../04-programbench.md#L10)）

注意这句话里三个词的分量：

- **architect**：架构自己做——没有类骨架、没有方法签名、没有 PRD、没有文件布局说明（[原文件 L16](../04-programbench.md#L16)）；
- **complete codebase**：交的不是补丁、不是片段，是一整个能构建出可执行文件的工程；
- **reproduces behavior**：判分只看行为，不看源码长什么样、用什么语言写。

### 1.1 四个考点

| 考点 | 在题里表现成什么 | 判分器怎么看到 |
| :-- | :-- | :-- |
| **黑盒行为推断** | 只能运行二进制、喂输入、观察输出，从输入/输出反推规则 | 隐藏 pytest 对同一输入的 stdout/stderr/退出码断言 |
| **CLI 语义精度** | 退出码 0/1/2 的分工、stdout 与 stderr 分流、帮助文本逐字节一致 | `returncode == 2`、`r.stderr == ""`、`r.stdout == expected`（golden 文件比对） |
| **大型项目重建耐力** | 6 小时 / 1000 步内搭出整个代码库，并通过十几套独立测试 | 单实例全量测试必须 **100%** 通过才算 Resolved |
| **架构自主决策** | 语言、模块划分、数据结构、shell 集成全部自选 | 只认 `/workspace/executable` 这一个产物 |

### 1.2 cleanroom：怎么保证是「真重建」而不是抄

评测环境叫 cleanroom（洁净室），四个硬约束缺一不可（[原文件 L22-L27](../04-programbench.md#L22-L27)）：

| 元素 | 约束 | 目的 |
| :-- | :-- | :-- |
| **可执行二进制** | 只有**执行权限**，没有读权限；`strings` / `objdump` / `hexdump` / 反编译器全部失败 | 禁止「反编译片段拼接」式作弊 |
| **文档** | 该程序的 README / man page 等，是模型**唯一**的信息来源 | 把「读源码」换成「读文档 + 做实验」 |
| **网络** | 断网；不能 clone 源码、不能经包管理器下载代码 | 防止直接拉原仓库 |
| **工作区** | 没有项目源码；模型自己选语言、写源码和构建脚本 | 强制从零设计 |

官方原话（英文）：

> The executable that is given to the agent only has execution, not read permissions. That means that any operation that is not execution (such as running a decompiler, disassembler, `objdump`, `strings`, or `hexdump`) will fail.
> （[原文件 L31](../04-programbench.md#L31)）

中文：**交给 agent 的可执行文件只有执行权限、没有读权限。任何非执行操作（跑反编译器、反汇编器、`objdump`、`strings`、`hexdump`）都会失败。**（[原文件 L31](../04-programbench.md#L31)）

不可读 + 断网 + 无源码，再加上「只按行为判分」，共同把任务锁死成：**只能通过实验推断行为，再自己实现出来**。断网是补上的限制——官方在早期实验里发现模型会 clone GitHub 或通过包管理器下载源码（[原文件 L324](../04-programbench.md#L324)）；二进制读权限则是为了防止「把反编译片段拼起来」（[原文件 L321](../04-programbench.md#L321)）。

### 1.3 它不考什么

- **不考 LLM judge**：判分器就是 pytest（`eval/run.sh` 直接 `pytest eval/tests/`），没有裁判模型参与（[原文件 L42-L50](../04-programbench.md#L42-L50)）。这一点和 HLE 那类「模型当裁判」的基准完全不同。
- **不考代码风格、不考架构优劣**：源码不可见也不评分，测试只看程序行为（[原文件 L68](../04-programbench.md#L68)）。
- **不考「能编译」**：能编译只是前提，最终要的是行为等价。

### 1.4 与 NL2Repo 的分界

NL2Repo 给完整自然语言规格（目录树、API 说明），属于「照规格施工」；ProgramBench **不给任何结构提示**——没有方法签名、没有类骨架、没有 PRD、没有文件布局说明（[原文件 L16](../04-programbench.md#L16)），属于「自己定规格 + 自己施工 + 自己验收」。所以同一模型在 NL2Repo 上的分数不能拿来推断 ProgramBench 分数。

---

## 2. 测试集规模（题量 / 测试数据 / 时间 / 成本）

### 2.1 规模总表

| 项目 | 数值 | 出处 / 说明 |
| :-- | :-- | :-- |
| 实例数 | **200** 个 | 从 `jq`、`ripgrep`、`fzf` 这类小工具到 FFmpeg、SQLite、PHP 解释器（[L12](../04-programbench.md#L12)） |
| 行为测试条数 | **24.8 万+ 条** | 由 **agent 驱动的 fuzzing** 生成，参考程序本身全过（[L13](../04-programbench.md#L13)） |
| 复杂度分布 | 几千行小仓库 → 几万行中型项目 → 巨型软件 | 三档都有（[L14](../04-programbench.md#L14)） |
| 单题时限 | **6 小时 / 1000 步** | 官方 FAQ（[L339](../04-programbench.md#L339)） |
| 单题资源 | 20 CPU / 60GB 内存 | 官方 FAQ（[L339](../04-programbench.md#L339)） |
| 单题平均成本 | **$36.36/题**（Claude Opus 5.5 xhigh） | 官方成绩表（[L93](../04-programbench.md#L93)） |
| 200 题总成本 | 约 **$7.3k** | `$36.36 × 200`，官方 FAQ 口径（[L339](../04-programbench.md#L339)） |
| 平台 | **仅 linux/amd64** | 镜像只构建 amd64（[L37](../04-programbench.md#L37)） |
| 镜像体积 | 单题约 **4.2GB** | 离线包只挑 5 题的原因之一（[L348](../04-programbench.md#L348)） |
| 离线包题量 | **5/200** | zoxide、cmatrix、zip-password-finder、jq、ripgrep（[L4](../04-programbench.md#L4)） |
| 测试数据 | HuggingFace `programbench/ProgramBench-Tests`（MIT、非 gated） | 每实例一个 `tests/*.tar.gz`（[L38](../04-programbench.md#L38)） |

> 成本是按官方公开单价与用量估算出来的**估算值**，不是报价单；不同模型差 5 倍以上（Opus 5.5 $36.36 vs GPT-5.6 Sol $6.08），见 §2.2。

### 2.2 官方榜（agent = mini-SWE-agent）

| 模型 | Resolved | Almost（≥95%） | 平均成本/题 |
| :-- | --: | --: | --: |
| Claude Opus 5.5 (xhigh) | **18.5%** | 70.5% | $36.36 |
| Claude Fable 5.1 (xhigh) | 9.0% | 55.5% | $56.84 |
| GPT 6 Astra (max) | 5.0% | 52.5% | $11.47 |
| GPT-5.6 Sol (xhigh) | 1.0% | 15.5% | $6.08 |

（数据抓取于 2026-11-01，[原文件 L89-L96](../04-programbench.md#L89-L96)）

两个观察：① **Resolved 极低**（最高 18.5%）但 **Almost 很高**（70.5%），说明模型能复刻「大部分行为」，总差最后几个百分点；② **成本与分数不成正比**（Fable 5.1 更贵 $56.84 却只有 9.0%，Opus 5.5 更便宜且更高）。

### 2.3 单题最好成绩（官方任务页）

官方任务页的历史最好成绩：ripgrep **100%**、zoxide 99%、fzf 99%、jq 98%（[原文件 L98](../04-programbench.md#L98)）。这说明题目**可解**，只是极难；`100%` 意味着 200 题里确实有少数被完全解出（Resolved = 1）。注意「历史最好」是**别人提交过的最好成绩**，不是当前模型成绩。

---

## 3. 单题结构：给什么 → 做什么 → 交什么 → 怎么判

### 3.1 一图流

| 环节 | 内容 |
| :-- | :-- |
| **给什么** | 一个可执行二进制（仅可执行）+ 该程序的文档（README / man / `--help` 输出可现场跑） |
| **做什么** | 任意运行二进制做实验 → 推断 CLI 语义与内部规则 → 自选语言写完整代码库 → 构建出可执行文件 |
| **交什么** | `/workspace/executable`（行为等价的新程序）；整个 workspace 打包成 `submission.tar.gz`（[L40](../04-programbench.md#L40)） |
| **怎么判** | `programbench eval <run-dir>` → 隐藏 pytest 黑盒调用 `/workspace/executable`，逐条断言 stdout / stderr / 退出码 / 文件系统副作用 |

### 3.2 目录结构（示意）

```
<instance>/                          # 例：ajeetdsouza__zoxide.67ca1bc
└── tests/
    ├── a9c8e0729570.tar.gz          # 一套独立的 eval/run.sh + eval/tests/
    └── aa89e180e290.tar.gz          # 又一套独立测试分支
        eval/                        # 每个 tar.gz 解包后都是一整套：
        ├── run.sh                   # 判分入口：cd /workspace && pytest eval/tests/
        ├── tests/
        │   ├── test_<program>.py    # 黑盒行为断言
        │   ├── golden/              # 逐字节比对的期望文件（如 help.txt / version.txt）
        │   └── test-files/          # 测试资源（如已知密码的 zip、字典、charset）
        └── results.xml              # pytest --junitxml 输出

/workspace/                          # cleanroom 容器内，模型的工作区
├── executable                       # ← 唯一必须存在的产物
└── ...                              # 模型自选的源码、构建脚本、依赖
```

结构依据：原文件 §2.2 的 `eval/run.sh` + `eval/tests/test_<program>.py` + 原仓库快照（[L39](../04-programbench.md#L39)）、jq 的 `golden/help.txt`（[L172](../04-programbench.md#L172)）、zip 的 `test-files/`（[L316](../04-programbench.md#L316)）。

### 3.3 判分器怎么调用被测程序

测试全部以**黑盒**方式调用 `/workspace/executable`，不 import 模型代码（[原文件 L54-L66](../04-programbench.md#L54-L66)）：

```python
EXECUTABLE = "/workspace/executable"

def run(*args, stdin=None, env=None, cwd=None, timeout=5.0):
    full_env = os.environ.copy()
    if env:
        full_env.update(env)                  # 测试可注入 _ZO_DATA_DIR 等环境变量
    return subprocess.run([EXECUTABLE, *args],
                          input=stdin.encode() if isinstance(stdin, str) else stdin,
                          capture_output=True, timeout=timeout, env=full_env, cwd=cwd)
```

所以模型交的不是「代码」，而是**一个行为等价的程序**；测试只看 stdout / stderr / exit code / 文件系统副作用（[L68](../04-programbench.md#L68)）。

### 3.4 一个任务 = 多套独立测试分支

ProgramBench 不是「一个任务一套测试」，而是**一个任务多套独立测试分支**。离线包里每个实例的 `tests/` 下都有多个 `*.tar.gz`，每个 tar 是一套独立的 `eval/run.sh` + `eval/tests/`（[L152-L154](../04-programbench.md#L152-L154)）：

| 实例 | 测试分支数 |
| :-- | --: |
| `ajeetdsouza__zoxide` | **2** |
| `jqlang__jq` | **12** |
| `burntsushi__ripgrep` | **13** |
| `abishekvashok__cmatrix` | **14** |
| `agourlay__zip-password-finder` | **16** |

`eval.json` 里对应 `test_branches` 列表（zoxide 那次是 `a9c8e0729570` + `aa89e180e290`），逐条结果带 `branch` 字段。多分支的意义是**避免单一测试套件的盲区**：同一程序被十几套独立生成的测试从不同角度考，某一套漏掉的错误行为，另一套可能抓到（[L164](../04-programbench.md#L164)）。

对做题者的直接影响：**不能针对一套测试过拟合**。比如只把 `--help` 硬编码成某个分支期望的样子，另一个分支的 golden 文本就会挂。

---

## 4. 怎么测：一次评测的完整流程

### 4.1 官方流程（六步）

1. **拉镜像 / 起 cleanroom 容器**：从 `programbench/<owner>_1776_<repo>.<hash>:task_cleanroom_v6` 启动；容器内只有二进制 + 文档 + 无源码的工作区，断网（[L37](../04-programbench.md#L37)、[L72](../04-programbench.md#L72)）。
2. **agent 探索**：官方基线是 mini-SWE-agent；agent 可以**任意运行二进制**、喂输入、观察输出。官方强调「没有隐藏的东西，都能通过实验发现」（[L73](../04-programbench.md#L73)）——这正是题目可解的前提。
3. **agent 实现**：自己选语言、设计架构、写全部源码与构建脚本，最终产出 `/workspace/executable`（[L74](../04-programbench.md#L74)）。
4. **提交**：把 workspace 打包成 `submission.tar.gz`（[L75](../04-programbench.md#L75)）。
5. **判分**：`programbench eval <run-dir>` 把提交放进评测环境，跑隐藏 pytest；每条测试是一个独立用例（[L76](../04-programbench.md#L76)）。
6. **计分**：按 §5 的公式算 `Score` / `Resolved` / `Almost resolved`。

### 4.2 实际敲命令（离线包口径）

```bash
# 1) 拉/载入 5 个任务镜像（离线包 images/ 里）
./offline/load_bundle.sh "$PWD"

# 2) 跑 agent（mini-swe-agent，串行）
mini-extra programbench --model "openai/<模型名>" \
  --filter "ajeetdsouza__zoxide|abishekvashok__cmatrix|agourlay_zip|jqlang__jq|burntsushi__ripgrep" \
  --workers 1 -c <mini-swe 配置文件>

# 3) 判分
programbench eval <run-dir>
```

### 4.3 离线包对官方流程做了哪些改动

| 改动 | 原因 |
| :-- | :-- |
| 任务镜像重打「离线 eval 修复」层：预装 `pytest-timeout` + 本地 wheelhouse + `/etc/pip.conf` 禁网 | 官方 `eval/run.sh` 会 `pip install pytest-timeout`，断网必失败（曾报 `results_read_failed`）（[L369](../04-programbench.md#L369)） |
| 覆盖 `environment.run_args`，去掉 `--cpus/--memory/--memory-swap` | 官方默认 20 CPU / 60GB，小机器会 `docker run exit 125`（[L370](../04-programbench.md#L370)） |
| 测试 blob 预下载到 `data/programbench_blobs/<instance>/` | 用 `PROGRAMBENCH_BLOB_DIR` 指向本地，`blob sync` 只校验不下载（[L371](../04-programbench.md#L371)） |

### 4.4 一次真实运行的时间线（我们自己的 zoxide）

模型 Ark `deepseek-v4-flash` + mini-swe-agent 2.4.6，参数 `step_limit=40`、墙钟 900 秒；结局是**到步数上限自动提交**，Score 56/531（[L150](../04-programbench.md#L150)）。这不是模型能力上限，提高 `step_limit` 后分数会更高——引用这个数时**必须同时写 40 步 / 900 秒**。

---

## 5. 判分机制与分数怎么算

### 5.1 三个指标

对第 `i` 个实例，设该实例被测用例数为 `total_i`、通过数为 `passed_i`：

| 指标 | 定义 | 性质 | 用途 |
| :-- | :-- | :-- | :-- |
| **Score** | `passed_i / total_i` | 连续值 0–1 | 诊断「差多少」（[L81](../04-programbench.md#L81)） |
| **Resolved** | `1` 当且仅当 `passed_i == total_i`，否则 `0` | 0/1 | **官方主指标**，决定榜单名次（[L82](../04-programbench.md#L82)） |
| **Almost resolved** | `1` 当且仅当 `passed_i / total_i ≥ 0.95` | 0/1 | 参考指标，官方明确它「只是方向」，不能替代 Resolved（[L83](../04-programbench.md#L83)） |

聚合方式：官方榜先按 **Resolved 比例**排序，Almost 第二、平均通过率第三（[L82](../04-programbench.md#L82)）。

### 5.2 为什么主指标不看平均通过率

官方解释（原文为中文意译）：

> 每个实例都包含很简单的测试（比如检查 `--help` 是否存在、`--version` 是否输出）。如果报平均通过率，会严重误导——一个只实现了 CLI 骨架的程序也能拿到不低的通过率。而「全过」才代表真的重建了这个程序。
> （[原文件 L85-L87](../04-programbench.md#L85-L87)）

这条解释和 §6 的题例完全对得上：几乎每道题的第一条断言都是「`--help` 退出码 0」「`--version` 里有版本号」，这些是「白送分」；真正难的是排序算法、数据库格式、错误文案、TUI 渲染。

### 5.3 实例：zoxide 的两个数字

我们那次实测（[原文件 L144-L150](../04-programbench.md#L144-L150)）：

| 口径 | 数字 | 含义 |
| :-- | :-- | :-- |
| 控制台 | `Score 56 (531 tests)` | 531 个用例里过 56 个，约 **10.5%** |
| 归档 `eval.json` | **577 条**逐条记录（`a9c8e0729570` 137 条 + `aa89e180e290` 440 条），其中 **335 passed**、242 failure，`solution_branch=submission` | 原始记录，335/577 ≈ **58.1%** |

两个数字**对不上**（531 vs 577、56 vs 335/577），原文件标了 `# TODO verify`：官方 `programbench eval` 的聚合口径（可能按分支/去重/过滤后的子集计分）尚未确认（[L147-L148](../04-programbench.md#L147-L148)）。引用时以控制台 `Score 56 / 531 tests` 为准，并注明 `eval.json` 的 577 是原始逐条记录。

### 5.4 「99% 通过也只算 Almost」

官方原话的意思是：一个 **15,000 条测试** 的任务，即使 99% 通过，Resolved 仍然是 **0**，只能算 Almost resolved（[L333](../04-programbench.md#L333)）。这就是 Resolved 最高只有 18.5% 的直接原因——不是「答错很多」，而是「必须一条不漏」。

### 5.5 多分支时怎么算总分（unknown）

多套测试分支如何合并成单实例的 `Score`（全部用例合并？按分支平均？取最差分支？），原文件**没有给出确定答案**，线上表现就是 §5.3 的 531 vs 577 差异。引用时只取同一 `programbench` 版本、同一 `eval` 命令产出的**控制台 Score**，不把 `eval.json` 的逐条通过率与官方 Resolved 混比；要精确复现就先跑一次 `programbench eval` 确认口径（`# TODO verify`）。

---

## 6. 真实题面（英中对照翻译）

ProgramBench 没有「一段自然语言题面」——**题面就是二进制 + 文档**，真正的验收标准写在隐藏测试里。下面 5 道题按离线包实例逐一给出：背景、测试原文（逐字英文）、中文翻译、判分点、为什么这样判。

> 官方对「可解性」的说明：agent 可以用任意输入运行给定程序并观察行为；没有隐藏的东西是实验发现不了的。（[原文件 L327](../04-programbench.md#L327)）

### 6.1 例 1：`ajeetdsouza__zoxide.67ca1bc`（2 个测试分支）

**背景**：zoxide 是目录跳转工具（`z foo` 跳到最常去的匹配目录），按访问频率与最近使用给目录打分；它还要负责 shell 集成（`init bash/zsh/fish/powershell`）和本地数据库持久化。

**被逐字钉死的英文文案**：

> `zoxide`、`COMMAND`、`no match found`、`not a directory`、`could not open database for importing`

**测试原文（`eval/tests/test_zoxide.py`，节选逐字；[原文件 L112-L132](../04-programbench.md#L112-L132)）**：

```python
def test_no_args_shows_help_on_stderr(self):
    """无参数时把帮助打到 stderr，并返回退出码 2"""
    result = run()
    assert result.returncode == 2
    assert b"zoxide" in result.stderr
    assert b"COMMAND" in result.stderr   # 连帮助文本的段落标题都要对

def test_add_with_symlink_resolved(self):
    """带 _ZO_RESOLVE_SYMLINKS=1 时，存解析后的真实路径，不存链接本身"""
    ...
    assert b"/tmp" in list_result.stdout
    assert str(link).encode() not in list_result.stdout

def test_query_returns_best_match(self):
    """add /tmp 后 query tmp 必须返回 /tmp"""
    td.run("add", "/tmp")
    result = td.run("query", "tmp")
    assert result.returncode == 0
    assert b"/tmp" in result.stdout
```

**中文翻译**：

- 不带任何参数运行 → 帮助信息输出到 **stderr**（不是 stdout），退出码 **2**（不是 0），且文本里必须出现 `zoxide` 和 `COMMAND`；
- `_ZO_RESOLVE_SYMLINKS=1` 时，`add` 一个符号链接 → 数据库里存**解析后的真实路径**，`query` 结果里**不能**出现链接路径；
- `add /tmp` 后 `query tmp` → 退出码 0，stdout 含 `/tmp`。

**判分点**：

| 断言 | 钉死的是什么 |
| :-- | :-- |
| `returncode == 2` | 无参数属于用法错误，走「错误退出」路径，而不是打印帮助后成功退出 |
| `stderr` 而非 stdout | 帮助/错误的分流约定；很多重建实现会图省事打到 stdout，直接挂 |
| `COMMAND` 段落 | 帮助文本不只是「包含程序名」，连 `COMMAND` 这个小标题都要有 |
| 符号链接解析 | `_ZO_RESOLVE_SYMLINKS` 环境变量的真实语义（存真实路径） |
| `query` 结果 | 打分/匹配逻辑的最低要求：至少能命中最相关目录 |

**为什么这样判**：zoxide 的行为几乎全在 CLI 契约里（退出码、stderr 分流、环境变量、数据库），而这些恰好是「只跑二进制做实验」能观察到的东西。测试不要求实现细节一致，只要求外部行为一致——所以这套断言既严格又公平。

**这一题的规模**（[原文件 L104-L108](../04-programbench.md#L104-L108)）：15 个测试类（`TestBasicInvocation`、`TestAddCommand`、`TestQueryCommand`、`TestRemoveCommand`、`TestImportCommand`、`TestInitCommand`、`TestEditCommand`、`TestEnvironmentVariables`、`TestDatabasePersistenceAndFormat`、`TestRankingAndScoring`、`TestQueryKeywordMatching`、`TestErrorHandling`、`TestSubcommandHelpAndVersion`、`TestEdgeCases`）；137 个测试函数，参数化展开后控制台按 **531 个用例**计分。（原文写「15 个测试类」，但实际列出的名字是 14 个，缺 1 个未列；此处照原文数字保留。）

**模型要复刻的核心难点**（[原文件 L136-L142](../04-programbench.md#L136-L142)）：rank/recency 打分（`--score` 输出分数、`_ZO_MAXAGE` 触发衰减）、`db.zo` 的二进制/文本格式与跨会话持久化、错误码与错误文案、`--help` 的段落与子命令顺序、`init bash/zsh/fish/powershell` 的 shell 集成输出（实测中 init 相关测试挂得最多）。

**实测结果**：Score 56/531，未 Resolved（[L146](../04-programbench.md#L146)）。

### 6.2 例 2：`jqlang__jq.b33a763`（12 个测试分支）

**背景**：jq 是 JSON 命令行处理器，`jq '.a'` 从 stdin 读 JSON、输出过滤结果；它的 `--help` / `--version` 文本、错误退出码、流式多值输出都是被脚本依赖的稳定契约。

**测试原文（`test_cli_basics.py`，逐字）**：

```python
def test_help_exact(golden_dir: Path):
    expected = read_text(golden_dir / "help.txt")
    r = run_jq(["--help"], stdin=None)
    assert r.returncode == 0
    assert r.stderr == ""
    assert r.stdout == expected          # 帮助文本必须逐字节一致

def test_version_exact(golden_dir: Path):
    expected = read_text(golden_dir / "version.txt")
    r = run_jq(["--version"], stdin=None)
    assert r.returncode == 0
    assert r.stderr == ""
    assert r.stdout == expected

def test_invalid_option_errors():
    r = run_jq(["--definitely-not-a-real-flag"], stdin=None)
    assert r.returncode != 0
    assert r.stdout == ""
    assert "--definitely-not-a-real-flag" in r.stderr
```

**核心语义测试（另一套分支 `test_filters_and_io.py`，逐字；[原文件 L170-L208](../04-programbench.md#L170-L208)）**：

```python
@pytest.mark.parametrize("stdin,filter_expr,expected", [
    ("1\n",       ".",   "1\n"),
    ("\"a\"\n",   ".",   "\"a\"\n"),
    ("{\"a\":1}\n", ".a", "1\n"),
    ("[1,2,3]\n", ".[]", "1\n2\n3\n"),
])
def test_basic_filters(stdin, filter_expr, expected):
    r = run_jq([filter_expr], stdin=stdin)
    assert r.returncode == 0
    assert r.stderr == ""
    assert r.stdout == expected
```

**中文翻译**：

- `--help`：退出码 0、stderr 必须为空、stdout 必须与 `golden/help.txt` **逐字节相同**（一个空格、一个换行都不能差）；
- `--version`：同上，比对 `golden/version.txt`；
- 未知参数：非零退出、stdout 为空、stderr 里必须回显这个参数名；
- 基本过滤器：`.` 原样输出、`.a` 取字段、`.[]` 展开数组，每个值后跟换行。

**判分点**：

| 断言 | 钉死的是什么 |
| :-- | :-- |
| `r.stdout == expected`（help/version） | 帮助与版本文本是**精确契约**，不是「包含关键字即可」 |
| `r.stderr == ""` | 正常路径不允许有警告噪音 |
| `returncode != 0` + `stdout == ""` | 错误路径必须干净：错误只走 stderr |
| 参数回显 | 错误信息要把用户输入的 flag 带出来，便于脚本定位 |
| `test_basic_filters` 4 组参数 | jq 的**核心语义**：JSON 值 → 过滤器 → 分行的 JSON 输出 |

**为什么这样判**：jq 被大量 shell 脚本依赖，`--help`/`--version` 与错误行为属于「机器可读接口」，必须逐字节稳定；而 `.` / `.a` / `.[]` 是最小完备的过滤器集合，能同时验证解析器与输出格式。另外还有 `-n null`、空 stdin、多个 JSON 值分别处理等边界（[L210](../04-programbench.md#L210)）。

**最好成绩**：官方任务页显示 jq 历史最好 **98%**——非常接近，但仍未 Resolved（[L210](../04-programbench.md#L210)）。

### 6.3 例 3：`burntsushi__ripgrep.3b7fd44`（13 个测试分支）

**背景**：ripgrep 是高性能递归 grep，退出码有严格约定（0 有匹配、1 无匹配、2 用法错误），帮助文本很长（>5KB），版本输出还带 feature 信息。

**英文原文（被钉死的文本与用法）**：

> `ripgrep requires at least one pattern` ｜ `USAGE:` ｜ `features:` ｜ `simd`

**测试原文（`test_basic.py`，逐字；[原文件 L216-L251](../04-programbench.md#L216-L251)）**：

```python
def test_no_arguments_shows_usage():
    result = run()
    assert result.returncode == 2
    assert b"ripgrep requires at least one pattern" in result.stderr or b"pattern" in result.stderr.lower()

def test_simple_pattern_match_in_file():
    with TempDir() as tmp:
        test_file = tmp.create_file("test.txt", "hello world\nfoo bar\nhello again\n")
        result = run("hello", str(test_file))
        assert result.returncode == 0
        assert b"hello world" in result.stdout
        assert b"hello again" in result.stdout
        assert b"foo bar" not in result.stdout

def test_help_flag_long():
    result = run("--help")
    assert result.returncode == 0
    assert b"ripgrep" in result.stdout
    assert b"USAGE:" in result.stdout
    assert len(result.stdout) > 5000        # 长帮助至少 5KB

def test_version_flag():
    result = run("--version")
    assert result.returncode == 0
    assert b"ripgrep" in result.stdout
    assert re.search(rb'\d+\.\d+\.\d+', result.stdout)
    assert b"features:" in result.stdout or b"simd" in result.stdout

def test_simple_pattern_no_match():
    with TempDir() as tmp:
        test_file = tmp.create_file("test.txt", "hello world\n")
        result = run("xyz", str(test_file))
        assert result.returncode == 1       # 无匹配是 1，不是 0
        assert result.stdout == b""
```

**中文翻译**：

- 无参数：退出码 **2**，stderr 说明缺少 pattern；
- 在文件里搜 `hello`：退出码 0，stdout 含两个 `hello` 行，不含 `foo bar`；
- `--help`：退出码 0，含 `ripgrep` 与 `USAGE:`，**输出长度 > 5000 字节**（长帮助不能偷懒写成几行）；
- `--version`：退出码 0，含 `ripgrep`、符合 `x.y.z` 的版本号、以及 `features:` 或 `simd` 字样；
- 无匹配：退出码 **1**（grep 家族的语义，不是 0），stdout 必须为空。

**判分点**：

| 断言 | 钉死的是什么 |
| :-- | :-- |
| 退出码 0 / 1 / 2 三态 | ripgrep 最容易被脚本依赖的契约：匹配 / 未匹配 / 用法错误 |
| `len(result.stdout) > 5000` | 帮助文本的**体量**；只写 3 行 usage 会挂 |
| 版本号正则 | 版本输出格式必须像真程序，而不是 `version 1` |
| `features:` / `simd` | 版本信息里的构建特性说明也要复刻 |
| 无匹配时 `stdout == b""` | 无匹配不得输出任何内容（不能「没找到也打印提示」） |

**为什么这样判**：退出码是 grep 类工具的头号契约，0/1/2 一旦搞错，所有脚本都坏；帮助文本长度和版本格式则用来排除「只实现核心匹配、CLI 随便写」的半成品。另外还测递归目录搜索、`--help` 与 `-h` 的长短差异（[L253](../04-programbench.md#L253)）。

**最好成绩**：ripgrep 历史最好 **100%**，是 200 题里少数被完全解出的（[L253](../04-programbench.md#L253)）。

### 6.4 例 4：`abishekvashok__cmatrix.5c082c6`（14 个测试分支）——TUI 怎么测

**背景**：cmatrix 是「终端矩阵雨」屏保程序，没有常规的 stdin→stdout 输出，测试改用 **tmux 伪终端**：起一个会话跑 0.5 秒，抓屏，再按 `q` 退出。

**测试原文（逐字，含 tmux 辅助函数与执行类；[原文件 L259-L281](../04-programbench.md#L259-L281)）**：

```python
def run_in_tmux(args, duration=0.5):
    session_name = f"cmatrix_test_{os.getpid()}"
    tmux_cmd = ["tmux", "new-session", "-d", "-s", session_name, "-x", "80", "-y", "24"]
    tmux_cmd.extend(["./executable"] + list(args))
    subprocess.run(tmux_cmd, capture_output=True, timeout=2)
    time.sleep(duration)                       # 跑 0.5 秒
    capture = subprocess.run(["tmux", "capture-pane", "-t", session_name, "-p"],
                             capture_output=True, timeout=2)
    subprocess.run(["tmux", "send-keys", "-t", session_name, "q"], ...)   # 按 q 退出
    return start, capture

class TestActualExecution:
    def test_default_execution(self):
        start, capture = run_in_tmux([])
        assert start.returncode == 0
        assert len(capture.stdout) > 0          # 屏幕上确实有矩阵字符
        assert b"error" not in start.stderr.lower()

    def test_screensaver_mode(self):  run_in_tmux(["-s"]) ...
    def test_async_mode(self):        run_in_tmux(["-a"]) ...
    def test_bold_mode(self):         run_in_tmux(["-b"]) ...
```

**中文翻译**：

- 在 80×24 的 tmux 会话里启动 `./executable`，跑 0.5 秒，抓取当前屏幕内容，再发送 `q` 退出；
- 默认模式：启动进程返回码 0、屏幕上有输出（矩阵字符）、stderr 里不能有 `error`；
- 模式开关逐个验：`-s` 屏保、`-a` 异步、`-b` 加粗（另有 `-o` 旧式滚动、`-B`）。

**判分点**：

| 断言 | 钉死的是什么 |
| :-- | :-- |
| `len(capture.stdout) > 0` | 程序真的画出了东西，而不是启动后立刻退出 |
| `b"error" not in start.stderr.lower()` | 不能在终端里报错刷屏 |
| 各模式都能起来 | 14 个分支从不同角度覆盖 `-s/-a/-b/-o/-B` 等参数 |
| 按 `q` 可退出 | 交互程序的基本契约（tmux 里卡死会拖垮测试） |

**为什么这样判**：TUI 程序没有可断言的 stdout，只能通过**伪终端抓屏**把「视觉输出」变成文本断言。这也说明 ProgramBench 的黑盒测试不限于管道式 CLI——**终端交互程序一样能被覆盖**。模型要复刻的是「0.5 秒内画出矩阵、参数生效、`q` 退出」，而不是像素级画面。

### 6.5 例 5：`agourlay__zip-password-finder.704700d`（16 个测试分支）

**背景**：zip-password-finder 是 ZIP 密码破解工具，支持字典模式与字符集暴力模式，输出格式固定为 `Password found:<密码>`；帮助、版本与参数校验各有一套固定文案。

**英文原文（被逐字钉死的帮助文本片段）**：

> `Find the password of protected ZIP files` ｜ `--inputFile` ｜ `--passwordDictionary` ｜ `--charset` ｜ `Password found:ab`

**测试原文（`test_zip_password_finder.py`，逐字；[原文件 L290-L314](../04-programbench.md#L290-L314)）**：

```python
def test_help_output(self):
    result = run_executable(["--help"])
    assert result.returncode == 0
    assert "Find the password of protected ZIP files" in result.stdout
    assert "--inputFile" in result.stdout
    assert "--passwordDictionary" in result.stdout
    assert "--charset" in result.stdout

def test_version_output(self):
    result = run_executable(["--version"])
    assert result.returncode == 0
    assert "zip-password-finder" in result.stdout
    assert "0.10.3" in result.stdout

def test_missing_input_file(self):
    result = run_executable(["-w", "1"])
    assert result.returncode == 2
    assert "the following required arguments were not provided" in result.stderr
    assert "--inputFile" in result.stderr

def test_dictionary_finds_password(self):
    result = run_executable(["-i", ZIP_FILE_2, "--passwordDictionary", PASSWORD_DICT, "-w", "1"])
    assert result.returncode == 0
    assert "Password found:ab" in result.stdout
```

**中文翻译**：

- `--help`：退出码 0，stdout 含程序简介 `Find the password of protected ZIP files`，以及三个参数名 `--inputFile` / `--passwordDictionary` / `--charset`；
- `--version`：退出码 0，含程序名 `zip-password-finder` 与版本 `0.10.3`；
- 缺必填参数（只给 `-w 1`）：退出码 **2**，stderr 含 clap 的固定句 `the following required arguments were not provided`，并点名 `--inputFile`；
- 字典模式破解：给 zip、字典、`-w 1` → 退出码 0，stdout 含 `Password found:ab`。

**判分点**：

| 断言 | 钉死的是什么 |
| :-- | :-- |
| `--help` 的四个字符串 | 帮助文本的**具体措辞**，不是「有帮助就行」 |
| `0.10.3` | 版本号必须**精确复刻**（不是随便写个 1.0.0） |
| 缺参退出码 2 + 固定错误句 | 参数校验的错误文案与退出码来自程序固定的 CLI 行为，重建时要模仿（[L304-L308](../04-programbench.md#L304-L308)） |
| `Password found:ab` | 核心功能（真的解出密码）+ 输出格式（冒号后无空格）双重验证 |
| 测试自带 `test-files/` | 已知密码的 zip、charset 文件、密码字典——输出可被直接验证（[L316](../04-programbench.md#L316)） |

**为什么这样判**：这道题同时考「元信息」和「真功能」：帮助/版本/错误文案是低成本、高区分度的契约断言；而 `Password found:ab` 要求程序真的跑通 ZIP 解密与字典搜索，无法靠硬编码糊弄（字典文件内容在测试资源里，密码 `ab` 是已知答案，但硬编码输出会被其他分支的不同 zip/字典组合打穿——16 个分支从不同角度覆盖）。

---

## 7. 口径陷阱与已知问题

| # | 陷阱 | 具体说明 | 正确做法 |
| :-- | :-- | :-- | :-- |
| 1 | **Resolved 不是平均通过率** | 主指标是「全部测试通过」的实例比例；模型卡上的 29.1 没标口径，推测是平均测试通过率，**不能**与 Resolved 直接比（[L344-L345](../04-programbench.md#L344-L345)） | 引用任何 ProgramBench 分数前先确认是 Resolved、Almost 还是 Score |
| 2 | **模型卡 29.1 无法归类** | 官方主指标 Resolved 最高 18.5%，29.1 与该口径不符；原文只写「推测是平均测试通过率」（[L345](../04-programbench.md#L345)），没有官方确认 | 写成「未标口径，`# TODO verify`」，不当作官方结论 |
| 3 | **测试分支多，历史最好 100% 很少** | 200 题里只有 ripgrep 等少数达到 100%；zoxide 99%、jq 98%、fzf 99% 都仍不是 Resolved（[L98](../04-programbench.md#L98)） | 「Almost」不等于「解出」；不要用 99% 宣称已解决 |
| 4 | **$36.36/题是官方估算** | 来自官方成绩表（Opus 5.5 xhigh）与 FAQ 的 `$7.3k`；FAQ 还提到个别 run 到过 $5k，实测成本随 scaffold、步数、模型价格浮动（[L339](../04-programbench.md#L339)） | 写「按官方估算」，标注模型与日期，不当报价 |
| 5 | **离线 5 题子集不可比官方榜** | 5/200 且是中型程序（避开了 FFmpeg/duckdb/pandoc 这类超大项目）（[L348](../04-programbench.md#L348)） | 只能同子集横评，报告里写清 5 个实例名 |
| 6 | **我们的 Score 56 被截断** | 40 步 / 900 秒自动提交，不是模型上限（[L150](../04-programbench.md#L150)） | 引用时必须带 step_limit 与墙钟 |
| 7 | **`eval.json` 与控制台 Score 口径不一致** | 531 vs 577、56 vs 335（[L147-L148](../04-programbench.md#L147-L148)） | 以控制台为准，`eval.json` 只作原始记录；聚合口径 `# TODO verify` |
| 8 | **测试可扩充、存在假阴性** | 测试由 agent fuzzing 生成，官方说发现假阳性/假阴性就补测试（[L330](../04-programbench.md#L330)）；同一程序多分支也是为了补盲区 | 分数会随测试集版本变化，跨时间比较要锁任务版本 |
| 9 | **只有 linux/amd64** | 官方镜像只构建 amd64；Windows/macOS 需 WSL2 或远程 Linux，QEMU 模拟很慢（[L341-L342](../04-programbench.md#L341-L342)） | 本地跑必须先准备 amd64 环境 |
| 10 | **评测环境需要 `pytest-timeout` 且断网** | 官方 `eval/run.sh` 会 `pip install pytest-timeout`，断网会失败；离线包已用预装 + wheelhouse 修复（[L369](../04-programbench.md#L369)） | 自建环境先准备本地 wheel 源 |

---

## 8. 来源

- 本分册母本：[`../04-programbench.md`](../04-programbench.md)——版本/题量 [L3](../04-programbench.md#L3)、cleanroom [L20-L31](../04-programbench.md#L20-L31)、判分 [L79-L98](../04-programbench.md#L79-L98)、题例 [L100-L316](../04-programbench.md#L100-L316)、FAQ [L318-L348](../04-programbench.md#L318-L348)、离线跑法 [L350-L371](../04-programbench.md#L350-L371)、坑 [L373-L380](../04-programbench.md#L373-L380)
- 官方站：<https://programbench.com/>（About / FAQ / 任务页；2026-11-01 抓取）
- 官方论文：<https://arxiv.org/abs/2605.03546>
- 官方代码：<https://github.com/facebookresearch/ProgramBench>
- 测试数据：HuggingFace [`programbench/ProgramBench-Tests`](https://huggingface.co/datasets/programbench/ProgramBench-Tests)，revision `5954a1957b5e0d770ec2c5523506abd212806315`（MIT、非 gated）
- 任务测试（原文件转录自离线包，本机不可访问）：`E:\bench-bundle\data\programbench_blobs\ajeetdsouza__zoxide.67ca1bc\tests\*.tar.gz`（`eval/run.sh`、`eval/tests/test_zoxide.py`）
- 实测证据：`report/results/programbench-zoxide/`（`eval.json`、trajectory、submission、日志）
- 相关章节：[`../../benchmark-guide.md`](../../benchmark-guide.md) §3.4、[`../../first-batch-bundle.md`](../../first-batch-bundle.md) §8（zoxide 端到端与 5 个修复）、本目录 [`00-总览.md`](00-总览.md)

> 待核实（`# TODO verify`）：① `programbench eval` 对多测试分支的聚合口径（531 vs 577）；② 模型卡 29.1 的确切指标定义；③ 离线包 5 题在当前 harness 下的完整成本。以上均无官方确认，引用时保留原标注。
