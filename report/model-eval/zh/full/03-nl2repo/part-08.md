# NL2Repo-Bench 全题规格中文翻译 · Part 8（第 55–58 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 55. `pss`（测试数 46）

**中文规格**

请创建一个名为 PSS（Python Source Search）的 Python 项目，实现一个智能源代码搜索工具。项目应包含以下功能：

1. **文件发现引擎**：实现一个递归文件搜索器，能够智能识别并过滤源代码文件。支持识别 40 种以上编程语言的文件类型（包括 Python、C++、Java、JavaScript、Go、Rust 等），并自动跳过版本控制目录（如 `.git` 与 `.svn`）、二进制文件、临时文件等。文件发现器应支持基于文件扩展名与文件名的模式匹配，并提供灵活的包含/排除规则配置。

2. **内容匹配引擎**：实现一个高性能内容搜索器，支持正则表达式匹配、字面量匹配、整词匹配、大小写敏感/不敏感匹配与反向匹配等多种搜索模式。匹配引擎应能在大型文件中快速搜索，并支持匹配数量上限、上下文显示等功能。

3. **输出格式化器**：实现彩色输出与结构化展示功能，包括高亮文件名、显示行号、高亮匹配内容与显示上下文。输出格式应支持终端模式与管道模式，并对搜索结果提供清晰的呈现。

4. **命令行接口**：设计完整的命令行参数解析系统，支持丰富的搜索选项（如 `--python`、`--cpp` 等文件类型过滤，`-i` 大小写不敏感，`-w` 整词匹配，`-v` 反向匹配等）。接口应提供详细的帮助信息与错误处理。

5. **核心 API 设计**：为每个功能模块设计独立的类接口与函数接口，包括 FileFinder（文件发现）、ContentMatcher（内容匹配）、OutputFormatter（输出格式化）、Driver（主控制器）等。每个模块应定义清晰的输入/输出格式与错误处理机制。

6. **跨平台兼容性**：确保工具在 Windows、Linux、macOS 等主流操作系统上正常运行，包括路径处理、文件编码与终端颜色支持。

7. **性能优化**：实现高效的搜索算法以支持在大型代码库中快速搜索，包括文件缓存与并行处理等优化策略。

上述功能需要组合起来构建完整的源代码搜索工具集。项目最终应包含文件发现、内容匹配、输出格式化等模块，并附带典型用法示例，形成可复现的搜索流程。该工具应能作为传统 grep 命令的增强替代方案，尤其适用于源代码项目中的高效文本搜索与代码分析。

6. **核心文件要求**：项目必须包含完整的 setup.py 文件，该文件不仅要把项目配置为可安装包（支持 pip install），还要声明完整依赖清单（包括 colorama 等核心库）。setup.py 文件应能验证所有功能模块是否正常工作。同时需要提供 psslib/__init__.py 作为统一 API 入口，从 driver 模块导入 pss_run 核心函数并提供版本信息，使用户通过简单的 "from psslib import pss_run" 语句即可访问主要功能。driver.py 中必须有 pss_run() 函数，用于协调文件发现、内容匹配与输出格式化等核心功能。该函数必须支持测试中使用的所有参数（roots、pattern、output_formatter、only_find_files、include_types、exclude_types、include_patterns、exclude_patterns、ignore_case、smart_case、invert_match、whole_words、literal_pattern、max_match_count 等）。filefinder.py 中必须实现 FileFinder 类及其 __init__() 构造函数与 files() 方法，支持测试中使用的所有参数（roots、recurse、ignore_dirs、find_only_text_files、search_extensions、ignore_extensions、search_patterns、ignore_patterns、filter_include_patterns、filter_exclude_patterns）。contentmatcher.py 中必须实现 ContentMatcher 类及其 __init__() 构造函数与 matcher() 方法，支持测试中使用的所有参数（pattern、ignore_case、invert_match、whole_words、literal_pattern、max_match_count），并且必须实现用于反向匹配的 inverted_matcher() 方法。matchresult.py 中必须实现 MatchResult，其中 MatchResult 派生自所导入的 namedtuple，其作用是接收 namedtuple 函数的值。outputformatter.py 中必须实现 OutputFormatter 抽象基类及其所有抽象方法（start_matches_in_file()、matching_line()、binary_file_matches()、found_filename()），以及 end_matches_in_file()、context_line()、context_separator() 等可选方法。defaultpssoutputformatter.py 中必须实现 DefaultPssOutputFormatter 类，继承 OutputFormatter 并提供默认的彩色输出实现。utils.py 中必须实现用于字节转字符串的 tostring() 函数、用于判断文件是否为文本文件的 istextfile() 函数，以及用于解码 colorama 颜色字符串的 decode_colorama_color() 函数。pss.py 中必须实现作为命令行入口的 main() 函数、用于解析命令行参数的 parse_cmdline() 函数，以及用于处理命令行选项的 PssOptionParser 类。所有这些类与函数必须与测试文件所使用的接口与行为完全兼容。

**考点**：用 `FileFinder`/`ContentMatcher`/`OutputFormatter`/`Driver` 四层拆分复刻 grep 式搜索器，难点是 `pss_run()` 的参数面覆盖（类型过滤、`smart_case`、反向匹配、上下文显示）与抽象输出格式化器的可插拔实现。

## 56. `pyautogui`（测试数 28）

**中文规格**

请创建一个名为 PyAutoGUI - Test 的 Python 脚本，用于对 PyAutoGUI 项目进行自动化测试。脚本应包含以下功能：

- 鼠标操作测试：自动测试所有与鼠标相关的函数，包括移动、点击、拖拽、滚动等。需要覆盖绝对坐标、相对坐标、动画效果与点击类型（单击、双击、右键单击）等各种参数，以验证坐标系、边界条件与动画平滑度。

- 键盘操作测试：测试键盘输入、按键模拟、组合键与热键等功能，包括文本输入、特殊按键、修饰键组合、输入间隔等，以确保字符编码、按键映射与输入速度控制正常工作。

- 屏幕截图与图像识别：测试屏幕截图、图像保存、图像查找与图像匹配等功能，包括全屏截图、区域截图、图像格式支持、相似度匹配与多显示器支持，以验证图像处理的准确性与性能。

- 消息框与用户交互：测试各种消息框类型（alert、confirm、prompt、password），包括按钮自定义、返回值处理与异常处理，以确保用户交互功能的完整性与可靠性。

- 坐标系与屏幕信息：测试屏幕尺寸获取、坐标转换、多显示器支持与坐标校验等功能，确保在不同分辨率与显示器配置下正常运行。

- 安全功能与异常处理：测试 fail-safe 机制、异常捕获、错误恢复、超时处理等，以确保自动化脚本的稳定性与安全性。

- 跨平台兼容性：测试不同操作系统（Windows、macOS、Linux）上的功能一致性，包括平台特定功能、依赖库兼容性与性能差异。

- 性能与稳定性：测试长时间运行、高频操作、资源占用、内存泄漏等，以确保生产环境中的稳定性。

- 测试客户端与测试用例结构：脚本需要引入 pytest 框架来模拟各种自动化场景，断言操作结果、响应时间、错误处理等。测试用例应覆盖所有核心功能模块、边界条件、异常情况与跨平台兼容性。

- 多模块与多平台支持：如果项目包含多个平台特定模块，脚本应能分别导入并测试各自的 API 接口与功能。

- 核心文件要求：项目必须包含完整的 setup.py 文件，需要把项目配置为可通过 pip install . 安装的标准 Python 包。应声明完整依赖清单，包括 pillow（图像处理支持）、pyscreeze（屏幕截图与图像识别）、pymsgbox（消息框交互）、pytweening（鼠标移动动画曲线）等核心库，以确保屏幕操作、输入模拟与图像识别等功能的依赖正常。setup.py 文件需要通过配置验证所有功能模块（如鼠标控制、键盘输入、屏幕截图、图像定位、异常处理等）的有效性，支持跨平台兼容处理（Windows、macOS、Linux），并确保鼠标移动（moveTo、moveRel）、点击操作（click、rightClick）与键盘输入（typewrite、hotkey）等核心功能在不同系统上一致运行。同时需要提供 pyautogui/__init__.py 作为统一 API 入口。该文件需要整合核心模块的关键组件：导出 moveTo、moveRel、position 等鼠标控制函数；click、rightClick、doubleClick、tripleClick 等点击操作函数；dragTo、dragRel 等拖拽函数；以及 mouseDown、mouseUp 等底层鼠标事件函数；从 keyboard 模块导出 typewrite、press、keyDown、keyUp、hold、hotkey 等输入函数，以及 isShiftCharacter、isValidKey 等辅助工具；从屏幕处理模块导出 size、onScreen、pixel、pixelMatchesColor、screenshot 等屏幕信息函数；从图像定位模块导出 locate、locateAll、locateOnScreen、locateAllOnScreen、locateCenterOnScreen、center 等图像识别函数；从动画曲线模块导出 linear、easeInQuad、easeOutQuad、easeInOutQuad 等 21 种鼠标移动动画函数；从异常处理模块导出 PyAutoGUIException、FailSafeException、ImageNotFoundException 等异常类；此外导出 FAILSAFE、PAUSE 等全局配置常量与 Point 坐标类，并通过 __version__ 提供版本信息。确保用户通过简单的 import pyautogui 语句即可访问所有主要功能，既支持 pyautogui.moveTo(100, 200) 等基本操作，也支持 pyautogui.locateOnScreen('button.png') 等高级图像识别功能。命令行工具通过 pyautogui 命令提供（入口点为 pyautogui.__main__:main），支持在终端中直接调用核心功能（如屏幕截图、鼠标与键盘模拟）。项目结构需要包含一个自动化测试模块，覆盖鼠标、键盘与图像识别等功能的单元测试与集成测试，并支持跨平台部署（适配不同系统的输入设备驱动与屏幕分辨率）。所有功能模块都需要通过标准 Python 导入路径访问，并兼容 Python 2.7 与 Python 3.x 版本。具体依赖版本限制、开发环境配置（如虚拟环境要求）与测试命令详见 setup.py 文档。

**考点**：为 GUI 自动化库构建可断言的操作级测试矩阵，难点是把不可控的屏幕与输入设备行为抽象成可重复的坐标、动画与异常路径断言，同时兼顾多平台模块分别导入测试。

## 57. `pyjwt`（测试数 299）

**中文规格**

请创建一个名为 PyJWT 的 Python 项目，实现一个生成与校验 JSON Web Token（JWT）的库。项目应包含以下功能：

1. JWT 生成器：能够创建符合 RFC 7519 规范的 JWT 令牌，支持标准声明（如过期时间、签发者）与自定义声明的设置。

2. JWT 校验器：能够校验 JWT 令牌的签名与声明，包括检查令牌是否过期、签发者是否匹配等。

3. 多算法支持：实现多种加密算法，包括对称算法（如 HS256、HS384、HS512）与非对称算法（如 RS256、RS384、RS512、ES256、ES384、ES512、EdDSA）。

4. 接口设计：为每个功能模块设计清晰的 API，支持简单的函数调用（如 `jwt.encode()` 与 `jwt.decode()`）与面向对象用法。

5. 错误处理：提供详细的异常类，用于精确捕获校验过程中的各种问题（如令牌过期、签名无效等）。

6. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，需要把项目配置为可安装包（支持 `pip install`）并声明完整依赖清单（如 `cryptography >= 3.4.0`、`pytest >= 7.0.0`、`coverage[toml]==5.0.4` 等实际使用的核心库）。`pyproject.toml` 应确保所有核心功能模块正常工作。同时需要提供 `jwt/__init__.py` 作为统一 API 入口，导入并导出 `DecodeError`、`ExpiredSignatureError`、`ImmatureSignatureError`、`InvalidAlgorithmError`、`InvalidAudienceError`、`InvalidIssuedAtError`、`InvalidIssuerError`、`InvalidJTIError`、`InvalidKeyError`、`InvalidSignatureError`、`InvalidSubjectError`、`InvalidTokenError`、`MissingCryptographyError`、`MissingRequiredClaimError`、`PyJWKClientConnectionError`、`PyJWKClientError`、`PyJWKError`、`PyJWKSetError`、`RSAAlgorithm`、`ECAlgorithm`、`OKPAlgorithm` 以及主要导入导出函数，并提供版本信息，使用户通过简单的 `"from jwt.algorithms/exceptions/api_jwk/utils/warnings import *"` 语句即可访问所有主要功能。

**考点**：覆盖 JWT 编解码、验签与声明校验的全部失败分支（过期、受众、签发者、算法不符、密钥缺失），难点是 RS/ES/EdDSA 多算法后端与 JWK/JWK Set 解析在同一 API 下统一抽象。

## 58. `pylama`（测试数 34）

**中文规格**

请创建一个名为 Pylama 的 Python 项目，实现一个代码质量审计工具。项目应包含以下功能：

1. 多 Linter 集成引擎：能够集中管理与调用多个 Python 代码检查工具，包括 pycodestyle（PEP8 风格检查）、pyflakes（静态代码分析）、mccabe（复杂度计算）、pydocstyle（文档字符串检查）、pylint（综合静态分析）、mypy（类型检查）、isort（导入排序检查）、eradicate（死代码检测）等。每个 Linter 应实现统一的接口规范。

2. 配置管理系统：实现强大的配置系统，支持多种配置文件格式（INI、TOML、setup.cfg 等），以及全局配置、特定文件配置、特定 Linter 配置等分层配置管理。配置系统应支持命令行参数覆盖、环境变量集成与配置文件自动发现。

3. 文件扫描与过滤：实现递归目录扫描功能，支持文件类型过滤、路径模式匹配与忽略规则处理。应支持从 stdin 读取代码、单文件检查与批量目录检查。

4. 错误报告与格式化：提供多种输出格式（pydocstyle、pycodestyle、pylint、parsable、json 等），并支持错误分类、严重级别排序与绝对路径输出。错误报告应包含文件名、行号、列号、错误类型与描述。

5. 异步处理与性能优化：实现并发文件检查机制并支持异步模式，以提升大型项目的检查效率。应包含内存优化、缓存机制与性能监控功能。

6. 核心文件要求：项目必须包含完整的 setup.py 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整依赖清单（包括 pycodestyle>=2.8.0、pyflakes>=2.4.0、mccabe>=0.6.1、pydocstyle>=6.1.1 等核心库）。配置文件应能验证所有功能模块是否正常工作。同时需要提供 `pylama/__init__.py` 作为统一 API 入口，导入并导出 `Namespace`、`DEFAULT_SECTION`、`get_config`、`Error`、`remove_duplicates`、`check_async`、`shell`、`check_paths`、`LINTERS`、`run`、`git_hook` 以及主要导入导出函数，并提供版本信息，使用户通过简单的 `from pylama.** import **` 或 `from pylama import **` 语句即可访问所有主要功能。

**考点**：用统一 Linter 适配层聚合 pycodestyle/pyflakes/mccabe/pydocstyle/pylint/mypy 等异构检查器，难点是分层配置解析（INI/TOML/setup.cfg 叠加命令行覆盖）与多格式错误输出的统一建模。
