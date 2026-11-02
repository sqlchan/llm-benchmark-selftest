# NL2Repo-Bench 全题规格中文翻译 · Part 12（第 75–81 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 75. `records`（测试数 31）

**中文规格**

请创建一个名为 Records 的 Python 项目，实现一个对人类友好的 SQL 查询与数据导出库。项目应包含以下功能：

1. **数据库连接与原生 SQL 查询**：实现一个 Database 类，能够通过数据库连接字符串（例如 `postgres://...`、`sqlite:///...` 等）连接主流关系型数据库（支持 RedShift、Postgres、MySQL、SQLite、Oracle、MS-SQL 等）。驱动程序需由用户自行安装。支持通过字符串或 SQL 文件执行原生 SQL 查询，并支持参数化查询（例如 `db.query('select * from table where id=:id', id=1)`）。

2. **结果集处理与访问**：查询结果应以 RecordCollection 的形式返回，支持多种访问方式（如 `row['col']`、`row.col`、`row[index]`）。可通过 `all()`、`first()`、`as_dict()` 等方法获取整个结果集、第一条结果或字典格式的结果。支持对结果集进行缓存、切片与迭代等操作。

3. **事务与批量操作**：支持数据库事务（例如 `t = Database.transaction(); t.commit()`），并实现 `bulk_query` 与 `bulk_query_file` 等批量插入/更新方法。

4. **数据导出功能**：集成 Tablib 库，支持用一行代码把查询结果导出为 CSV、XLS、JSON、HTML、YAML 与 Pandas DataFrame 等多种格式，便于数据分析与报表生成。导出接口包括 `rows.export('csv')`、`rows.export('json')`、`rows.export('df')` 等。

5. **命令行工具**：实现 `records` 命令行工具，支持通过命令行执行 SQL 查询并把结果导出为多种格式的文件。支持参数注入、数据库 URL 指定、格式选择等。例如：

   ```
   records "select * from users where active=:active" csv active=true --url=sqlite:///test.db
   ```

6. **辅助功能**：支持通过 `$DATABASE_URL` 环境变量自动配置数据库连接。实现 `Database.get_table_names()` 方法，以方便地获取当前数据库中所有表的名称。

7. **核心文件要求**：项目必须包含完整的 `setup.py` 文件，把项目配置为可安装包（支持 `pip install`），并声明所有依赖（如 `SQLAlchemy==2.0.30`、`tablib==3.5.0`、`openpyxl==3.1.2`、`docopt==0.6.2`、`psycopg2-binary==2.9.9`、`sqlalchemy-redshift==0.8.14` 等核心库）。`setup.py` 应能验证所有功能模块是否正常工作；同时需要提供 `records.py` 作为统一 API 入口，从 `records` 模块导入 `query()` 等核心函数，导出 `Database`、`Connection`、`RecordCollection`、`Record` 等配置类，并提供版本信息，使用户通过简单的 `import records` 语句即可访问所有主要功能。

**考点**：在 SQLAlchemy 2.0 之上做一层薄封装，把连接串解析、原生/参数化 SQL、事务与批量写入串成同一条链路，难点是 RecordCollection 的多形态访问（`row['col']`/`row.col`/`row[index]`）与借助 tablib 在单行内完成 CSV/XLS/JSON/HTML/YAML/DataFrame 多格式导出。

## 76. `requests-html`（测试数 41）

**中文规格**

请创建一个名为 requests-html 的 Python 项目，实现一个 HTML 解析库。项目应包含以下关键功能：

1. **基础功能测试**：实现从字符串或 URL 加载 HTML 内容，支持解析多种编码格式的文档，提供完整的 CSS 选择器与 XPath 选择器支持，并准确提取元素属性、文本内容与链接，包括相对链接与绝对链接的自动转换。

2. **浏览器渲染测试**：集成 Chromium 浏览器，支持完整的 JavaScript 执行与动态内容加载，实现自定义脚本注入、表单提交、点击事件触发与元素等待功能。

3. **会话管理测试**：实现同步与异步会话管理，支持 Cookie 持久化与请求头管理，提供请求超时设置、重试机制与代理支持。

4. **分页与导航测试**：自动检测并处理分页内容，支持多页内容的合并与提取，实现页面跳转、前进、后退与刷新功能。

5. **异常处理测试**：处理连接超时与请求失败等网络异常，验证对无效 HTML 文档与选择器匹配失败的处理，并实现渲染超时与资源使用限制机制。

6. **性能测试**：测试页面加载时间、渲染速度与资源占用，支持高并发请求与渲染测试，评估系统资源使用效率。

7. **兼容性测试**：验证在不同 Chromium 版本上的运行情况，测试在 Windows、Linux、macOS 等不同操作系统上的表现，并确保与 Python 3.6 及以上版本兼容。

8. **安全测试**：实现 XSS 防护与注入攻击防护，管理跨域请求与文件访问权限，防止 CSRF 攻击。

9. **集成测试**：与 pytest 测试框架无缝集成，支持 asyncio 异步编程模型，并保持与标准 requests 库的兼容性。

10. **基准测试**：度量请求响应时间、页面渲染速度与资源使用效率，并进行高并发请求与大数据量处理测试。

11. **核心文件要求**：项目必须包含完整的 `setup.py` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整依赖清单（包括 `requests >= 2.22.0`、`pyquery >= 1.4.0`、`fake-useragent >= 0.1.11`、`parse >= 1.12.0` 等核心库）。`setup.py` 文件应能验证所有功能模块是否正常工作。同时应提供 `requests_html.py` 作为统一 API 入口，导入并导出 `HTMLSession`、`AsyncHTMLSession`、`HTMLResponse`、`HTML` 及主要的导入导出函数，并提供版本信息，使用户通过简单的 `from requests_html import *` 语句即可访问所有主要功能。

**考点**：在 requests 之上叠加「lxml/CSS/XPath 静态解析」与「Chromium 渲染取 DOM」两条通道，难点是相对链接与绝对链接的自动转换、同步与异步会话及分页导航的统一抽象，以及渲染超时与资源上限下的异常兜底。

## 77. `retrying`（测试数 23）

**中文规格**

请创建一个名为 Retrying 的 Python 项目，实现一个通用重试库。项目应包含以下功能：

1. 装饰器体系：从函数调用中提取并应用重试逻辑，同时支持 `@retry` 与 `@retry()` 两种语法形式。重试结果应为 Retrying 对象或等价的可调用形式。

2. 重试控制：实现一个函数（或类），用于比较两个重试配置是否等价，包括比较停止条件与等待策略。应支持限制尝试次数、控制时间延迟、自定义停止函数，以及固定间隔、随机等待、增量等待与指数退避等策略。

3. 异常处理：专门处理特定异常类型、异常包装、自定义异常判断函数等。例如 `IOError` 与 `ValueError` 应分别处理，异常包装应保留原始异常信息。

4. 接口设计：为每个功能模块（如装饰器、停止条件、等待策略、异常处理、结果校验等）设计独立的函数接口或类接口，同时支持装饰器调用与直接调用。各模块应定义清晰的输入与输出格式。

5. 示例与评测脚本：提供示例代码与测试用例，演示如何使用 `@retry` 装饰器与 `Retrying` 类进行重试操作（例如 `@retry(stop_max_attempt_number=3, wait_fixed=1000)` 应正确地重试 3 次）。上述功能需要组合起来，构建完整的重试工具集。最终项目应包含装饰器、重试控制、异常处理与结果校验等模块，并附带典型测试用例，形成可复现的重试流程。

6. 核心文件要求：项目必须包含完整的 `setup.py` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整依赖清单（包括 `six>=1.7.0` 等核心库）。`setup.py` 文件应能验证所有功能模块是否正常工作。同时需要提供 `retrying.py` 作为统一 API 入口，从重试装饰器与 Retrying 类导入 `retry`、`Retrying`、`RetryError` 等核心函数与类，并提供版本信息，使用户通过简单的 `from retrying import retry, Retrying, RetryError` 语句即可访问所有主要功能。`retrying.py` 中需要有一个 `call()` 方法，使用各种策略执行重试逻辑。

**考点**：把「停止条件 × 等待策略 × 可重试判定」拆成可组合组件，并让 `@retry` 与 `@retry(...)`（含无参/带参两种形式）都收敛到同一个 `Retrying.call()` 重试循环，难点是指数退避与随机等待的组合、`stop_max_attempt_number` 等阈值的精确语义，以及异常包装后原始异常信息的保留。

## 78. `rich-click`（测试数 145）

**中文规格**

请创建一个名为 Rich-Click 的 Python 项目，实现一个 Click 命令行界面美化库。项目应包含以下功能：

1. **Rich 渲染引擎**：能够接管 Click 帮助输出的渲染，使用 Rich 库提供美化的命令行界面，并支持颜色、表格与面板等视觉效果。渲染结果应支持多种输出格式（text、HTML、SVG）。

2. **兼容包装层**：实现与 Click API 完全兼容的包装类，包括 RichCommand、RichGroup、RichContext 等，确保用户可以从 Click 无缝迁移到 Rich-Click。

3. **样式与主题系统**：提供完整的样式配置系统，支持颜色、边框与对齐等视觉元素的自定义。应支持全局配置与局部配置的灵活组合。

4. **分组与排序功能**：实现选项分组（OPTION_GROUPS）与命令分组（COMMAND_GROUPS）功能，支持通配符匹配与优先级排序，使命令行帮助更有条理。

5. **多标记支持**：集成对 Markdown 与 Rich 标记语言的解析支持，允许在帮助文本中使用富文本格式标记。

6. **CLI 工具集成**：提供一个命令行工具，能在不修改原始代码的前提下，为任何使用 Click 的第三方应用添加 Rich 美化效果。

7. **核心文件要求**：项目必须包含定义良好的 `pyproject.toml` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整依赖清单（包括 `click>=8`、`rich>=12`、`typing-extensions` 等核心库）。同时需要提供 `src/rich_click/__init__.py` 作为统一 API 入口，从各模块导入 `RichCommand`、`RichGroup`、`RichContext` 等核心类，并提供 `command` 与 `group` 等装饰器函数，使用户通过简单的 `import rich_click as click` 语句即可访问所有主要功能。`rich_help_rendering.py` 中应有 `rich_format_help()` 与 `rich_format_error()` 等函数，以处理各种渲染场景。

**考点**：在不改变 Click 行为契约的前提下接管 help 与 error 的渲染管线，难点是 `RichCommand`/`RichGroup`/`RichContext` 对 Click 内部渲染路径的替换、OPTION_GROUPS/COMMAND_GROUPS 的通配符匹配与优先级排序，以及 text/HTML/SVG 多格式输出的一致性。

## 79. `schedule-master`（测试数 81）

**中文规格**

请创建一个名为 `schedule` 的 Python 项目，用于测试 `schedule` 库的核心功能。项目应包含以下特性：

1. 基础任务调度测试：验证每分钟、每小时与每天执行任务的基本功能。
2. 特定时间点调度测试：测试在特定时间点执行任务的功能（例如每天 10:30）。
3. 时间范围调度测试：验证在特定时间区间内执行任务的功能（例如每 5–10 分钟）。
4. 带标签的任务管理：实现任务的添加、获取与删除功能。
5. 任务取消与清空：测试取消单个任务与清空所有任务的功能。
6. 任务执行状态跟踪：监控任务的执行状态与下次执行时间。
7. 异常处理：处理无效的时间格式与任务执行异常。
8. 多任务并发执行：测试同时调度多个任务的功能。
9. 装饰器使用：使用 `@repeat` 装饰器定义周期性任务。
10. 时区处理：测试不同时区下的任务调度功能。
11. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整依赖清单（包括 `docutils`、`Pygments`、`pytest`、`pytest-cov`、`pytest-flake8`、`Sphinx`、`black==20.8b1`、`click==8.0.4`、`mypy`、`pytz`、`types-pytz` 等核心库）。`pyproject.toml` 文件应能验证所有功能模块是否正常工作。同时需要提供 `schedule/__init__.py` 作为统一 API 入口，从 `schedule` 模块导入并导出核心函数，并提供版本信息，使用户通过 `from schedule import xxx` 或 `import schedule` 等简单语句即可访问所有主要功能。

**考点**：以「时间表达式解析 → 下次运行时间计算 → 轮询触发」为核心的调度器实现，难点是特定时刻与时间区间（如每 5–10 分钟）的边界判定、标签化任务管理与取消清空、`@repeat` 装饰器注册，以及时区换算与无效时间格式下的鲁棒性。

## 80. `schema`（测试数 118）

**中文规格**

请创建一个名为 Schema 的 Python 项目，实现一个数据结构校验库。项目应包含以下功能：

1. 数据结构校验器：能够校验输入的 Python 数据结构的格式与内容，支持字典、列表、元组与集合等复杂嵌套结构。校验结果应为布尔值或转换后的数据对象，支持类型检查与值校验。

2. Schema 匹配系统：实现用于比较数据结构是否符合预定义 schema 的函数（或类），包括类型匹配、取值范围检查、正则表达式校验等。应支持 And 与 Or 的逻辑组合，以及自定义校验函数。

3. 特殊校验处理：专门处理可选字段、禁止字段、默认值、常量值等。例如 `Optional("field")` 表示可选字段，`Forbidden("field")` 表示禁止字段，`Use(int)` 表示类型转换。

4. 接口设计：为每个功能模块（如 Schema 类、And 类、Or 类、Regex 类、Use 类等）设计独立的类接口，支持链式调用与错误处理。各模块应定义清晰的输入与输出格式。

5. 示例与校验脚本：提供示例代码与校验用例，演示如何使用 `Schema()` 与 `validate()` 函数进行数据结构校验（例如 `Schema({"name": str, "age": And(int, lambda n: 0 <= n <= 150)}).validate({"name": "John", "age": 30})` 应返回校验后的数据）。上述功能需要组合起来，构建完整的数据校验工具集。项目最终应包含校验器、比较器与整体校验等模块，并附带典型校验用例，形成可复现的校验流程。

6. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整依赖清单（包括 `contextlib2>=0.5.5`、`pytest>=8.0.0`、`pytest-cov>=4.0.0`、`coverage>=7.0.0`、`mock>=5.0.0`、`pre-commit>=3.0.0` 等库）。`pyproject.toml` 应能验证所有功能模块是否正常工作。同时需要提供 `schema/__init__.py` 作为统一 API 入口，从各校验模块导入 `Schema`、`And`、`Or`、`Regex`、`Use`、`Optional`、`Forbidden`、`Const`、`Literal`、`SchemaError`、`SchemaWrongKeyError`、`SchemaMissingKeyError`、`SchemaForbiddenKeyError`、`SchemaUnexpectedTypeError`、`SchemaOnlyOneAllowedError` 等核心类，并提供版本信息，使用户通过简单的 `from schema import *` 语句即可访问所有主要功能。`__init__.py` 中需要有一个 `Schema` 类作为主要校验入口，使用各种策略校验 Python 数据结构是否符合预定义 schema。

**考点**：把「数据结构 → 预定义 schema」的匹配做成可组合的校验器代数（And/Or/Regex/Use/Optional/Forbidden/Const/Literal），难点是嵌套结构的递归校验、错误的精确分类（wrong key/missing key/forbidden key/unexpected type/only-one-allowed），以及 `Use` 转换后返回值的类型一致性。

## 81. `six`（测试数 200）

**中文规格**

请实现一个名为 Six 的 Python 兼容性工具库，满足以下核心功能：

1. 提供统一的类型判断常量（如 `string_types`、`integer_types`、`class_types`、`text_type`、`binary_type`），使代码在 Python 2 与 Python 3 中都能进行无差异的类型判断。

2. 实现标准库重命名兼容。通过 `six.moves` 统一导入 `queue`、`configparser`、`urllib` 等模块与常用函数，并自动适配不同 Python 版本的标准库结构。

3. 为迭代器与字典操作提供兼容接口，如 `next`、`Iterator`、`iterkeys`、`itervalues`、`iteritems`、`viewkeys`、`viewvalues`、`viewitems`，确保遍历与操作方式在不同版本间行为一致。

4. 实现字节与字符串处理函数，如 `b`、`u`、`unichr`、`int2byte`、`byte2int`、`ensure_binary`、`ensure_str`、`ensure_text`，为 Python 2/3 中文本与二进制数据的转换提供无缝兼容。

5. 提供函数与方法属性访问工具，如 `get_unbound_function`、`get_method_function`、`get_method_self`、`get_function_code`、`get_function_defaults`、`get_function_globals`、`get_function_closure`，统一底层属性的获取方式。

6. 实现语法兼容函数，如 `exec_`、`print_`、`raise_from`、`reraise`，屏蔽 Python 2/3 在语法与异常处理上的差异。

7. 提供元类与类装饰器兼容工具，如 `with_metaclass`、`add_metaclass`、`python_2_unicode_compatible`，简化跨版本的类定义与继承结构。

8. 实现 unittest 断言兼容方法，如 `assertCountEqual`、`assertRaisesRegex`、`assertRegex`、`assertNotRegex`，确保单元测试代码在不同 Python 版本间行为一致。

9. 提供 `wraps` 装饰器与 `StringIO`/`BytesIO` 兼容对象，确保装饰器与字符串 IO 操作的跨版本一致性。

10. 核心文件要求：项目必须包含完整的 `setup.py` 文件。该文件需要把项目配置为可安装包（支持 `pip install`）并声明完整依赖清单（如 `flake8 >= 3.7.9`、`isort >= 4.3.21`、`mypy >= 0.770`、`pre-commit >= 2.0.1` 等实际使用的核心库）。`setup.py` 文件应确保所有核心功能模块都能正常工作。同时应提供 `six.py` 作为统一 API 入口，导入并导出 `moves` 及主要的导入导出函数，并提供版本信息，使用户通过简单的 `import six` 与 `from six import **` 语句即可访问所有主要功能。

**考点**：在一个单文件里同时承载 Python 2/3 的命名差异（`moves` 动态模块）、语义差异（`string_types`、`iteritems`、`ensure_str` 等）与语法差异（`with_metaclass`、`exec_`、`reraise`），难点是 `moves` 的懒加载属性代理与版本分支判定必须对调用方完全透明。
