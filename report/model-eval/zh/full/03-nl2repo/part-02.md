# NL2Repo-Bench 全题规格中文翻译 · Part 2（第 29–32 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 29. `freezegun`（测试数 133）

**中文规格**

请创建一个名为 freezegun 的 Python 项目，实现一个在测试中冻结与操控时间的工具库。项目应包含以下功能：

1. **时间冻结器**：实现 `freeze_time` 装饰器与上下文管理器，使 `datetime.datetime.now()`、`datetime.date.today()`、`time.time()`、`time.localtime()`、`time.gmtime()`、`time.strftime()` 等函数在测试期间返回指定的冻结时间。支持字符串、`datetime`、`date`、`lambda` 等多种时间输入格式。

2. **时区与本地化支持**：支持 `tz_offset` 参数，以模拟不同时区下的本地时间与 UTC 时间，并兼容带时区信息的 `datetime` 对象。

3. **时间推进与单调时间**：支持 `tick`、`auto_tick_seconds` 等参数，让时间可以自动或手动推进，模拟时间流逝。冻结 `time.monotonic()`、`time.perf_counter()` 等单调时间相关 API。

4. **类型兼容与伪造类**：自动用 `FakeDate` 与 `FakeDatetime` 替换标准库的 `datetime.date` 与 `datetime.datetime`，确保类型检查、加减运算、`replace`、`astimezone`、序列化、数据库适配等操作保持兼容。

5. **异步与多线程支持**：`freeze_time` 可用于 `async` 协程、类装饰器与方法装饰器。支持 `real_asyncio` 参数，并兼容 `asyncio`、`unittest`、`pytest` 等测试框架。

6. **全局与局部配置**：支持 `configure`、`reset_config` 等全局配置接口，并允许自定义忽略模块列表，避免影响多线程、多进程等模块。

7. **异常与边界处理**：稳健处理非法输入、极端时间、递归调用等情况，确保测试安全。

8. **接口设计**：所有主要函数（如 `freeze_time`、`FakeDate`、`FakeDatetime`、`fake_time`、`fake_localtime`、`fake_gmtime`、`fake_strftime`、`configure`）都应实现在 `freezegun/api.py` 中，支持 `from freezegun.api import ...` 的导入方式。主入口 `freezegun/__init__.py` 应导出 `freeze_time`、`configure` 等核心接口，便于用户通过 `from freezegun import freeze_time` 直接访问主要功能。

9. **示例与评测脚本**：提供 `freeze_time`、`FakeDatetime`、`FakeDate` 等的典型用法示例与测试用例，演示如何冻结时间、推进时间、序列化、适配数据库与进行类型检查。所有测试用例应覆盖正常、边界与异常输入，支持 `pytest` 执行与覆盖率统计。

10. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件，把项目配置为可安装包（支持 `pip install`），并声明完整依赖清单（如 `python-dateutil==2.9.0.post0`、`maya==0.6.1`、`pytest==8.4.0`、`pytest-cov==5.0.0`、`coveralls==4.0.0`、`setuptools==70.0.0`、`wheel==0.43.0`、`mypy==1.10.0` 等，这些是实际使用的核心库）。同时提供 `freezegun/__init__.py` 作为统一 API 入口，导入并导出 `freeze_time`、`fake_date_function`、`fake_datetime_function`、`fake_gmtime_function`、`fake_localtime_function`、`fake_strftime_function`、`fake_time_function`、`equal_to_anything`、`FakeDatetime`、`FakeDate`、`fake_time`、`fake_localtime`、`fake_gmtime`、`fake_strftime`、`reset_config`、`configure`、`_freeze_time`、`_is_cpython` 等主要导入导出的函数或类（其中 `fake_module.equal_to_anything` 是 `EqualToAnything` 类的实例）。另外提供版本信息，使用户能通过 `from freezegun import *`、`from freezegun.* import *`、`from freezegun.tests.fake_module import *` 等简单语句访问所有主要功能。

**考点**：用伪造的 `FakeDatetime`/`FakeDate` 与替换后的 `time` 函数把"当前时间"变成可控值并在退出时还原，难点在 `tz_offset`、tick 推进以及异步/多线程下的作用域隔离。

## 30. `frontmatter`（测试数 55）

**中文规格**

请创建一个名为 Python-Frontmatter 的 Python 项目，实现一个文档元数据解析与管理库。项目应包含以下功能：

1. 多格式元数据解析器：应能从输入文本中提取并解析 front matter 元数据，支持 YAML 格式（如以 `---` 包围的元数据块）、JSON 格式（如以 `{}` 包围的元数据）、TOML 格式（如以 `+++` 包围的元数据）等多种格式。解析结果应为包含元数据与文档内容两部分的 Python 字典对象。

2. 文档加载与解析：实现从文件或字符串加载文档的函数（或脚本），自动探测元数据格式，并把元数据与内容两部分分离。应支持从文件路径、文件对象或字符串加载文档，并处理不同编码格式（如 UTF-8、UTF-8-SIG 等）。

3. 元数据操作与修改：提供便捷的元数据访问与修改接口，支持以字典方式访问元数据字段，支持元数据的增、删、改、查操作，以及元数据合并与更新功能。

4. 文档再生成：实现把修改后的元数据与内容按原格式重新组合的功能，支持保持原格式或转换为其他格式，并确保输出格式的一致性。

5. 自定义处理器支持：为每种元数据格式设计独立的处理器类，支持自定义分隔符、自定义解析规则，并可扩展支持新的元数据格式。

6. 核心文件要求：项目必须包含完整的 `setup.py` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整依赖清单（包括 `PyYAML`、`toml`、`pytest`、`mypy`、`types-PyYAML`、`types-toml` 等核心库）。`setup.py` 文件应能验证所有功能模块是否正常工作。同时需要提供 `frontmatter/__init__.py` 作为统一 API 入口，从 `default_handlers` 模块导入 `YAMLHandler`、`JSONHandler`、`TOMLHandler` 等处理器类，导出 `parse`、`load`、`loads`、`dump`、`dumps`、`check`、`checks`、`detect_format`、`Post` 等核心类与函数，并提供版本信息，使用户通过简单的 `import frontmatter` 语句即可访问所有主要功能。`default_handlers.py` 中需要有 `BaseHandler` 基类来定义处理器的基本接口（包括 `detect`、`split`、`load`、`export`、`format` 等核心方法），以及各格式的具体处理器实现。根据对测试目录的分析，测试文件 `tests/unit_test.py` 引用了 `frontmatter.load`、`frontmatter.dumps`、`frontmatter.check`、`frontmatter.detect_format`、`frontmatter.handlers` 等函数与变量。`tests/test_files.py` 引用了 `frontmatter.load` 与 `frontmatter.Post` 类。`tests/test_docs.py` 引用 `frontmatter` 模块本身进行文档测试。`tests/stub_tests.py` 引用 `frontmatter.loads` 函数。这些测试文件验证 `Post` 对象的 `to_dict`、`__getitem__`、`__setitem__`、`__contains__`、`get`、`keys`、`values` 等方法，以及 `YAMLHandler`、`JSONHandler`、`TOMLHandler` 处理器的 `detect`、`split`、`load`、`export` 等方法，以确保整个 API 接口的完整性与正确性。

**考点**：按分隔符探测并拆分 YAML / JSON / TOML 三类 front matter、把正文与元数据分离后再无损重组，难点是格式自动识别与 `Post` 同时具备字典与属性语义。

## 31. `ftfy`（测试数 336）

**中文规格**

请创建一个名为 ftfy 的 Python 项目，实现一个 Unicode 文本修复库。项目应包含以下功能：

1. **编码检测与修复模块**：实现智能的 mojibake（乱码）检测算法，能识别 UTF-8 被错误解码为其他编码（如 Latin-1、Windows-1252 等）的情形。应支持多层编码问题的修复，例如多次编码转换造成的复杂文本损坏。核心函数应能自动检测编码模式并施加相应的修复策略。

2. **文本修复函数**：实现多种文本修复函数，包括 HTML 实体解码（支持大小写不敏感的实体）、控制字符移除、全角字符规范化、连字展开、引号规范化等。每个修复函数应作为独立模块实现，支持可配置的修复策略。

3. **启发式算法**：实现基于规则的启发式算法来检测文本问题并避免误报。算法应能区分正常文本与损坏文本，只在证据充分时施加修复。包含字符频率分析、编码模式识别与文本合理性判定等功能。

4. **配置系统**：设计灵活的配置系统，允许用户启用或禁用特定修复功能。配置应支持默认策略与自定义策略，并提供修复过程的详细描述功能。

5. **命令行接口**：提供完整的命令行工具，支持文件处理与流式处理。命令行工具应能处理不同编码的输入文件，并详细输出修复过程。

6. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件，把项目配置为可通过 `pip install` 安装的标准 Python 包，并声明完整依赖清单——包括 `wcwidth`（用于 Unicode 字符宽度计算以支持文本格式化功能）等核心库，确保文本修复、编码处理、终端显示等方面的兼容性。`ftfy/__init__.py` 应作为统一 API 入口，整合各模块的核心功能：导出主要文本修复函数（`fix_text()` 完整文本修复、`fix_text_segment()` 分段修复、`fix_encoding()` 专注编码修复、`fix_encoding_and_explain()`／`fix_and_explain()` 返回修复过程描述、`apply_plan()` 执行自定义修复步骤）；工具函数（`explain_unicode()` 解析 Unicode 字符、`fix_file()` 处理文件修复、`guess_bytes()` 猜测字节序列的编码）；配置类与数据类型（`TextFixerConfig` 修复策略配置、`ExplainedText` 封装修复结果与说明、`ExplanationStep` 记录单步修复细节）；并通过 `__version__` 提供版本信息，确保用户能通过 `from ftfy import fix_text` 等简洁语句直接访问所有核心功能。`ftfy/fixes.py` 应实现基础文本修复逻辑：`unescape_html()` 处理 HTML 实体转义（如把 `&amp;` 还原为 `&`）；`fix_surrogates()` 修复 Unicode 代理字符（解决非法 UTF-16 代理对问题）；`remove_control_chars()` 移除非打印控制字符（保留换行等必要控制字符）；`remove_terminal_escapes()` 清除终端转义序列（如 ANSI 颜色码），为上层修复函数提供基础操作支持。在 `ftfy/chardata.py` 中，`possible_encoding()` 函数应实现字符编码兼容性检查，判断给定文本是否可能属于指定编码（如 UTF-8、Latin-1），为编码猜测与修复提供底层判断依据。在 `ftfy/bad_codecs/__init__.py` 中应实现 `search_function()` 函数，注册并查找自定义编解码器（如对 Windows-1252、ISO-8859 等编码的扩展处理），支持对非标准编码的解析能力。其下 `utf8_variants.py` 中的 `IncrementalDecoder` 类应支持 UTF-8 变体的增量解码（如重复编码或错误续接的 UTF-8），逐步处理字节流并修复编码异常。在 `ftfy/cli.py` 中，`main()` 函数应作为命令行入口，支持命令行参数解析：包括指定文件路径（用于批量文本修复）、编码猜测开关（自动检测输入编码）、Unicode 规范化选项（指定 NFC/NFD 等规范化形式）等，使工具能通过终端直接调用。在 `ftfy/formatting.py` 中，`display_ljust()` 函数应实现 Unicode 字符的左对齐格式化，考虑不同字符的显示宽度（如全角字符占 2 列），确保修复后的文本在终端中整齐显示。在 `ftfy/badness.py` 中，`is_bad()` 函数应通过量化指标（如非 ASCII 字符占比、代理字符出现频率）检测文本是否存在编码问题，作为是否触发修复流程的判定依据，优化修复效率。

**考点**：用打分式启发方法判断"UTF-8 被误读成 Latin-1 / Windows-1252"的乱码并逐层还原，难点是既修好乱码又不误伤正常文本。

## 32. `funcy`（测试数 203）

**中文规格**

请创建一个名为 funcy 的 Python 项目，实现一个全面的 Python 函数式编程工具库。项目应包含以下功能：

1. 增强的集合操作工具：提供高性能的集合操作实现，包括 `walk`（集合遍历与转换）、`select`（条件筛选）、`compact`（空值过滤）、`distinct`（去重）、`flatten`（展平）等。这些工具应提供统一的集合操作接口，支持高效的增、删、改、查操作，适用于复杂数据处理与集合管理场景。

2. 函数组合与变换工具：实现智能的函数操作能力，包括 `compose`（函数组合）、`curry`（函数柯里化）、`partial`（偏函数）、`complement`（函数取反）、`all_fn`（函数组合）等。应支持多种函数操作模式，提升函数式编程的便利性与代码可读性。

3. 序列处理工具：提供多序列处理能力，包括 `take`（取前 N 个元素）、`drop`（跳过前 N 个元素）、`chunks`（分块处理）、`pairwise`（配对处理）、`group_by`（分组处理）等。应保证序列操作的安全性与兼容性，适用于数据流处理与批量操作场景。

4. 流程控制抽象工具：实现专业的流程控制管理系统，包括 `retry`（重试机制）、`limit_error_rate`（错误率限制）、`suppress`（异常抑制）、`once`（单次执行）、`cached_property`（缓存属性）等。应支持复杂的控制流模式与校验机制，适用于应用逻辑与错误处理。

5. 调试与开发工具：提供丰富的调试操作方式，包括 `tap`（调试输出）、`print_exits`（函数退出打印）、`log_calls`（调用日志）、`print_durations`（执行耗时统计）等。应支持多种调试模式，适用于开发调试与性能分析场景。

6. 接口设计：为每个功能模块设计独立的函数接口，支持直接导入与模块化使用。每个模块应定义清晰的输入输出格式，便于集成到现有项目。用户应能通过简单的 `from funcy import walk, compose, retry` 语句访问所需函数。

7. 示例与测试脚本：提供示例代码与测试用例，演示如何使用各种工具函数进行集合操作、函数组合、流程控制、调试分析等（如 `walk(str.upper, {'a', 'b'})` 应返回 `{'A', 'B'}`）。上述功能需有机结合，构建完整的 Python 函数式编程工具集。

8. 核心文件要求：项目必须包含完整的 `setup.py` 文件，需使用 setuptools 把项目配置为可安装包（支持 `pip install` 与可编辑模式安装），明确说明 Python 版本要求（建议支持 Python 3.6 及以上），并列出完整依赖清单（如有第三方依赖，需在此声明）。`setup.py` 文件需配置包数据与模块结构，确保所有功能模块（如序列处理、函数装饰、流程控制等）在安装后可验证正常工作，并支持通过 `python setup.py test` 进行基本功能验证。同时需要提供 `funcy/__init__.py` 作为统一 API 入口。该文件需从各子模块导入核心功能与工具：从 `types` 模块导入类型相关工具，从 `tree` 模块导入树结构处理函数，从 `strings` 模块导入字符串操作工具，从 `seqs` 模块导入序列处理函数（如 `lmap`、`keep`、`lfilter`），从 `objects` 模块导入对象操作工具，从 `funcs` 模块导入函数处理工具（如 `autocurry`），从 `funcolls` 模块导入函数式集合工具，从 `funcmakers` 模块导入函数构造工具，从 `flow` 模块导入流程控制函数（如 `silent`、`suppress`），从 `decorators` 模块导入装饰器工具（如 `decorator`），从 `debug` 模块导入调试辅助工具，从 `colls` 模块导入集合操作工具，从 `calc` 模块导入计算相关工具。此外，需直接导出常用核心函数（如 `rest`、`is_list`、`merge_with`、`lmap`），并通过 `__version__` 变量提供版本信息，确保用户能通过简单的 `from funcy import walk, compose, retry, lmap, autocurry, silent` 语句访问所有主要功能。各模块中需实现相应的核心函数以支撑函数式编程能力：`seqs` 模块提供序列处理函数（`lmap`、`keep`、`lfilter` 等），`funcs` 模块实现函数装饰与变换（`autocurry`、函数组合等），`flow` 模块处理流程控制（`silent` 忽略异常、`suppress` 捕获异常等），`decorators` 模块提供装饰器构造工具（`decorator`），`colls` 模块实现集合操作，`tree` 模块处理树结构遍历与操作，`strings` 模块提供字符串处理函数，`types` 模块提供类型检查与转换工具。各模块功能需相互配合，构成完整的函数式编程工具集，覆盖序列操作、函数构造、流程控制、数据结构处理等核心场景。

**考点**：跨十几个子模块提供函数式工具集（遍历/筛选、组合与柯里化、懒序列、重试与异常抑制），难点是各模块导出面与懒求值语义必须严格一致。
