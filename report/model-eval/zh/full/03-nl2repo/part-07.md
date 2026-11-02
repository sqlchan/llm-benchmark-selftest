# NL2Repo-Bench 全题规格中文翻译 · Part 7（第 52–54 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 52. `pathlib2`（测试数 344）

**中文规格**

请创建一个名为 pathlib2 的 Python 项目，实现一个跨平台的文件系统路径操作库。项目应包含以下功能：

1. **路径对象的创建与构造**：能够从输入字符串创建文件系统路径对象，支持跨平台的路径处理。应自动检测操作系统类型并返回相应的 Path 类（`WindowsPath` 或 `PosixPath`），支持字符串、Path 对象与 `os.PathLike` 对象的组合传入。解析结果应为 Path 对象或等价的可比较形式。

2. **纯路径操作**：实现不涉及文件系统 I/O 的纯路径操作，包括路径解析与规范化、路径分量提取与操作、跨平台路径语义处理。应支持路径属性访问（获取驱动器前缀、根目录、文件名与扩展名等路径分量），以及路径修改（`with_name`、`with_suffix`、`with_stem` 等方法）。

3. **路径拼接与组合**：实现把多个路径分量组合成完整路径的功能，包括路径分量规范化、相对路径处理与绝对路径优先。应支持使用 `/` 运算符进行路径拼接、`joinpath()` 方法、混合类型拼接等。

4. **相对路径计算**：实现计算两条路径之间相对路径关系的功能，包括公共前缀检测、相对路径构造与路径规范化。应支持 `relative_to()` 方法与 `is_relative_to()` 方法。

5. **绝对路径解析**：实现把相对路径转换为绝对路径并解析符号链接的功能，包括当前工作目录获取、符号链接解析与路径规范化。应支持 `absolute()` 与 `resolve()` 方法。

6. **文件读写操作**：实现便捷的文件读写方法，包括文件打开与关闭管理、编码处理、错误处理。应支持 `read_text()`、`write_text()`、`read_bytes()`、`write_bytes()` 等方法。

7. **目录操作**：实现目录的创建、删除与遍历功能，包括目录创建权限检查、递归创建目录与目录内容遍历。应支持 `mkdir()`、`rmdir()`、`iterdir()` 等方法。

8. **文件状态查询**：实现检查文件与目录的存在性与类型的功能，包括文件系统状态检查、文件类型判断与权限检查。应支持 `exists()`、`is_file()`、`is_dir()`、`is_symlink()` 等方法。

9. **文件操作**：实现文件的删除、重命名与替换功能，包括文件删除权限检查、原子重命名操作与文件替换处理。应支持 `unlink()`、`rename()`、`replace()` 等方法。

10. **模式匹配**：实现使用通配符模式匹配文件与目录的功能，包括通配符模式解析、文件名匹配与递归目录搜索。应支持 `glob()`、`rglob()` 等方法。

11. **符号链接操作**：实现符号链接的创建与管理功能，包括符号链接创建、链接目标读取与链接有效性检查。应支持 `symlink_to()`、`readlink()`、`is_symlink()` 等方法。

12. **权限与属性操作**：实现修改文件权限与获取文件属性的功能，包括权限位操作、文件属性获取与所有者信息查询。应支持 `chmod()`、`stat()`、`owner()`、`group()` 等方法。

13. **平台特定特性**：实现处理不同操作系统特定路径格式的功能，包括 Windows 路径处理、POSIX 路径处理、平台检测与适配。应支持 `WindowsPath`、`PosixPath` 等平台特定类。

14. **路径比较与排序**：实现比较路径对象并执行排序操作的功能，包括路径规范化比较、字典序排序与大小写敏感处理。应支持路径对象的比较运算符与排序函数。

15. **路径迭代与遍历**：实现遍历目录结构与路径分量的功能，包括目录内容迭代、路径分量访问与父目录遍历。应支持 `iterdir()`、`parts` 属性、`parents` 属性等。

16. **错误处理与异常管理**：实现处理文件系统操作中各种异常情况的功能，包括异常类型识别、错误恢复策略与用户友好的错误提示。应支持 `FileNotFoundError`、`PermissionError`、`OSError` 等异常处理。

17. **高级路径操作**：实现复杂的路径操作与转换功能，包括 URI 转换、字节表示与路径校验。应支持 `as_uri()`、`bytes()` 转换等方法。

18. **接口设计**：为每个功能模块设计独立的类接口或函数接口，支持面向对象调用。各模块应定义清晰的输入/输出格式，提供直观的 API。

19. **示例与测试脚本**：提供示例代码与测试用例，演示如何使用 `Path()` 构造函数创建路径对象、通过 `/` 运算符进行路径拼接、通过 `glob()` 方法进行模式匹配等。应包含典型用例与测试用例，形成可复现的操作流程。

20. **核心文件要求**：项目必须包含完整的 `setup.py` 文件，该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整依赖清单（包括对 Python 标准库 pathlib 的兼容性支持），`setup.py` 应能验证所有功能模块是否正常工作；同时需要提供 `pathlib2/__init__.py` 作为统一 API 入口，从 PurePath 与 Path 模块导入核心类，导出 `Path`、`PurePath`、`WindowsPath`、`PosixPath` 等核心类，并提供版本信息，使用户通过简单的 `from pathlib2 import Path` 语句即可访问所有主要功能。`__init__.py` 中需要一个 Path 类，以使用多种策略处理文件系统路径操作。

**考点**：用 `PurePath`/`Path` 两层结构复刻 pathlib 语义并兼顾 Python 2 兼容，难点是跨平台路径解析（自动选择 `WindowsPath`/`PosixPath`、drive/root 拆分）以及纯路径计算与真实 I/O 操作的严格分离。

## 53. `pdfplumber-stable`（测试数 171）

**中文规格**

请创建一个名为 pdfplumber-stable 的 Python 项目，实现一个 PDF 结构化信息提取库。项目应包含以下功能：

1. **打开与加载 PDF 文件**：支持通过文件路径、文件对象与字节流等多种方式打开 PDF 文件。支持密码保护、自动修复与页面选择。

2. **提取 PDF 元数据**：获取 PDF 的元数据信息，如创建时间、修改时间、作者与生成工具。

3. **页面操作与属性获取**：支持获取 PDF 的基本属性，如总页数、单页的宽度与高度、页码。支持页面裁剪（crop）、区域过滤（`within_bbox`、`outside_bbox`）与对象过滤（filter）等操作。

4. **提取 PDF 对象**：详细提取每页上的字符（chars）、线条（lines）、矩形（rects）、曲线（curves）、图像（images）、注释（annots）与超链接（hyperlinks）等对象，并获取它们的详细属性（如坐标、颜色、字体等）。

5. **文本提取与处理**：支持按页、按区域、按布局等方式提取文本。支持提取单词、文本行与全文。支持自定义容差参数、正则搜索与重复字符移除等高级文本处理。

6. **表格检测与提取**：自动检测并提取页面上的表格，返回结构化数据。支持多种表格边界识别策略（线条、文本、显式指定等），并支持自定义参数。

7. **处理图像与图形对象**：获取图像的大小、位置、色彩空间与原始数据等信息。获取线条、矩形、曲线等图形对象的详细属性。

8. **可视化调试与图像渲染**：把页面渲染为图像，支持对象叠加、表格可视化，以及在 Jupyter Notebook 中进行交互式可视化。

9. **命令行接口（CLI）**：提供 CLI 工具，支持把 PDF 内容导出为 CSV、JSON 与纯文本等格式。支持通过命令行参数自定义导出内容、页码、对象类型等。

10. **提取表单数据**：支持从 PDF 表单中提取字段名与字段值。

11. **异常处理与兼容性**：对元数据无效、PDF 结构异常等情况具备容错能力，并支持多个 Python 版本环境。

12. **核心文件要求**：项目必须包含完整的 `setup.py` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整依赖清单（包括 `pdfminer.six == 20250506`、`pillow<=9.1`、`pytest ==8.3.2`、`pandas ==2.2.2` 等核心库）。`setup.py` 文件应能验证所有功能模块是否正常工作。同时应提供 `pdfplumber/__init__.py` 作为统一 API 入口，导入并导出 `T_table_settings`、`Table`、`TableSettings`（类）、`PDFDocEncoding`、`decode_text`、`MalformedPDFException`、`resolve_and_decode`、`PdfminerException`、`CTM`、`TableFinder`、`fix_fontname_bytes`、`extract_text`、`within_bbox`、`repair`、`PDFStructTree` 以及主要的导入导出函数，并提供版本信息，使用户能通过 `from pdfplumber import **`、`from pdfplumber.ctm/table/utils/utils.exceptions/structure import **` 等简单语句访问所有主要功能。

**考点**：在 pdfminer.six 之上重建页面对象的几何分层与表格判定流水线，难点是 chars/lines/rects/curves 的坐标统一、裁剪链（crop → within_bbox/outside_bbox → filter）的叠加语义，以及线条/文本/显式三种表格边界策略的自动选择。

## 54. `plac`（测试数 28）

**中文规格**

请创建一个名为 Plac 的 Python 项目，实现一个命令行参数解析库。项目应包含以下功能：

1. **核心参数解析模块**：实现函数签名分析器，能够从函数、方法与类中提取参数信息。创建装饰器体系：`pos()`、`opt()`、`flg()`，分别用于标注位置参数、可选参数与标志参数。实现 `Annotation` 类以存储参数元数据（help、kind、abbrev、type、choices、metavar）。创建 `ArgumentParser` 类，继承自 `argparse.ArgumentParser`，并增加 `.func` 与 `.argspec` 属性。实现 `call()` 函数作为主入口，支持调用函数、类与模块，并确保从 Python 2.6 到 Python 3 的兼容性，包括对 `inspect.getfullargspec` 的兼容处理。

2. **扩展功能模块**：实现用于交互式解释器的 `Interpreter` 类，支持命令执行与任务管理。创建任务管理系统：`BaseTask`、`SynTask`、`ThreadedTask`、`MPTask` 类。实现 `TaskManager` 类以管理任务生命周期（提交、执行、终止、输出）。通过 `runp()` 函数增加多进程支持，实现并行任务执行。实现用于任务监控的 `Monitor` 与 `Manager` 类。提供 `import_main()` 函数以动态导入模块，并支持通过 `start_server()` 函数进入服务器模式以进行网络交互。其他工具类包括：`TerminatedProcess` 异常、用于增强输入处理的 `ReadlineInput`、用于帮助管理的 `HelpSummary`、用于自定义格式化的 `PlacFormatter`、用于子进程管理的 `Process`，以及作为可启动/可停止对象基类的 `StartStopObject`。

3. **GUI 界面模块**：实现继承自 `Monitor` 的 `TkMonitor` 类，提供 Tkinter GUI 界面。创建滚动文本控件以显示任务输出，支持任务监听器的添加、删除与通知，并实现主循环与队列读取机制。

4. **接口设计**：为各功能模块（如参数解析、装饰器体系、交互式解释器、任务管理等）设计独立的命令行接口或函数接口，支持终端调用测试。各模块应定义清晰的输入与输出格式。

5. **示例与评测脚本**：提供示例代码与测试用例，演示如何使用 `call()` 函数进行参数解析与命令执行（例如 `plac.call(main, ["--help"])` 应返回帮助文档）。应整合上述所有特性，构建完整的命令行参数解析工具集。最终项目应包含解析、装饰器、交互、任务管理等模块，并附带典型测试用例，形成可复现的命令行工具开发流程。

6. **核心文件要求**：项目必须包含完整的 `setup.py` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整依赖清单（仅依赖 Python 标准库，包括 `argparse`、`inspect`、`functools`、`datetime`、`gettext`、`textwrap`、`os`、`sys`、`re`、`time`、`shlex`、`subprocess`、`multiprocessing`、`threading`、`signal`、`queue`、`Tkinter`/`tkinter`、`ScrolledText`、`imp`/`importlib` 等核心库）。`setup.py` 文件应能验证所有功能模块是否正常运行。此外，应提供 `plac.py` 作为统一 API 入口，从 `plac_core` 与 `plac_ext` 模块导入 `call`、`pos`、`opt`、`flg` 等核心函数，导出 `Interpreter`、`TaskManager`、`Monitor`、`TkMonitor` 等类，并提供版本信息，使用户通过简单的 `import plac` 语句即可访问所有主要功能。`plac_core.py` 中应有 `call()` 函数，使用多种策略解析命令行参数并调用指定函数。`opt()` 函数作为可选参数装饰器（在 `test_plac.py` 中用于测试可选参数解析），`flg()` 函数作为标志参数装饰器（在 `test_plac.py` 中用于测试标志参数解析），`annotations()` 函数作为完整的注解装饰器（在 `test_plac.py` 中用于测试复杂参数注解），`parser_from()` 函数用于从函数创建解析器（在 `test_plac.py` 中用于创建测试解析器）。在 `plac.py` 下，需要通过 `import plac` 导入主模块以测试基础功能，并通过 `import plac_core` 直接访问核心函数以进行测试。核心类包括：`Interpreter` 作为提供 REPL 功能的交互式解释器类，`TaskManager` 作为管理长时间运行任务的任务管理类，`Monitor` 作为监控任务执行状态的任务监控类，`TkMonitor` 作为提供图形界面监控的 GUI 监控接口类，`ArgumentParser` 作为扩展参数解析器类，`Annotation` 作为存储参数元数据的类。

**考点**：用函数签名与注解反射自动生成 argparse 解析器，难点是 `pos`/`opt`/`flg` 三类参数到 argparse 动作的映射、`call()` 对函数/类/模块的统一调用与帮助回退，以及交互式解释器与多进程任务管理的接口边界。
