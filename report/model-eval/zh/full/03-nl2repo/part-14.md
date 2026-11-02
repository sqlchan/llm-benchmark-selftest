# NL2Repo-Bench 全题规格中文翻译 · Part 14（第 87–89 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 87. `structlog`（测试数 828）

**中文规格**

请创建一个名为 `structlog` 的 Python 项目，实现一个结构化日志库。项目应包含以下功能：

1. **配置管理系统**：应能管理全局日志配置，支持 `configure()`、`configure_once()`、`get_logger()`、`wrap_logger()` 等核心函数。配置系统应支持对处理器链、包装类、上下文类、logger 工厂等组件进行灵活配置，并提供查询与重置配置状态的函数。需在 `src/structlog/_config.py` 中实现 `_Configuration` 类，用于管理全局配置状态。

2. **结构化日志**：实现 `BoundLogger` 类以支持结构化日志，包含 `bind()`、`unbind()`、`try_unbind()`、`new()` 等用于上下文管理的方法。应支持把任意键值对作为日志字段、自动时间戳与日志级别、异常堆栈信息以及上下文信息。需在 `src/structlog/_base.py` 中实现 `BoundLoggerBase` 基类。

3. **处理器系统**：实现丰富的处理器链，包括 `KeyValueRenderer`、`LogfmtRenderer`、`JSONRenderer`、`TimeStamper`、`StackInfoRenderer`、`CallsiteParameterAdder`、`UnicodeEncoder`、`UnicodeDecoder` 等处理器。每个处理器都应支持自定义配置与序列化。所有处理器类都需在 `src/structlog/processors.py` 中实现。

4. **开发工具支持**：实现 `ConsoleRenderer` 以提供带颜色的控制台输出，支持 `RichTracebackFormatter`、`better_traceback`、`plain_traceback` 等异常格式化工具。应支持颜色配置、列格式化与级别样式等高级特性。`ConsoleRenderer` 与异常格式化器需在 `src/structlog/dev.py` 中实现。

5. **标准库集成**：实现与 Python 标准库 `logging` 的无缝集成，包括 `BoundLogger`、`AsyncBoundLogger`、`LoggerFactory`、`ProcessorFormatter` 等类。应同时支持同步与异步日志，并对 `logging` 接口提供完整兼容。所有标准库集成类都需在 `src/structlog/stdlib.py` 中实现。

6. **上下文管理**：实现对线程本地存储与异步上下文变量的支持，包括 `ThreadLocalDict`、`merge_contextvars`、`clear_contextvars` 等函数。应支持上下文的绑定、传递与清理操作。`bind_contextvars()`、`clear_contextvars()` 等函数需在 `src/structlog/contextvars.py` 中实现，`bind_threadlocal()`、`clear_threadlocal()` 等函数需在 `src/structlog/threadlocal.py` 中实现。

7. **输出系统**：实现对多种输出格式的支持，包括 `PrintLogger`、`WriteLogger`、`BytesLogger` 及其对应的工厂类。应支持文件输出、字节输出、打印输出等不同输出方式。所有输出 logger 类都需在 `src/structlog/_output.py` 中实现。

8. **测试框架**：实现 `ReturnLogger`、`ReturnLoggerFactory`、`CaptureLogs` 等测试工具，以支持日志捕获、校验与模拟。应提供完整的测试辅助功能。所有测试工具类都需在 `src/structlog/testing.py` 中实现。

9. **异常处理**：实现 `DropEvent` 异常类及异常处理机制，以支持处理器链中的异常捕获与优雅降级。应提供完整的错误处理策略。`DropEvent` 异常类需在 `src/structlog/exceptions.py` 中实现。

10. **类型系统**：实现完整的类型注解与类型检查支持，包括 `EventDict`、`WrappedLogger`、`Processor` 等类型定义。应支持静态类型检查与 IDE 智能提示。所有类型定义都需在 `src/structlog/types.py` 与 `src/structlog/typing.py` 中实现。

11. **框架集成**：实现对 Twisted 异步框架的集成支持，包括 `TwistedLogger`、`TwistedLoggerFactory` 等类。应提供异步日志与事件循环集成。所有 Twisted 集成类都需在 `src/structlog/twisted.py` 中实现。

12. **工具函数**：实现 `get_processname()`、`_format_exception()`、`_format_stack()` 等工具函数，以支持进程名获取、异常格式化、堆栈格式化等功能。`get_processname()` 函数需在 `src/structlog/_utils.py` 中实现，`_format_exception()` 与 `_format_stack()` 函数需在 `src/structlog/_frames.py` 中实现。

13. **异常追踪系统**：实现完整的异常追踪与格式化功能，包括 `ExceptionDictTransformer`、`safe_str()`、`to_repr()` 等函数。应支持异常堆栈的 JSON 格式化与安全字符串表示。所有异常追踪相关功能都需在 `src/structlog/tracebacks.py` 中实现。

14. **配置校验**：实现配置校验与默认值管理，包括 `is_configured()`、`get_config()`、`reset_defaults()` 等函数。应提供查询与重置配置状态的函数。这些配置校验函数需在 `src/structlog/_config.py` 中实现。

15. **性能优化**：实现日志缓存与性能优化机制，包括 `cache_logger_on_first_use`、`make_filtering_bound_logger` 等函数。应支持高性能日志与内存优化。`make_filtering_bound_logger()` 函数需在 `src/structlog/_native.py` 中实现。

16. **可扩展性设计**：实现可扩展的架构设计，支持处理器、渲染器、工厂类等自定义组件。应提供完整的扩展接口与文档。

17. **接口设计**：为每个功能模块（如配置、日志记录、处理器、输出）设计独立的函数接口，以支持终端调用测试。每个模块都应定义清晰的输入与输出格式。

18. **示例与评测脚本**：提供示例代码与测试用例，演示如何使用 `get_logger()` 与 `configure()` 函数进行日志配置与记录（例如 `get_logger().info("message", key="value")` 应输出结构化日志）。需组合上述功能，构建一套完整的结构化日志工具包。最终项目应包含配置、记录、处理、输出与测试等模块，并配有典型测试用例，形成可复现的日志流程。

19. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件，需要把项目配置为可安装包（支持 `pip install` 与 editable 模式安装），声明完整的依赖清单——包括与类型支持相关的依赖，并明确支持 Python 3.6 及以上版本。`pyproject.toml` 需通过构建配置确保所有功能模块（如 logger 创建、配置管理、日志渲染、上下文处理）都能正常工作，并支持通过测试命令触发全功能验证。同时需提供 `src/structlog/__init__.py` 作为统一 API 入口。该文件需从各核心模块导入关键组件：从 `_config` 导入 `configure`、`get_logger`、`wrap_logger`、`configure_once`、`BoundLoggerLazyProxy` 等配置与 logger 管理工具；从 `_base` 与 `_generic` 导入 `BoundLoggerBase`、`BoundLogger` 等基础 logger 类；从 `_log_levels` 导入 `NAME_TO_LEVEL`、`LEVEL_TO_NAME`、`CRITICAL`、`WARN` 等日志级别常量；从 `processors` 导入 `KeyValueRenderer`、`JSONRenderer`、`TimeStamper`、`ExceptionRenderer` 等日志处理器；从 `threadlocal` 导入 `bind_threadlocal`、`clear_threadlocal` 等线程本地上下文工具；从 `contextvars` 导入 `bind_contextvars`、`merge_contextvars` 等上下文变量管理函数；从 `stdlib` 导入 `ProcessorFormatter`、`add_log_level` 等标准库适配工具；从 `testing` 导入 `CapturingLogger`、`ReturnLogger`、`LogCapture` 等测试辅助工具；从 `typing` 导入 `BindableLogger`、`EventDict` 等类型提示；从 `dev` 导入 `ConsoleRenderer` 等开发工具；从 `exceptions` 导入 `DropEvent` 异常类；此外还要导入 `PrintLogger`、`BytesLogger` 等 logger 实现以及 `get_processname` 等工具函数，并提供 `__version__` 等版本信息。确保用户通过简单的 `from structlog import get_logger, configure, BoundLogger, JSONRenderer` 语句即可访问所有主要功能。在 `src/structlog/_config.py` 中，除 `configure()`、`get_logger()`、`wrap_logger()` 外，还需实现 `configure_once()` 以保证配置只生效一次；定义 `BoundLoggerLazyProxy` 用于 logger 的惰性初始化；并管理全局配置对象 `_CONFIG` 以及 `_BUILTIN_DEFAULT_PROCESSORS`、`_BUILTIN_DEFAULT_LOGGER_FACTORY` 等默认配置项，以支撑全局日志配置与 logger 创建的核心逻辑，并为其他模块提供统一的配置入口。

**考点**：以「可组合的处理器链 + 绑定上下文的 logger + 惰性代理配置」复刻 structlog 的骨架，难点是 19 条要求涉及的十余个模块职责切分与 `__init__.py` 统一导出、`configure_once()` 的「只生效一次」幂等语义，以及 threadlocal 与 contextvars 两套上下文机制在同步/异步下的一致行为。

## 88. `synthetic`（测试数 93）

**中文规格**

请创建一个名为 Synthetic Data Kit 的 Python 项目，实现一个面向 LLM 微调的合成数据集生成库。项目应包含以下功能：

1. 多格式文档解析器：从多种输入格式中提取并解析文档内容，支持 PDF（使用 `pdfminer.six`）、HTML（使用 `BeautifulSoup`）、YouTube 视频转录（使用 `pytube`）、DOCX 与 PPTX（使用 `python-docx`/`python-pptx`）以及纯文本格式。解析结果应采用统一的文本格式或 Lance 数据集格式，并支持多模态内容提取。

2. 智能内容生成系统：实现一个基于 LLM 的内容生成模块，能够从解析后的文档中生成各类训练数据，如高质量问答对（QA pairs）、思维链推理样本（Chain of Thought）与文档摘要。应支持分块处理、批量生成、自定义提示模板以及可配置的生成参数。

3. 质量控制与筛选：使用 Llama 模型作为裁判，对生成的合成数据进行质量评估与筛选，支持可配置的质量阈值、批处理以及细粒度的质量评分机制，以确保输出数据的高质量。

4. 多格式输出转换器：为生成的数据集提供多种便于微调的输出格式，包括 JSONL、Alpaca 格式、OpenAI 微调格式、ChatML 格式等，同时支持本地文件存储与 HuggingFace 数据集格式导出。

5. 命令行工具接口：基于 Typer 构建完整的 CLI 工具，提供 ingest、create、curate、save-as 四个核心命令，支持单文件与批处理、预览模式、详细日志输出以及灵活的配置覆盖机制。

6. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `datasets>=2.14.0`、`pdfminer.six>=20221105`、`pydantic>=2.4.0`、`python-docx>=0.8.11`、`python-pptx>=0.6.21`、`pytube>=15.0.0`、`pyyaml>=6.0`、`requests>=2.31.0`、`rich>=13.4.2`、`typer>=0.9.0`、`openai>=1.0.0`、`flask>=2.0.0`、`beautifulsoup4>=4.12.0` 等核心库）。`pyproject.toml` 应能验证所有功能模块是否正常工作。同时需要提供 `synthetic_data_kit/__init__.py` 作为统一 API 入口，从各子模块导入核心函数，并提供版本信息与配置管理，使用户可以通过简单的 `from synthetic_data_kit import ingest, create, curate, save_as` 语句访问所有主要功能。在 `models/llm_client.py` 中应有一个 `LLMClient` 类，统一管理不同 LLM 提供方（vLLM、OpenAI API、Llama API 等）的接口调用与响应处理。`unit.py` 与 `utils.py` 文件具备多文档解析功能。只需用 `from synthetic_data_kit import *` 导入核心模块，即可实现文档解析功能。最后，项目将通过构建完整的数据处理流水线与多种输出格式来验证整体功能的正确性。

**考点**：串起「多格式解析 → LLM 生成 → Llama 裁判筛质 → 多格式导出」的端到端流水线，难点是 13 个依赖及其版本下限的逐个锁定、`LLMClient` 对 vLLM/OpenAI/Llama 三类后端响应形态的统一封装，以及 Typer 四个子命令（ingest/create/curate/save-as）的配置覆盖与预览模式。

## 89. `tablib`（测试数 172）

**中文规格**

请创建一个名为 Tablib 的 Python 项目，实现一个通用表格数据集处理库。项目应包含以下功能：

1. **数据结构支持**：实现两种核心结构——Dataset（单表数据集）与 Databook（多表数据集），以支持对数据进行灵活的组织与管理。

2. **多格式导入与导出**：支持 Excel、CSV、TSV、JSON、YAML、HTML、LaTeX、ODS、DBF、SQL 以及 Pandas DataFrame 等主流格式数据的读取、写入与格式转换。

3. **格式自动识别与扩展**：自动识别输入流的数据格式，并支持注册与扩展新的数据格式。

4. **数据批处理**：支持数据的批量导入、导出、格式转换与数据清洗。

5. **与 Pandas 集成**：兼容 Pandas DataFrame，便于与数据分析及科学计算工作流集成。

6. **API 设计**：为每项功能提供清晰的 Python 函数接口，并支持可扩展的命令行接口。

7. **错误处理与异常体系**：稳健地处理不支持的格式、数据类型错误等异常。

8. **单元测试与回归测试**：提供完整的测试用例，覆盖所有核心功能的导入、导出、格式转换与异常场景。

9. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件，应把项目配置为可安装包（支持 `pip install`），并声明完整的依赖清单（如 `pandas==2.3.1`、`pyyaml==6.0.2`、`tabulate==0.9.0`、`xlrd==2.0.2`、`xlwt==1.3.0` 等，这些是实际使用的核心库）。`setup.py` 文件应确保所有核心功能模块都能正常工作。同时应提供 `src/tablib/__init__.py` 与 `src/tablib/_vendor/dbfpy/__init__.py` 作为统一 API 入口，导入并导出 fields、utils、Row、detect_format、UnsupportedFormat、registry 以及主要的导入导出函数，并提供版本信息，使用户可以通过 `from tablib._vendor.dbfpy import **` 与 `from tablib.core/exceptions/formats import **` 等简单语句访问所有主要功能。其中，`/src/tablib/core.py` 文件中的 Row 类用于封装表格数据中的行数据。`/src/tablib/core.py` 文件中的 detect_format 函数用于自动检测数据格式，其核心功能是根据输入数据流判定对应的表格数据格式（如 CSV、JSON、Excel 等）。`/src/tablib/exceptions.py` 文件中的 UnsupportedFormat 类是 Tablib 库中定义的异常类，继承自 TablibException 与 NotImplementedError，用于表示与不支持的格式相关的错误。Registry 类应在 `/src/tablib/formats/_init_.py` 中完整定义，包含 `_formats` 等类属性以及 register、register_builtins、formats、get_format 等方法，用于管理 Tablib 库中各种数据格式（如 CSV、JSON、Excel 等）的注册、存储与获取。在 `/src/tablib/_vendor/dbfpy/` 文件夹中，需要 fields.py 来定义与处理 DBF（dBASE 数据库文件）字段。`/src/tablib/_vendor/dbfpy/` 文件夹中的 utils.py 文件应包含 unzfill、getDate、getDateTime、_InvalidValue 等函数，提供与 DBF 文件处理相关的字符串处理、日期与时间转换以及特殊值定义功能，以支撑 DBF 格式数据的解析与处理。

**考点**：以「Dataset/Databook 双结构 + 可注册的格式注册表」支撑十余种格式的读写与互转，难点是 `detect_format` 对输入流的格式嗅探、`Registry` 把内置注册与用户注册分离，以及 DBF 这类需要自研 vendored 解析（fields/utils）的冷门格式。

