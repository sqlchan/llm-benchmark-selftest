# NL2Repo-Bench 全题规格中文翻译 · Part 4（第 39–42 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 39. `ipytest`（测试数 74）

**中文规格**

请创建一个名为 ipytest 的 Python 项目，实现一个用于 Jupyter Notebook 测试执行与校验的库。项目应包含以下功能：

1. 配置管理模块：能够灵活配置测试执行环境，支持断言改写（assertion rewriting）、magic 命令注册、测试清理模式等核心配置项。配置结果应为持久化的设置或等价的环境状态。应支持两种配置模式：用于快速配置的 `autoconfig()` 与用于细粒度配置的 `config()`，包含 `rewrite_asserts`、`magics`、`clean`、`addopts`、`run_in_thread`、`defopts`、`display_columns`、`raise_on_error`、`coverage` 等 9 个核心配置参数。

2. 测试执行模块：实现 notebook 中执行测试代码的功能，同时支持同步与异步测试执行。应支持 `run()` 函数调用、`%%ipytest` magic 命令、命令行参数传递、插件集成、线程隔离等执行方式，以及智能的测试发现与错误处理机制。

3. 状态管理模块：提供 notebook 环境中测试状态的智能管理，包括清理全局变量、重载模块、隔离作用域。应支持按模式清理匹配测试的 `clean()` 函数、强制重载模块的 `force_reload()` 函数，并处理 notebook 环境特有的全局状态问题。

4. 断言改写模块：实现 AST 转换器来改写 assert 语句，提供更详细的错误信息。应支持与 IPython shell 的自动集成、转换器的注册与注销，以及自定义 AST 节点处理逻辑。

5. 覆盖率支持模块：为 notebook 测试提供代码覆盖率分析，支持与 pytest-cov 的集成、临时文件名转换与 cell 追踪。应支持覆盖率配置的自动生成、cell 标识符转换，以及覆盖率数据的收集与报告。

6. 环境准备模块：实现临时文件管理、模块注册、参数映射等工具函数。应支持动态创建临时模块文件、把 notebook 注册为 Python 模块、模板变量替换（如 `{MODULE}`、`{test_name}`），以及列宽控制等环境准备功能。

7. 接口设计：为每个功能模块（如配置管理、测试执行、状态管理、断言改写、覆盖率支持）设计独立的 API 接口，同时支持 Python 函数调用与 IPython magic 命令调用。每个模块应定义清晰的输入输出格式与错误处理机制。

8. 示例与评测脚本：提供示例代码与测试用例，演示如何使用 `autoconfig()` 与 `run()` 函数进行环境配置与测试执行（例如 `ipytest.autoconfig(); ipytest.run()` 应能正确执行当前模块中的测试）。需要组合上述功能，构建完整的 notebook 测试工具包。

9. 测试验证系统：提供全面的测试用例覆盖，包括从配置管理到测试执行完整流程的 10 个功能节点测试；基于真实 Jupyter notebook 的 notebook 环境回归测试；异常输入处理、环境依赖错误、线程安全问题等边界情况测试；以及用于定量评估测试执行速度与覆盖率收集准确性的性能基准测试。

10. 项目必须包含完整的 `pyproject.toml` 文件，不仅把项目配置为可安装包（支持 pip 安装），还要声明完整的依赖清单（包括 `pytest>=5.4`、`ipython>=8.18.1`、`packaging>=24.2`、`coverage>=7.6.12`、`pytest-cov>=6.0.0`、`pytest-asyncio>=0.25.0`、`nbval>=0.11.0`、`ruff>=0.9.0` 等核心库）。`pyproject.toml` 文件应能验证所有功能模块是否正常工作。同时应提供 `ipytest/__init__.py` 作为统一的 API 入口，能从 `config` 与 `_impl` 模块分别导入 `autoconfig`、`config`、`force_reload`、`find_coverage_configs`、`ArgMapping`、`RewriteAssertTransformer`、`eval_defots_auto`、`eval_run_kwargs`、`clean`、`runl` 等核心函数与类，并提供版本信息，使用户能通过 `from ipytest.xxx import xxx` 这样的简单语句访问所有主要功能。在 `ipytest/__init__.py` 中需要定义 `__all__`，其中包含 "Error"、"autoconfig"、"clean"、"config"、"force_deload"、"reload"、"run" 等核心类或函数。

**考点**：在 notebook cell 里把 pytest 跑通并把结果回显到同一 cell，难点是 `%%ipytest` magic 与 `run()` 的参数拼装、`clean`/`force_reload` 的全局状态隔离，以及 coverage 临时文件名与 cell 追踪之间的映射回填。

## 40. `jinja`（测试数 911）

**中文规格**

请创建一个名为 Jinja2 的 Python 项目，实现一个功能完整的模板引擎。项目应包含以下特性：

1. **模板解析器**：能够解析 Jinja2 模板语法，包括变量表达式 `{{ }}`、控制结构 `{% %}`、注释 `{# #}` 等。解析结果应为抽象语法树（AST）节点，支持模板继承、包含（include）与宏定义等高级特性。

2. **词法分析器（Lexer）**：实现词法分析功能，把模板文本切分为 token 流，识别关键字、标识符、字符串、数字、运算符等。应支持自定义分隔符、行语句前缀、注释前缀等配置选项。

3. **语法分析器（Parser）**：基于词法分析结果构建语法树，处理表达式优先级、函数调用、过滤器链、测试表达式等。应支持复杂的 Python 表达式语法，包括列表、字典、元组与切片。

4. **代码生成器（CodeGenerator）**：把语法树编译为可执行的 Python 代码，支持优化、字节码缓存、异步渲染等特性。应生成高效的渲染函数，支持变量作用域、循环上下文与宏调用。

5. **运行时环境**：为模板渲染提供运行时支持，包括变量解析、过滤器执行、测试求值与宏调用。应支持沙箱环境、自动转义、错误处理等安全特性。

6. **模板加载器**：实现多种模板加载机制，包括文件系统加载器、包加载器、字典加载器、函数加载器与选择加载器。应支持模板缓存、自动重载与模板发现等功能。

7. **过滤器系统**：提供丰富的内置过滤器，包括字符串处理、列表操作、数学计算与格式化。应支持自定义过滤器、过滤器链与异步过滤器等扩展功能。

8. **测试系统**：实现模板测试功能，支持 `defined`、`undefined`、`none`、`number`、`string`、`sequence`、`mapping`、`callable`、`sameas`、`equalto`、`even`、`odd`、`divisibleby`、`escaped`、`upper`、`lower` 等内置测试。

9. **扩展系统**：提供扩展机制，支持自定义标签、过滤器、测试与全局函数。应支持扩展的注册、配置与生命周期管理。

10. **安全特性**：实现沙箱环境，限制模板中可执行的代码，防止恶意代码执行。应支持自动转义、白名单机制与资源限制等安全措施。

11. **异步支持**：提供异步模板渲染功能，支持异步过滤器、异步迭代器与异步宏调用。应与同步 API 保持兼容。

12. **调试支持**：提供模板调试功能，包括错误定位、变量追踪与性能分析。应支持调试信息的生成与展示。

13. **国际化支持**：提供国际化功能，支持多语言模板、翻译标签与复数处理。应支持与 Babel 等国际化框架的集成。

14. **性能优化**：实现多种性能优化技术，包括字节码缓存、常量折叠、死代码消除与循环优化。应提供性能监控与分析工具。

15. **接口设计**：为每个功能模块设计清晰的 API 接口，支持环境配置、模板创建、渲染执行与错误处理。每个模块应定义清晰的输入输出格式。

16. **示例与测试**：提供示例代码与测试用例，演示如何使用 `Environment`、`Template`、过滤器、测试与宏等核心功能。应包含典型使用场景与最佳实践。

17. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `MarkupSafe>=3.0`、`pytest`、`ruff`、`tox`、`sphinx` 等核心库）。`pyproject.toml` 应能验证所有功能模块是否正常工作。此外，需要提供 `jinja2/__init__.py` 作为统一 API 入口，从各模块导入核心类与函数，并导出 `Environment`、`Template`、`Undefined`、`StrictUndefined`、`DebugUndefined`、`ChainableUndefined`、`make_logging_undefined`、`select_autoescape`、`clear_caches`、`is_undefined`、`pass_context`、`pass_environment`、`pass_eval_context`、`TemplateError`、`TemplateNotFound`、`TemplatesNotFound`、`TemplateSyntaxError`、`TemplateRuntimeError`、`TemplateAssertionError`、`UndefinedError`、`BytecodeCache`、`FileSystemBytecodeCache`、`MemcachedBytecodeCache`、`BaseLoader`、`FileSystemLoader`、`PackageLoader`、`DictLoader`、`FunctionLoader`、`ChoiceLoader`、`PrefixLoader`、`ModuleLoader` 等核心类，并提供版本信息，使用户能通过简单的 `from jinja2 import Environment, Template` 语句访问所有主要功能。`environment.py` 中应有 `Environment` 类来管理模板环境配置与模板加载；`compiler.py` 中应有 `CodeGenerator` 类来生成可执行的 Python 代码；`lexer.py` 中应有 `Lexer` 类进行词法分析；`parser.py` 中应有 `Parser` 类进行语法分析；`runtime.py` 中应有 `Context` 类来管理模板运行时上下文；`filters.py` 中应有各种内置过滤器函数；`loaders.py` 中应有各种模板加载器类；`nodes.py` 中应有各种 AST 节点类；`exceptions.py` 中应有各种异常类；`utils.py` 中应有各种工具函数；`bccache.py` 中应有字节码缓存相关类；`ext.py` 中应有扩展系统相关类；`sandbox.py` 中应有沙箱环境相关类；`tests.py` 中应有内置测试函数；`async_utils.py` 中应有异步工具函数；`visitor.py` 中应有访问者模式相关类；`optimizer.py` 中应有代码优化相关类；`meta.py` 中应有元数据相关函数；`nativetypes.py` 中应有原生类型支持相关类；`debug.py` 中应有调试相关函数；`defaults.py` 中应有默认配置常量；`constants.py` 中应有常量定义；`idtracking.py` 中应有标识符追踪相关类；`_identifier.py` 中应有标识符模式定义。需要组合上述功能构建完整的模板引擎工具包。项目最终应包含解析、编译、渲染与扩展等模块，并配有典型测试用例，形成可复现的模板处理流程。项目将通过单元测试、集成测试、性能测试与安全测试等多种方式验证，以确保模板引擎的正确性、性能与安全性。

**考点**：从词法、语法到代码生成再拼出运行时，重建一个可用的模板引擎并让 911 个用例通过；难点是表达式优先级与过滤器链的 AST 表示、字节码缓存的失效条件，以及沙箱白名单下的属性访问与异步渲染对同步 API 的兼容。

## 41. `jsonlines`（测试数 27）

**中文规格**

请创建一个名为 'jsonlines' 的 Python 项目，实现一个高效的 JSON Lines 格式数据处理库。项目应包含以下功能：

1. **JSON Lines 文件读写**：实现 JSON Lines 格式文件的读取与写入功能。
2. **流式处理**：支持大文件的高效流式处理。
3. **数据类型支持**：完整支持所有 JSON 标准数据类型。
4. **错误处理**：提供健壮的错误处理机制。
5. **编码处理**：支持多种字符编码。
6. **迭代器接口**：提供 Python 迭代器接口。
7. **上下文管理器**：支持 with 语句进行资源管理。
9. **核心文件要求**：项目必须包含完整的 setup.py 文件，不仅把项目配置为可安装包（支持 pip 安装），还要声明完整的依赖清单（包括 `attrs>=19.2.0`、`pytest`、`types-ujson` 等核心库）。setup.py 应能验证所有功能模块是否正常工作。同时需要提供 `jsonlines/__init__.py` 文件作为统一 API 入口，从 `jsonlines.py` 模块导入 `Reader`、`Writer`、`open`、`Error`、`InvalidLineError` 等核心类与函数，并提供版本信息，使用户能通过简单的 `from jsonlines import Reader, Writer, open` 语句访问所有主要功能。

在 `jsonlines.py` 中，需要 `Reader` 类，支持从文件对象或可迭代对象读取 JSON Lines 数据，提供逐行读取的 `read()` 方法与迭代读取的 `iter()` 方法，并支持类型化读取（`type` 参数）、空值处理（`allow_none` 参数）、跳过空行（`skip_empty` 参数）与跳过非法行（`skip_invalid` 参数）。需要 `Writer` 类，支持把 JSON Lines 数据写入文件对象，提供写入单个对象的 `write()` 方法（返回写入的字符数）与批量写入多个对象的 `write_all()` 方法，并支持紧凑输出（`compact` 参数）、键排序（`sort_keys` 参数）、缓冲刷新（`flush` 参数）与自定义序列化（`dumps` 参数）。

需要 `open()` 函数作为便捷接口，根据 `mode` 参数（`'r'`、`'w'`、`'a'`、`'x'`）返回 `Reader` 或 `Writer` 实例，自动处理文件编码（UTF-8）与 UTF-8 BOM 探测，并支持自定义 `loads` 与 `dumps` 函数。需要 `Error` 基类与 `InvalidLineError` 子类来处理异常情况，提供包含行号与原始行内容的详细错误信息。需要 `SKIPPABLE_SINGLE_INITIAL_CHARS` 常量来定义行首可跳过的字符（如 `\x1e` 与 UTF-8 BOM），支持 RFC7464 文本序列格式。需要实现 `ReaderWriterBase` 基类，提供共享的文件操作行为（如 `close()`、`__repr__()` 与上下文管理器支持）。需要实现 `DumpsResultConversion` 枚举类，处理不同 JSON 库返回值的类型转换。需要实现 `repr_for_fp()` 辅助函数，生成文件对象的字符串表示。需要支持多个 JSON 库以提升性能，优先 orjson（若可用），其次 ujson，最后回退到标准库 json。需要实现完整的类型标注体系，包括泛型类型变量、联合类型、字面量类型等，使用 `@overload` 装饰器为重载方法提供准确的类型提示，并支持 mypy 静态类型检查。

**考点**：用极小的 API 面（`Reader` / `Writer` / `open`）包装流式读写与错误分类，难点是跨 orjson、ujson、标准库 json 的返回值归一、BOM 与 `\x1e` 行首字符跳过，以及让 mypy 通过的分层 `@overload` 泛型标注。

## 42. `justext`（测试数 61）

**中文规格**

请创建一个名为 `jusText` 的 Python 项目，实现一个高效的 HTML 样板内容移除库。项目应聚焦于从网页中准确抽取正文，并提供清晰易用的接口。项目需要包含以下核心功能：

1. HTML 内容预处理与编码识别：
   能够自动识别并正确处理多种字符编码（如 UTF-8、ISO-8859-2 等），特别是通过解析 HTML 中 `<meta>` 标签的 `charset` 来解码文本。
   在解析之前高效清理 HTML DOM，自动移除 `<script>`、`<style>`、`<head>` 与 HTML 注释等非内容标签。

2. 段落抽取与构建：
   能够通过流式解析（SAX）高效遍历 DOM 树，识别所有块级元素（如 `p`、`div`、`h1 - h6`、`li` 等），并把它们转换为结构化的段落对象。
   能够智能处理 `<br>` 标签，依据其所在位置与出现频率，把它视为段落内的换行或段落之间的分隔符。

3. 启发式内容分类：
   实现强大的启发式分类算法，能够依据**链接密度**（链接文本占比）、**文本长度**与**停用词密度**（常见虚词占比）对每个段落做初步分类。
   实现上下文修正机制，通过分析"邻近"段落的分类结果，对处于模糊状态的段落（例如极短段落或停用词很少的段落）进行智能修正，从而显著提升分类准确率。

4. 多语言支持：
   项目需要内置 80 多种语言的停用词表。
   提供接口（如 `get_stoplist(language_name)`），让用户能方便地加载指定语言的停用词表，以优化该语言网页的处理。

5. 集成测试系统：
   提供端到端集成测试脚本（如 `test_integration.py`），全面验证整个库的功能。该脚本应模拟真实使用场景：准备一份包含正文、导航链接、页眉、页脚与评论等复杂元素的 HTML 文档，调用核心 `justext` 函数进行处理，并对抽取结果做断言，确保正文被完整保留、所有样板内容被成功移除。

6. 项目必须包含完整的 `setup.py` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `lxml==6.0.0`、`lxml_html_clean==0.4.2`、`pytest==8.4.1`、`coverage==7.10.0` 等核心库）。`setup.py` 应能验证所有功能模块是否正常工作。同时应提供 `justext/__init__.py` 作为统一 API 入口，导入并导出 `PathInfo`、`classify_paragraphs`、`preprocessor`、`html_to_dom`、`ParagraphMaker`、`Paragraph` 以及主要的导入导出函数，并提供版本信息，使用户能通过简单的 `from justext/justext.core/paragraph/utils import **` 语句访问所有主要功能。

**考点**：用链接密度、停用词密度与文本长度三个特征做段落级正文判定，再用邻域上下文修正模糊段落；难点是在流式 SAX 遍历下把块级元素与 `<br>` 正确切分成段落，并保持 80 多种语言停用词表的覆盖。
