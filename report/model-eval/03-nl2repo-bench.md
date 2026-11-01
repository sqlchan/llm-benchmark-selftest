# NL2Repo-Bench：从一份规格「无中生有」整个仓库

> 版本：arXiv v2（2026-01-08）｜题量：**104 题 / 9 类 Python 库**｜官方 harness：**仓库自带 `main.py` 驱动 OpenHands 0.56 headless**｜官方口径：**平均测试通过率（average test pass rate，0–100%）**；论文另报 Pass@1 count
> 离线包现状：**16/104 题**（10 基线 + 6 补充），3 并发，离线派生测试镜像已预装构建依赖。
> 本文题例来自 `E:\bench-bundle\data\nl2repo\harness\test_files\` 与 `results/nl2repo-smoke/` 的真实产物。

## 1. 这个基准在测什么

只给模型一份**自然语言规格**（约 18.8k tokens）和一个**空工作区**，让它从 0 到 1 写出一个完整、可安装的 Python 库；然后用**原仓库上游的 pytest** 判分，分数 = 通过的测试用例占比。

它和 DeepSWE 的区别：DeepSWE 是「已有仓库上改」，NL2Repo 是「什么都没有，从规格开始造」——更接近真实外包/新项目启动。和 ProgramBench 的区别：NL2Repo 给的是完整自然语言规格（有目录树、依赖版本、API 说明），ProgramBench 只给二进制和文档。

- 官方 104 题、9 类；单题**没有轮数上限**，交互可达数百轮，非常慢且贵。
- **没有 LICENSE 文件**（仓库无 LICENSE，GitHub API `license=null`）——再分发/商用前需联系作者。
- 结果按随机 UUID 存 `result/<uuid>.json`，官方**没有汇总脚本**，平均通过率要自己算。

## 2. 评测系统的组成

### 2.1 每题的数据（`test_files/<task>/`）

```
test_files/aiofiles/
├─ start.md              # 49 KB 的规格：介绍 + 自然语言需求 + 环境版本 + 目录树 + API 说明
├─ test_files.json       # 测试相关文件清单
├─ test_commands.json    # 判分要执行的命令（安装 + pytest）
└─ test_case_count.txt   # 测试用例数（aiofiles = 211）
```

`test_commands.json` 在离线包里是（原文）：

```json
["pip install --no-build-isolation --no-index -e .",
 "pytest --continue-on-collection-errors tests"]
```

`--continue-on-collection-errors` 很关键：某个测试文件 import 失败时，**继续跑其余用例**，而不是整题直接 0 分——这就是它为什么用「通过率」而不是「全过」。

### 2.2 harness 组件（`data/nl2repo/harness/`）

| 文件/目录 | 作用 |
| :-- | :-- |
| `main.py` | 入口：读 `config.json`，起容器、跑任务、写结果 |
| `openhands/openhands_app.py` | 起 OpenHands app 容器、下发任务、收集结果 |
| `openhands/post_processor.py` | 结束后的后处理：打包 workspace → 构建测试镜像 → 跑测试命令 → 解析 pytest |
| `docker_self/` | 用 python-on-whales 管理 Docker（本地 Docker only） |
| `template/config.toml` | OpenHands 配置模板（`max_iterations` 等） |

### 2.3 两个容器镜像

| 镜像 | 作用 |
| :-- | :-- |
| `ghcr.io/all-hands-ai/openhands:0.56` | OpenHands app（模型代理 + 前端 shell） |
| `ghcr.io/all-hands-ai/runtime:0.56-nikolaik` | agent 的执行沙箱（bash / 编辑器） |

> 原地址 `docker.all-hands.dev/all-hands-ai/*` 已 NXDOMAIN（域名下线），离线包改用 `ghcr.io/all-hands-ai/*`（见 `report/second-batch-bundle.md` §5.1）。

## 3. 一次评测的完整生命周期

1. **写配置**（`config.json`）：

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

2. **起 app 容器**：harness 起 `openhands-app-<port>`，把 `workspaces/<task>/`（含 `start.md`）挂进容器，端口映射 `3000 -> base+序号`。
3. **下发任务**：`openhands_app.py` 里的指令是固定的一句（原文）：

> According to the start.md in the workspace, implement the entire project as per the requirements specified in the document, ensuring that the final product can be directly run in the current directory. The running requirements should comply with the `<API Usage Guide>` section of the document. Please complete this task step by step.

**中文翻译**：

> 根据工作区里的 `start.md`，按文档要求实现整个项目，确保最终产物能在当前目录直接运行。运行要求应遵循文档的「API Usage Guide」一节。请一步一步完成这个任务。

4. **模型干活**：OpenHands 在 runtime 沙箱里循环「读规格 → 写文件 → 跑命令 → 看报错 → 再改」。没有轮数上限（模板默认 `max_iterations = 500`；我们冒烟时特意调成 8 控制时长）。
5. **结束**：模型自己说完成，或达到迭代上限；harness 把 `/workspace` 打包成 `workspace.zip`。
6. **后处理构建测试镜像**：以官方测试镜像为基础（`FROM ghcr.io/multimodal-art-projection/nl2repobench/<task>:1.0`），把模型写的仓库放进去，构建出 `python-test-<task>` 镜像。
7. **跑测试命令**：在测试容器里依次执行 `test_commands.json` 里的命令（安装 + pytest），拿到 pytest 输出。
8. **解析与落盘**：从 pytest 输出里解析 `passed / failed / errors / skipped / total / success_rate`，写进 `result/<task_uuid>.json`。

## 4. 判分机制：通过率，不是全过

`openhands_app.py` 里直接取后处理结果：

```python
pytest_results = post_process_result['pytest_results']
test_score = pytest_results['passed'] if pytest_results['total'] > 0 else 0
```

我们实测的 result JSON（`results/nl2repo-smoke/result-aiofiles_bo1.json`）里字段长这样：

```json
"post_process_result": {
  "status": "success",
  "test_results": {
    "pytest_results": {"passed": 1, "failed": 20, "errors": 12, "total": 211,
                       "success_rate": 0.004739336492890996}
  }
}
```

- **单题分数 = `success_rate` = `passed / total`**（0–100%）。
- `errors`（collection error）会单独计数，不会中断整题；`--continue-on-collection-errors` 保证其余用例照跑。
- 官方整轮 = 104 题的平均通过率；论文另报 Pass@1 count（通过率 100% 的题数）。

> 注意：result JSON 里还有 `score` / `test_score` 字段，那是 harness 的原始字段（冒烟里是 1），**不要**把它当基准成绩；正式口径看 `pytest_results.success_rate`。

## 5. 真实题例

### 5.1 `aiofiles`（Medium，211 个测试）

`start.md` 的开头（原文 + 翻译）：

> **Introduction and Goals of the aiofiles Project**
>
> aiofiles is a Python library **for asynchronous file operations**, providing asynchronous processing capabilities for local disk files in asyncio applications. This library is licensed under the Apache 2 license. It delegates blocking file I/O operations to separate threads through a thread pool executor, thus avoiding blocking the asyncio event loop...

**中文**：aiofiles 是一个做**异步文件操作**的 Python 库，为 asyncio 应用提供本地磁盘文件的异步处理能力，用线程池 executor 把阻塞 I/O 挪到别的线程，避免阻塞事件循环。

接着是「Natural Language Instruction (Prompt)」的 9 条要求（原文节选 + 翻译）：

1. **异步文件操作核心**：实现异步 open/read/write，支持文本与二进制，提供 `read()`、`write()`、`readline()`、`readlines()`、`writelines()` 的异步版本。
2. **线程池 executor 集成**：通过 asyncio 线程池把阻塞 I/O 放到独立线程，支持自定义 loop 和 executor。
3. **异步迭代**：文件对象实现异步迭代器协议，支持 `async for` 逐行读。
4. **异步临时文件模块**：`TemporaryFile`、`NamedTemporaryFile`、`SpooledTemporaryFile`、`TemporaryDirectory`，都支持 `async with`。
5. **异步 OS 操作**：`stat`、`mkdir`、`makedirs`、`rename`、`remove`、`symlink`、`listdir`、`scandir` 等全部异步化。
6. **异步标准输入输出**：`stdin`、`stdout`、`stderr` 及其 bytes 版本。
7. **接口设计**：清晰的 API、`async with`、异步迭代、错误处理。
8. **示例与测试**：完整示例代码与测试用例。
9. **核心文件要求**：必须有可 `pip install` 的 `pyproject.toml`、`src/aiofiles/__init__.py`，导出 `aioopen`、`wrap`、`stdin`、`stdout` 等。

规格还给环境版本（Python 3.11.7、pytest 8.4.1、pytest-asyncio 1.1.0 等）和目录树。模型要照着这份规格把整个包写出来，最后跑 **211 个上游测试**。

### 5.2 `jsonlines`（Easy，27 个测试）——最小的题之一

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

**中文翻译**（要点）：

> jsonlines 是处理 JSON Lines（逐行 JSON）格式的 Python 库，简化 `.jsonl`/`.ndjson` 的读写，支持大文件流式处理。
>
> 要实现的库包含：读写、流式处理、全 JSON 类型、健壮错误处理、多编码、迭代器接口、上下文管理器；核心文件要提供 `Reader`（支持 `read()`/`iter()`、`type`、`allow_none`、`skip_empty`、`skip_invalid`）、`Writer`（`write()`/`write_all()`、`compact`、`sort_keys`、`flush`、`dumps`）、`open()`（按 `'r'/'w'/'a'/'x'` 返回 Reader/Writer，处理 UTF-8 与 BOM）、`Error`/`InvalidLineError`（错误信息带行号和原始行）、`SKIPPABLE_SINGLE_INITIAL_CHARS`（`\x1e` 与 BOM，支持 RFC7464）、`ReaderWriterBase`、`DumpsResultConversion`、`repr_for_fp()`；JSON 库优先 orjson，其次 ujson，最后标准库 json；要完整的类型注解（泛型、Union、Literal、`@overload`，能过 mypy）。

**它怎么判**：`test_case_count.txt` = **27**。这属于 104 题里测试最少的一档（有 5 题的测试数比它还少），适合验证链路；但要求并不少——27 个测试覆盖读写、类型化读取、空行/非法行、BOM、三种 JSON 库后端、上下文管理器、类型注解。

### 5.3 `tinydb`（Medium，204 个测试）——规格自己写明了测试规模

**规格原文**（节选）：

> TinyDB is a **lightweight document-oriented database** designed specifically for small applications. It aims to provide a local storage solution implemented purely in Python without external dependencies...
>
> - **Document-based storage**: Each piece of data is stored in a dict format...
> - **Pure Python implementation**: No third-party dependencies...
> - **Simple and easy to use**: It includes 7 test files, a total of **141 test functions** and **204 test cases**, covering multiple aspects such as data insertion, querying, updating, multi-table management, storage backends, operation functions, and type tools.
> - **Powerful extensibility**: custom storage backends and middleware
> - **High-quality assurance**: 100% unit test coverage

**中文翻译**：

> TinyDB 是面向小应用的轻量文档数据库，纯 Python、无外部依赖；数据以 dict 存储；**7 个测试文件、141 个测试函数、204 个测试用例**，覆盖插入、查询、更新、多表管理、存储后端、操作函数、类型工具；支持自定义存储后端和中间件；100% 单元测试覆盖。

**它怎么判**：`test_case_count.txt` = **204**（与规格里写的 204 一致——这是少数「规格直接告诉你测试规模」的题）。模型要复刻数据库核心、表管理、`doc_id` 语义、查询/更新/删除、存储后端与中间件；测试跑的是上游 TinyDB 的完整测试集。

### 5.4 `flask-restful`（Medium，362 个测试）——完整 Web 框架

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

**中文翻译**（要点）：

> Flask-RESTful 是基于 Flask 的扩展库，用于快速构建 REST API，提供资源抽象、参数解析、序列化、错误处理、内容协商、CORS、加密等能力。
>
> 要实现：Resource/路由（多路由、路径参数、endpoint、Blueprint）；`reqparse`（类型转换、默认值、必填、choices、actions、trim、可空、文件上传）；`fields`（String/Integer/Float/Boolean/DateTime/Url/Nested/List/Raw/Fixed/Arbitrary/FormattedString）；JSON/XML 响应与 `Accept` 协商；`abort`/自定义错误/信号链；`crossdomain` CORS；AES 加密；inputs 校验；`flask_restful/__init__.py` 必须导出 `Api`、`Resource`、`fields`、`reqparse`、`inputs`、`marshal`、`marshal_with`、`abort`、`utils`，并在 `__version__.py` 提供版本号。

**它怎么判**：`test_case_count.txt` = **362**，`test_commands.json` 是 `pytest --continue-on-collection-errors`（不带 `tests` 路径，跑仓库默认收集）。这题要复刻一个完整的 Web 框架层：路由、解析、序列化、协商、错误、CORS、加密，API 覆盖面在 16 题里位居前列。

### 5.5 `python-slugify`（Easy，82 个测试）——Unicode → URL slug

**规格原文**（节选）：

> Python-Slugify is a Python library **for slugifying Unicode strings**, capable of intelligently converting text in various languages (including Chinese, Russian, French, etc.) into URL-friendly slug formats... (for example, converting "影師嗎" to "ying-shi-ma" and "C'est déjà l'été." to "c-est-deja-l-ete" through the slugify() function).

**中文翻译**：

> Python-Slugify 是把 Unicode 字符串转成 URL slug 的库，能把中文、俄语、法语等文本智能转成 ASCII slug，例如 `"影師嗎"` → `"ying-shi-ma"`、`"C'est déjà l'été."` → `"c-est-deja-l-ete"`。

规格还要求：HTML 实体/十进制/十六进制编码解析；`slugify()` 支持自定义分隔符、最大长度、词边界截断、停用词过滤；引号/数字/标点处理；自定义替换规则（如 `[['|', 'or'], ['%', 'percent']]`）与正则过滤；完整 CLI（`--separator`、`--max-length`、`--word-boundary`、`--stopwords`、`--replacements`、`--allow-unicode`）；`slugify/__init__.py` 导出 `slugify`、`DEFAULT_SEPARATOR`、`smart_truncate`；`special.py` 里要有 `PRE_TRANSLATIONS`、`CYRILLIC`、`GERMAN`、`GREEK` 等常量。

**它怎么判**：`test_case_count.txt` = **82**，`test_commands.json` 是 `pytest --continue-on-collection-errors test.py`（注意目标是 `test.py` 而不是 `tests/`）。这题小，但「Unicode 转换表 + 边界规则 + CLI」都得对，适合作为 NL2Repo 的第一道冒烟题。

### 5.6 题例速览（测试数来自各任务 `test_case_count.txt`）

| 任务 | 测试数 | 难度（官方 CSV） | 一句话 |
| :-- | --: | :-- | :-- |
| `jsonlines` | 27 | Easy | JSON Lines 读写库，最小 |
| `python-slugify` | 82 | Easy | Unicode → URL slug + CLI |
| `tinydb` | 204 | Medium | 纯 Python 文档数据库 |
| `aiofiles` | 211 | Medium | 异步文件库 |
| `flask-restful` | 362 | Medium | 完整 REST 框架层 |
| `fastapi-users` | 556 | Hard | Web/用户认证 |
| `stable-baselines3` | 798 | Hard | 强化学习库 |
| `python-pytest-cases` | 1372 | Hard | 测试框架 |
| `ydata-profiling` | 2182 | Hard | 数据分析/EDA，单题测试量最大之一 |

`ydata-profiling` 要模型从零写出能过 2182 个测试的数据分析库——这就是为什么单题能跑几百轮、几小时。

## 6. 常见问题（中文问答）

**Q1：模型能看到测试吗？**
看不到。`test_files/<task>/` 里只有规格和「测试命令」，测试代码在官方测试镜像的上游仓库里；模型只拿到 `start.md`。

**Q2：为什么分数是连续值（0–100%）而不是 0/1？**
因为一个仓库有很多测试，全过极难；用通过率能区分「写了 30%」和「写了 80%」。官方整轮取平均通过率，而不是「全过的题数」（后者论文另报 Pass@1 count）。

**Q3：pytest collection error 为什么不算直接 0 分？**
`--continue-on-collection-errors` 让 import 失败的测试文件只计 error，其余用例继续跑。这是为了让「部分实现」也能拿到部分分，避免一个 import 错误把整题归零。

**Q4：单题为什么要跑几小时？**
OpenHands 要自己规划、写几十个文件、反复跑测试修错；没有轮数上限，交互可达数百轮，模型越笨越慢。

**Q5：能并行吗？**
官方 harness 只支持本地 Docker（python-on-whales），多机要 NFS 共享。单机可以并发，但每个任务要独立端口、独立 state 目录、独立测试镜像/容器——我们的离线包已打并行补丁（`max_pool_size`、`NL2REPO_PORT_BASE`），32C/64G 建议 pool=3。

**Q6：为什么离线包要把测试命令改成 `--no-index`？**
官方测试镜像只含骨架，`pip install -e .` 会联网装构建后端（hatchling 等）和依赖；离线环境装不了，所以派生镜像预装 `build-system.requires` + 项目依赖，并把命令改成 `pip install --no-build-isolation --no-index -e .`。

**Q7：没有 LICENSE 会有什么影响？**
仓库没有 LICENSE 文件（GitHub API 也是 null），严格说再分发/商用前需联系作者；公司内部自测一般没问题，但对外交付要注意。

**Q8：结果怎么汇总？**
官方没有汇总脚本，结果按 UUID 存 `result/<uuid>.json`，要自己算平均通过率。我们离线包在 `run_batch2.sh nl2repo` 外层脚本里汇总。

**Q9：模型可以在容器里装包吗？**
可以（OpenHands 有 bash），但离线环境没有 pip 源；所以要么用镜像里预装的包，要么在派生镜像里预装。正式跑前先确认任务的依赖都在镜像里。

**Q10：NL2Repo 的分数能和模型卡比吗？**
不能直接比。模型卡用的是官方 harness + 特定模型/端点 + 全量 104 题；我们离线包是 16 题子集 + 内网端点，且测试命令是离线改写版。

## 7. 离线包里怎么跑

```bash
# 冒烟：1 题 8 轮（约 10–20 分钟）
BUNDLE_DIR=$PWD NL2REPO_TASKS=aiofiles NL2REPO_MAX_ITERATIONS=8 \
  ./offline/run_batch2.sh nl2repo

# 正式：16 题，3 并发
PROFILE=32c64g ./offline/run_batch2.sh nl2repo
```

离线包对官方流程的改动：

| 改动 | 原因 |
| :-- | :-- |
| 镜像源 `docker.all-hands.dev` → `ghcr.io/all-hands-ai/*` | 原 registry NXDOMAIN |
| `NL2REPO_HOST_ROOT`：runner 以「相同绝对路径」挂载离线包 | OpenHands 对 volume 路径做正则校验，必须是 `/` 开头的宿主机路径 |
| 启动命令改 `bash -c` + `shlex.quote` | 任务文本含空格，list 形式会被拆成多个 argv |
| 16 个派生测试镜像预装构建依赖 + `pip install --no-build-isolation --no-index -e .` | 断网时 `pip install -e .` 会失败 |
| 并行补丁：per-port 端口/state/容器名，`NL2REPO_MAX_POOL` | 单进程内安全并发 2–3 题 |

## 8. 口径陷阱与已知问题

1. **无 LICENSE**：再分发/商用需联系作者。
2. **离线测试命令是改写版**（`--no-build-isolation --no-index`），与官方口径有差异，报告需注明。
3. **`max_iterations` 影响分数**：官方模板默认 500，我们冒烟用 8；正式跑必须用默认/更大值，否则会低估。
4. **结果无汇总**：`result/` 按 UUID 落盘，要自己算平均。
5. **子集（16/104）**：横评可以，对榜不行。
6. **冒烟分数不可用**：`results/nl2repo-smoke/` 里那次的 pytest 分数是「官方骨架镜像 + 联网失败」导致的，不是模型分。

## 9. 来源

- 官方仓库：<https://github.com/multimodal-art-projection/NL2RepoBench>（`test_files/`、`workspaces/`、`docker_self/`）
- 论文：arXiv v2（2026-01-08），平均测试通过率与 Pass@1 count 的口径
- 任务文件：`E:\bench-bundle\data\nl2repo\harness\test_files\<task>\`（start.md / test_commands.json / test_case_count.txt）
- harness 源码：`E:\bench-bundle\data\nl2repo\harness\openhands\openhands_app.py`、`post_processor.py`
- 本仓库：[`../benchmark-guide.md`](../benchmark-guide.md) §3.5、[`../second-batch-bundle.md`](../second-batch-bundle.md) §5（离线补丁）、[`../third-batch-bundle.md`](../third-batch-bundle.md)（+6 题）
- 实测证据：`report/results/nl2repo-smoke/`（端到端冒烟，分数不可用）、`report/results/nl2repo-parallel-smoke/`（2 题并发机制验证）
