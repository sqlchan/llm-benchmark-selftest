# NL2Repo-Bench 全题规格中文翻译 · Part 9（第 59–63 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 59. `pyperclip`（测试数 2）

**中文规格**

请创建一个名为 `pyperclip` 的 Python 项目，实现一个跨平台的剪贴板操作库。项目应包含以下功能：

1. **跨平台剪贴板支持**：自动检测并适配不同操作系统的剪贴板机制。在 Windows 系统上使用 Windows API（通过 ctypes 调用 user32.dll）。在 macOS 系统上支持 pbcopy/pbpaste 命令行工具以及 PyObjC 框架。在 Linux 系统上支持 xclip、xsel、wl-clipboard、klipper 等多种剪贴板工具。为 WSL 环境提供专门支持，并在 Cygwin 环境下支持 /dev/clipboard。程序需要为当前系统自动选择最合适的剪贴板实现，并支持对 Wayland 与 X11 显示服务器的自动检测。

2. **核心剪贴板操作**：提供统一的复制与粘贴函数接口。`copy(text)` 函数能够把文本内容写入系统剪贴板，并支持字符串、数字、布尔值等基本数据类型的自动转换（None、列表等不支持的类型将抛出异常）。`paste()` 函数能够从系统剪贴板读取文本内容并返回。两个函数都应处理 Unicode 字符、emoji 符号与特殊字符的编码问题，并支持 UTF-8 编码。

3. **剪贴板机制管理**：实现剪贴板机制的动态选择与切换功能。`determine_clipboard()` 函数能够自动探测可用的剪贴板实现。`set_clipboard(clipboard_type)` 函数允许用户手动指定剪贴板机制（如 "windows"、"pbcopy"、"xclip"、"xsel"、"wl-clipboard"、"klipper"、"qt"、"pyobjc"、"no" 等）。`is_available()` 函数检查剪贴板功能是否可用。支持懒加载机制，避免在 import 时自动初始化剪贴板。

4. **异常处理与错误管理**：提供完整的异常处理机制，包括 PyperclipException 基类、PyperclipWindowsException（Windows 特有错误）与 PyperclipTimeoutException（超时错误）。当剪贴板不可用时，通过选择 "no" 剪贴板后端提供优雅降级；在该状态下尝试复制/粘贴应以 PyperclipException 抛出，并给出有帮助的指引。支持用于 Windows API 调用错误检查的 CheckedCall 类。

5. **命令行接口**：提供用于剪贴板操作的命令行工具接口。支持 `python -m pyperclip -c [text]` 命令把文本复制到剪贴板，并支持 `python -m pyperclip -p` 命令把剪贴板中的文本粘贴到标准输出。当未提供文本参数时，从标准输入读取内容用于复制。

6. **测试体系构建**：提供覆盖所有受支持剪贴板机制的完整单元测试。测试范围包括：基础复制与粘贴功能测试，Unicode 字符与 emoji 支持测试，空白字符与特殊字符处理测试，数据类型转换测试（整数、浮点数、布尔值，以及 None、列表等不支持类型的异常测试），各平台特定剪贴板机制测试（Windows、macOS、Linux、WSL、Cygwin、Qt、XClip、XSel、WlClipboard、Klipper），以及异常处理测试。需要为每种剪贴板机制提供专门的测试类，支持平台检测与条件跳过。

7. **高级剪贴板特性**：在 Linux 系统上支持主选区缓冲区（PRIMARY selection）与剪贴板缓冲区（CLIPBOARD selection）的区分。xclip、xsel、wl-clipboard 等工具支持 primary 参数以操作主选区缓冲区。支持 Qt 框架的剪贴板操作，包括对 PyQt5 与 qtpy 的自动检测。支持 KDE 桌面环境下的 Klipper 剪贴板管理器。提供上下文管理器以安全地管理 Windows 剪贴板资源，确保资源被正确释放。

8. **核心文件要求**：项目必须包含完整的 setup.py 文件。该文件不仅要把项目配置为可安装包（支持 pip install），还要声明完整依赖清单（包括 pytest==8.2.2、mypy==1.10.0 等测试库）。setup.py 应能验证所有功能模块是否正常工作。同时需要提供 pyperclip/__init__.py 作为统一 API 入口，从各剪贴板初始化模块导入 init_osx_pbcopy_clipboard、init_osx_pyobjc_clipboard、init_dev_clipboard_clipboard、init_qt_clipboard、init_xclip_clipboard、init_xsel_clipboard、init_wl_clipboard、init_klipper_clipboard、init_no_clipboard、init_windows_clipboard、init_wsl_clipboard 等各类剪贴板的初始化函数，并导出 _executable_exists、PyperclipException 等核心工具与异常类，同时提供版本信息，使用户通过简单的 `from pyperclip import *` 语句即可访问主要功能。在 __init__.py 中需要有 _executable_exists() 函数用于检查系统命令是否存在，有 PyperclipException 异常类用于处理剪贴板操作错误，以及各平台对应的剪贴板初始化函数，以支持 Windows、macOS、Linux、WSL、Cygwin 等不同系统上的剪贴板操作。

**考点**：用一个可懒加载的后端注册表统一封装十余种系统剪贴板机制，难点是各平台探测与降级路径（Windows API/Cygwin/WSL/Wayland 与 X11）、类型转换与异常封装，以及无可用后端时"no"实现的优雅失败语义。

## 60. `pypinyin`（测试数 966）

**中文规格**

请创建一个名为 python-pinyin 的 Python 项目，实现一个汉字拼音转换库。项目应包含以下功能：

1. **表达式解析器**：能够从输入字符串中提取并解析汉字文本，支持简体中文、繁体中文、标点符号与特殊字符。解析结果应为拼音字符串或等价的可比较形式。

2. **等价性校验**：实现一个函数（或脚本），比较两个拼音表达式是否等价，包括声调比较与符号比较。应支持声调符号与数字声调之间的近似比较、拼音符号简化的判定，以及多音字/异读字的等价判定。

3. **特殊结构处理**：应对声母、韵母、声调、注音符号（Bopomofo）、威妥玛拼音（Wade-Giles）等进行特殊处理。例如 "nǐ" 与 "ni3" 应视为等价，把声母与韵母分开的 "n" + "i" 等价于 "ni"。

4. **接口设计**：为各功能模块（如解析、声调比较、符号比较、风格转换等）设计独立的命令行接口或函数接口，以支持终端调用测试。每个模块应定义清晰的输入与输出格式。

5. **示例与评测脚本**：提供示例代码与测试用例，演示如何使用 parse() 与 convert() 函数进行输入解析与拼音转换（例如 `convert(parse("你好"), style="tone")` 应返回 `['nǐ', 'hǎo']`）。需要组合上述功能，构建完整的拼音转换工具集。项目最终应包含解析、转换与整体校验等模块，并附带典型测试用例，形成可复现的转换流程。

6. **核心文件要求**：项目必须包含完整的 setup.py 文件。该文件不仅要把项目配置为可安装包（支持 pip 安装），还要声明完整依赖清单（包括 jieba==0.42.1、typing-extensions==4.12.2、chardet==5.2.0 等核心库）。setup.py 文件应能验证所有功能模块是否正常工作。同时需要提供 pypinyin/__init__.py 作为统一 API 入口，导入并导出核心函数、类等，并提供版本信息，使用户通过简单的 `from pypinyin import xxx`、`from pypinyin.xxx import xxx` 语句即可访问所有主要功能。在 converter.py 中需要有 pinyin_comvert() 函数，使用多种策略把汉字转换为拼音。

**考点**：把"解析—风格转换—等价比较"拆成可独立调用的模块并用声调符号/数字声调两套表示互校，难点是多音字与声母韵母拆分的等价判定，以及 parse/convert 链式 API 的稳定输出格式。

## 61. `pyquery`（测试数 74）

**中文规格**

请创建一个名为 PyQuery 的 Python 项目，实现一个类似 jQuery 的、用于查询与操作 XML/HTML 文档的库。项目应包含以下特性：

1. **jQuery 风格 API 设计**：实现尽可能接近 jQuery 的 API，支持用 CSS 选择器语法查询元素。提供链式方法，并实现 jQuery 的伪类选择器（如 first、last、even、odd、eq、lt、gt、checked、selected、file）。解析结果应为可操作的 DOM 元素对象。

2. **多来源数据加载器**：实现从多种来源加载 XML/HTML 文档的功能，包括字符串形式的 HTML/XML、本地文件、网络 URL 以及 lxml 文档对象。支持为网络请求自定义 opener，以及会话管理与超时设置。

3. **DOM 遍历与操作函数**：实现完整的 DOM 操作功能，包括元素查找（find()、children()、parent()、siblings() 等）、元素过滤（filter()、not_()、is_() 等）、内容操作（html()、text()、val() 等）与属性操作（attr()、css() 等）。

4. **文档修改与构建函数**：支持对文档结构进行动态修改与构建，包括内容插入（append()、prepend()、after()、before() 等）、元素包裹（wrap()、wrap_all() 等）、元素替换（replace_with() 等）与元素删除（remove()、empty() 等）。

5. **表单处理模块**：提供处理 Web 表单的专门功能，包括表单序列化（serialize()、serialize_array()、serialize_dict()、serialize_pairs() 等）与表单取值操作（支持 input、textarea、select 等表单元素的值获取与设置）。

6. **网页抓取支持**：内置网页抓取功能，支持直接加载 HTTP/HTTPS URL。提供对自定义 opener、会话管理与超时设置的支持。

7. **接口设计**：为每个功能模块（如选择器查询、DOM 操作、表单处理、网络请求）设计独立的函数接口，支持链式调用。每个模块应定义清晰的输入与输出格式，并同时提供 camelCase 与 snake_case 两种方法命名风格。

8. **示例与测试脚本**：提供示例代码与测试用例，演示如何使用 PyQuery 进行 HTML 解析与 DOM 操作。提供覆盖所有核心功能的完整 150 条测试用例。

9. **核心文件要求**：项目必须包含配置完善的 setup.py 文件，该文件不仅要把项目配置为可安装包（支持 pip install），还要声明完整依赖清单（包括 lxml>=2.1、cssselect>=1.2.0、requests、pytest 等核心库）。setup.py 文件应能验证所有功能模块正常运行。此外，应提供 pyquery/__init__.py 作为统一 API 入口，从 pyquery 模块导入核心 PyQuery 类并提供版本信息，使用户通过简单的 `from pyquery import PyQuery as pq` 语句即可访问所有主要功能。在 pyquery.py 中应提供 PyQuery 类的完整实现，包含所有 jQuery 风格方法，并提供 no_default 常量以处理未指定默认值的情形。其中 PyQuery 是 pyquery 库的核心类，提供类似 jQuery 的 API 用于解析与操作 HTML/XML 文档；fromstring 是解析函数，能够把字符串形式的 HTML/XML 内容转换为 DOM 元素，支持多种解析器并自动处理非标准 HTML；url_opener 是网络请求函数，用于从 URL 获取网页内容，优先使用 requests 库（若已安装），否则回退到 urllib，支持 URL 编码、请求参数与超时设置。

**考点**：用 lxml/cssselect 复刻 jQuery 选择器语义与链式调用，难点是伪类选择器（first/last/eq/lt/gt 等下标式过滤）与 jQuery 扩展选择器的一致性，以及"多来源加载 + 表单序列化 + 双命名风格"同时保持 API 兼容。

## 62. `pysondb-v2`（测试数 96）

**中文规格**

请创建一个名为 pysonDB-v2 的 Python 项目，实现一个 JSON 数据库。项目应包含以下功能并满足以下要求：

1. **基础数据库操作**
    - 创建数据库（JSON 文件）
    - 向数据库添加单条数据记录（add）
    - 批量向数据库添加多条数据记录（add_many）
    - 查询全部数据（get_all）
    - 按 ID 查询数据（get_by_id）
    - 按条件查询数据（get_by_query）
    - 更新指定 ID 的数据（update_by_id）
    - 按条件批量更新数据（update_by_query）
    - 删除指定 ID 的数据（delete_by_id）
    - 按条件批量删除数据（delete_by_query）
    - 清空数据库（purge）

2. **数据库结构与类型支持**
    - 支持动态添加新字段
    - 支持自动生成唯一 ID
    - 支持数据类型校验

3. **命令行接口（CLI）功能**
    - 通过命令行创建数据库文件
    - 通过命令行添加、查询、更新与删除数据
    - 通过命令行显示数据库内容（show）
    - 通过命令行把数据库导出为 CSV 文件（tocsv）
    - 通过命令行合并数据库（merge）
    - 通过命令行清空数据库（purge）
    - 通过命令行迁移旧版本数据库（migrate）

4. **错误处理与提示**
    - 对非法操作、文件不存在与数据格式错误提供清晰的异常与提示。

5. **工具函数与辅助特性**
    - ID 生成器
    - 数据校验工具

6. **接口设计**：代码实现应具备良好设计。每个功能模块（如数据库初始化、复杂查询、批量操作、数据库管理、启用高性能模式、错误处理、数据校验、数据导出与转换、并发、数据库备份与恢复）都应设计函数接口并定义清晰的输入与输出格式。

7. **示例与测试脚本**：提供示例代码与测试用例，演示如何使用 PysonDB() 函数初始化数据库，以及如何使用其他 API（如 db.add()）执行数据操作。需要组合上述功能，构建完整的示例代码，演示数据库初始化、CRUD 操作、数据导出与备份，并附带相应的测试用例。

8. **核心文件要求**：项目必须包含完整的 setup.py 文件。该文件不仅要把项目配置为可安装包（支持 pip install），还要声明完整依赖清单（包括 ujson==5.2.0、prettytable==3.3.0、pytest==8.4.1、pytest-mock==3.14.1 与 python>=3.7.0 等核心库）。setup.py 文件应能验证所有功能模块是否正常工作。

**考点**：以单个 JSON 文件为存储实现带 ID 生成与类型校验的类文档数据库，难点是条件查询/批量更新删除的语义一致性、旧版本数据迁移与 CSV 导出，以及 CLI 与 Python API 共享同一套操作语义。

## 63. `pytest-cov`（测试数 184）

**中文规格**

请创建一个名为 pytest-cov 的 Python 项目，实现一个测试覆盖率收集与报告插件。项目应包含以下功能：

1. **覆盖率引擎**：在测试执行过程中跟踪代码覆盖率，支持多种运行模式（集中式、分布式主节点、分布式工作节点）。支持分支覆盖率与行覆盖率统计，并处理子进程的覆盖率收集。

2. **报告生成系统**：实现多种报告格式的生成，包括终端报告（term、term-missing）、HTML 报告、XML 报告、JSON 报告、LCOV 报告与代码注解报告。支持自定义报告输出路径与报告格式组合。

3. **分布式测试支持**：为 pytest-xdist 分布式测试框架提供完整支持，在多个工作进程之间正确收集与合并覆盖率数据。处理不同主机之间的路径映射与数据传输。

4. **子进程覆盖率收集**：通过环境变量与 .pth 文件自动初始化子进程覆盖率，支持复杂的进程树结构与信号处理机制。

5. **插件接口设计**：为 pytest 框架设计完整的钩子函数接口，支持测试生命周期的所有阶段。每个钩子应定义清晰的触发时机与处理逻辑。

6. **配置管理系统**：提供灵活的配置项管理，支持命令行参数、配置文件与环境变量等多种配置方式。包含覆盖率阈值检查、精度控制与上下文跟踪等高级功能。

7. **核心文件要求**：项目必须包含完整的 pyproject.toml 文件，该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整依赖清单（包括 `pytest>=6.2.5`、`coverage[toml]>=7.5`、`pluggy>=1.2` 等核心库）。pyproject.toml 应能验证所有功能模块是否正常工作。同时需要提供 `src/pytest_cov/__init__.py` 作为统一 API 入口，定义 `CoverageError`、`PytestCovWarning`、`Central`、`DistMaster`、`DistWorker` 等异常类，并提供版本信息，使用户通过 `import pytest_cov.plugin` 等简单语句即可访问所有主要功能。在 `plugin.py` 中需要有 `CovPlugin` 类作为 pytest 的核心插件入口，提供完整的测试生命周期钩子函数支持。项目将通过 pytest 测试框架的插件机制验证其功能，确保在各种测试场景下都能正确收集与报告覆盖率数据。

**考点**：作为 pytest 插件挂钩整个测试生命周期并驱动 coverage.py，难点是分布式（xdist）场景下多工作节点数据的合并与路径映射、子进程通过 .pth/环境变量自动启动覆盖率，以及"命令行 + 配置文件 + 环境变量"三源配置的优先级与阈值校验。
