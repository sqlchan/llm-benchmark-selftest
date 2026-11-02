# NL2Repo-Bench 全题规格中文翻译 · Part 1（第 1–28 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da`，`test_files/<task>/start.md` 的「Natural Language Instruction」段；测试数取自 `test_case_count.txt`。
> 本分册只译「从规格造库」的题面要求，不译 API Usage Guide / 目录树等参考章节（那些是规格附录，原文可在仓库核对）。

## 1. `aiofiles`（测试数 211）

**中文规格**

请创建一个名为 aiofiles 的 Python 项目，实现一个异步文件操作库。项目应包含以下功能：

1. 异步文件操作核心：实现异步的文件打开、读取与写入函数，提供与 Python 标准文件 API 相似的异步接口。应支持文本文件与二进制文件的异步操作，包括 `read()`、`write()`、`readline()`、`readlines()`、`writelines()` 等方法的异步版本。

2. 线程池执行器集成：通过 asyncio 的线程池执行器把阻塞式文件 I/O 委派给独立线程，确保文件操作不阻塞事件循环。实现文件操作的异步包装，支持自定义配置 `loop` 与 `executor` 参数。

3. 异步迭代支持：实现异步文件对象的迭代功能，支持 `async for` 循环按行迭代文件。文件对象应实现异步迭代器协议，允许异步逐行读取文件内容。

4. 异步临时文件模块：以异步版本实现 `tempfile` 模块的功能，包括 `TemporaryFile`、`NamedTemporaryFile`、`SpooledTemporaryFile` 和 `TemporaryDirectory` 等类。每个类都应支持 `async with` 上下文管理器，提供完整的异步临时文件操作接口。

5. 异步 OS 操作：实现文件系统操作的异步版本，包括文件状态查询（`stat`）、目录操作（`mkdir`、`makedirs`、`rmdir`、`removedirs`）、文件移动（`rename`、`renames`、`replace`）、文件删除（`remove`、`unlink`）、符号链接操作（`symlink`、`readlink`、`link`）以及目录遍历（`listdir`、`scandir`）。所有操作都通过线程池执行器转为异步。

6. 异步标准输入输出：提供异步访问系统标准输入输出的接口，包括 `stdin`、`stdout`、`stderr` 及其对应的字节版本（`stdin_bytes`、`stdout_bytes`、`stderr_bytes`），支持标准流的异步读写。

7. 接口设计：为每个功能模块设计清晰的 API 接口，支持 `async with` 上下文管理器与异步迭代器（`async for`）。每个模块应定义明确的输入输出格式与错误处理机制。

8. 示例与测试：提供完整的示例代码与测试用例，演示如何使用 `aiofiles.open()` 进行异步文件操作、如何使用异步临时文件，以及如何执行异步文件系统操作。测试应覆盖各种文件类型与操作场景。

9. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，把项目配置为可安装包（支持 pip install），声明项目版本信息与完整的依赖清单（包括 `asyncio>=3.9.0`、`io>=3.9.0`、`mypy>=1.16.0`、`tempfile>=3.9.0`、`ruff>=0.11.12`、`pytest>=8.3.5` 等标准库），提供 `src/aiofiles/__init__.py` 作为统一 API 入口，导入并导出 `aioopen`、`wrap`、`stderr`、`stderr_bytes`、`stdin`、`stdin_bytes`、`stdout`、`stdout_bytes` 与 `main` 函数，使用户能通过简单的 "from aiofiles import **" 与 "from aiofiles.threadpool import**" 语句访问所有主要功能。

**考点**：用线程池执行器把阻塞式文件 I/O 包装成异步 API，并给出 `tempfile` / `os` 常用能力的异步复刻。

## 2. `arguably`（测试数 70）

**中文规格**

请创建一个名为 Arguably 的 Python 项目，实现一个现代的命令行参数解析库。项目应包含以下功能：

1. 装饰器 API：应能通过 `@arguably.command` 装饰器定义命令行函数，支持从类型注解自动推断参数类型与默认值。解析结果应为与 argparse 兼容的命令行接口。

2. 类型安全：被实现的函数应能自动处理各种 Python 类型，包括基础类型（`str`、`int`、`float`、`bool`）、复杂类型（`list`、`tuple`、`dict`）、自定义类型（`Path`、`Enum`、`dataclass`）等。

3. 高级特性支持：应对子命令、枚举、异步函数、版本标志等提供特殊处理。例如应支持嵌套子命令、枚举选项的自动生成以及异步函数的执行。

4. 接口设计：应为每个功能模块（如命令注册、参数解析、类型转换、帮助生成等）设计独立的函数接口，支持灵活配置。每个模块应定义明确的输入输出格式。

5. 示例与测试脚本：提供示例代码与测试用例，演示如何使用 `@arguably.command` 与 `arguably.run()` 函数进行命令定义与应用启动（例如 `arguably.run(name="myapp", version_flag=True)` 应启动一个带版本标志的应用）。需要组合上述特性构建完整的命令行工具包。项目最终应包含命令注册、参数解析、类型转换、帮助生成等模块，并配有典型测试用例，形成可复现的开发流程。

6. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，需要把项目配置为可安装包（支持 pip install 与可编辑模式安装），声明完整的依赖清单（包括 pytest、coverage 等测试库），同时包含项目运行的核心依赖。此外，应通过 **project.optional-dependencies** 分组管理测试与文档等扩展依赖，确保可通过 `pip install .[test]` 安装完整测试环境，并支持通过 pytest 验证所有功能模块（如命令解析、类型处理、CLI 交互等）。另外应提供 `arguably/init.py` 作为统一 API 入口。该文件需要从 `_context` 与 `_commands` 模块导入 `command`、`run` 等核心函数，从内部模块导入 `Permissions`、`PermissionsAlt`、`HiBye` 等类型类，以及 `get_and_clear_io`、`run_cli_and_manual`、`append_argv` 等工具函数；还应导出 `subtype`、`error`、`is_target` 等辅助函数，并通过 `version` 变量提供版本信息。API 设计应确保用户能通过简单的 `from arguably import command, run, Permissions, get_and_clear_io` 语句访问所有主要功能，覆盖命令定义、参数解析、类型校验与 CLI 运行等核心能力。在 `_context.py` 文件中需要定义一个名为 `context` 的全局实例，用于接收 `_Context` 类。该函数应整合 `append_argv` 对命令行参数做预处理，结合 `run_cli_and_manual` 处理 CLI 执行与手册生成之间的联动逻辑，支持 `Permissions` 等类型参数的解析与校验，并通过 `get_and_clear_io` 管理输入输出流。最后应以多种策略（如交互式解析、批量参数处理、错误捕获与提示）实现命令行参数解析与命令执行过程。

**考点**：以装饰器把类型注解直接映射为 argparse 风格的 CLI，覆盖子命令、枚举与异步函数执行。

## 3. `arxiv-mcp-server`（测试数 23）

**中文规格**

请创建一个名为 ArXiv MCP Server 的 Python 项目，实现一个学术论文搜索与分析服务。项目应包含以下功能：

1. **论文搜索工具**：能按关键词、日期范围、学科类别等在 arXiv 上搜索论文，支持高级过滤与结果排序。搜索功能应支持字段限定符（如 `all:`、`ti:`、`abs:`、`au:`、`cat:`）以提供更精确的搜索结果。

2. **论文下载工具**：实现论文自动下载功能，支持 PDF 格式下载并自动转换为 Markdown 格式。下载过程应包含状态跟踪、错误处理与本地存储管理。

3. **论文列表工具**：提供查看已下载论文列表的功能，包括论文元数据（标题、作者、摘要、链接等）的展示与管理。

4. **论文阅读工具**：实现读取已下载论文内容的功能，支持 Markdown 格式内容的展示与结构化访问。

5. **深度分析提示词**：提供专门的研究分析提示词，包含系统化的论文分析工作流，覆盖执行摘要、详细分析、方法论分析、结果评估、实践与理论意义、未来研究方向等完整的分析结构。

6. **配置管理**：实现灵活的配置系统，支持存储路径设置、最大结果数限制、请求超时等参数配置。

7. **MCP 协议集成**：实现 Model Context Protocol（MCP）服务器，提供标准化的工具（tool）与提示词（prompt）接口，支持 AI 助手的无缝集成。

8. **错误处理与状态管理**：实现完整的错误处理机制，包括网络错误、文件操作错误与格式转换错误的处理，以及下载与转换状态的跟踪。

9. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，应把项目配置为可安装包（支持 pip install）并声明完整的依赖清单（如 `arxiv>=2.1.0`、`mcp>=1.2.0`、`pymupdf4llm>=0.0.17`、`aiohttp>=3.9.1` 等实际使用的核心库）。`pyproject.toml` 应确保所有核心功能模块可正常工作。同时应提供 `src/arxiv_mcp_server/__init__.py` 作为统一 API 入口，导入并导出 `list_prompts`、`get_prompt`、`handle_download`、`get_paper_path`、`conversion_statuses`、`handle_search`、`Settings` 以及 main 导入导出函数，并提供版本信息，使用户能通过简单的 "from arxiv_mcp_server.tools/config/tools.download/prompts.handlers import **" 语句访问所有主要功能。

**考点**：把 arXiv 检索、PDF→Markdown 下载阅读与深度分析提示词封装成 MCP 标准工具/提示词服务。

## 4. `asteval`（测试数 227）

**中文规格**

请创建一个名为 asteval 的 Python 项目，实现一个安全的表达式求值库。项目应包含以下功能：

1. 表达式解析与执行：应能把输入字符串解析为 Python 抽象语法树（AST），并在受控环境里安全地执行表达式，支持变量赋值、算术运算、逻辑运算以及列表、字典、集合、元组等常见数据结构的操作。

2. 安全机制：禁止危险操作（如文件系统访问、系统命令、任意代码执行），防止用户输入带来的安全风险。实现符号表隔离与只读内置符号，支持自定义只读变量与函数。

3. 错误处理与异常捕获：捕获并记录运行时错误（如 `ZeroDivisionError`、`TypeError`、`NameError`、`AttributeError`、`KeyError`、`ValueError`、`SyntaxError`、`NotImplementedError`、`RecursionError`、`OverflowError` 等），并提供详细的错误信息接口，便于用户调试与问题定位。

4. 控制流支持：支持 `if`、`for`、`while`、`try/except`、`try/else/finally`、`break`、`continue`、`assert`、`with` 等 Python 控制流语句，并正确处理嵌套与作用域。

5. 函数定义与调用：支持用户自定义函数（含带默认参数、可变参数、关键字参数以及嵌套函数），允许在符号表中注册自定义函数，并支持 numpy/scipy 等科学计算库的集成。

6. 兼容性与可扩展性：支持自定义符号表、扩展内置函数、配置节点处理器（如禁用某些语法节点），允许用户通过配置项灵活调整解释器行为。

7. 只读符号与内置保护：实现只读符号机制，防止用户修改关键变量与内置函数，支持配置 `builtins_readonly` 与 `readonly_symbols`。

8. 结果返回与符号表管理：返回表达式的最终结果，并支持用户查询与管理符号表中的变量与函数。

9. 命令行与接口设计：为每个功能模块（如表达式执行、错误查询、符号表管理等）设计独立的函数接口，支持终端调用与自动化测试。每个接口应定义明确的输入输出格式。

10. 示例与测试脚本：提供典型示例代码与测试用例，覆盖所有主要功能点，包括表达式求值、错误捕获、符号表操作、控制流语句、函数定义与调用等。测试脚本应自动验证所有功能模块的正确性。

11. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，把项目配置为可安装包（支持 pip install），声明完整的依赖清单（如 `numpy>=1.20.0`、`numpy_financial>=1.0.0`、`pytest>=6.0.0`、`pytest-cov>=2.0.0`、`coverage>=5.0.0` 等）。项目应包含 `asteval/__init__.py` 作为统一 API 入口，导出 `Interpreter`、`make_symbol_table`、`NameFinder`、`get_ast_names` 等核心类与函数，并提供版本信息，使用户能通过简单的 "from asteval/asteval.astutils import **" 语句访问所有主要功能。在 `astutils.py`（原文写作 `astutilits.cy`）中需要提供「先尝试导入、失败则降级」的回退机制以处理 numpy 相关错误。

**考点**：基于 AST 的受限解释器，安全地执行表达式并隔离/保护符号表。

## 5. `autojump`（测试数 23）

**中文规格**

请创建一个名为 Autojump 的 Python 项目，实现一个智能文件系统导航工具。项目应包含以下功能：

1. 目录数据库管理：自动记录并更新用户访问过的目录路径。支持跨平台数据存储（Linux、macOS、Windows）。数据格式应为 JSON 或文本，包含访问次数、最后访问时间、路径权重等信息。

2. 智能路径匹配：实现多种匹配算法，包括模糊匹配、连续字符匹配与任意位置匹配。支持部分路径匹配、优先子目录、多参数组合匹配等高级特性。

3. 权重计算系统：基于访问频率、最近使用时间、路径深度等因素计算目录权重。使用智能算法（如时间衰减与频率加权）优化匹配结果的排序。

4. 多 Shell 支持：为不同 shell 环境（bash、zsh、fish、tcsh 等）提供适配脚本，支持自动补全、Tab 菜单、历史记录等功能，确保在各种终端环境下都有最佳体验。

5. 命令行接口设计：为每个功能模块（如数据库管理、路径匹配、权重计算、shell 集成等）设计独立的命令行接口，支持多种操作模式（跳转、打开文件管理器、优先子目录等）。每个模块应定义明确的输入输出格式。

6. 核心文件要求：项目必须包含完整的 `install.py` 文件。该文件不仅应处理项目的安装过程（支持手动执行以完成 setup），还应声明并管理必要的依赖（包括 Python 标准库、`argparse`、`json`、`os`、`sys` 等核心库）。`install.py` 可在安装过程中验证所有功能模块是否正常工作。项目结构在 `bin/` 目录中放置核心模块：`autojump_data.py`、`autojump_match.py`、`autojump_utils.py`，其中包含核心功能。其中，`Entry` 是存储目录条目信息的命名元组（named tuple），包含 `path` 与 `weight` 属性；`load` 函数用于从数据文件加载目录条目信息（返回路径—权重字典），并处理文件不存在或读取错误的情况；`save` 函数用于把目录条目数据原子地保存到文件并创建备份；`match_anywhere` 函数用于匹配路径中任意位置出现的模式（各模式需按相同顺序出现，不要求连续）；`match_consecutive` 函数用于匹配在路径末尾连续出现的模式（例如 `['foo', 'baz']` 可匹配以 `/.../foo/.../baz` 结尾的路径）。用户可通过 shell 函数 `j`、`jc`、`jo`（定义在 `autojump.bash`、`autojump.zsh` 等 shell 脚本中）使用主要功能，其中 `j` 是用于快速跳转到匹配目录的核心命令；`jc` 是 `j` 的变体，用于跳转到子目录；`jo` 用于打开匹配目录的文件管理器窗口（而不是切换目录）。

**考点**：以访问频次加权数据库 + 多策略模式匹配实现 `j` 跳转，并用 shell 函数做终端集成。

## 6. `autopep8`（测试数 564）

**中文规格**

请创建一个名为 autopep8 的 Python 项目，实现一个自动把 Python 代码格式化为符合 PEP 8 风格的工具。项目应包含以下功能：

1. 代码格式化引擎：实现核心代码格式化引擎，能自动修复 Python 代码中的 PEP 8 风格问题。引擎应支持多种格式化策略，包括缩进修复、空白处理、行长度控制、import 语句规范化等。格式化过程应基于 pycodestyle 工具检测出的问题，并提供智能修复算法。

2. PEP 8 错误修复：实现完整的 PEP 8 错误码修复功能，包括 E1 系列（与缩进相关）、E2 系列（与空白相关）、E3 系列（与 import 相关）、E4 系列（与 import 相关）、E5 系列（与行长度相关）、E7 系列（与语法相关）、W 系列（与警告相关）等。每个错误码应有对应的修复函数，如 `fix_e101()`、`fix_e201()`、`fix_e401()` 等。

3. 命令行接口：提供完整的命令行接口，支持文件格式化、目录递归处理、差异显示、原地修改等。命令行应支持多个选项，如 `--in-place`（原地修改）、`--diff`（显示差异）、`--aggressive`（激进模式）、`--max-line-length`（最大行长度）、`--select/--ignore`（选择/忽略特定错误）等。

4. 配置系统：实现灵活的配置系统，支持从 `pyproject.toml`、`setup.cfg`、`.pep8` 等配置文件读取设置，并支持全局配置与局部配置的合并。配置系统应能处理各种格式化选项，如缩进大小、行长限制、忽略的错误码等。

5. 多文件处理：支持批量处理多个 Python 文件，包括递归目录扫描、文件过滤、并行处理等。应提供文件匹配、排除模式、编码检测等实用功能。

6. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，不仅应把项目配置为可安装包（支持 pip install），还应声明完整的依赖清单（包括 `pycodestyle >= 2.12.0`、`tomli` 等核心库）。`pyproject.toml` 可验证所有功能模块是否正常工作。同时应提供 `autopep8.py` 作为主要实现文件，包含作为核心格式化引擎的 `FixPEP8` 类，实现 `fix_code()`、`fix_file()`、`fix_multiple_files()`、`get_module_imports_on_top_of_file` 等主要功能，并提供版本信息，使用户能通过 "import autopep8" 与 "from autopep8 import *" 等简单语句访问所有主要功能。

**考点**：把 pycodestyle 的检查结果映射为代码文本级自动修复，并叠加配置合并与批量文件处理。

## 7. `autorccar`（测试数 13）

**中文规格**

请创建一个名为 AutoRCCar 的 Python 项目，实现一套完整的自主遥控车系统。项目应包含以下功能：

1. 视频流处理模块：能从树莓派摄像头模块实时采集视频流，支持 JPEG 格式编码与传输，实现低延迟的视频数据传输。处理结果应为 OpenCV 图像对象，支持实时显示与图像预处理（如灰度转换、ROI 提取等）。

2. 神经网络模型训练：实现基于 OpenCV 的神经网络模型，能从训练图像数据中学习驾驶决策。应支持图像数据采集、模型训练、预测验证等功能。模型结构为 76800→32→4 的全连接网络，使用 Sigmoid 激活函数与反向传播训练。

3. 目标检测系统：检测并识别停车标志、交通灯等关键目标，使用级联分类器实现实时目标检测。应支持 Haar 特征检测、距离测量与安全距离判断等功能。

4. 传感器数据融合：整合超声波传感器数据，实现测距与避障功能。应支持实时距离数据接收、安全阈值判断、紧急停止控制等。

5. 硬件控制接口：设计 Arduino 控制接口，实现对遥控车的精确控制。应支持前进、后退、左转、右转等基本动作，以及复合动作（如前左转、后右转等）。

6. 核心文件要求：项目必须包含完整的 `environment.yml` 文件。该文件应把项目配置为可安装包（支持 pip install）并声明完整的依赖清单（如 `opencv-python==4.12.0.88`、`numpy==2.2.6`、`scikit-learn==1.7.1`、`pygame==2.6.1` 等实际使用的核心库）。`environment.yml` 应确保所有核心功能模块可正常工作。项目需提供 `computer/rc_driver.py` 作为自动驾驶程序的主入口，从 `model` 与 `rc_driver_helper` 模块导入神经网络模型与控制函数。在 `model.py` 中应有 `NeuralNetwork` 类，包含 `create()`、`train()`、`evaluate()`、`save_model()`、`load_model()`、`predict()` 等函数，以及用于数据加载的 `load_data()` 函数。在 `rc_driver_helper.py` 中应有包含 `steer()` 与 `stop()` 函数的 `RCControl` 类、包含 `calculate()` 函数的 `DistanceToCamera` 类，以及包含 `detect()` 函数的 `ObjectDetection` 类。项目应导出这些核心类并提供完整的测试用例，使用户能通过简单的 "python rc_driver.py" 命令启动自动驾驶系统。用户应能通过 "from rc_driver import **" 等简单语句访问所有主要功能。

**考点**：树莓派小车端到端的「摄像头视频流 + OpenCV 小型神经网络转向 + 超声波/目标检测」闭环。

## 8. `binaryalert`（测试数 77）

**中文规格**

请创建一个名为 BinaryAlert 的 Python 项目，实现一个恶意软件检测系统。项目应包含以下功能：

1. 文件解析器：能从 S3 存储桶下载并解析二进制文件，支持多种文件格式（如可执行文件、压缩文件、归档文件等）。解析结果应为可分析的二进制数据或等效的可检测形式。

2. YARA 规则匹配：实现使用 YARA 规则检测恶意软件特征的功能（或脚本），包括字符串匹配、正则表达式匹配、条件匹配等。应支持多种恶意软件类型的检测、规则编译与优化，以及实时匹配结果通知。

3. 特殊结构处理：专门处理 UPX 压缩文件、归档文件、CarbonBlack 集成、S3 事件通知等，如自动解包 UPX 文件、深度分析归档内容、从 CarbonBlack 下载文件。

4. 接口设计：为每个功能模块（如文件下载、YARA 分析、结果存储、告警发送等）设计独立的命令行接口或函数接口，支持终端调用测试。每个模块应定义明确的输入输出格式。

5. 示例与评估脚本：提供示例代码与测试用例，演示如何使用 `analyze_lambda_handler` 与 `verify` 函数进行文件分析与恶意软件检测（例如 `verify(parse("malware.exe"), yara_rules)` 应返回匹配结果）。需要组合上述功能构建完整的恶意软件检测工具箱。项目最终应包含文件处理、规则匹配与整体检测模块，并配有典型测试用例，形成可复现的检测流程。

6. 核心文件要求：项目必须包含完整的 `manage.py` 文件。该文件不仅应把项目配置为可管理的工具（支持各种管理命令），还应声明完整的依赖清单（包括 `boto3==1.9.99`、`yara-python==3.8.0`、`cbapi==1.3.6`、`terraform`、`pytest` 等核心库）。`manage.py` 可验证所有功能模块是否正常工作。同时需要提供 `cli/manager.py` 作为统一管理入口，从 `cli`、`lambda_functions`、`rules` 模块导入核心函数，导出 `Manager` 类与各类配置类，并提供版本信息，使用户能通过 "from cli import "、"from cli.config/exceptions/manager/import "、"from lambda_functions.analyzer/lambda_functions.analyzer.common/lambda_functions/ import " 与 "from rules import" 等简单语句访问所有主要功能。

7. 核心文件要求：项目必须包含完整的 `requirements.txt` 文件。该文件应把项目配置为可安装包（支持 `pip install`）并声明完整的依赖清单（如实际使用的 `defusedxml=0.7.1`、`Jinja2=3.1`、`json5=0.9`、`PyYAML=6.0` 等核心库）。`requirements.txt` 应确保所有核心功能模块可正常工作。同时需要提供 `lambda_functions/__init__.py`、`cli/__init__.py` 与 `rules/__init__.py` 作为 API 接口，导入并导出核心功能类等，并提供版本信息，使用户能通过 "from cli import **"、"from rules import **" 与 "from lambda_functions import **" 等简单语句访问所有主要功能。

**考点**：S3 事件驱动的 Lambda 化恶意文件分析流水线，核心是用 YARA 规则匹配 + UPX/归档解包。

## 9. `bleach`（测试数 448）

**中文规格**

请创建一个名为 Bleach 的 Python 项目，实现一个 HTML 安全清洗库。项目应包含以下功能：

1. **HTML 清洗器**：能从输入 HTML 字符串中移除恶意脚本与危险内容，基于白名单机制过滤标签与属性，并支持自定义允许的标签、属性与协议集合。清洗结果应为安全的 HTML 片段。
2. **链接化处理器**：实现自动识别文本中的 URL 与电子邮件地址并转换为可点击 HTML 链接的功能。应支持域名识别、端口号处理、括号与标点处理，以及自定义链接属性（如 `rel="nofollow"`）。
3. **CSS 清洗器**：对 CSS 样式做安全过滤，移除危险的 CSS 属性，支持 SVG 属性、URL 处理与字符实体处理，确保样式内容的安全性。
4. **回调函数系统**：为链接化功能提供回调机制，支持添加 `rel="nofollow"`、`target="_blank"` 等属性，以及自定义的链接处理逻辑。
5. **接口设计**：为每个功能模块（如清洗、链接化、CSS 清洗、回调处理等）设计独立的函数接口，并支持终端调用测试。每个模块应定义明确的输入输出格式。
6. **示例与评估脚本**：提供示例代码与测试用例，演示如何使用 `clean()` 与 `linkify()` 函数进行 HTML 清洗与链接化（例如 `clean('<script>alert("XSS")</script><p>Hello</p>')` 应返回 `<p>Hello</p>`）。需要组合上述功能构建完整的 HTML 安全处理工具箱。
7. **核心文件要求**：项目必须包含完整的 `setup.py` 文件，不仅应把项目配置为可安装包（支持 pip install），还应声明完整的依赖清单（包括 `html5lib`、`webencodings`、`tinycss2`、`pytest` 等核心库）。`setup.py` 可验证所有功能模块是否正常工作。同时需要提供 `bleach/__init__.py` 作为统一 API 入口，从 `sanitizer`、`linkifier`、`css_sanitizer` 等模块导入 `clean`、`linkify` 等核心函数，导出 `Cleaner`、`Linker`、`CSSSanitizer` 等核心类，并提供版本信息，使用户能通过简单的 `from bleach import **` 语句访问所有主要功能。

**考点**：基于 html5lib 解析树的标签/属性/协议白名单清洗，外加 linkify 与 CSS 消毒。

## 10. `boltons`（测试数 423）

**中文规格**

请创建一个名为 boltons 的 Python 项目，实现一个综合性的 Python 工具库。项目应包含以下功能：

1. 数据结构工具：提供高性能的数据结构实现，包括 `OrderedMultiDict`（支持多值的有序字典）、`PriorityQueue`（优先队列）、`OneToOne`（一对一映射）等。这些结构应提供完整的字典接口，支持高效的增删改查操作，适用于复杂数据处理场景。

2. 迭代器工具：实现丰富的迭代器操作函数，包括 `chunked`（数据分块）、`windowed`（滑动窗口）、`remap`（递归数据重建）、`backoff`（指数退避）等。应支持多种迭代模式，提升数据处理效率与代码可读性。

3. 文件操作工具：提供安全的文件操作函数，包括 `atomic_save`（原子保存文件）、`rotate_file`（文件轮转）、`iter_find_files`（文件查找）等。应确保文件操作的原子性与安全性，适用于高并发环境。

4. 缓存机制：实现高效的缓存系统，包括 LRU（最近最少使用）缓存、TTL（生存时间）缓存等。应支持自定义缓存策略与容量管理，适用于性能优化场景。

5. 调试与错误处理工具：提供 `TracebackInfo`（栈回溯信息）、异常处理工具、调试辅助函数等。应支持详细的错误信息收集与分析，便于问题诊断与调试。

6. 接口设计：为每个功能模块设计独立的函数接口，支持直接导入与模块化使用。每个模块应定义明确的输入输出格式，便于集成到已有项目。用户应能通过简单的 `from boltons import xxx` 语句访问所需功能。

7. 示例与测试脚本：提供示例代码与测试用例，演示如何使用各种工具函数进行数据处理、文件操作、缓存管理等（例如 `chunked([1,2,3,4,5], 2)` 应返回 `[[1,2], [3,4], [5]]`）。需要把上述功能有机结合，构建完整的 Python 工具包。

8. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件。该文件不仅应把项目配置为可安装包（支持 `pip install`），还应声明完整的依赖清单与 Python 版本要求。`pyproject.toml` 可验证所有功能模块是否正常工作。同时需要提供 `boltons/__init__.py` 作为统一 API 入口，从各 utils 模块导入核心函数，并提供版本信息，使用户能通过简单的 `from boltons import xxx` 语句访问所有主要功能。每个 utils 模块中都应有相应核心函数实现各类工具能力。其中，`ecoutils`：处理环境变量、配置文件等外部配置的工具。`fileutils`：文件操作相关工具函数，如文件查找与权限处理。`ioutils`：输入输出相关工具，简化流与缓冲区等 I/O 操作。`strutils`：字符串处理工具，包括前后缀处理、格式化等常见字符串操作。`urlutils`：URL 解析、拼接与查找相关工具。`debugutils`：调试相关工具，如跟踪、日志与断点，辅助开发调试。`dictutils`：字典相关高级操作，如有序字典、只读字典、子集提取。`formatutils`：字符串格式化、参数提取与格式模板处理函数。`funcutils`：函数工具，包括装饰器、函数构造与偏函数，支持函数式编程。`iterutils`：迭代器相关工具，如窗口化、配对、递归遍历等高级迭代操作。`namedutils`：带字段名的数据结构工具，如命名元组与命名列表。`mathutils`：数学相关工具，如取整、位运算与数值范围限制。`queueutils`：队列相关工具，包括优先队列、堆队列等数据结构。`setutils`：集合相关工具，如索引集合与集合补集等高级集合操作。`socketutils`：socket 相关工具，简化网络通信、缓冲与异常处理。`statsutils`：统计分析工具，如均值、方差等基础统计计算。`tableutils`：表格数据结构与操作工具，便于处理二维数据。`tbutils`：异常与栈回溯处理工具，便于解析与展示异常信息。`timeutils`：时间相关工具，如日期区间与时间计算。`typeutils`：类型相关工具，如哨兵对象与类型判断等辅助函数。这些模块为 Python 标准库提供实用补充，提升日常开发的效率与便利性。

**考点**：面向标准库的高密度「小型工具模块」集合，重点是原子文件操作、LRU/TTL 缓存与迭代器工具。

## 11. `boto`（测试数 1014）

**中文规格**

请创建一个名为 Boto3 的 Python 项目，实现一套完整的 AWS 云服务访问 SDK。项目应包含以下功能：

1. 会话管理系统：实现 `Session` 类管理 AWS 凭证、区域配置与 user agent 设置。应支持多种凭证配置方式（访问密钥、会话令牌、账户 ID），提供 `get_credentials()`、`get_available_services()`、`get_available_resources()`、`get_available_regions()` 等方法，并支持配置文件管理与自定义 user agent。

2. 客户端创建机制：实现 `client()` 函数为所有 AWS 服务创建低层客户端。应支持服务名、区域、API 版本、SSL 配置、endpoint URL 等参数，提供对 AWS 服务的完整覆盖，包括 S3、EC2、DynamoDB、SQS、SNS 及其他所有 AWS 服务。

3. 面向资源的编程：实现 `resource()` 函数提供高层资源抽象接口。应支持资源集合、操作、子资源等，通过 `ResourceFactory` 类动态创建资源对象，并支持 `load()`、`reload()`、`wait_until()` 等资源级操作。

4. S3 传输功能：实现 S3 文件传输的高层抽象，包括 `S3Transfer` 类与 `TransferConfig` 配置类。应支持单段与多段上传/下载、进度回调、重试机制、并行传输等，提供 `upload_file()`、`download_file()`、`copy()` 等方法，并支持自定义传输配置与进度监控。

5. DynamoDB 条件表达式：实现 DynamoDB 查询条件的构建系统，包括 `Attr`、`Key` 类及各种条件运算符。应支持等于、不等于、大于、小于、包含、以…开头、存在性检查等操作，提供 `eq()`、`lt()`、`gt()`、`contains()`、`begins_with()`、`between()` 等方法，并支持复杂条件表达式的组合。

6. EC2 标签管理：实现 EC2 实例的标签操作功能，包括 `create_tags()` 与 `delete_tags()` 方法。应支持批量创建与删除标签，提供标签过滤与查询功能，并支持标签键值对的校验与管理。

7. CRT 传输管理器：实现基于 AWS CRT 的高性能传输管理器，提供 `CRTTransferManager` 类。应支持 S3 传输优化、连接池管理、并发控制等，并提供与标准传输管理器的兼容接口。

8. 异常处理系统：实现完整的异常处理机制，包括 `ResourceNotExistsError`、`UnknownAPIVersionError`、`DynamoDBNeedsConditionError` 等自定义异常类。应提供清晰的错误消息与异常层次结构，支持异常的分类与处理。

9. 工具函数集合：实现各类工具函数，包括 `inject_attributes()`、`import_module()`、`lazy_call()` 等。应支持动态属性注入、模块导入、延迟加载等，提供开发辅助工具。

10. 文档生成系统：实现自动文档生成功能，包括服务文档、资源文档、方法文档等。应支持 RST 格式文档生成，提供 API 文档的完整覆盖，包括示例代码与参数说明。

11. 测试框架支持：实现完整的测试支持体系，包括单元测试、功能测试、集成测试等。应支持所有 AWS 服务的 client 与 resource 创建测试，提供 API 版本同步校验与服务可用性检查等功能。

12. 配置管理：实现灵活的配置管理系统，支持环境变量、配置文件、代码配置等多种方式。应提供默认配置、自定义配置与配置校验功能，支持不同环境下的配置切换。

上述特性需要组合起来构建完整的 AWS SDK 工具包。项目最终应包含会话管理、客户端创建、资源抽象、服务定制、传输优化、条件构建、文档生成等模块，并配有完整测试用例，形成可复现的 AWS 云服务访问流程。

13. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件。该文件不仅应把项目配置为可安装包（支持 `pip install`），还应声明完整的依赖清单（包括 `botocore>=1.39.16,<1.40.0`、`jmespath>=0.7.1,<2.0.0`、`s3transfer>=0.13.0,<0.14.0` 等核心库）。同时需要提供 `boto3/__init__.py` 作为统一 API 入口，导入 `ResourceNotExistsError`、`ResourceLoadException`、`DynamoDBNeedsConditionError`、`DynamoDBNeedsKeyConditionError`、`DynamoDBOperationNotSupportedError`、`TransferConfig`、`create_transfer_manager`、`has_minimum_crt_version`、`AnamoDBHighLevelResource`、`ParameterTransformer`、`TransformationInjector`、`copy_dynamodb_params`、`register_high_level_interface` 等核心类与函数，并提供版本信息。使用户能通过简单语句访问所有主要特性，如 "import boto3" 与 "from boto3.session/s3/dynamodb/ec2/resources/docs import **"。在 `session.py` 中应有 `Session` 类管理 AWS 会话与凭证。在 `resources/factory.py` 中应有 `ResourceFactory` 类动态创建资源对象。在 `s3/transfer.py` 中应有 `S3Transfer` 类处理 S3 文件传输操作。

**考点**：多层 SDK 架构——会话/凭证、低层 client 与高层 resource 抽象、S3 分段传输、DynamoDB 条件表达式构建。

## 12. `box`（测试数 147）

**中文规格**

请创建一个名为 box 的 Python 项目，实现一个综合性的 Python 字典增强工具库。项目应包含以下功能：

1. 字典结构增强工具：提供高性能的字典结构实现，包括 `Box`（支持点号访问的增强字典）、`BoxList`（支持点号访问的增强列表）、`ConfigBox`（专用于配置管理的字典）、`SBox`（简写形式的 Box）、`DDBox`（带默认值的字典 Box）等。这些结构应提供完整的字典接口，支持高效的增删改查操作，适用于复杂数据处理与配置管理场景。

2. 点号访问与属性转换工具：实现智能的点号访问功能，包括键名转换（从 camelCase 到 snake_case）、安全前缀处理、转换检查等。应支持多种访问模式，提升字典操作的便捷性与代码可读性。

3. 文件格式转换工具：提供多格式文件操作函数，包括 JSON、YAML、TOML、MessagePack 等的读写操作，支持原子保存文件、自动类型转换等。应确保文件操作的安全性与兼容性，适用于配置管理与数据持久化场景。

4. 配置管理工具：实现专业的配置管理系统，包括与环境变量集成、默认值处理、命名空间管理、动态配置更新等。应支持复杂的配置层级与校验机制，适用于应用配置与环境管理。

5. 高级字典操作工具：提供丰富的字典操作方法，包括字典合并（加、减、OR 运算）、递归转换、安全访问、冻结模式等。应支持多种操作模式，适用于数据整合与处理场景。

6. 接口设计：为每个功能模块设计独立的类接口，支持直接导入与模块化使用。每个模块应定义明确的输入输出格式，便于集成到已有项目。用户应能通过简单的 `from box import Box, ConfigBox` 语句访问所需功能。

7. 示例与测试脚本：提供示例代码与测试用例，演示如何使用各类工具类进行字典操作、配置管理、文件格式转换等（例如 `Box({"user": {"name": "admin"}}).user.name` 应返回 `"admin"`）。需要把上述功能有机结合，构建完整的 Python 字典增强工具包。

8. 核心文件要求：项目必须包含完整的 `setup.py` 文件，需要把项目配置为可安装包（支持 pip install 与可编辑模式安装）。`setup.py` 需通过构建配置验证所有功能模块（如字典增强、格式转换、错误处理等）正常工作，并支持通过测试命令触发全功能验证。同时需要提供 `box/__init__.py` 作为统一 API 入口。该文件需要从各核心模块导入关键组件：从 box 模块导入 `Box`（基础字典增强类）、`ConfigBox`（配置型字典）、`SBox`（安全字典）、`DDBox`（双向下标字典）、`BoxList`（增强列表类）等核心字典类；从错误处理模块导入 `BoxError`（基础异常）与 `BoxKeyError`（键错误异常）；从功能函数模块导入 `box_from_file`（从文件加载为 Box 对象）与 `box_from_string`（从字符串解析为 Box 对象）；此外还需导出版本信息（如 `__version__`），确保用户能通过简单的 `from box import Box, ConfigBox, BoxList, BoxError` 语句访问所有主要功能。各模块中需通过核心类实现丰富的字典增强能力：`Box` 类提供递归字典操作、属性式访问、格式转换等基础增强；`BoxList` 支持列表与字典的混合递归处理；`ConfigBox` 针对配置场景优化，支持默认值与类型转换；`SBox` 强化安全访问，避免未定义键导致的错误；`DDBox` 实现键与值之间的双向下标访问。在辅助模块中，`box.py` 中的 `_get_dot_paths`（点路径解析）与 `_camel_killer`（命名风格转换）等函数支撑字典的高级操作；`converters` 模块中的 `_from_toml`、`_to_json`、`_to_yaml` 等函数实现 Box 对象与多种格式的互转，并配合 `BOX_PARAMETERS` 配置转换规则，完整覆盖字典数据的解析、处理与序列化需求。

**考点**：以 `dict` 子类派生的属性式访问容器族，配套多格式（JSON/YAML/TOML/MessagePack）序列化与配置场景特化。

## 13. `cachier`（测试数 180）

**中文规格**

请创建一个名为 Cachier 的 Python 项目，实现一个持久化、无过期时间的函数缓存库。项目应包含以下功能：

1. **装饰器缓存系统**：实现 `@cachier` 装饰器，支持函数级持久化缓存，包括参数哈希生成、缓存键管理、结果存储与检索。装饰器应支持多种配置参数，如 `stale_after`（过期时间）、`backend`（缓存后端）、`hash_func`（自定义哈希函数）等。

2. **多后端架构**：实现五种缓存后端的支持，包括内存缓存（memory）、pickle 文件缓存（pickle）、Redis 缓存（redis）、MongoDB 缓存（mongo）与 SQL 数据库缓存（sql）。每个后端应实现统一接口但提供不同的存储特性，支持跨机器缓存与分布式部署。

3. **智能过期管理**：实现 `stale_after` 过期机制，支持设置缓存数据的「保质期」；实现 `next_time` 异步更新模式，在下次调用时重新计算；实现自动清理过期条目的功能，支持由后台线程定期清理。

4. **并发安全机制**：实现线程安全的缓存操作，包括计算过程中的状态标记、等待机制、超时控制与锁管理。支持多线程环境下的并发访问，防止重复计算与竞态条件。

5. **配置管理系统**：支持全局配置与函数级配置，提供默认参数设置、全局启用/禁用缓存功能，以及运行时覆盖参数的能力。实现动态配置更新与参数校验。

6. **错误处理与恢复**：实现完善的异常处理机制，包括损坏缓存文件的恢复、数据库连接失败的处理、计算超时控制。提供优雅的错误恢复与降级策略。

7. **性能优化特性**：支持缓存条目大小限制、性能监控，以及不同缓存策略的性能对比。提供性能评估脚本与优化建议。

8. **命令行工具**：提供 `cachier` 命令行工具，支持设置最大工作线程数等系统级配置以及缓存管理操作。

9. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件。该文件不仅应把项目配置为可安装包（支持 `pip install`），还应声明完整的依赖清单（包括 `pytest==8.4.1`、`mypy_extensions ==1.1.0` 等核心库）。`pyproject.toml` 可验证所有功能模块是否正常工作。同时应提供 `src/cachier/__init__.py` 作为统一 API 入口，使用户能通过简单的 `from cachier import *` 语句访问所有主要功能。从 `cachier.cores.base` 模块导入 `_BaseCore`、`RecalculationNeeded`；从 `cachier.config` 模块导入 `get_default_params`、`set_default_params`、`CacheEntry`、`_global_params`；从 `cachier` 模块导入 `get_global_params`、`cachier`；从 `cachier.core` 模块导入 `DEFAULT_MAX_WORKERS`、`MAX_WORKERS_ENVAR_NAME`、`_get_executor`、`_max_workers`、`_set_max_workers`；从 `cachier.__main__` 模块导入 `cli`、`set_max_workers`；从 `cachier.cores.memory` 模块导入 `_MemoryCore`；从 `cachier.cores.mongo` 模块导入 `MissingMongetter`、`_MongoCore`；从 `cachier.cores.pickle` 模块导入 `_PickleCore`；从 `cachier.cores.redis` 模块导入 `MissingRedisClient`、`_RedisCore`；从 `cachier.cores.sql` 模块导入 `_SQLCore`，并以 `sql_mod` 为别名导入 `cachier.cores.sql` 模块；从 `cachier.util` 模块导入 `parse_bytes`；同时导入 `cachier` 模块本身。版本信息通过 `cachier` 模块内的 `_version.py` 文件提供，项目 `pyproject.toml` 通过 `[tool.setuptools.dynamic]` 配置 `version = { attr = "cachier._version.__version__" }` 获取版本。

**考点**：装饰器级跨进程持久缓存，难点是五种后端统一接口、`stale_after`/`next_time` 语义与并发防重复计算。

## 14. `cerberus`（测试数 249）

**中文规格**

请创建一个名为 Cerberus 的 Python 项目，实现一个轻量且可扩展的数据校验库。项目应包含以下功能：

1. 核心校验器：实现 `Validator` 与 `BareValidator` 类，提供文档校验与规范化功能，支持多种校验规则（`required`、`nullable`、`type`、`min`、`max`、`regex` 等），包括处理校验规则的全部 `_validate_*` 方法、用于数据规范化的 `_normalize_*` 方法，以及 `validate()`、`validated()`、`normalized()` 等核心方法。

2. Schema 定义系统：实现 `DefinitionSchema`、`SchemaError`、`UnvalidatedSchema` 等类来处理 schema 的定义与解析，支持包含嵌套结构、逻辑运算符（`anyof`、`allof`、`oneof`、`noneof`）与 schema 引用的复杂校验 schema 定义。

3. 错误处理机制：实现 `ValidationError`、`ErrorList`、`DocumentErrorTree`、`SchemaErrorTree` 等类提供错误处理系统，支持错误收集、错误树结构，以及包括 `BasicErrorHandler` 与自定义错误处理器在内的多种错误格式化方式。

4. 工具函数与可扩展性：实现 `TypeDefinition`、`validator_factory`、`compare_paths_lt` 等工具函数，支持自定义校验规则与类型定义，提供 schema 注册表（schema registry）与规则集注册表（ruleset registry）功能，并支持动态创建校验器类。

5. 平台兼容性：实现 `importlib_metadata` 以处理版本检测与平台兼容，支持所有 Python 3.7+ 版本（包括 CPython 与 PyPy 实现），并处理不同 Python 版本间的导入差异。

6. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，不仅应把项目配置为可安装包（支持 pip install），还应声明完整的依赖清单（包括 pytest 等测试框架）。`pyproject.toml` 应能验证所有功能模块是否正常工作。此外，提供 `cerberus/__init__.py` 作为统一 API 入口，从 `validator`、`schema`、`errors`、`utils` 与 `platform` 模块导入 `Validator`、`DocumentError`、`SchemaError`、`errors`、`schema_registry`、`rules_set_registry`、`TypeDefinition` 等核心组件，并提供版本信息。使用户能通过 "from cerberus import Validator, errors" 等简单语句访问所有主要功能。在 `validator.py` 中应有 `BareValidator` 与 `Validator` 类实现核心校验功能，包括处理校验规则的全部 `_validate_*` 方法、用于数据规范化的 `_normalize_*` 方法，以及 `validate()`、`validated()`、`normalized()` 等核心方法。在 `schema.py` 中应有 `DefinitionSchema`、`SchemaError`、`UnvalidatedSchema` 等类处理 schema 的定义与解析。在 `errors.py` 中应有 `ValidationError`、`ErrorList`、`DocumentErrorTree`、`SchemaErrorTree` 等类提供错误处理系统。在 `utils.py` 中应有 `TypeDefinition`、`validator_factory`、`compare_paths_lt` 等工具函数。在 `platform.py` 中应有 `importlib_metadata` 处理版本检测与平台兼容。创建 `test_validation.py`、`test_schema.py`、`test_normalization.py`、`test_errors.py`、`test_customization.py`、`test_registries.py`、`test_utils.py`、`test_assorted.py` 等测试文件。每个测试文件应包含适当的 import 语句，确保正确导入并测试所有核心功能模块。

为满足仓库结构要求，`benchmarks` 目录下文件 `__init__.py` 的内容应为：

```python
from pathlib import Path


DOCUMENTS_PATH = Path(__file__).parent / "documents"
```

**考点**：以「规则 → `_validate_*` / `_normalize_*` 方法」的可插拔映射实现 schema 校验，并配套错误树与注册表。

## 15. `cherry`（测试数 34）

**中文规格**

请创建一个名为 `cherry` 的 Python 项目，实现一个轻量文本分类库。项目应包含以下功能：

1. **数据处理与训练**：能加载并处理用户提供的训练数据。数据格式可以是常见文本文件（如 `.txt`、`.csv`），其中每条数据包含文本内容与对应的分类标签。程序需要从数据中自动构建词表并完成模型训练。
2. **文本分类预测**：提供核心分类函数（或脚本），能对输入的新文本进行分类预测。支持加载预训练模型或用户自行训练的模型，并返回最可能的分类标签及其置信度（或概率）。
3. **预训练模型与定制化**：项目应内置若干常用预训练模型（如用于新闻分类、邮件分类、情感分析等），用户可直接加载使用。同时应支持用户替换或自定义核心算法，例如分词方式（例如允许用户接入 jieba 或其他分词器）。
4. **接口设计**：为每个核心功能（如模型训练、文本预测）设计独立的命令行接口或函数接口。每个接口应有明确的输入输出定义。例如命令行工具应能通过参数指定训练数据路径、模型保存路径或待分类文本。
5. **示例与用法演示**：提供示例代码与演示案例，展示如何调用 `train()` 与 `classify()` 函数进行模型训练与预测。例如 `train(model='my_data', encoding='utf-8')` 应完成训练并保存模型，`classify(model='my_data', text='some new text')` 应返回预测结果。最后把它们整合为完整的分类工具包，并提供清晰的使用流程。
6. **核心文件要求**：项目必须包含完整的 `setup.py` 文件。该文件不仅应把项目配置为可安装包（支持 `pip install`），还应声明完整的依赖清单（包括 `scikit-learn`、`numpy`、`pandas`、`joblib`、`matplotlib`、`regex`、`tqdm` 等核心库）。`setup.py` 文件可验证所有功能模块是否正常工作。同时需要提供 `cherry/__init__.py` 作为统一 API 入口，导入并导出 `Classify`、`train`、`performance`、`search`、`display`、`_load_data_from_local`、`_load_data_from_remote`、`_decompress_data`、`_fetch_remote`、`get_clf`、`get_vectorizer`、`get_vectorizer_and_clf`、`DATA_DIR`、`load_data` 以及 main 导入导出函数，并提供版本信息，使用户能通过简单的 `from cherry.** import **` 或 `from cherry import **` 语句访问所有主要功能。在 `cherry/trainer.py` 中应有完整的训练流程管理功能。在 `cherry/classifyer.py` 中应有分类预测的核心逻辑，通过多种策略处理文本特征提取与分类预测，确保系统的完整性与可用性。

**考点**：极简「词表 + sklearn 分类器」文本分类流水线，并封装预训练模型加载与可替换分词器。

## 16. `cookiecutter`（测试数 381）

**中文规格**

请创建一个名为 Cookiecutter 的 Python 项目，实现一个项目模板生成工具。项目应包含以下功能：

1. **模板仓库管理**：实现从多种来源获取项目模板的功能，如本地目录、远程 Git 仓库与 ZIP 文件。应支持克隆模板仓库、缓存管理、版本检出（checkout 特定分支或 tag），以及模板目录的自动发现与校验（确保存在 `cookiecutter.json` 配置文件）。

2. **用户交互系统**：实现完整的用户交互功能，包括文本输入提示、是/否选择、多选项列表、字典/JSON 输入等。应支持设置默认值、输入校验、自定义提示消息，以及在非交互模式（`no_input`）下自动使用默认值。

3. **模板渲染引擎**：实现基于 Jinja2 模板引擎的文件内容渲染，支持变量替换、条件语句、循环结构、过滤器等高级功能。应正确处理二进制文件（直接复制）与文本文件（渲染后复制），同时保留文件权限与目录结构。

4. **上下文生成与管理**：实现模板上下文的生成、合并与覆盖机制。应支持从 `cookiecutter.json` 加载默认配置、用用户配置文件覆盖、用命令行参数覆盖，以及为嵌套模板传递上下文。

5. **Hook 系统**：实现 pre-prompt、pre-generation 与 post-generation hook 的发现与执行机制。应同时支持 Python 脚本与 Shell 脚本作为 hook，提供上下文变量传递，并处理 hook 执行失败的情况。

6. **重放（Replay）功能**：实现保存与重放用户输入的功能，支持把用户配置保存为 JSON 文件，并在后续使用中自动加载，用于批量生成项目与配置复用。

7. **命令行接口**：提供完整的命令行接口，支持对全部核心功能的参数化调用，包括模板路径、输出目录、配置选项、hook 控制等参数。

8. **错误处理与日志**：实现完善的异常处理机制，包括模板不存在、配置错误、渲染失败、hook 执行失败等情况的处理，并提供详细的日志输出与错误信息。

9. **配置管理**：实现用户配置文件的加载、解析与管理，支持缩写定义、默认模板目录、replay 目录等配置项。

10. **文件操作工具**：提供文件系统操作的辅助工具，包括目录创建、文件复制、权限设置与临时目录管理。

11. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件。该文件不仅应把项目配置为可安装包（支持 `pip install`），还应声明完整的依赖清单（包括 `jinja2>=3.0.0`、`click>=8.0.0`、`binaryornot>=0.4.4`、`rich>=10.0.0`、`pytest>=6.0.0`、`pytest-cov>=2.0.0` 等核心库）。`pyproject.toml` 文件可验证所有功能模块是否正常工作。此外，`cookiecutter/__init__.py` 需作为统一 API 入口，从 `cookiecutter` 模块导入并导出核心函数、类等，并提供版本信息，使用户能通过 `from cookiecutter import xxx` 等简单语句访问所有主要功能。在 `generate.py` 中要求提供 `generate_context()` 函数生成模板上下文，`generate_files()` 函数渲染并生成项目文件。在 `prompt.py` 中要求提供 `prompt_for_config()` 函数处理用户交互，以及 `read_user_variable()`、`read_user_choice()`、`read_user_yes_no()` 等函数处理不同类型的用户输入。在 `hooks.py` 中要求提供 `run_hook()` 函数执行 hook 脚本，`find_hook()` 函数发现 hook 文件。在 `repository.py` 中要求提供 `determine_repo_dir()` 函数判定模板仓库目录，支持本地路径、Git URL 与 ZIP 文件等多种模板来源。在 `config.py` 文件中必须包含 `DEFAULT` 配置。

**考点**：模板仓库解析 + Jinja2 渲染 + 交互式上下文收集与 hook 生命周期，最难的是多来源模板定位与 replay。

## 17. `coverage_shield`（测试数 11）

**中文规格**

请创建一个名为 Coverage-Shield 的 Python 项目，实现一个测试覆盖率徽章自动化命令行工具。项目应包含以下功能：

1. **覆盖率报告生成器**：能运行单元测试并生成覆盖率报告，支持 unittest 与 pytest 测试框架。应通过 subprocess 调用外部 coverage 命令，把返回的覆盖率数据解析为 pandas DataFrame 格式，并计算平均覆盖率百分比。

2. **智能徽章生成器**：实现能根据覆盖率百分比自动选择颜色（使用 seaborn 调色板）并生成符合 shields.io 标准的徽章 URL 的功能。应支持成功状态（显示具体覆盖率百分比）与失败状态（显示 "failing"）的徽章。

3. **文件更新器**：智能更新 `README.md` 文件，支持用正则表达式匹配替换已有徽章，或在文件开头自动添加新徽章。应提供 `.covignore` 文件配置，采用 `.gitignore` 风格以忽略特定文件的覆盖率计算。

4. **Git 集成模块**：实现 Git 操作集成，包括检查文件变更状态、自动暂存、提交并推送更新后的 README 文件。应提供可选的自动提交功能。

5. **命令行接口**：为每个功能模块设计独立的命令行接口以支持终端调用测试。应包含以下参数：`-d/--directory`（目标目录）、`-r/--readme`（README 文件路径）、`-t/--tester`（测试框架选择）、`-g/--git_push`（Git 推送选项）。

6. **示例与测试脚本**：提供示例代码与测试用例，演示如何使用 `run_code_coverage()` 函数运行测试并生成报告、使用 `make_coverage_badge_url()` 函数生成徽章 URL、使用 `replace_regex_in_file()` 函数更新 README 文件。应包含覆盖所有核心功能模块的完整单元测试套件。

7. **核心文件要求**：项目必须包含定义良好的 `setup.py` 文件。该文件不仅应把项目配置为可安装包（支持 pip install），还应声明完整的依赖清单（包括 `pandas`、`seaborn`、`coverage`、`setuptools`、`pre-commit`、`pathlib` 等核心库）。`setup.py` 文件可验证所有功能模块是否正常工作。同时需要提供 `coverage_shield/__init__.py` 作为统一 API 入口，从 `command_line_interface_functions` 与 `unittest_coverage_functions` 模块导入核心函数 `build_command_line_interface` 与 `run_code_coverage`，并提供版本信息，使用户能通过简单的 "python -m coverage_shield" 语句访问所有主要功能。在 `unittest_coverage_functions.py` 中应有 `parse_coverage_report()` 函数解析覆盖率报告字符串、`get_badge_colour()` 函数根据覆盖率值选择徽章颜色、`make_coverage_badge_url()` 函数生成完整徽章 URL，以及 `replace_regex_in_file()` 函数更新 README 文件中的徽章。

**考点**：把 coverage 文本报告解析成百分比、映射成 shields.io 徽章 URL 并幂等回写 README。

## 18. `databases`（测试数 154）

**中文规格**

请创建一个名为 Databases 的 Python 项目，实现一个异步数据库操作库。项目应包含以下功能：

1. **异步数据库连接管理**：实现异步数据库连接池管理，支持多种数据库后端（PostgreSQL、MySQL、SQLite）。每个异步任务维护独立的数据库连接，确保并发安全与连接隔离。应支持连接生命周期管理、自动获取/释放连接，以及连接池配置优化。

2. **统一查询执行接口**：提供统一的异步查询执行接口，支持原生 SQL 与 SQLAlchemy Core 表达式，自动处理参数绑定、类型转换与结果集封装。应支持多种查询模式：单行、多行、单值、迭代等，以及批量操作优化。

3. **事务管理系统**：实现完整的异步事务管理功能，支持嵌套事务、自动提交/回滚、装饰器模式，以及多任务环境下的事务隔离。确保数据一致性与 ACID 特性，支持测试环境下的强制回滚模式。

4. **数据库后端抽象**：提供统一的数据库后端抽象接口，支持多种数据库驱动的无缝集成，包括 PostgreSQL（asyncpg、aiopg）、MySQL（aiomysql、asyncmy）、SQLite（aiosqlite）等。通过抽象层实现与数据库无关的代码编写。

5. **数据类型处理与类型安全**：提供完整的 Python 数据类型到数据库类型的映射，支持自动类型转换、类型校验与类型安全的查询构建。通过 SQLAlchemy 类型系统确保数据一致性与安全性，支持 JSON、datetime、numeric 等复杂数据类型。

6. **Web 框架集成支持**：提供与主流 Web 框架的无缝集成，支持 FastAPI、Starlette 等 ASGI 框架，包括数据库中间件、依赖注入、连接生命周期管理等。在 Web 应用中实现数据库最佳实践。

7. **连接池管理与任务隔离**：实现基于 `asyncio.Task` 的连接池管理机制，使用 `WeakKeyDictionary` 实现任务到连接的映射，支持连接复用与自动释放，确保每个异步任务拥有独立的数据库连接。

8. **查询构建与参数绑定**：支持 SQLAlchemy Core 表达式与原生 SQL 查询，自动处理参数绑定与查询编译，提供类型安全的查询接口。与 SQLAlchemy 的查询编译系统集成，支持预编译参数与查询优化。

9. **批量操作与性能优化**：支持批量插入、更新与删除操作，通过 `execute_many` 方法优化大数据量处理性能，减少数据库往返次数。支持用异步迭代器处理大数据集，实现内存优化与流式处理。

10. **错误处理与异常管理**：提供完善的错误处理机制，包括连接错误、事务回滚、查询执行异常等，确保应用的健壮性与数据一致性。实现自动事务回滚、连接清理与优雅降级机制。

**核心文件要求**：项目必须包含完整的 `setup.py` 文件，不仅应把项目配置为可安装包（支持 pip install），还应声明完整的依赖清单（包括 `sqlalchemy>=2.0.7`、`asyncpg>=0.27.0`、`aiosqlite>=0.17.0`、`aiomysql>=0.1.0`、`asyncmy>=0.2.0`、`psycopg>=3.0.0`、`pymysql>=1.0.0`、`pytest>=7.0.0`、`pytest-asyncio>=0.21.0`、`httpx>=0.24.0`、`starlette>=0.20.0`、`fastapi>=0.100.0` 等核心库）。`setup.py` 应能验证所有功能模块是否正常工作，同时提供 `databases/__init__.py` 作为统一 API 入口，从 core 模块导入 `Database` 与 `DatabaseURL` 核心类，导出 `Connection`、`Transaction` 等接口类，并提供版本信息，使用户能通过简单的 "from databases import Database, DatabaseURL" 语句访问所有主要功能，并可通过 `from databases import **` 访问全部功能。在 `core.py` 中应有 `Database` 类管理数据库连接池与事务、`Connection` 类管理单个连接、`Transaction` 类管理事务生命周期，使用 `ContextVar` 与 `WeakKeyDictionary` 实现任务级连接隔离与事务管理。在 `interfaces.py` 中定义 `Backend`、`ConnectionBackend`、`TransactionBackend` 等抽象接口，确保不同数据库后端之间的一致性。在 `backends/` 目录中为每种数据库类型提供具体实现，包括连接池配置、SSL 支持、方言处理等。项目最终应包含连接管理、事务处理、查询执行、类型安全、Web 集成等核心模块，并配有完整测试用例，形成可复现的异步数据库操作库。

**考点**：用 `ContextVar` + `task` 级连接隔离实现多后端异步连接池与事务，并做 SQLAlchemy Core 编译集成。

## 19. `dbutils`（测试数 140）

**中文规格**

请创建一个名为 DBUtils 的 Python 项目，实现一个数据库连接管理库。项目应包含以下功能：

1. 连接池管理模块：实现 `PooledDB` 类管理数据库连接池，支持配置最小/最大缓存连接数、连接共享策略、阻塞等待机制等。应支持兼容 DB-API 2 的数据库接口，并提供线程安全的连接获取与归还功能。

2. 持久连接模块：实现 `PersistentDB` 类提供线程亲和（thread-affinity）的持久数据库连接。同一线程始终使用同一连接，支持限制连接复用次数、会话配置命令、事务管理等功能。连接关闭时自动重连，确保应用稳定性。

3. 连接稳定性增强模块：实现 `SteadyDB` 类为底层数据库连接提供「加固」功能。当数据库连接丢失或达到使用上限时，自动透明地重新打开连接。支持限制连接使用次数、会话准备命令，以及处理故障转移异常。

4. 简化连接池模块：实现 `SimplePooledDB` 类提供轻量级数据库连接池。接口设计完全透明，使用后连接自动归还到池。支持线程安全，适用于简单连接池需求。

5. PostgreSQL 专用模块：为 PostgreSQL 数据库提供专门实现，包括 `PersistentPg`、`PooledPg`、`SteadyPg` 与 `SimplePooledPg` 类，支持经典 PyGreSQL API 与 DB-API 2 接口。

6. 接口设计：为每个功能模块设计清晰的类接口，支持配置参数（如连接参数、池大小、超时设置等）。每个模块应定义明确的连接获取、归还与关闭方法，保持与标准 DB-API 2 接口的兼容性。

7. 示例与使用说明：提供完整的示例代码与文档，演示如何使用各类连接管理类。包含基本用法、高级配置、错误处理、性能优化等场景的示例代码。

8. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，不仅应把项目配置为可安装包（支持 `pip install`），还应声明完整的依赖清单（包括 `setuptools>=77`、`Python>=3.7`、`Python<=3.13`、`PyGreSQL>=5`、`docutils>=0.18`、`pytest>=7`、`ruff>=0.0.284` 等核心库）。项目结构应包含 `dbutils/__init__.py` 作为统一包入口，从各模块导入核心类，导出 `InvalidConnectionError`、`NotSupportedError`、`PooledDB`、`SharedDBConnection`、`TooManyConnectionsError`、`PersistentDB`、`local`、`SteadyPgConnection` 等主要类与函数，并提供版本信息，使用户能通过简单的 `from dbutils import `、`from dbutils.persistent_pg/pooled_db/pooled_pg/steady_pg/persistent_db import ` 语句访问所有主要功能。

**考点**：DB-API 2 之上的四种连接复用策略（池化/线程亲和/加固/简化池）与失效自动重连语义。

## 20. `decouple`（测试数 67）

**中文规格**

请创建一个名为 Python-Decouple 的 Python 项目，实现一个配置管理分离库。项目应包含以下功能：

1. **配置读取器**：应能从多个来源读取配置参数，包括环境变量、`.env` 文件与 `.ini` 文件，并按优先级顺序取值（环境变量 > 配置文件 > 默认值）。应支持自动检测配置文件位置，并向上递归搜索 `settings.ini` 或 `.env` 文件。

2. **类型转换系统**：实现智能类型转换功能，能把字符串配置自动转换为 Python 原生类型。应支持布尔转换（如 "True"/"False"、"yes"/"no"、"1"/"0" 等）、整数转换、列表转换（通过 CSV 解析）、元组转换等，并提供自定义转换函数的能力。

3. **配置校验与约束**：实现 `Choices` 校验器，可把配置值限制在预定义选项范围内，支持 Django 风格的 choices 元组格式。同时支持能处理复杂字符串切分与类型转换需求的 CSV 解析器。

4. **Docker 集成**：支持 Docker secrets 功能，能从 `/run/secrets/` 目录读取敏感配置信息，为容器化部署提供安全的配置管理方案。

5. **接口设计**：设计简洁的 API 接口，主要提供 `config()` 函数作为核心接口，支持 `default` 与 `cast` 等参数。同时提供 `Csv` 与 `Choices` 等辅助类用于复杂配置处理。每个模块应定义明确的输入输出格式与错误处理机制。

6. **编码与兼容性**：支持多种编码格式（默认 UTF-8）并提供编码配置能力。确保对 Python 2.7 与 3.x 的向后兼容，并处理不同版本间的 API 差异。

7. **核心文件要求**：项目必须包含完整的 `setup.py` 文件。该文件不仅应把项目配置为可安装包（支持 pip install），还应声明完整的依赖清单（包括 `setuptools` 等核心库）。`setup.py` 应能验证所有功能模块是否正常工作。同时需要提供 `decouple.py` 作为核心实现文件，包含 `Config`、`RepositoryIni`、`RepositoryEnv`、`RepositorySecret`、`AutoConfig`、`Csv`、`Choices` 等核心类，并提供版本信息，使用户能通过简单的 "from decouple import xxx" 语句访问所有主要功能。在 `decouple.py` 中必须有 `strtobool()` 函数处理布尔转换（支持 "y"/"yes"/"t"/"true"/"on"/"1" 为 True，"n"/"no"/"f"/"false"/"off"/"0" 为 False），有 `UndefinedValueError` 异常类处理未定义配置，有 `Undefined` 类表示未定义类型，以及 `undefined` 实例作为未定义值的引用。在 `Config` 类中必须实现 `get()` 方法支持 `option`、`default` 与 `cast` 参数，`_cast_boolean()` 方法处理布尔转换，`_cast_do_nothing()` 静态方法作为默认转换函数，以及 `__call__()` 方法作为 `get()` 的便捷调用。在 `RepositoryIni` 类中必须实现 `__init__()` 方法接受 `source` 与 `encoding` 参数、`__contains__()` 方法检查键是否存在、`__getitem__()` 方法获取配置值，支持从 `.ini` 文件的 `[settings]` 段读取配置。在 `RepositorySecret` 类中必须实现 `__init__()` 方法从指定目录读取 secrets 文件、`__contains__()` 方法检查键是否存在、`__getitem__()` 方法获取配置值，支持 Docker secrets 功能。在 `AutoConfig` 类中必须实现 `__init__()` 方法接受可选的 `search_path` 参数、`_find_file()` 方法向上递归搜索配置文件、`_load()` 方法加载配置仓库、`_caller_path()` 方法获取调用者路径，以及 `__call__()` 方法作为配置访问接口，支持自动检测 `settings.ini` 或 `.env` 文件。在 `Csv` 类中必须实现 `__init__()` 方法接受 `cast`、`delimiter`、`strip` 与 `post_process` 参数，以及 `__call__()` 方法执行 CSV 解析，支持自定义分隔符、字符清理、类型转换与后处理。在 `Choices` 类中必须实现 `__init__()` 方法接受 `flat`、`cast` 与 `choices` 参数，以及 `__call__()` 方法执行选项校验，支持扁平列表与 Django 风格选项元组，以及类型转换函数。项目还必须提供 `DEFAULT_ENCODING` 常量（默认 `'UTF-8'`）以支持编码配置功能。

8. **示例与文档**：提供完整的 README 文档，包含安装说明、基本用法示例、高级功能演示（如 Django 集成、CSV 解析、Choices 校验等）以及常见问题。文档应覆盖所有主要功能模块的使用方法与最佳实践。

**考点**：配置源分层（环境变量 > 文件 > 默认）+ 可插拔 `cast` 转换，含 Docker secrets 与向上递归查找。

## 21. `deepdiff`（测试数 970）

**中文规格**

请创建一个名为 DeepDiff 的 Python 项目，实现一个深度对象比较库。项目应包含以下功能：

1. **深度比较引擎**：实现 `DeepDiff` 类，可递归比较两个 Python 对象的所有层级，支持字典、列表、集合、元组与自定义对象等复杂数据结构。比较结果应包含详细的差异信息，包括类型变化、值变化、条目增删等。支持忽略顺序、忽略类型变化、路径过滤等高级配置选项。

2. **差异对象系统**：实现 `Delta` 类，可捕获并应用差异，类似 Git 的提交系统。应支持把差异应用到原对象以生成新对象状态，以及双向差异应用。支持序列化、校验机制、错误处理等。

3. **深度搜索功能**：实现 `DeepSearch` 类，可在复杂数据结构中搜索特定值，支持路径匹配、类型过滤、正则表达式等。

4. **深度哈希功能**：实现 `DeepHash` 类为复杂对象生成哈希值，支持哈希缓存、自定义 hasher 等。

5. **命令行接口**：为每个功能模块设计独立的命令行接口，支持 `diff`、`patch`、`grep`、`extract` 等命令，并支持多种文件格式。

6. **序列化支持**：实现序列化模块，支持 JSON、Pickle 等格式的序列化与反序列化，并支持安全的反序列化机制。

7. **特殊结构处理**：为 NumPy 数组、Pandas DataFrame、Polars DataFrame、自定义对象等提供专门处理。

8. **工具函数集合**：实现路径处理、类型检测、数值处理、时间处理、缓存管理等工具函数。

9. **测试验证脚本**：创建 `comprehensive_test.py` 文件，应包含以下测试函数：
   - 测试 `DeepDiff` 的基本比较功能（针对字典、列表、集合等）
   - 测试 `Delta` 的差异应用功能（正向与反向应用）
   - 测试 `DeepSearch` 的搜索功能（各种搜索模式）
   - 测试 `DeepHash` 的哈希功能（针对各种数据类型）
   - 测试命令行接口（`diff`、`patch`、`grep`、`extract` 命令）
   - 测试序列化功能（JSON、Pickle 等）
   - 测试特殊数据结构（NumPy、Pandas 等）
   - 测试错误处理与边界情况
   - 测试性能优化功能（缓存、限制等）
   - 测试配置选项（各种忽略选项、路径过滤等）

10. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件，需要把项目配置为可安装包（支持 pip install 与可编辑模式安装）并声明完整的依赖清单，包括 `deepdiff==8.5.0`（核心库）、`numpy==1.26.4`（数组比较支持）、`pandas==2.2.3`（数据结构比较）、`pytest==8.4.0`（测试框架）、`click`（命令行工具）、`orjson`（高效 JSON 处理）、`tomli-w`（TOML 写入）、`pyyaml`（YAML 序列化）、`jsonpickle`（对象序列化）、`polars`（数据框比较）等核心库。同时需要提供 `deepdiff/__init__.py` 作为统一 API 入口。该文件需要整合各核心模块的关键组件：从 `diff` 模块导入 `DeepDiff`（核心差异计算类）；从 `delta` 模块导入 `Delta`（差异增量类）；从 `deephash` 模块导入 `DeepHash`（对象哈希生成类）与 `sha256hex`（哈希算法）；从 `search` 模块导入 `DeepSearch`（深度搜索类）与 `grep`（模式匹配函数）；从 `commands` 模块导入 `diff`、`patch`（差异应用）、`extract`（数据提取）等工具函数；从 `path` 模块导入 `parse_path`、`stringify_path`（路径解析与转换）、`GET`/`GETATTR`（路径操作常量）；从 `model` 模块导入 `DiffLevel`（差异层级模型）、`DictRelationship`（字典关系处理）等结构类；从 `helper` 模块导入 `AnySet`（无序集合比较）、`SetOrdered`（有序集合处理）等辅助类型；从 `serialization` 模块导入 `json_dumps`、`pickle_load`（跨格式序列化）；此外还需导出 `summarize`（差异摘要）、`LFUCache`（缓存机制）、`BaseOperator`（自定义运算符基类）等扩展功能，并通过 `__version__` 提供版本信息。确保用户能通过 `from deepdiff import DeepDiff, Delta, DeepHash, grep, parse_path` 等简洁语句访问所有主要功能。在 `grader.py` 中，`deepdiff_expr_eq()` 函数需要使用多种策略验证两个对象的深度差异等价性：通过 `DeepDiff` 的 `ignore_order` 参数处理集合顺序差异，使用 `cutoff_distance` 控制数值类型（如 numpy 数组与浮点数）的容忍范围，通过 `exclude_paths` 忽略无关字段；结合 `Delta` 验证差异的可逆性（应用补丁后是否能恢复原对象）；使用 `helper` 模块中的 `datetime_normalize` 函数处理时间格式差异，并使用 `diff_numpy_array` 专门验证数组元素；支持自定义 `BaseOperator` 处理特殊类型（如 Pydantic 模型与枚举），最终返回布尔值与差异详情，确保复杂对象比较的准确性与灵活性。

**考点**：递归差异模型（含 `Delta` 可逆补丁、`DeepHash` 稳定哈希）对复杂嵌套对象做可配置、可序列化的比较。

## 22. `deslib`（测试数 532）

**中文规格**

请创建一个名为 DESlib 的 Python 项目，实现一个动态集成选择（DES）与动态分类器选择（DCS）算法库。项目应包含以下功能：

1. **算法实现模块**：
   - 实现十余种主流动态集成选择（DES）与动态分类器选择（DCS）算法，包括但不限于 META-DES、KNORA-E、KNORA-U、DES-P、KNOP、OLA、LCA、MCB、A Priori、A Posteriori 等。
   - 支持静态集成方法（如 Oracle、Single Best、Static Selection、Stacked Classifier）作为对比基线。
   - 每个算法应为独立的 Python 类，全部继承自统一基类，接口风格与 scikit-learn 一致（`fit`、`predict`、`predict_proba`、`score`）。

2. **工具与评估模块**：
   - 提供聚合函数（如多数投票、加权投票）、多样性度量与实例硬度分析等工具模块。
   - 支持局部区域定义、分类器能力（competence）评估与选择机制，支持多种距离度量与 KNN 后端（可选高性能 FAISS 以加速大规模数据处理）。
   - 支持异构分类器池，并与 scikit-learn 生态兼容。

3. **接口设计**：
   - 每个功能模块（如算法实现、聚合、多样性、KNN 后端等）应有独立的 Python 包与清晰的 API。
   - 提供统一 API 入口（如 `deslib/__init__.py`）导出所有主要算法与工具类。用户可使用 `from deslib import KNORAE, META_DES` 等语句直接访问。
   - 所有算法类与工具函数都应有详细的 docstring，说明输入输出格式与用法。

4. **示例与测试用例**：
   - 提供丰富的示例代码与测试用例，演示如何使用各种算法进行训练、预测与评估。
   - 示例应覆盖 scikit-learn 集成、FAISS 加速、异构分类器池等典型场景。
   - 测试用例应覆盖所有主要功能模块，确保算法的正确性与兼容性。

5. **依赖与安装**：
   - 项目必须包含完整的 `setup.py` 文件，支持通过 `pip install` 安装。
   - `setup.py` 文件应声明完整的依赖清单（如 scikit-learn、numpy、scipy、faiss、joblib、pytest 等），并能验证所有功能模块是否正常工作。
   - 分别提供 `requirements.txt` 与 `requirements-dev.txt` 用于生产与开发环境。

6. **文档与版本信息**：
   - 提供详细的 `README.rst` 与 `docs/` 文档，介绍项目背景、功能、用法、API 说明、引用方式等。
   - `deslib/__init__.py` 文件应包含 `__version__` 变量以统一管理版本信息。

7. **兼容性与可扩展性**：
   - 所有算法与工具应完全兼容 scikit-learn API，支持与 scikit-learn pipeline 无缝集成。
   - 支持 FAISS 作为可选依赖，用于大规模数据的高效 KNN 检索。
   - 采用模块化、易扩展的架构，便于新算法与工具的接入。

8. **项目结构要求**：
   - `deslib/` 目录应包含 `des/`、`dcs/`、`static/`、`util/`、`tests/` 等子包，对应不同的算法与工具模块。
   - 每个子包应有 `__init__.py` 文件导出主要类与函数。
   - 根目录应有 `setup.py`、`README.rst`、`requirements.txt`、`LICENSE.txt` 等核心文件。

9. **API 入口与主要功能**：
   - `deslib/__init__.py` 文件作为统一 API 入口，导入并导出所有核心算法与工具。
   - 用户可使用 `from deslib.des.knora_e import KNORAE` 等语句访问所有主要功能。

10. **评估与基准**：
    - 提供 `benchmarks/` 目录，包含在典型数据集（如 UCI HIGGS）上的性能评估脚本。
    - 支持多种评估指标与实验配置，便于算法对比与复现。

11. **核心文件要求**：项目必须包含完整的 `setup.py` 文件，需要把项目配置为可通过 `pip install` 安装的标准 Python 包，声明完整的依赖清单——包括 `scikit-learn>=1.0.2`（基础机器学习算法支持）、`numpy>=1.17.0`（数值计算核心）、`scipy>=1.4.0`（科学计算工具）等核心库，确保动态选择算法、多样性度量与数据集处理等功能的兼容性。`setup.py` 文件需能验证所有功能模块是否正常工作，支持通过测试命令触发全量验证，覆盖基类接口一致性（如 `BaseDS` 的方法实现）、动态选择算法的预测逻辑（KNORAE、METADES 等）、静态选择策略的有效性（Oracle、SingleBest 等），以及 `util` 模块中工具函数的正确性（如数据集生成 `make_xor`、多样性度量 `Q_statistic`）。同时需要提供 `deslib/__init__.py` 作为统一 API 入口，需整合各核心模块的关键组件：从 `des` 模块导入动态集成选择算法（KNORAE、KNORAU、METADES、DESP、KNOP、DESKNN、DESClustering、DESMI 等）；从 `dcs` 模块导入动态分类器选择算法（OLA、LCA、MCB、APriori、APosteriori、Rank 等）；从 `static` 模块导入静态选择方法（Oracle、SingleBest、StaticSelection、StackedClassifier 等）；从 `base` 模块导入基类 `BaseDS`；从 `util` 模块导入核心工具函数（如数据集生成 `make_P2`、多样性计算 `ratio_errors_errors`、概率函数 `softmax` 等）。此外需通过 `__version__` 提供版本信息，确保用户能通过简单的 `from deslib import KNORAE, OLA, Oracle` 语句直接访问主要功能，而无需关注内部模块结构。在 `deslib/base.py` 中，`BaseDS` 基类需定义动态选择算法的通用接口，规范所有子类的实现标准：核心方法包括 `fit(X, y)`（训练模型，拟合基分类器与动态选择机制）、`predict(X)`（预测样本标签）、`predict_proba(X)`（输出类别概率分布），确保算法基础训练与预测流程的一致性；抽象方法包括 `estimate_competence(X)`（评估基分类器在样本上的能力）、`select(X)`（基于能力选择最优基分类器子集）、`classify_with_ds(X)`（基于选择结果进行最终预测），强制不同动态选择策略的子类（如 KNORAU 中的邻域选择、OLA 中的全局准确率能力评估）提供统一扩展框架。基类还需整合 `util` 模块中的工具（如用于邻域搜索的 `faiss_knn_wrapper`、用于样本硬度评估的 `hardness_region_competence`），为子类提供基础工具支持，并确保所有动态选择算法在 API 层面的一致性，降低用户学习成本与算法间切换的迁移成本。

**考点**：以 `BaseDS` 统一 DES/DCS 算法族（competence 估计 + 选择 + 聚合），保持与 scikit-learn 接口一致。

## 23. `dictdatabase`（测试数 594）

**中文规格**

请创建一个名为 DictDataBase 的 Python 项目，实现一个高性能的面向文档数据库库。项目应包含以下功能：

1. **核心数据库引擎**：实现基于 JSON 文件的文档数据库，支持创建、读取、更新与删除操作。数据库应能处理任何可序列化为 JSON 的 Python 对象，并提供高效的键值对访问。

2. **并发安全机制**：实现基于文件锁的并发控制系统，确保多线程与多进程环境下的数据一致性。应支持读写锁分离以避免死锁，并提供锁超时与孤儿锁清理机制。

3. **智能索引系统**：为 JSON 文件中的键建立索引，记录键值对在文件中的位置信息（起始字节、结束字节、缩进层级等），以便无需解析整个文件即可快速局部读取。

4. **会话管理系统**：以上下文管理器形式提供会话接口，支持事务性操作。应实现全文件会话、单键会话与条件查询会话等多种会话类型，确保数据写入的原子性。

5. **高效 I/O 操作**：实现安全的文件读写操作，支持压缩存储（zlib）与多种 JSON 编码器（标准 `json` 模块与 `orjson`）。应提供局部读取与写入能力，只操作所需的数据片段。

6. **配置管理**：实现灵活的配置系统，支持存储目录设置、压缩选项、缩进格式与 JSON 编码器选择等参数配置。

7. **接口设计**：为每个功能模块设计清晰的 API 接口。核心接口包括用于选择文件/文件夹的 `at()` 方法、用于读取数据的 `read()`、用于创建文件的 `create()`、用于删除文件的 `delete()`，以及用于开启会话的 `session()`。

8. **示例与测试脚本**：提供演示基本用法的示例代码，包括用户管理、购买记录等实际应用场景。展示如何通过 `DDB.at("users").create(users_dict)` 创建数据库、通过 `DDB.at("users", key="u3").read()` 读取特定键值，以及通过 `with DDB.at("users").session() as (session, users):` 执行事务性操作。

9. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件，按规范配置为可通过 pip 安装的包，声明完整的依赖清单（包括 `orjson>=3.9` 与 `path-dict` 等核心库，支持 JSON 序列化与路径字典操作等基础功能）。使用 `dictdatabase/__init__.py` 作为统一 API 入口，整合各模块的核心组件：导入 `byte_codes`（字节码常量）、`utils`（工具函数）、`io_safe`（安全 I/O 操作）、`io_bytes`（字节级 I/O）、`config`（配置工具）、`io_unsafe`（底层 I/O）、`locking`（锁管理），从 `models` 模块导入 `at` 函数，从 `configuration` 模块导入 `Confuguration` 类，确保用户通过 `import dictdatabase as DDB` 即可访问所有核心功能。核心模块需实现以下功能：在 `models.py` 中实现 `DDBMethodChooser` 类（包含 `exists()`、`create()`、`delete()`、`read()`、`session()` 等方法，支持文件操作、键值访问、条件查询等）与 `at()` 函数（用于创建 `DDBMethodChooser` 实例，支持路径拼接、通配符选择与条件过滤）；在 `locking.py` 中实现 `AbstractLock` 基类与 `ReadLock`、`WriteLock` 类（包含 `_lock()`、`_unlock()`、`has_lock` 等属性与方法，支持文件锁管理、并发控制与孤儿锁清理），并实现 `FileLocksSnapshot`（锁状态管理）与 `LockFileMeta`（锁文件元数据）类；在 `io_safe.py` 中实现 `read()`、`write()`、`delete()`、`partial_read()` 等安全 I/O 函数（含错误处理）；在 `io_unsafe.py` 中实现底层 I/O 操作（`read()`、`write()`、`partial_read()`、`partial_write()` 等，支持字节级操作与部分文件处理）；在 `io_bytes.py` 中实现字节级 I/O 函数（`read()`、`write()` 等，支持指定位置读写、范围操作与压缩文件处理）；在 `utils.py` 中实现 `file_info()`、`file_exists()`、`find_all()`、`seek_index_through_value_bytes()` 等工具函数（支持文件信息查询、路径查找与字节索引定位）；在 `configuration.py` 中实现 `Confuguration` 类（包括 `storage_directory`、`indent`、`use_compression`、`use_orjson` 等配置属性）；在 `byte_codes.py` 中定义 `BACKSLASH`、`QUOTE`、`SPACE` 等字节码常量（用于字节级 JSON 解析）。此外，在 `sessions.py` 中实现 `SessionBase` 基类与 `SessionFileFull`、`SessionFileKey`、`SessionFileWhere`、`SessionDirFull`、`SessionDirWhere` 等会话类型（包含 `__enter__()`、`__exit__()`、`write()` 等方法，提供事务性操作支持）；在 `indexing.py` 中实现 `Indexer` 类（包含 `get()`、`write()` 等方法，支持键值索引、位置记录与哈希校验）。所有模块需协同工作，通过统一 API 确保高效且安全的字典式数据库操作。

10. **性能优化**：实现高效的并发读写操作，支持文件夹操作与条件查询，并通过 `where` 回调函数实现数据过滤。确保大 JSON 文件上的读写性能，支持约每秒 2000 次的读取速度。

**考点**：以字节偏移索引 + 文件读写锁在 JSON 文件上实现「不解析全文」的局部读写与事务会话。

## 24. `docopt-ng`（测试数 614）

**中文规格**

请创建一个名为 docopt-ng 的 Python 项目，用于构建美观且强大的命令行接口（CLI）。项目应包含以下功能：

1. 声明式参数定义：支持通过文档字符串（docstring）声明命令行接口并自动解析参数、选项、子命令等。解析结果应为与 argparse 兼容的命令行接口，可直接映射到 Python 函数参数。

2. 类型安全：实现参数类型自动推断与转换，支持基础类型（`str`、`int`、`float`、`bool`）、可选参数、列表参数等。允许用户自定义类型转换逻辑以确保类型安全。

3. 高级特性支持：支持嵌套子命令、参数默认值、选项别名、参数校验、帮助信息自动生成与版本标志等高级特性。应能处理复杂的命令行结构与多级命令。

4. 接口设计：为每个功能模块（如参数解析、类型转换、帮助生成、错误处理等）设计独立的函数接口以支持灵活配置。每个模块应定义明确的输入输出格式，便于扩展与维护。

5. 示例与测试脚本：提供示例代码与测试用例，演示如何使用 docopt-ng 进行命令行参数声明与解析（例如 `docopt(doc, argv)` 应能解析命令行参数并返回结构化结果）。需要组合上述特性构建完整的命令行工具包。项目最终应包含参数解析、类型转换、帮助生成、错误处理等模块，并配有典型测试用例，形成可复现的开发流程。

6. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，需要把项目配置为可安装包（支持 pip install 与可编辑模式安装）并声明完整的依赖清单，包括但不限于 pytest、coverage 等测试库，以及 docopt 运行所需的核心依赖（如 `typing-extensions`）。`pyproject.toml` 文件需通过 `[build-system]` 与 `[project]` 段配置完整构建流程，并支持通过 `[project.optional-dependencies]` 分组管理测试与文档等扩展依赖，确保可通过 `pip install .` 安装完整测试环境。此外，`docopt/__init__.py` 需作为统一 API 入口。该文件应从 `_version` 模块导入版本信息，并提供包括 `docopt`、`DocoptExit`、`DocoptLanguageError` 在内的所有核心函数，以及 `_Argument`、`_Option`、`_Pattern` 等内部类。API 设计确保用户能通过 `from docopt import docopt, DocoptExit, _Argument` 这样的简单语句访问所有主要功能，包括命令行参数解析、模式匹配、错误处理与类型转换。`_version.py` 文件仅通过 `__version__` 变量包含符合语义化版本规范的版本信息，确保用户可通过 `docopt.__version__` 获取当前版本。

**考点**：由 usage/docstring 反推出选项文法并做模式匹配解析，附带类型推断与帮助生成。

## 25. `emoji`（测试数 102）

**中文规格**

请创建一个名为 Emoji-Process 的 Python 项目，实现一个 Emoji 表情处理库。项目应包含以下功能：

1. **表达式解析器**：从输入字符串中提取并解析 Emoji 表达式，支持多种格式（如 `:smile:`、Unicode 表情符号、ZWJ 复合表达式等）。解析结果应为标准化的 Emoji 对象或等效的可比较形式。

2. **表达式转换器**：实现 Emoji 名称与 Unicode 表达式之间互相转换的功能（或脚本），包括多语言支持、别名处理、变体选择等。应支持不同分隔符、版本过滤、自定义处理函数等。

3. **表达式分析器**：对字符串中的 Emoji 做深度分析，包括位置提取、去重统计、版本检测、状态判断等。例如 `"Hello 😀😀"` 应能分析出两个相同 Emoji 及其位置信息。

4. **特殊结构处理**：为 ZWJ（零宽连接符）复合表达式、肤色修饰符、性别修饰符、旗帜表达式等提供专门处理。例如 `👨‍👩‍👧‍👦` 应被正确解析为家庭表达式组合。

5. **接口设计**：为每个功能模块（如解析、转换、分析、检测等）设计独立的命令行接口或函数接口以支持终端调用测试。每个模块应定义明确的输入输出格式。

6. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件，不仅应把项目配置为可安装包（支持 pip install），还应声明完整的依赖清单（包括 `requests>=2.32.3`、`beautifulsoup4>=4.12.3`、`cloudscraper>=1.2.71`、`pytest>=7.4.4`、`sphinx>=7.2.6`、`django>=4.1.1` 等核心库）。同时需要提供 `emoji/__init__.py` 作为统一 API 入口，从 `__init__.py` 导入并导出核心函数、类等，并提供版本信息，使用户能通过简单的 "import emoji" 语句访问所有主要功能。

**考点**：以 Unicode 数据表驱动的 emoji 识别/转换，需正确处理 ZWJ 组合、肤色与旗帜等多码位序列。

## 26. `fastapi-users`（测试数 556）

**中文规格**

请创建一个名为 FastAPI-Users-Auth 的 Python 项目，实现一套完整的用户认证与授权管理系统。项目应包含以下功能：

1. 用户管理器模块：实现用户创建、更新、删除与查询等核心操作，支持异步数据库操作。应包含用户模型定义（支持 email、password、激活状态、验证状态、超级用户权限等字段）、用户创建与更新 schema，以及完整的用户生命周期管理。管理器应支持自定义用户模型扩展，并提供统一的用户操作接口。

2. 认证系统模块：实现多种认证策略与传输方式的组合，包括 JWT 策略、数据库 token 策略、Redis 策略等。支持 Bearer token 与 Cookie 传输方式，并提供可配置的认证后端。认证系统应支持 token 生成、校验、刷新与吊销功能，确保用户会话管理的安全性。

3. 数据库适配器模块：提供统一的数据库操作接口，支持 SQLAlchemy（关系型数据库）与 Beanie（MongoDB）等不同数据库后端。适配器应实现标准 CRUD 操作，支持异步操作，并提供数据库连接管理与事务处理功能。

4. OAuth 集成模块：支持第三方 OAuth 提供方（如 Google、GitHub、Facebook 等）的登录与账号关联功能。实现 OAuth 授权流程、回调处理、账号关联与用户信息同步。支持同时集成多个 OAuth 提供方，并提供统一的 OAuth 管理接口。

5. 密码安全模块：实现安全的密码哈希与校验机制，支持多种哈希算法（如 Argon2、bcrypt 等）。提供密码强度校验、密码重置与邮箱验证等功能。确保密码存储与传输的安全性，并支持密码策略配置。

6. API 路由模块：提供完整的 RESTful API 接口，包括用户注册、登录、登出、密码重置、邮箱验证与用户信息管理等路由。每个路由应支持恰当的 HTTP 方法、请求校验、响应格式化与错误处理。路由应支持依赖注入与中间件集成。

7. 配置与依赖管理：项目必须包含完整的 `pyproject.toml` 文件，声明完整的依赖清单（包括 `fastapi`、`pwdlib`、`email-validator`、`pyjwt`、`python-multipart`、`makefun` 等核心库），并支持项目安装与分发。提供统一配置管理，支持环境变量与配置文件。

8. 测试与文档：提供完整的测试套件，包括单元测试、集成测试与端到端测试。测试应覆盖所有核心功能模块，包括用户管理、认证、OAuth、密码安全等。提供详细的 API 文档与使用示例，确保项目的可维护性与可扩展性。

9. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，应把项目配置为可安装包（支持 `pip install`）并声明完整的依赖清单（如 `fastapi >= 0.65.2`、`pwdlib[argon2,bcrypt] == 0.2.1`、`email-validator >= 1.1.0, < 2.3`、`pyjwt[crypto] == 2.10.1`、`python-multipart == 0.0.20`、`makefun >= 1.11.2, < 2.0.0` 等实际使用的核心库）。`pyproject.toml` 应确保所有核心功能模块可正常工作。同时需要提供 `fastapi_users/__init__.py` 作为统一 API 入口，导入并导出 `Depends`、`FastAPI`、`Request`、`Response`、`status`、`OAuth2PasswordRequestForm`、`SecurityBase`、`BaseUserDatabase` 以及 main 导入导出函数，并提供版本信息，使用户能通过 `from fastapi import *` 与 `from fastapi_users.responses/security/authentication/exceptions/jwt/manager/router import *` 等简单语句访问所有主要功能。

**考点**：可插拔认证后端（JWT / 数据库 token / Redis）+ 数据库适配器（SQLAlchemy / Beanie）组合出完整用户生命周期与 OAuth 流程。

## 27. `flask-restful`（测试数 362）

**中文规格**

请创建一个名为 Flask-RESTful 的 Python 项目，实现一个 RESTful API 框架。项目应包含以下功能：

1. 资源与路由管理：支持通过继承 `Resource` 类定义 RESTful 资源。支持多路由、路径参数、endpoint 命名与 Blueprint 集成。
2. 参数解析与校验：支持使用 `reqparse.RequestParser` 定义并解析来自多个来源的参数。支持类型转换、默认值、必填字段、choices、actions、trim、可空性以及文件上传。
3. 数据序列化与字段定义：支持使用 `fields` 模块定义输出格式。支持 `String`、`Integer`、`Float`、`Boolean`、`DateTime`、`Url`、`Nested`、`List`、`Raw`、`Fixed`、`Arbitrary` 与 `FormattedString` 等类型。
4. 响应格式与内容协商：支持 JSON 与 XML 等多种响应格式。支持基于 `Accept` 头的自动协商。支持自定义 JSON 序列化参数。
5. 错误处理与自定义异常：支持使用 `abort` 快速抛出错误、自定义错误响应，以及在全局或资源级别处理错误。支持信号链（signal chains）。
6. CORS 支持：支持使用 `crossdomain` 装饰器为资源或接口添加 CORS 支持。
7. 加密工具：提供 AES 加解密工具。
8. 输入类型与校验：支持使用 `inputs` 模块做类型转换、正则表达式、区间、布尔、日期、自然数、正数等校验。
9. 示例与用法：提供 `todo_simple`、`todo` 与 `xml_representation` 等典型用法示例。
10. 兼容性与集成：支持 Python 2/3，兼容多个 Flask 版本，并可与 Flask-SQLAlchemy、Flask-Login 等扩展集成。
11. 核心文件要求：
   - 项目必须包含完整的 `setup.py`（声明依赖并支持 pip 安装），并能自动检测所有 API 导出是否完整。
   - `flask_restful/__init__.py` 作为统一 API 入口，**必须导出** `Api`、`Resource`、`fields`、`reqparse`、`inputs`、`marshal`、`marshal_with`、`abort` 与 `utils` 等所有核心类与函数，并在 `__version__.py` 文件中提供 `__version__` 变量。
   - 用户应能通过 `from flask_restful import Api, Resource, fields, reqparse, inputs, marshal, marshal_with, abort, utils` 访问所有主要功能。
   - **`OrderedDict` 工具类用于在 fields 与响应格式化中维护有序键值对，必须可通过 `from flask_restful import OrderedDict` 导出，以支持 API 开发中的有序数据结构需求。**
   - **CORS 支持相关内容应通过 `from flask_restful.utils import cors` 导入。**
   - **与参数解析相关的 `Argument`、`RequestParser`、`Namespace` 应通过 `from flask_restful.reqparse import Argument, RequestParser, Namespace` 导入。**
   - `examples/` 目录中的示例代码可直接运行，以演示各 API 的典型用法。
   - `docs/` 目录中的文档支持用 Sphinx 自动生成，包含 API 说明、用法示例与扩展说明。

**考点**：把 Flask 上的资源路由、`reqparse` 参数校验、`fields`/`marshal` 序列化与内容协商组合成 REST 框架，并保证导出符号完整。

## 28. `flasky`（测试数 34）

**中文规格**

请创建一个名为 Flasky 的 Python 项目，实现一个社交博客应用。项目应包含以下功能：

1. 用户认证系统：实现用户注册、登录、邮箱验证与密码重置等功能。支持基于角色的权限控制，包括普通用户与管理员等角色。用户注册时需进行邮箱验证，登录支持「记住我」功能。密码重置通过邮件发送重置链接完成。支持修改邮箱地址的功能，并使用 Gravatar 服务作为用户头像。

2. 文章管理系统：实现文章发布、编辑、删除与分页展示等功能。支持 Markdown 格式与富文本内容，并提供文章搜索与分类功能。文章支持 HTML 内容渲染、文章详情页与文章编辑权限控制。

3. 评论系统：实现文章的评论功能，支持评论发布、管理与审核等操作。评论支持 HTML 内容渲染、分页展示与审核功能。管理员可删除或隐藏不当评论。

4. 关注系统：实现用户关注功能，支持关注、取消关注与关注列表展示等操作。为被关注者提供动态推送，支持关注者文章流的展示，实现社交网络的核心功能。支持关注者统计与关注关系查询。

5. 接口设计：每个功能模块（用户管理、文章管理、评论管理、关注管理）都应有独立的 API 接口，支持 RESTful 设计。提供清晰的输入输出格式，支持 JSON 数据交换，并包含完整的错误处理与状态码。支持 API 认证与权限控制。

6. 核心文件要求：项目必须包含完整的 `requirements.txt` 文件，应把项目配置为可安装包（支持 pip install）并声明完整的依赖清单（如 `Flask==0.12.2`、`Flask-SQLAlchemy==2.2`、`Flask-Migrate==2.0.4`、`Flask-Login==0.4.0` 等实际使用的核心库）。`setup.py` 文件应确保所有核心功能模块可正常工作。同时应提供 `app/init.py` 作为统一 API 入口，导入并导出 `User`、`Role`、`Post`、`Comment`、`create_app`、`db`、`fake`、`AnonymousUser`、`Permission`、`Follow`、`current_app` 以及 main 导入导出函数，并提供版本信息，使用户能通过简单的 "from flask import **" 与 "from app.models import **" 语句访问所有主要功能。

**考点**：以 Flask + SQLAlchemy 复刻经典博客应用的角色权限、邮箱验证、评论审核与关注流等业务闭环。
