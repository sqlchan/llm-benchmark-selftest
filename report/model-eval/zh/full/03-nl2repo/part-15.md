# NL2Repo-Bench 全题规格中文翻译 · Part 15（第 90–94 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 90. `tenacity`（测试数 124）

**中文规格**

请创建一个名为 Tenacity 的 Python 项目，实现一个通用型的自动重试库。项目应包含以下核心功能：

1. **重试装饰器与核心机制**：实现 `@retry` 装饰器，能够为任意同步或异步函数自动添加重试机制。支持无限重试、限定重试次数、超时重试等多种模式，并能够自动跟踪尝试次数、异常链与统计信息。

2. **停止条件策略**：支持多种停止重试的策略，包括最大尝试次数（`stop_after_attempt`）、最大重试时长（`stop_after_delay`）、提前终止（`stop_before_delay`）以及多条件组合（AND/OR）。

3. **等待策略**：支持固定等待、增量等待、随机等待、指数退避、抖动（jitter）与链式等待等多种等待策略。所有等待策略都可以灵活组合，以适配不同的业务场景。

4. **重试条件策略**：支持基于异常类型、异常消息、返回值等自定义重试条件，支持多条件组合（AND/OR/NOT），灵活控制重试逻辑。

5. **异步与多生态支持**：支持 `asyncio`、`trio`、`tornado` 等异步场景的重试，自动识别同步/异步函数并调度其执行，确保事件循环不被阻塞。

6. **回调与日志机制**：支持在重试之前、之后以及等待之前的自定义回调（例如日志记录、统计、外部通知等），可灵活插入自定义逻辑，提升可观测性与可调试性。

7. **上下文管理器与代码块重试**：实现 `Retrying` 与 `AsyncRetrying` 类，支持用 for/with 结构对任意代码块进行重试，便于多步操作与资源管理。

8. **动态参数与高级用法**：支持在运行时动态修改重试参数（`retry_with`），并支持自定义回调、mock sleep、mock logger、retry_error_callback 与自定义异常链等高级测试场景。

9. **统计与监控**：每个被 `@retry` 装饰的函数都有一个 `statistics` 属性，记录重试次数、开始时间、耗时等信息，便于对重试行为进行监控、告警与性能分析。

10. **类型安全与兼容性**：支持类型注解、mypy/typeguard 检查，并兼容 Python 3.9+ 与主流异步生态。

11. **错误处理与边界场景**：支持 `reraise=True`，用 `TryAgain` 主动触发重试，使 `RetryError` 可序列化，并跟踪异常链，适用于复杂异常处理与分布式场景。

12. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件，把项目声明为可安装包（支持 'pip installation'）并完整声明依赖。应以 `tenacity/__init__.py` 作为统一 API 入口，导入并导出 `retry`、`Retrying`、`AsyncRetrying` 等类，并提供版本信息，使所有主要功能都可以通过简单的 `from tenacity import xxx` 或 `import tenacity` 访问。

**考点**：用「装饰器 + 可迭代状态机（`Retrying`/`AsyncRetrying`）」把同步与异步重试统一成一条链路，难点是停止、等待、条件三类策略的可组合代数，以及统计信息、异常链与可序列化 `RetryError` 等边界行为。

## 91. `tinydb`（测试数 204）

**中文规格**

请创建一个名为 TinyDB 的 Python 项目，实现一个轻量级的面向文档数据库。项目应包含以下关键功能：

1. **数据库核心类 TinyDB**：实现数据库初始化、存储后端选择、表管理（创建、切换、删除）以及默认表操作。

2. **表管理**：每张表支持插入、批量插入、查询、批量查询、更新、批量更新、删除、批量删除、计数与遍历等操作。

3. **文档对象**：每条数据都有唯一的 doc_id，可通过 doc_id 精确操作文档。

4. **查询系统（Query/where）**：支持链式与表达式两种方式构建查询条件，并支持字段相等、范围、模糊以及逻辑组合（AND/OR/NOT）等多种查询。

5. **操作函数（operations）**：支持 set、delete、add、increment、decrement 等字段级变更操作。

6. **存储后端抽象（Storage）**：支持 JSON 文件存储与内存存储等多种后端，用户可以自定义并扩展存储方式。

7. **中间件机制（Middleware）**：支持缓存、加密等中间件扩展，以增强存储行为。

8. **兼容性与零依赖**：纯 Python 实现，不依赖第三方库，兼容 Python 3.8+ 与 PyPy3。

9. **上下文管理**：支持 with 语句自动关闭数据库资源。

10. **版本信息与 API 入口**：包含统一的 API 入口与版本信息，便于用户导入与调用。

11. 项目必须包含完整的 pyproject.toml 文件。该文件不仅要把项目配置为可安装包（支持 pip install），还要声明完整的依赖清单（包括 pytest==6.2.5、mypy==1.8.0、typing-extensions==4.11.0、Sphinx==7.2.6 等核心库）。同时应提供 tinydb/__init__.py 作为统一 API 入口，导入并导出 CachingMiddleware、Middleware、delete、increment、decrement、add、subtract、set、Query、where、JSONStorage、MemoryStorage、Storage、touch、Document、LRUCache、freeze、FrozenDict、TinyDB 及主要的导入导出函数，并提供版本信息，使用户通过简单的 "from tinydb.middlewares/operations/queries/storages/table/utils/database import **" 语句即可访问所有主要功能。

**考点**：以 doc_id 为主键、把存储后端与中间件抽成可插拔接口的极简文档数据库，难点是 Query 的链式运算符重载与逻辑组合，以及 `__init__.py` 一次性导出全部公开 API 的完整性。

## 92. `tqdm`（测试数 139）

**中文规格**

请创建一个名为 tqdm 的 Python 项目，实现一个进度条显示库。项目应包含以下功能：

1. **进度条核心引擎**：为任意可迭代对象包裹进度条显示，支持自动计算进度百分比、处理速度与剩余时间等指标。进度条应支持多种显示格式（包括 ASCII 字符与 Unicode 字符）以及自定义样式（例如颜色、前缀描述）。

2. **多环境适配**：实现适配不同输出环境的进度条，包括标准控制台输出、Jupyter Notebook Widget 显示、GUI 界面（tkinter）以及富文本显示（与 rich 库集成）。每个环境应有独立的实现模块，但共享核心逻辑。

3. **高级功能支持**：为异步编程（asyncio）、并发处理（multiprocessing、threading）以及与数据科学库（pandas、dask、keras）的集成提供专门适配。例如用 tqdm.asyncio.tqdm(async_iterable) 进行异步迭代，用 tqdm.contrib.concurrent.thread_map() 进行并发映射。

4. **命令行工具接口**：设计命令行管道支持，允许在 shell 管道中使用 python -m tqdm。支持字节数统计、自定义分隔符、进度监控等。每个参数都应支持环境变量覆盖与类型校验。

5. **扩展与集成模块**：提供日志系统集成（日志重定向）、通知系统（telegram、slack、discord 机器人通知），以及 tenumerate()、tzip()、tmap() 等增强内置函数的实用工具。综合上述功能构建完整的进度条显示工具集。

6. **核心文件要求**：项目必须包含完整的 pyproject.toml 文件。该文件不仅要把项目配置为可安装包（支持 pip install），还要声明完整的依赖清单（包括 setuptools>=42、setuptools_scm[toml]>=3.4、ipywidgets>=6 等可选依赖）。该配置文件应能验证所有功能模块是否正常工作。此外，应提供 tqdm/__init__.py 作为统一 API 入口，从 std 模块导入 tqdm、trange、tenumerate 等核心函数，导出 TqdmWarning、TqdmTypeError、TqdmDeprecationWarning、TqdmLoggingHandler、TMonitor、DummyTqdmFile 等各种类，并提供版本信息，使用户通过简单的 "from tqdm/tqdm.asyncio/contrib/cli/utils/notebook/std import **" 语句即可访问所有主要功能。在 std.py 中应有一个核心 tqdm 类，实现进度条的全部基础功能，包括显示、更新、格式化等。

**考点**：以单一核心 `tqdm` 类加各环境适配层（notebook、gui、rich、asyncio、concurrent）分层组织，难点是格式化模板与刷新节流，以及 CLI 管道、环境变量覆盖与多后端共享核心逻辑的一致性。

## 93. `trimming`（测试数 10）

**中文规格**

请创建一个名为 CSV-Trimming 的 Python 项目，实现一个 CSV 文件清洗库。项目应包含以下功能：

1. **CSV 填充检测与移除**：自动识别并删除 CSV 文件四周的空行与空列，支持智能边缘检测算法。实现 `trim_padding()` 方法，检测 CSV 边界并移除填充内容，同时保留有效数据区域。

2. **重复模式识别与处理**：实现检测并移除重复表头行与重复模式行的功能，支持 `drop_duplicated_schema()` 方法。应能够识别重复列名模式与重复数据行模式，并智能保留最合适的表头。

3. **空单元格与空行处理**：专门处理空单元格、NaN 值与空行，实现 `drop_empty_rows()` 与 `drop_empty_columns()` 方法。应支持空值的多种表示形式（包括 Unicode 空格、各种 NaN 变体等）。

4. **表头恢复与标准化**：实现 `restore_header()` 方法，从数据中识别并恢复正确的表头，支持表头检测算法与列名标准化处理。

5. **相关行处理**：支持处理跨行相关联的数据，实现 `normalize_correlated_rows()` 方法。提供回调函数机制，允许用户自定义关联检测逻辑，以处理被拆分到多行的数据记录。

6. **字符串清洗与标准化**：实现 `trim_spaces()` 与 `_deep_strip()` 方法，清洗单元格内的多余空格与特殊字符，并进行深层的字符串标准化处理。

7. **NaN 值还原**：实现 `restore_true_nan()` 方法，区分真正的 NaN 值与表示空值的字符串，正确还原数据中真实的缺失值。

8. **命令行界面设计**：为每个功能模块设计独立的命令行界面，支持终端调用测试。在 `cli.py` 中实现 `main()` 函数，支持输入与输出文件路径参数，以及 `--no-restore-header`、`--keep-padding`、`--keep-duplicated-schema` 等选项。

9. **核心类设计**：在 `trim.py` 中实现 `CSVTrimmer` 类，提供 `__init__()` 方法以支持关联回调函数参数，并提供主方法 `trim()` 集成全部清洗功能。该类应支持可配置的清洗选项（restore_header、drop_padding、drop_duplicated_schema）。

10. **测试用例与验证**：提供完整的测试套件，包括 `test_cases.py` 中的文档集测试、`test_cli.py` 中的命令行界面测试、`test_trim_with_correlation.py` 中的关联处理测试、`test_trimming.py` 中的基础功能测试等。测试应覆盖各种边界情况与错误处理。

11. **日志系统**：在 `logger.py` 中实现日志功能，为清洗过程提供详细的进度信息与调试支持。

12. **项目配置与依赖管理**：在 `setup.py` 中把项目配置为可安装包，声明完整的依赖清单（包括 pandas、numpy、ugly_csv_generator、tqdm、pytest 等），并提供命令行入口点配置。

13. **核心文件要求**：项目必须包含完整的 setup.py 文件，不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 ugly_csv_generator>=1.1.4、random_csv_generator>=1.0.0、scipy>=1.10.0 等核心库）。该 setup.py 应能验证所有功能模块是否正常工作。同时需要提供 csv_trimming/__init__.py 作为统一 API 入口，从 trim 模块导入 CSVTrimmer 核心类。在 trim.py 中需要有一个 trim() 函数集成全部清洗步骤，包括对 trim_spaces()、trim_padding()、drop_empty_rows()、restore_header()、restore_true_nan()、normalize_correlated_rows()、drop_empty_columns()、drop_duplicated_schema() 等方法的协同调用。在 cli.py 中定义 main 函数，作为命令行工具的入口，解析用户传入的输入与输出 CSV 文件路径以及清洗选项，并调用 CSVTrimmer 类清洗输入 CSV 后保存到指定输出路径。使用户通过 "from csv_trimming import CSVTrimmer" 与 "from csv_trimming.** import **" 这类简单语句即可访问主要功能。

**考点**：面向「脏 CSV」构建边界检测与结构修复流水线（填充裁剪 → 空行空列 → 表头恢复 → NaN 还原 → 重复 schema → 跨行归并），难点是 padding 与重复表头的启发式判定，以及用回调机制把拆分到多行的记录合并回一条。

## 94. `tsfresh`（测试数 317）

**中文规格**

### 项目概述

请创建一个名为 tsfresh 的 Python 项目，实现一个时间序列特征提取库。项目应包含以下功能：

1. **特征提取器**：能够从输入的时间序列数据中提取并计算出数百个特征，支持基础统计特征（例如均值、方差、峰值个数）与复杂特征（例如时间反演对称性统计量、频域特征等）。提取结果应以 pandas DataFrame 或等价的可分析格式呈现。

2. **特征选择器**：实现能够基于统计假设检验筛选相关特征的功能（或脚本），同时覆盖有监督与无监督学习场景。应支持多种统计检验方法（例如 Mann-Whitney U 检验、Fisher 精确检验等）、多种多重检验校正（例如 Benjamini-Yekutieli 过程）以及自定义特征选择策略。

3. **特殊结构处理**：对多变量时间序列、事件序列与不规则采样数据进行特殊处理，例如支持按 ID 分组的时间序列、处理缺失值，并支持对不同时间序列类型进行特征提取。

4. **接口设计**：为各功能模块（例如特征提取、特征选择、数据预处理、结果后处理等）设计独立的命令行界面或函数接口，支持终端调用测试。每个模块应定义清晰的输入与输出格式。

5. **示例与评估脚本**：提供示例代码与测试用例，演示如何使用 `extract_features()` 与 `select_features()` 函数进行特征提取与选择（例如 `extract_features(timeseries_data, column_id='id', column_sort='time')` 应返回一个特征矩阵）。

6. **核心文件要求**：项目必须包含完整的 `setup.py` 文件，不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `pandas >= 1.3.0`、`numpy >= 1.20.0`、`scipy >= 1.7.0`、`scikit-learn >= 1.0.0`、`statsmodels >= 0.13.0`、`pywt >= 1.1.0`、`pytest` 等核心库）。该 `setup.py` 文件应能验证所有功能模块是否正常工作。同时需要提供 `tsfresh/__init__.py` 作为统一 API 入口，从 `feature_extraction` 与 `feature_selection` 模块导入 `extract_features`、`select_features`、`calculate_relevance_table`、`combine_relevance_tables`、`get_feature_type`、`infer_ml_task` 等核心函数，导出 `ComprehensiveFCParameters`、`MinimalFCParameters`、`ClusterDaskDistributor`、`IterableDistributorBaseClass`、`LocalDaskDistributor`、`MapDistributor`、`MultiprocessingDistributor` 等配置类，并提供版本信息，使用户通过 `from tsfresh import ...`、`from tsfresh.feature_extractions/defaults/utilities/examples/transformers` 这类简单语句即可访问所有主要功能。在 `feature_calculators.py` 中应有各种特征计算函数，用于提取不同类型的时序特征。

**考点**：以「特征计算器注册表 + 假设检验筛选」两层组织数百个特征，难点是 `feature_calculators.py` 中计算器的统一签名与命名推导、多种并行分发器（dask/multiprocessing/map）的抽象，以及 `__init__.py` 与 defaults/utilities 子包的大面积导出。
