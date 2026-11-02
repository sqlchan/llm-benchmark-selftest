# NL2Repo-Bench 全题规格中文翻译 · Part 3（第 33–38 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 33. `fuzzywuzzy`（测试数 71）

**中文规格**

请创建一个名为 FuzzyWuzzy 的 Python 项目，实现一个模糊字符串匹配库。项目应包含以下功能：

1. 基础相似度计算器：计算两个字符串之间的相似度分数，支持多种算法（如 `ratio`、`partial_ratio`、`token_sort_ratio`、`token_set_ratio` 等）。计算结果应为 0 到 100 之间的整数分数，表示相似度百分比。

2. 批量匹配处理：实现在一组候选字符串中查找最佳匹配的函数，包括单个最佳匹配与多个匹配结果。应同时支持列表与字典两种数据结构，以及自定义评分函数与预处理器。

3. 文本预处理功能：对输入字符串做标准化，包括移除非字母数字字符、转换大小写、移除空格等。支持强制 ASCII 转换与 Unicode 处理，以保证匹配算法的稳定性。

4. 接口设计：为每个功能模块（如基础匹配、批量处理、文本预处理等）设计独立的函数接口，支持灵活的参数配置。每个模块应定义清晰的输入输出格式与评分标准。

5. 示例与评测脚本：提供示例代码与测试用例，演示如何使用 `fuzz.ratio()` 与 `process.extractOne()` 进行字符串相似度计算与最佳匹配查找（例如 `process.extractOne("new york mets", choices)` 应返回最相似的字符串及其分数）。上述功能需要组合起来，构建成完整的模糊匹配工具箱。项目最终应包含相似度计算、批量处理、文本预处理等模块，以及典型测试用例，形成可复现的匹配流程。

6. 核心文件要求：项目必须包含完整的 `setup.py` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `python-Levenshtein>=0.12`、`pytest>=8.0.0`、`hypothesis>=6.0.0`、`pycodestyle>=2.0.0` 等可选性能库）。`setup.py` 文件应能验证所有功能模块是否正常工作。同时需要提供 `fuzzywuzzy/__init__.py` 作为统一 API 入口，导出 `fuzz`、`process`、`utils`、`StringProcessor` 以及主要的导入导出函数，并提供版本信息，使用户通过简单的 `from fuzzywuzzy import **` 语句即可访问所有主要功能。

**考点**：把多种相似度算法统一成 0–100 整数分数、并在列表与字典候选集上按可替换的 scorer / processor 批量择优，难点是大小写、非字母数字与词序差异的归一化。

## 34. `gitingest`（测试数 133）

**中文规格**

请创建一个名为 GitIngest 的 Python 项目，实现一个自动化的代码仓库分析工具。项目应包含以下功能：

1. 仓库克隆器：应能从多种 Git 平台（GitHub、GitLab、Bitbucket 等）克隆代码仓库，支持指定分支、commit 哈希与子路径。克隆结果应为本地文件系统路径，并应支持私有仓库的 Token 认证。

2. 文件系统扫描器：实现扫描本地目录或已克隆仓库、提取文件内容并生成结构化摘要的功能。应支持文件大小上限、包含/排除模式过滤、多种文件格式处理，以及 Gitignore 规则的应用。

3. 内容提取器：专门处理不同类型的文件，包括普通文本文件、Jupyter Notebook 转换，以及跳过二进制文件。应支持 Notebook 中代码 / markdown / raw 单元格的转换，以及大文件的智能截断。

4. 接口设计：为每个功能模块（如克隆、扫描、提取、转换等）设计独立的命令行接口与 Web API 接口，支持 CLI 调用与 Web 服务。每个模块应定义清晰的输入输出格式。

5. 示例与测试脚本：提供示例代码与测试用例，演示如何使用 `ingest_query()` 函数进行仓库分析与内容提取（例如 `ingest_query(local_path="./", max_file_size = 1000000, ignore_patterns="tests/")` 应返回结构化摘要）。上述功能需要组合起来，构建成完整的代码仓库分析工具箱。项目最终应包含克隆、扫描、提取、转换等模块，以及典型测试用例，形成可复现的分析流程。

6. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，需要把项目配置为可安装包（支持 `pip install`），准确声明完整的依赖清单（涵盖 `click`、`fastapi`、`pathspec`、`pydantic`、`python-dotenv`、`tiktoken`、`uvicorn` 等核心运行时依赖，以及 `pytest`、`coverage` 等开发依赖），并通过 **project.optional-dependencies** 分组管理测试、文档与开发工具等扩展依赖。`pyproject.toml` 需要配置完整的构建系统（build-system）与项目元数据（project），确保所有开发环境依赖都能通过 `pip install -e .[dev]` 安装，并支持用 pytest 进行全面的功能测试验证。同时需要提供 `src/gitingest/__init__.py` 作为统一 API 入口。该文件需要从 cloning、ingestion、notebook_utils 等模块导入核心函数，导出 `IngestionQuery`、`CloneConfig` 等配置类，并通过 `__version__` 变量提供符合语义化版本规范的版本信息。API 设计应遵循最小惊讶原则，确保用户通过简单的 `from gitingest import ingest_query, clone_repo` 语句即可访问所有主要功能，同时隐藏内部实现细节。在 `server/main.py` 中，需要实现符合 FastAPI 规范的 `process_query()` 函数。该函数需要处理 Web 请求参数校验、认证与授权、异步任务调度，并调用 `ingest_query` 等核心函数执行仓库分析，最终返回结构化的 JSON 响应。函数应包含完整的异常处理机制，能够捕获并返回 `InvalidGitHubTokenError`、`AsyncTimeoutError` 等自定义异常，并提供符合 OpenAPI 规范的接口文档。

**考点**：把"克隆 → 目录遍历 → 按 gitignore/大小/后缀过滤 → 按格式提取"串成一条可复现流水线，难点是 Notebook 单元格与二进制文件的差异化处理以及 CLI / FastAPI 双入口共用同一核心。

## 35. `google-images-download`（测试数 30）

**中文规格**

请创建一个名为 Google Images Download 的 Python 项目，实现一个图片搜索与下载库。项目应包含以下功能：

1. 参数解析器：能够从命令行参数或配置文件中提取并解析下载参数，支持关键词搜索（如 "cat"、"sunset" 等）与批量关键词处理。解析结果应为一个可执行的下载任务配置对象。

2. 网络请求处理：实现处理 HTTP 请求与 Selenium 自动化的函数（或脚本），包括 User-Agent 伪装、SSL 证书处理、反爬机制等。应支持 Python 2.x 与 3.x 版本的兼容性，以及 Chrome WebDriver 的自动化操作。

3. 图片搜索与过滤：对颜色、尺寸、类型、时间、使用权限等做专门处理，如筛选红色图片、筛选大尺寸图片、过滤照片类型等。支持相似图片搜索与指定站点搜索功能。

4. 接口设计：为每个功能模块（如参数解析、网络请求、图片下载、文件管理等）设计独立的命令行接口或函数接口，支持终端调用测试。每个模块应定义清晰的输入输出格式。

5. 示例与评测脚本：提供示例代码与测试用例，演示如何使用 `download()` 与 `download_executor()` 函数进行参数解析与图片下载（例如 `download({"keywords": "cat", "limit": 5})` 应返回下载结果）。上述功能需要组合起来，构建成完整的图片下载工具箱。最终项目应包含解析、搜索、下载与管理等模块，以及典型测试用例，形成可复现的下载流程。

6. 核心文件要求：项目必须包含完整的 `setup.py` 文件，需要把项目配置为可通过 `pip` 安装的包。同时应声明完整的依赖清单（包括 `selenium`、`urllib3`、`requests` 等核心库），并能够验证所有功能模块是否正常工作。在 API 入口设计上，应使用 `google_images_download/__init__.py` 作为统一入口。从 `google_images_download` 子模块（即 `google_images_download.py`）导入核心函数 `download` 与 `download_executor`，导出 `DownloadConfig`、`SearchConfig`、`FilterConfig` 等配置类，并提供版本信息，确保用户通过 `from google_images_download import download` 这样的简单语句即可访问所有主要功能，且与 `from google_images_download import google_images_download` 的导入逻辑兼容。此外，`google_images_download.py` 文件应包含 `download_page()` 函数，通过多种策略处理网页请求与图片提取，以保证核心功能的实现。

**考点**：把关键词 / 过滤条件解析成配置对象后驱动"请求页面—用多套正则策略抽取图片 URL—限数下载"，难点是反爬与页面结构变动下的鲁棒提取，以及 `__init__.py` 与同名子模块的导入兼容。

## 36. `graphneuralnetwork`（测试数 4）

**中文规格**

请创建一个名为 GraphNeuralNetwork 的 Python 项目，实现一个图神经网络（GNN）算法库。项目应包含以下特性：

1. **图神经网络模型实现**：实现三种经典的图神经网络算法，包括 GCN（Graph Convolutional Network，图卷积网络）、GraphSAGE 与 GAT（Graph Attention Network，图注意力网络）。每个模型都应包含完整的网络架构定义、前向传播逻辑与训练接口，支持自定义隐藏层维度、激活函数、dropout 率等超参数配置。

2. **数据处理模块**：实现图数据的加载、预处理与标准化功能，支持 Cora 等标准图数据集。应包含邻接矩阵预处理、特征矩阵归一化、训练 / 验证 / 测试集划分等核心函数。数据处理应支持稀疏矩阵格式，以提升大规模图数据的处理效率。

3. **模型训练与评估**：实现完整的训练流程，包括损失函数计算、优化器配置、早停机制与模型检查点保存。评估模块应支持多种指标（如分类准确率、加权交叉熵等），并提供训练过程的可视化功能。

4. **工具函数库**：提供与图操作相关的工具函数，如邻居采样、图遍历、特征聚合。这些函数应支持不同的聚合策略（如 mean、sum、max 等），并能够处理有向图与无向图。

5. **接口设计**：为每个功能模块设计清晰的 API 接口，支持简单的模型创建、训练与预测调用。每个模块应定义清晰的输入输出格式，并提供详细文档。

6. **测试与示例**：提供完整的测试用例与示例代码，演示如何使用不同的 GNN 模型完成图节点分类任务。测试应覆盖模型创建、数据加载、训练过程、结果评估等关键环节。

7. **核心文件要求**：项目必须包含完整的 `setup.py` 文件，不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `tensorflow>=1.12.0`、`networkx`、`numpy`、`scipy`、`pytest` 等核心库）。`setup.py` 文件应能验证所有功能模块是否正常工作。同时需要提供 `gnn/__init__.py` 作为统一 API 入口，从 `gcn`、`gat`、`graphsage` 模块导入相应的模型类，并提供版本信息，使用户通过简单的 `from gnn.** import GCN, GAT, GraphSAGE` 语句即可访问所有主要功能。在 `utils.py` 中，应提供 `load_data_v1()` 函数用于加载并预处理图数据，以及 `preprocess_adj()` 函数用于标准化邻接矩阵。

**考点**：在 TensorFlow 1.x 静态图风格下复现 GCN / GraphSAGE / GAT 三种聚合公式，难点是邻接矩阵归一化（含自环）与稀疏格式下的稀疏矩阵乘法保持一致。

## 37. `humanize`（测试数 607）

**中文规格**

请创建一个名为 Humanize 的 Python 项目，实现一个数据人性化展示库。该项目应包含以下功能：

1. 数字人性化模块：能够把数字转换为人类可读的格式，包括千位分隔符（如 `1,234,567`）、词形表示（如 `1.2 million`）、序数（如 `1st`、`2nd`、`3rd`）、分数表示（如 `1/3`）、科学计数法（如 `3.00 x 10²`）等。应支持大数字的自动转换与格式化。

2. 时间人性化模块：实现把时间差转换为自然语言描述的函数，包括相对时间（如 "3 minutes ago"、"2 hours ago"、"yesterday"、"tomorrow"）、精确时间差（如 "2 days, 1 hour, and 33 seconds"）、自然日期（如 "today"、"yesterday"、"Jun 05"）等。应支持不同时间单位的智能选择与本地化。

3. 文件大小人性化模块：把字节数转换为人类可读的文件大小格式，支持十进制（如 `1.5 MB`）与二进制（如 `1.5 MiB`）表示，以及 GNU 风格（如 `2.9K`）格式。应支持从字节到 QB（quettabyte）的完整范围。

4. 列表人性化模块：把数组转换为自然语言列表，自动添加逗号与连词 "and"（如 "apples, bananas, and oranges"）。应支持不同长度列表的智能处理。

5. 国际化支持：提供多语言本地化支持，包括阿拉伯语、中文、英语、法语、德语、日语、韩语等 30 多种语言。应支持运行时语言切换与自定义翻译路径。

6. 接口设计：为每个功能模块设计独立的函数接口，支持多种输入格式（数字、字符串、datetime 对象等）。每个模块应定义清晰的输入输出格式与错误处理。

7. 示例与用法脚本：提供示例代码与用法案例，演示如何使用 `intcomma()` 添加千位分隔符、`naturaltime()` 转换相对时间、`naturalsize()` 格式化文件大小、`natural_list()` 处理列表等核心函数。

8. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `hatch-vcs==1.0.0`、`hatchling==1.27.0`、`Python>=3.9`、`gettext==0.19.8.1`、`pytest==7.4.2`、`pytest-cov==4.1.0`、`freezegun==1.3.0` 等核心库）。此外，`pyproject.toml` 文件必须配置使用 `hatch-vcs` 从版本控制系统（VCS）获取版本信息，设置中需指定版本来源为 "vcs"、生成版本文件（如 `src/humanize/_version.py`），并定义诸如 local scheme 处理等版本规则。`pyproject.toml` 文件应能验证所有功能模块是否正常工作。另外，需要提供 `src/humanize/__init__.py` 作为统一 API 入口，导入 `intcomma`、`naturaltime`、`naturalsize`、`natural_list` 与 `activate` 等核心函数与类，并提供版本信息（从生成的版本文件导入），使用户通过 `import humanize`、`from humanize import *` 等简单语句即可访问所有主要功能。在 `number.py` 中，需要 `intcomma()`、`intword()`、`ordinal()`、`fractional()`、`scientific()` 等函数来处理各类数字人性化需求；在 `time.py` 中，需要 `naturaltime()`、`naturaldelta()`、`naturalday()`、`naturaldate()`、`_date_and_delta()`、`precisedelta()` 等函数来处理时间人性化需求；在 `filesize.py` 中，需要 `naturalsize()` 函数来处理文件大小人性化需求；在 `lists.py` 中，需要 `natural_list()` 函数来处理列表人性化需求；在 `i18n.py` 中，需要 `activate()`、`deactivate()`、`_gettext()` 等函数来处理国际化需求。

**考点**：把数字、时间差、字节数、列表四类数据统一渲染成本地化自然语言，难点是 `naturaltime` / `precisedelta` 的单位选择与单复数、以及 `gettext` 语言激活后各模块取词的一致性。

## 38. `icecream`（测试数 40）

**中文规格**

请创建一个名为 IceCream 的 Python 项目，实现一个智能调试工具。项目应包含以下关键特性：

1. **基础调试输出**：提供一个能够打印变量名与变量值的函数，支持同时输出多个变量，并自动高亮输出以提升可读性。

2. **上下文信息**：支持显示文件名、行号与函数名。可配置是否显示完整路径，并支持自定义上下文信息格式。

3. **输出定制**：允许自定义前缀，支持自定义输出函数，可配置参数转字符串的方式，并支持行宽限制。

4. **语法高亮**：使用 Pygments 库提供语法高亮，支持 Solarized dark 主题，并自动适配不同的终端环境。

5. **Windows 支持**：通过 colorama 提供 Windows 终端颜色支持，并自动处理 ANSI 转义序列。

6. **配置选项**：支持运行时动态配置，可启用/禁用输出，并可配置上下文显示方式。

7. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `colorama>=0.3.9`、`pygments>=2.2.0`、`executing>=2.1.0`、`asttokens>=2.0.1` 等核心库）。`pyproject.toml` 应能验证所有功能模块是否正常工作。同时需要 `icecream/__init__.py` 作为统一 API 入口，导入并导出 `ic`、`argumentToString`、`stderrPrint`、`NO_SOURCE_AVAILABLE_WARNING_MESSAGE`、`DEFAULT_PREFIX`、`__title__`、`__license__`、`__version__`、`__author__`、`__contact__`、`__url__`、`__description__` 等核心函数/变量。其中 `ic` 是 `IceCreamDebugger` 的实例，而 `NO_SOURCE_AVAILABLE_WARNING_MESSAGE`、`DEFAULT_PREFIX`、`__title__`、`__license__`、`__version__`、`__author__`、`__contact__`、`__url__`、`__description__` 都是变量。这样用户通过简单的 `from icecream import *` 语句即可访问所有主要功能。在 `icecream.py` 中，需要 `IceCreamDebugger` 类来实现调试功能，包含 `__call__`、`format`、`configureOutput` 等方法，以及 `argumentToString` 函数来格式化不同类型参数的输出。在 `builtins.py` 中，需要 `install()` 与 `uninstall()` 函数，把 `ic` 函数安装到 Python 内置命名空间。

**考点**：靠 `asttokens` / `executing` 从调用帧回读实参的源码文本，从而原样打印 `变量名 = 值`，难点是同一行多个调用与多行表达式的参数切分，以及 `install()` 注入内置命名空间后 `ic` 的全局可用。
