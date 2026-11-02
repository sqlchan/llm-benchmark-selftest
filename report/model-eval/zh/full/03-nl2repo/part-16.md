# NL2Repo-Bench 全题规格中文翻译 · Part 16（第 95–99 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 95. `typing_extensions`（测试数 535）

**中文规格**

请创建一个名为 Typing-Extensions 的 Python 项目，实现一个 Python 类型系统扩展库。项目应包含以下功能：

1. 核心类型系统模块：把较新 Python 版本的类型标注特性提供给较旧版本，包括回移新的类型特性（如 TypeGuard、Self、Literal、TypedDict、Protocol 等）并支持实验性类型系统。所有类型构造都应是 Python 标准库 typing 模块的扩展，并与 mypy、pyright 等静态类型检查器完全兼容。

2. 类型构造实现：实现一整套类型系统构造，包括基础类型（Any、ClassVar、Final、Literal 等）、高级类型系统（Protocol、TypedDict、TypeGuard 等）、工具函数（get_args、get_origin、get_type_hints 等）以及实验性特性（支持 PEP 提案中的新类型系统概念）。

3. 向后兼容支持：把最新的类型标注特性回移到 Python 3.9+ 版本，确保与既有代码无缝集成。应支持语义化版本，以保证 API 稳定，并做到零运行时开销（所有功能都在类型层面）。

4. 接口设计：为每个功能模块设计独立的类型构造与工具函数接口，以支持与静态类型检查器的完整集成。每个模块都应定义清晰的类型注解和 docstring，并提供丰富的类型系统工具函数。

5. 示例与使用指南：提供示例代码和使用说明，演示如何通过导入 typing_extensions 模块来使用新特性（例如 `from typing_extensions import TypeGuard, Self, Literal` 等），以及如何通过静态类型检查器获得与原生 typing 模块相同的类型检查支持。上述功能需要组合起来构建一个完整的 Python 类型系统扩展工具包。最终项目应包含类型构造、工具函数、向后兼容支持等模块，并配有典型使用示例，形成一套可复现的类型系统扩展流程。

6. 核心文件要求：项目必须包含配置完善的 `pyproject.toml` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `python>=3.9`、`flit_core>=3.11,<4`、`ruff==0.12.3`、`pre-commit==5.0.0`、`sphinx-lint==1.0.0` 等核心库）。`pyproject.toml` 文件应能验证所有功能模块是否正常工作。此外，应提供 `src/typing_extensions.py` 作为统一 API 入口，导出 `_FORWARD_REF_HAS_CLASS`、Annotated、Any、AnyStr、AsyncContextManager、AsyncIterator、Awaitable、Buffer、Callable、ClassVar、Concatenate、Dict、Doc、Final、Format、Generic、IntVar、Iterable、Iterator、List、Literal、LiteralString、NamedTuple、Never、NewType、NoDefault 等类型构造与工具函数，并提供版本信息，使用户通过简单的 `from typing_extensions import *` 语句即可访问所有主要功能。在 `typing_extensions.py` 中应提供完整的类型系统实现，包括全部回移的类型构造与实验性函数。

**考点**：核心是把新版类型系统的构造与工具函数回移到 Python 3.9+，难点在于同一份 `typing_extensions.py` 既要按运行时版本做条件降级、又要让 mypy/pyright 在类型层面看到与原生 typing 一致的语义，同时保持零运行时开销与语义化版本承诺。

## 96. `uiautomator`（测试数 101）

**中文规格**

请创建一个名为 uiautomator 的 Python 项目，实现一个 Android UI 自动化测试库。项目应包含以下功能：

1. **设备连接管理**：通过 ADB 与 Android 设备建立连接，支持多设备管理与远程设备连接。提供指定设备序列号、配置 ADB 服务器等功能，保证设备通信稳定。

2. **UI 元素定位系统**：实现强大的 UI 元素选择器，支持文本匹配、resource ID、类名、描述等多种定位方式。支持层级关系查询（父子元素、兄弟元素）、相对位置定位以及元素存在性检查。

3. **手势操作模拟**：提供一整套触摸操作 API，包括单击、长按、滑动、拖拽、多点触控等。支持精确的坐标操作与基于元素的操作，以及链式手势调用。

4. **设备控制功能**：实现基础设备控制，包括亮屏/熄屏、按键模拟、方向控制与截图功能。支持设备信息获取、应用包管理、通知栏操作等系统级功能。

5. **智能等待机制**：提供元素等待、界面刷新等待、空闲等待等功能，保证测试脚本的稳定性。支持超时设置、条件等待与自定义等待策略。

6. **测试辅助功能**：包含窗口层级导出、元素信息获取、测试报告生成等。提供调试工具与错误处理机制，便于定位问题与维护脚本。

7. **核心文件要求**：项目必须包含完整的 `setup.py` 文件，把项目配置为可通过 `pip install` 安装的标准 Python 包。声明完整的依赖清单，包括 `urllib3>=1.7.1`（用于网络请求支持）、`mock>=1.0.1`（用于测试模拟）、`nose>=1.0`（测试框架）、`coverage>=3.6`（代码覆盖率分析）等核心库，以保证设备通信、RPC 调用与测试验证等功能的正常依赖。`setup.py` 文件应通过配置验证所有功能模块（如设备连接、UI 元素定位、操作执行、错误处理等）的有效性，支持通过测试命令触发全功能验证，覆盖设备连接、元素选择、事件触发等核心场景。同时提供 `uiautomator/__init__.py` 作为统一 API 入口。该文件应整合各核心模块的关键组件：从设备通信模块导入 `AutomatorDevice`（设备操作核心类，对外导出为 Device）、`Adb`（ADB 工具类）和 `AutomatorServer`（自动化测试服务器）；从 selector 模块导入 `Selector`（UI 元素选择器）；从 RPC 通信模块导入 `JsonRPCClient`（JSON-RPC 客户端）、`JsonRPCMethod`（RPC 方法装饰器）和 `JsonRPCError`（RPC 错误类）；从对象-元素交互模块导入 `AutomatorDeviceObject`（设备对象基类）和 `AutomatorDeviceNamedUiObject`（具名 UI 元素对象）；从工具模块导入 `param_to_property`（把参数转换为属性的工具）；此外定义 `device` 实例（`AutomatorDevice` 的默认实例），并通过 `__version__` 提供版本信息，确保用户通过简单的 `from uiautomator import *` 语句即可访问所有主要功能，同时支持 `d(text="OK").click()` 这类元素操作与 `d.screen.on()` 这类设备控制，从而简化从设备连接到 UI 交互的整个流程。

**考点**：把 ADB + 设备端 uiautomator JSON-RPC 服务封装成 Pythonic 的链式 API，难点是 Selector 的多条件定位与父子/兄弟查询、设备对象与具名 UI 对象的层叠抽象，以及点击/滑动等手势在坐标与元素两种入参下的统一调度。

## 97. `unidecode`（测试数 65）

**中文规格**

请创建一个名为 `Unidecode` 的 Python 项目，实现一个把 Unicode 文本无损降级为 ASCII 的音译工具库。项目应包含以下功能：

1. Unicode 到 ASCII 音译（核心功能）：提供 `unidecode()`、`unidecode_expect_ascii()` 与 `unidecode_expect_nonascii()` 等函数，把含非 ASCII 字符的 Unicode 字符串音译为最接近的 ASCII 字符串。支持多种错误处理策略（如 ignore、strict、replace、preserve），并允许自定义未映射字符的替换方式。对西方语言字符音译效果良好，对远离拉丁字母的文字（如中文、日文、韩文）只做简单的字符映射。

2. 命令行工具支持：提供命令行工具，可通过 `unidecode` 命令在终端中直接对文件、标准输入或命令行参数中的文本进行音译。支持指定输入文件、直接传入字符串、指定输入编码（如 utf-8、sjis 等），并支持 base64 编码输入，以兼容 Windows 上特殊字符的传输。对错误输入给出清晰的错误提示。

3. API 设计与兼容性：主 API 入口为 `unidecode/__init__.py`，导出核心音译函数与异常类 `UnidecodeError`。支持 Python 3.7 及以上版本，具备完整的类型注解，并包含 `py.typed` 文件以支持类型检查工具。

4. 音译表与模块结构：使用按块划分的字符映射表（如 `x000.py`、`x001.py` 等）。每个模块负责一部分 Unicode 块的音译映射，并在需要时动态加载，以提升性能与可维护性。通过缓存机制优化音译表的加载效率。

5. 异常与告警处理：对无法映射的字符、代理对、私有区字符等给出合理的告警或异常，便于开发者定位问题。支持对无法映射字符的自定义处理方式（如替换、保留、报错等）。

6. 测试系统：提供全面的单元测试，覆盖核心音译逻辑、命令行工具、异常处理、特殊字符处理等。测试用例包括对常见西方语言、希腊文、俄文、日文、中文等多语言字符音译效果的验证，以及对错误处理分支的覆盖。支持 doctest，自动验证 README 文档中的示例代码。

7. 打包与安装：项目包含完整的 `setup.py`，支持 pip 安装，声明 Python 版本要求与类型注解支持。提供 `console_scripts` 入口，使 `unidecode` 命令在安装后可直接使用。包含 `unidecode/py.typed` 文件以支持类型检查工具。

8. 示例与用法演示：README 与测试用例提供丰富的示例，演示如何通过 API 与命令行工具完成 Unicode 到 ASCII 的音译。示例包括多语言的调用方式、特殊符号以及不同错误处理策略。

9. 测试 Python 文件的设计建议：测试 `unidecode()`、`unidecode_expect_ascii()` 与 `unidecode_expect_nonascii()` 的基础功能及所有错误处理分支。测试命令行工具的文件输入、标准输入、命令行参数输入、不同编码与 base64 输入等场景。测试异常与告警的触发与处理。覆盖多语言、多区块字符的音译效果。测试类型注解与 API 兼容性。可参考 `tests/` 目录中的单元测试与 doctest 设计测试用例。

10. 核心文件要求：项目必须包含完整的 `setup.py` 文件，把项目配置为可安装包（支持 `pip install`），并声明完整的依赖清单（如 `setuptools>=40.0.0`、`typing-extensions>=3.7.4`、`pytest>=6.0.0`、`tox>=3.20.0` 等实际使用的核心库）。`setup.py` 应保证所有核心功能模块都能正常工作。项目需要包含 `unidecode/__init__.py` 作为统一 API 入口，导出 `unidecode`、`unidecode_expect_ascii`、`unidecode_expect_nonascii` 与 `UnidecodeError` 等核心函数和类，使用户通过简单的 `from unidecode import *` 语句即可访问所有主要功能。

**考点**：按 Unicode 块切分的映射表加按需动态导入与缓存，是性能与体积的关键；难点是三种音译入口在 ASCII/非 ASCII 预期下的行为差异、ignore/strict/replace/preserve 策略与代理对、私有区字符的告警边界，以及命令行工具对文件、stdin、参数字符串与 base64 输入的统一处理。

## 98. `unittest-parametrize`（测试数 26）

**中文规格**

请创建一个名为 unittest-parametrize 的 Python 项目，实现一个 unittest 测试参数化库。项目应包含以下功能：

1. 参数化装饰器：应能通过 `@parametrize` 装饰器对 unittest 测试方法进行参数化，支持多种参数名定义方式（字符串形式如 `"x,expected"`，元组形式如 `("x", "expected")`）。该装饰器应自动生成多个独立的测试方法，每个方法对应一组参数值。

2. 基础测试类：实现 `ParametrizedTestCase` 基类，它继承自 `unittest.TestCase`。利用 Python 的 `__init_subclass__` 机制，在类定义时自动处理参数化的测试方法。该基类应与现有 unittest 测试框架完全兼容，并支持 Django tests、pytest 等多种测试运行器。

3. 高级参数配置：提供 `param` 对象用于高级参数配置，支持自定义测试 ID 与参数值包装等功能。实现对 `ids` 参数的支持，允许用户为每组参数指定自定义的测试名后缀，提升测试可读性与调试便利性。

4. 同步与异步支持：完整支持同步与异步测试方法的参数化，正确处理由 `async def` 定义的测试方法，确保参数化的异步测试能够正常运行。

5. 错误处理与校验：实现全面的参数校验机制，包括检查参数数量、校验参数类型、检测重复 ID 以及检查装饰器叠加。提供清晰的错误信息，帮助开发者快速定位问题。

6. 接口设计：项目必须包含完整的 `pyproject.toml` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `pytest==8.4.0`、`pytest-randomly==3.16.0`、`typing-extensions==4.14.0`、`tomli==2.2.1`、`pygments==2.19.1`、`pluggy==1.6.0`、`packaging==25.0.0`、`iniconfig==2.1.0`、`importlib-metadata==8.7.0`、`exceptiongroup==1.3.0`、`colorama==0.4.6`、`coverage>=7.8.2` 等核心库）。`setup.py` 文件应能验证所有功能模块是否正常工作。同时需要提供 `unittest_parametrize/__init__.py` 作为统一 API 入口，导出 `parametrize` 装饰器、`ParametrizedTestCase` 基类、`param` 参数对象等核心组件，并提供版本信息，使用户通过简单的 `from unittest_parametrize import parametrize, ParametrizedTestCase, param` 语句即可访问所有主要功能。

7. 示例与测试脚本：提供示例代码与测试用例，演示如何使用 `@parametrize` 装饰器与 `ParametrizedTestCase` 基类进行测试参数化（例如 `@parametrize("x,expected", [(1,1), (2,4), (3,9)])` 应能生成三个独立的测试方法：`test_square_0`、`test_square_1` 与 `test_square_2`）。

**考点**：在类定义期用 `__init_subclass__` 把被装饰的方法展开成多个带自动后缀的测试方法，难点是参数名两种写法（字符串/元组）的归一化、`ids` 与 `param` 的组合语义、async 测试在 unittest 运行器下的正确调度，以及参数数量、重复 ID、装饰器叠加等错误的早期校验。

## 99. `verifiers`（测试数 171）

**中文规格**

请创建一个名为 Verifiers 的 Python 项目，实现一个可验证的多轮 LLM 强化学习训练与评测库。项目应包含以下特性：

1. **解析器与消息处理**
    - **基础文本解析器**：能够从输入字符串或对话消息中抽取关键信息，支持纯文本、结构化 XML 以及逐步推理格式（例如 `<think>...</think>` 标签）。
    - **XML 解析器**：支持解析多字段、字段别名、字段缺失等复杂结构的 XML 格式，并输出结构化对象。
    - **逐步推理解析器**：支持抽取带 `<think>` 标签的推理内容，并允许为多步推理场景自定义抽取函数。

2. **奖励函数与评测机制**
    - **奖励函数 Rubric**：支持自定义奖励函数的注册、加权组合与异步调用，从而对模型输出进行灵活打分。
    - **奖励组 RubricGroup**：支持多个 Rubric 的聚合与批量打分，适用于多维度、多准则的评测场景。

3. **环境与多轮对话**
    - **单轮环境 SingleTurnEnv**：支持单轮问答、chat/completion 两种格式、异步生成与状态管理，适用于基础 RL 训练与评测。
    - **多轮环境 MultiTurnEnv**：支持多轮对话、最大轮数限制与状态管理，适用于复杂的交互式 RL 训练。
    - **分组环境 EnvGroup**：支持多环境分组、分组奖励与批量 rollout，便于多任务、多场景的联合训练与评测。

4. **Mock 测试与数据集支持**
    - **MockAsyncOpenAI**：提供可控的输入-输出映射，同时支持 chat 与 completion 两种模式，便于在没有 API key 的情况下做单元测试。
    - **数据集支持**：支持 HuggingFace datasets 格式，便于批量数据加载与评测。

5. **典型测试用例与评测脚本**
    - 提供丰富的测试用例，覆盖解析器、奖励函数、单/多轮环境、分组环境等所有核心功能，并同时支持异步与同步测试方式。
    - 支持使用 pytest、pytest-asyncio、pytest-cov 等工具进行自动化测试与覆盖率统计。

6. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件，声明所有依赖（例如 transformers、datasets、pytest、pytest-asyncio、pytest-cov、openai、deepspeed 等），并支持通过 `pip install -e .[all]` 一键安装全部功能。提供 `verifiers/__init__.py` 作为统一 API 入口，导出 `Parser`、`XMLParser`、`ThinkParser`、`Environment`、`SingleTurnEnv`、`MultiTurnEnv`、`Rubric`、`RubricGroup`、`EnvGroup` 等核心类，使用户通过 `from verifiers import Parser, Rubric, SingleTurnEnv` 等语句即可访问所有主要功能。`verifiers/envs/`、`verifiers/rubrics/`、`verifiers/parsers/` 等子模块分别实现环境、奖励与解析等功能，结构清晰、便于扩展。`tests/` 目录应包含 `test_parser.py`、`test_xml_parser.py`、`test_think_parser.py`、`test_rubric.py`、`test_rubric_group.py`、`test_singleturn_env.py`、`test_multiturn_env.py`、`test_env_group.py` 等测试文件，覆盖所有核心功能点。提供 `mock_openai_client.py`，其中包含 `MockAsyncOpenAI` 类，支持输入-输出映射，以便在没有 API key 的情况下测试。所有核心模块都应具备清晰的类/函数接口，支持直接导入使用，并提供详尽的 docstring 说明输入输出格式与数据类型。此外，提供典型用例与评测脚本，演示如何使用 `Parser`、`Rubric`、`SingleTurnEnv` 等类完成解析、奖励计算、环境交互与评测。

**考点**：围绕「解析器 → 奖励函数 → 环境 rollout」三段式搭建可验证的 RL 训练/评测闭环，难点是 XML 与 `<think>` 推理格式的结构化解析、Rubric/RubricGroup 的加权聚合与异步打分，以及单轮/多轮/分组环境在无 API key 的 MockAsyncOpenAI 下仍可按同一接口批量评测。
