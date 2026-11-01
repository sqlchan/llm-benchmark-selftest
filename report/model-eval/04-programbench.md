# ProgramBench：只给二进制和文档，把整个程序「重建」出来

> 版本：2026-10-22 更新｜题量：**200 个实例 / 24.8 万+ 条行为测试**｜官方 harness：**`programbench` CLI + mini-SWE-agent**｜官方主指标：**Resolved（完全解出的题数比例）**；辅助 Almost resolved（≥95%）与平均通过率
> 离线包现状：**5/200 题**（zoxide、cmatrix、zip-password-finder、jq、ripgrep），其中 zoxide 实测跑出 Score 56/531（未 resolved）。
> 本文引文：官方站 <https://programbench.com/>（2026-11-01 抓取）+ 包内 `data/programbench_blobs/` 测试文件 + `report/results/programbench-zoxide/` 实测证据。

## 1. 这个基准在测什么

**Given only a compiled binary and its documentation, agents must architect and implement a complete codebase that reproduces the original program's behavior.**
（只给一个编译好的二进制和它的文档，agent 必须自己设计架构、写完整代码库，复现原程序的行为。）

- 200 个实例，从 `jq`、`ripgrep`、`fzf` 这类小工具，到 FFmpeg、SQLite、PHP 解释器这种大型项目。
- 测试规模：24.8 万+ 条行为测试，**由 agent 驱动的 fuzzing 生成**；参考程序本身能全过。
- 三种复杂度都有：几千行的小仓库 → 几万行的中型项目 → 巨型软件。

它和 NL2Repo 的区别：NL2Repo 给完整自然语言规格（有目录树、API 说明），ProgramBench **不给任何结构提示**——没有方法签名、没有类骨架、没有 PRD、没有文件布局说明；模型要自己决定语言、抽象、模块划分和接口。

## 2. 评测系统的组成

### 2.1 cleanroom 容器里有什么

| 元素 | 说明 |
| :-- | :-- |
| **可执行二进制** | 只有**执行权限**，没有读权限；`strings` / `objdump` / `hexdump` / 反编译器全部失败 |
| **文档** | 该程序的文档（README / man page 等），是模型唯一的信息来源 |
| **网络** | 断网；不能 clone 源码、不能通过包管理器下载代码 |
| **工作区** | 工作区里没有项目源码；模型自己选语言、写源码和构建脚本 |

官方原话：

> The executable that is given to the agent only has execution, not read permissions. That means that any operation that is not execution (such as running a decompiler, disassembler, `objdump`, `strings`, or `hexdump`) will fail.

### 2.2 任务镜像与测试数据

| 组件 | 形式 |
| :-- | :-- |
| 任务镜像 | `programbench/<owner>_1776_<repo>.<hash>:task_cleanroom_v6`（Docker Hub `programbench` 组织；只构建 linux/amd64） |
| 测试数据 | HuggingFace `programbench/ProgramBench-Tests`（MIT、非 gated），每个实例一个 `tests/*.tar.gz` |
| 测试内容 | `eval/run.sh` + `eval/tests/test_<program>.py` + 原仓库快照（用于提供测试资源） |
| 提交物 | `submission.tar.gz`（整个 workspace）→ `programbench eval <run-dir>` 判分 |

`eval/run.sh` 的核心就是跑 pytest：

```bash
cd /workspace
pytest eval/tests/ \
    --junitxml=eval/results.xml \
    --timeout=5 --timeout-method=thread \
    -n auto -v
```

### 2.3 测试怎么调用被测程序

以 zoxide 的测试文件为例，测试都以黑盒方式调用 `/workspace/executable`（测试文件开头）：

```python
EXECUTABLE = "/workspace/executable"

def run(*args, stdin=None, env=None, cwd=None, timeout=5.0):
    full_env = os.environ.copy()
    if env:
        full_env.update(env)
    return subprocess.run([EXECUTABLE, *args],
                          input=stdin.encode() if isinstance(stdin, str) else stdin,
                          capture_output=True, timeout=timeout, env=full_env, cwd=cwd)
```

模型交的不是「代码」，而是**一个行为等价的程序**；测试只看 stdout/stderr/exit code/文件系统副作用。

## 3. 一次评测的完整生命周期

1. **起 cleanroom 容器**：从 `task_cleanroom_v6` 镜像启动；容器内只有二进制 + 文档 + 工作区（无项目源码），断网。
2. **模型探索**：agent（官方基线 mini-SWE-agent）可以**任意运行二进制**、喂输入、观察输出——官方说「没有隐藏的东西，都能通过实验发现」。
3. **模型实现**：自己选语言、设计架构、写全部源码和构建脚本；最终产出 `/workspace/executable`。
4. **提交**：把 workspace 打包成 `submission.tar.gz`。
5. **判分**：`programbench eval <run-dir>` 把提交放进评测环境，跑隐藏 pytest；每条测试是一个独立用例。
6. **计分**：`Score = 通过用例数 / 总用例数`；`Resolved = 1` 当且仅当该题**全部**测试通过；`Almost resolved = 通过率 ≥ 95%`。

## 4. 判分机制：黑盒行为测试，主指标看「全过」

- **Score（通过率）**：`passed / total`，连续值。适合诊断「差多少」。
- **Resolved（主指标）**：该实例全部测试通过才算 1。官方榜按 Resolved 排序，Almost 第二、平均通过率第三。
- **Almost resolved**：≥95% 通过，作为参考（官方明确说它「只是方向」，不能替代 Resolved）。

为什么主指标不用平均通过率？官方解释（意译）：

> 每个实例都包含很简单的测试（比如检查 `--help` 是否存在、`--version` 是否输出）。如果报平均通过率，会严重误导——一个只实现了 CLI 骨架的程序也能拿到不低的通过率。而「全过」才代表真的重建了这个程序。

官方数据（2026-11-01 抓取）：

| 模型（agent=mini-SWE-agent） | Resolved | Almost | 平均成本/题 |
| :-- | --: | --: | --: |
| Claude Opus 5.5 (xhigh) | **18.5%** | 70.5% | $36.36 |
| Claude Fable 5.1 (xhigh) | 9.0% | 55.5% | $56.84 |
| GPT 6 Astra (max) | 5.0% | 52.5% | $11.47 |
| GPT-5.6 Sol (xhigh) | 1.0% | 15.5% | $6.08 |

单题最好成绩（官方任务页）：zoxide 99%、ripgrep 100%、jq 98%、fzf 99%——说明题目**可解**，只是极难。

## 5. 真实题例：`ajeetdsouza__zoxide.67ca1bc`

### 5.1 测试规模

我们包里的 `eval/tests/test_zoxide.py`：

- **15 个测试类**：`TestBasicInvocation`、`TestAddCommand`、`TestQueryCommand`、`TestRemoveCommand`、`TestImportCommand`、`TestInitCommand`、`TestEditCommand`、`TestEnvironmentVariables`、`TestDatabasePersistenceAndFormat`、`TestRankingAndScoring`、`TestQueryKeywordMatching`、`TestErrorHandling`、`TestSubcommandHelpAndVersion`、`TestEdgeCases`；
- **137 个测试函数**，经参数化展开后：控制台按 **531 个测试用例**计分（`Score 56 / 531 tests`），而归档的 `eval.json` 里两个测试分支合计 **577 条**逐条记录（见 §5.4）；
- 覆盖：帮助文本、退出码、`add/query/remove/import/init/edit`、环境变量（`_ZO_DATA_DIR`、`_ZO_ECHO`、`_ZO_EXCLUDE_DIRS`、`_ZO_MAXAGE`、`_ZO_RESOLVE_SYMLINKS`）、数据库持久化与格式、**排序打分**、关键词匹配、错误处理、边界情况。

### 5.2 典型断言（原文 + 说明）

```python
def test_no_args_shows_help_on_stderr(self):
    """无参数时把帮助打到 stderr，并返回退出码 2"""
    result = run()
    assert result.returncode == 2
    assert b"zoxide" in result.stderr
    assert b"COMMAND" in result.stderr   # 连帮助文本的段落都要对

def test_add_with_symlink_resolved(self):
    """带 _ZO_RESOLVE_SYMLINKS=1 时，存储解析后的真实路径，不存链接本身"""
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

### 5.3 模型要复刻什么

不只是「能 cd」：

- **排序算法**：zoxide 的 rank/recency 打分（`--score` 要输出分数，`_ZO_MAXAGE` 要触发衰减）；
- **数据库格式**：`db.zo` 的二进制/文本格式、跨会话持久化；
- **错误码与错误文案**：`no match found`、`not a directory`、`could not open database for importing` 等；
- **帮助文本**：`--help` 的段落、子命令顺序；
- **shell 集成**：`init bash/zsh/fish/powershell` 的输出（我们的实测里 init 相关测试挂了最多）。

### 5.4 我们实测的结果

- 控制台：`Score 56 (531 tests)`（`report/results/programbench-zoxide/README.md`）；
- 归档的 `eval.json`：`test_results` 里 **577 条**（两个测试分支：`a9c8e0729570` 137 条 + `aa89e180e290` 440 条），其中 **335 passed**、242 failure；`solution_branch=submission`；
- 两者数字对不上（531 vs 577、56 vs 335/577≈58%）：**`# TODO verify`** 官方 `programbench eval` 的聚合口径（可能是按分支/去重/过滤后的子集计分）。引用时以控制台 `Score 56 / 531 tests` 为准，并注明 `eval.json` 的 577 是原始逐条记录。

这次运行是 Ark `deepseek-v4-flash` + mini-swe-agent 2.4.6，`step_limit=40`、墙钟 900 秒，到步数上限自动提交——**不是模型能力上限**，提高 `step_limit` 后分数会更高。

### 5.5 机制补充：一个任务有多套独立测试分支

ProgramBench 不是「一个任务一套测试」，而是**一个任务多套独立测试分支**。我们离线包里每个实例的 `tests/` 下都有多个 `*.tar.gz`，每个 tar 是一套独立的 `eval/run.sh` + `eval/tests/`：

| 实例 | 测试分支数 |
| :-- | --: |
| `ajeetdsouza__zoxide` | 2 |
| `jqlang__jq` | 12 |
| `burntsushi__ripgrep` | 13 |
| `abishekvashok__cmatrix` | 14 |
| `agourlay__zip-password-finder` | 16 |

`eval.json` 里对应 `test_branches` 列表（zoxide 那次是 `a9c8e0729570` + `aa89e180e290`），逐条结果带 `branch` 字段。多分支的意义是**避免单一测试套件的盲区**：同一程序被十几套独立生成的测试从不同角度考，某一套漏掉的错误行为，另一套可能抓到。

### 5.6 例 2：`jqlang__jq.b33a763`（12 个分支）

**测试原文**（`test_cli_basics.py`）：

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

**中文说明**：`--help` 和 `--version` 的输出必须与 golden 文件**逐字节相同**（连空格/换行都算）；未知参数必须非零退出、stdout 为空、stderr 回显该参数。

另一套分支（`test_filters_and_io.py`）用参数化测 jq 的核心语义：

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

还有 `-n null`、空 stdin、多个 JSON 值分别处理等边界。官方任务页显示 jq 的历史最好成绩 **98%**——接近可解，但仍未 Resolved。

### 5.7 例 3：`burntsushi__ripgrep.3b7fd44`（13 个分支）

**测试原文**（`test_basic.py`）：

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

**中文说明**：ripgrep 的**退出码语义**（0 有匹配、1 无匹配、2 用法错误）、帮助文本长度、版本号格式、feature/SIMD 字样都被钉死；还有递归目录搜索、`--help` 与 `-h` 长短差异等。官方任务页显示 ripgrep 历史最好 **100%**——这是 200 题里少数被完全解出的。

### 5.8 例 4：`abishekvashok__cmatrix.5c082c6`（14 个分支）——TUI 怎么测

cmatrix 是「终端矩阵雨」程序，没有 stdin/stdout 式的常规输出，测试用 **tmux 伪终端**：

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

**中文说明**：模型重建的 cmatrix 必须在 tmux 里跑起来、0.5 秒内画出东西、按 `q` 能退出、各模式（`-s` 屏保、`-a` 异步、`-o` 旧式滚动、`-b`/`-B` 加粗）都可用。**TUI 程序也要能被黑盒行为测试覆盖**。

### 5.9 例 5：`agourlay__zip-password-finder.704700d`（16 个分支）

**测试原文**（`test_zip_password_finder.py`）：

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

**中文说明**：程序要能真的**破解 ZIP 密码**（字典模式和字符集暴力模式），输出格式 `Password found:<密码>` 必须一致；同时帮助文本、版本号（`0.10.3`）、参数缺失/文件不存在的退出码（2/1）和错误文案都要复刻。测试自带的 `test-files/` 里有已知密码的 zip、charset 文件、密码字典，输出可直接验证。

## 6. 常见问题（中文问答）

**Q1：模型能反编译二进制吗？**
不能。二进制只有执行权限、没有读权限；`strings`、`objdump`、`hexdump`、反编译器都会失败。官方明确这是为了防止「把反编译片段拼起来」。

**Q2：模型能联网找源码吗？**
不能。容器断网；官方在早期实验里发现模型会 clone GitHub 或通过包管理器下载源码，所以加了断网限制。

**Q3：模型能运行二进制观察行为吗？**
可以，而且官方鼓励：「agent 可以用任意输入运行给定程序，观察它的行为；没有隐藏的东西是实验发现不了的。」这就是它可解的原因。

**Q4：测试是谁写的？**
测试由「agent 驱动的 fuzzing」生成，覆盖 200 个任务共 24.8 万+ 条；参考程序能全过。官方也说测试可以继续扩充（发现假阳性就补）。

**Q5：为什么 Resolved 这么低（最高 18.5%）？**
因为要求「全部测试通过」：一个 15,000 条测试的任务，即使 99% 通过也只算 Almost。官方认为这正说明「从零重建」很难，而不是脚手架问题。

**Q6：题目可解吗？**
可解。官方任务页显示 zoxide 最好 99%、ripgrep 100%、jq 98%；「best score」是历史最好提交的成绩。参考实现本身全过。

**Q7：单题成本多少？**
官方榜平均 $36.36/题（Opus 5.5），200 题约 $7.3k；FAQ 提到个别 run 到过 $5k。CPU 是 20C/60GB，单题上限 6 小时 / 1000 步。

**Q8：为什么只能 linux/amd64？**
官方镜像只构建 linux/amd64；Windows/macOS 要 WSL2 或远程 Linux，QEMU 模拟很慢。

**Q9：模型卡上的 29.1 和 Resolved 是一回事吗？**
不是。官方主指标是 Resolved（全过）；模型卡 29.1 没标口径，推测是平均测试通过率，不能直接比。

**Q10：我们的离线包为什么只有 5 题？**
镜像大（单题约 4.2GB）、成本高（$36/题）、评测还要 HF 测试 blob；先选 5 个中型程序（zoxide/cmatrix/zip/jq/ripgrep），避开 FFmpeg/duckdb/pandoc 这类超大程序。

## 7. 离线包里怎么跑

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

离线包对官方流程的改动：

| 改动 | 原因 |
| :-- | :-- |
| 任务镜像重打「离线 eval 修复」层：预装 `pytest-timeout` + 本地 wheelhouse + `/etc/pip.conf` 禁网 | 官方 `eval/run.sh` 会 `pip install pytest-timeout`，断网必失败（曾报 `results_read_failed`） |
| 覆盖 `environment.run_args` 去掉 `--cpus/--memory/--memory-swap` | 官方默认 20 CPU / 60GB，小机器会 `docker run exit 125` |
| 测试 blob 预下载到 `data/programbench_blobs/<instance>/` | 用 `PROGRAMBENCH_BLOB_DIR` 指向本地目录，`blob sync` 只校验不下载 |

## 8. 口径陷阱与已知问题

1. **主指标是 Resolved，不是 Score**：模型卡 29.1 与本包 Score 56 都不是 Resolved，不能混比。
2. **子集（5/200）**：只能做同子集相对比较。
3. **我们那次 Score 56 是在 40 步/900 秒截断下拿到的**，不代表模型上限。
4. **镜像只有 amd64**：Windows 需 WSL2。
5. **评测环境需要 pytest-timeout**：离线包已修复；自己搭环境时注意。
6. **`eval.json` 与 Score 的口径差异**：`# TODO verify`（见 §5.4）。

## 9. 来源

- 官方站：<https://programbench.com/>（About / FAQ / 任务页；2026-11-01 抓取）
- 官方论文：<https://arxiv.org/abs/2605.03546>；GitHub：<https://github.com/facebookresearch/ProgramBench>
- 测试数据：HuggingFace `programbench/ProgramBench-Tests`（revision `5954a1957b5e0d770ec2c5523506abd212806315`）
- 任务测试：`E:\bench-bundle\data\programbench_blobs\ajeetdsouza__zoxide.67ca1bc\tests\*.tar.gz`（`eval/run.sh`、`eval/tests/test_zoxide.py`）
- 本仓库：[`../benchmark-guide.md`](../benchmark-guide.md) §3.4、[`../first-batch-bundle.md`](../first-batch-bundle.md) §8（zoxide 端到端与 5 个修复）
- 实测证据：`report/results/programbench-zoxide/`（eval.json、trajectory、submission、日志）
