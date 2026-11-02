# NL2Repo-Bench 全题规格中文翻译 · Part 13（第 82–86 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 82. `sklearn`（测试数 70）

**中文规格**

请创建一个名为 sklearn-pandas 的 Python 项目，实现一个连接 Scikit-Learn 与 pandas 的桥接库。项目应包含以下功能：

1. **DataFrame 映射器**：实现 `DataFrameMapper` 类，能够把 pandas DataFrame 的列映射到 Scikit-Learn 的 transformer，支持单列与多列变换，并能处理稀疏矩阵输出。该映射器应支持默认 transformer，以处理未被显式指定的列，并在变换后保留 DataFrame 结构。

2. **特征生成器**：提供 `gen_features` 函数以简化特征定义过程，支持批量生成特征变换配置。特征生成器应能自动处理不同类型的特征（数值型、类别型、文本型等），并与 `DataFrameMapper` 无缝集成。

3. **数值变换器**：实现 `NumericalTransformer` 类，提供常用的数值变换功能，包括 `log` 与 `log1p` 变换。该变换器应能正确处理边界值（如零值与负值）以及异常输入，并给出清晰的错误信息。

4. **Pipeline 集成**：定制 `TransformerPipeline` 类，使其兼容 Scikit-Learn 的 `Pipeline` 并支持链式 transformer。该 pipeline 应支持单步与多步变换，并能与其他 Scikit-Learn 组件（如交叉验证与网格搜索）协同工作。

5. **接口设计**：为每个功能模块设计清晰的 API 接口，支持通过简单的函数调用完成复杂的数据变换任务。接口应保持与 Scikit-Learn 一致的风格，包括 `fit`、`transform`、`fit_transform` 等方法。

6. **性能优化**：优化数据处理逻辑以降低内存占用，实现并行处理功能以加速特征变换，并提供详细的性能基准测试报告，量化不同场景下的性能，包括处理速度与资源占用。

7. **文档与示例**：编写完整的 API 文档，提供丰富的使用示例与教程，包括常见问题（FAQ）与贡献指南，确保新用户能快速上手、开发者能方便地为项目做贡献。

8. **兼容性保证**：确保该库兼容 Python 3.6+ 版本，支持主流的 pandas 与 scikit-learn 版本，并提供详细的版本迁移指南，帮助用户在不同版本之间平滑升级。

9. **核心文件要求**：提供完整的 `setup.py` 文件，把项目配置为可安装的 Python 包，声明所有依赖（包括 `pandas==2.3.1`、`scikit-learn>=1.3.0`、`numpy>=1.26.0`、`pytest` 等）。实现 `sklearn_pandas/__init__.py` 作为 API 入口，导出主要类与函数 `DataFrameMapper`、`_handle_feature`、`_build_transformer`、`TransformerPipeline`、`gen_features`、`_call_fit`、`NumericalTransformer`，支持通过 `from sklearn_pandas import *` 或 `from sklearn_pandas.* import *` 导入语句访问所有主要功能。

**考点**：把列级 transformer 映射、默认转换器与稀疏输出统一收敛到 `DataFrameMapper`，难点是未显式指定列的兜底处理、变换后仍保留 DataFrame 结构，以及 `TransformerPipeline` 与 sklearn 的 `Pipeline`、交叉验证和网格搜索的互操作。

## 83. `sortedcontainers`（测试数 296）

**中文规格**

请创建一个名为 Python-SortedContainers 的 Python 项目，实现一个高性能的纯 Python 有序容器库。该项目应包含以下功能：

**1. 核心数据结构的实现**：实现三种核心有序容器类型：SortedList（有序列表）、SortedDict（有序字典）与 SortedSet（有序集合）。所有容器都必须维持元素的顺序，并提供时间复杂度为 O(log n) 的插入、删除与查找操作。SortedList 应支持完整的序列操作（索引、切片、迭代），SortedDict 应继承 dict 的功能并维持键的顺序，SortedSet 应同时提供集合运算与序列访问能力。

**2. key 函数的支持**：实现 SortedKeyList 类，以支持自定义排序用的 key 函数。key 函数应能处理复杂对象、多级排序以及特殊排序规则（如取模运算、负值排序等）。提供基于 key 的二分查找、范围查询与索引操作。

**3. 性能优化机制**：实现负载因子动态调整、内存管理优化与索引树维护等性能优化机制。支持大规模数据处理（10 万个以上元素），并确保在各种数据规模下都有高效性能。提供内部一致性检查与索引重建功能。

**4. 完整的 API 接口**：为每种容器类型提供完整的、与 Python 标准库兼容的接口，包括序列操作（`__getitem__`、`__setitem__`、`__delitem__`、`__iter__`、`__reversed__`）、集合操作（union、intersection、difference、symmetric_difference）、字典操作（keys、values、items、get、setdefault）等。支持运算符重载（`+`、`-`、`&`、`|`、`^` 等）。

**5. 视图对象的实现**：为 SortedDict 实现有序视图对象（SortedKeysView、SortedItemsView、SortedValuesView），支持索引访问、切片操作与集合运算。视图对象应实时反映字典中的状态变化。

**6. 错误处理与边界条件**：实现完善的错误处理机制，包括参数校验、异常抛出、边界检查等。处理空容器、单元素、重复元素与不可比较对象等边界情况。提供压力测试与随机操作测试。

**7. 测试与性能基准**：提供完整的单元测试套件，覆盖所有功能模块与边界条件。实现性能基准测试框架，以支持与第三方有序容器库的性能对比。提供压力测试、内存泄漏测试与并发安全测试。

**8. 文档与示例**：提供详细的 API 文档、使用示例与性能分析报告。包含典型应用场景的代码示例，如算法交易、数据分析、缓存管理等。

**9. 构建与发布**：项目必须包含完整的 setup.py 文件，把项目配置为可安装包（支持 pip install）并声明完整的依赖清单。提供 tox.ini 多环境测试配置，以支持跨不同 Python 版本的兼容性测试。

**10. 核心文件要求**：项目必须包含完整的 pyproject.toml 文件。该文件不仅要把项目配置为可安装包（支持 pip install），还要声明完整的依赖清单（包括 pytest==8.4.0、pytest-cov==6.2.1、coverage==7.10.1、ruff==0.4.3、pylint<2.6、doc8==2.0.0、rstcheck==6.2.5、sphinx==8.2.3、docutils==0.21.2、matplotlib==3.9.1、scipy==1.14.0、numpy==1.26.4、build==1.2.1、twine==6.1.0、wheel==0.44.0、tox==4.28.3 等核心库）。同时需要提供 `src/sortedcontainers/__init__.py` 作为统一 API 入口，从 sortedlist、sorteddict 与 sortedset 模块导入 SortedList、SortedKeyList、SortedDict、SortedSet 等核心类，导出 SortedKeysView、SortedItemsView、SortedValuesView 等视图类，并提供版本信息，使用户能通过简单的 `from sortedcontainers import SortedList, SortedDict, SortedSet` 语句访问所有主要功能。在 sortedlist.py 中需要有 SortedKeyList 类，以支持自定义排序用的 key 函数。在 sorteddict.py 中需要有视图对象的实现，以提供有序的键值对访问。在 sortedset.py 中需要有完整的集合运算实现，以支持 union、intersection、difference 等。

**考点**：用纯 Python 在 `SortedList`、`SortedDict`、`SortedSet`、`SortedKeyList` 上同时维持 O(log n) 增删查与索引树一致性，难点是 key 函数下的二分查找与批量重建、视图对象实时反映字典改动，以及双下划线方法与运算符重载、边界异常处理的全覆盖。

## 84. `sqlparse`（测试数 461）

**中文规格**

请创建一个名为 sqlparse 的 Python 项目，实现一个 SQL 解析与格式化工具库。项目应包含以下功能：

1. SQL 解析器：应能从输入字符串中提取并解析 SQL 语句，支持多种数据库方言与复杂 SQL 结构。解析结果应为结构化的 TokenList 或等价的可分析对象，供后续处理与分析使用。

2. SQL 格式化：实现美化 SQL 代码的函数（或脚本），包括缩进、对齐、关键字大小写转换、换行等。应支持多种格式化选项，以提升 SQL 代码的可读性与规范性。

3. 多语句切分：支持把包含多条 SQL 语句的字符串切分为独立的语句块，适用于批量 SQL 脚本处理与自动化分析。

4. 可扩展的 filter 机制：允许用户自定义格式化与分析规则，支持插件式扩展，以满足不同业务场景下的 SQL 处理需求。

5. 接口设计：为每个功能模块（如解析、格式化、切分等）设计独立的命令行接口或函数接口，支持终端调用与脚本集成。每个模块应定义清晰的输入与输出格式，便于集成到自动化工具链中。

6. 示例与测试脚本：提供示例代码与测试用例，演示如何使用 format()、parse() 与 split() 函数完成 SQL 代码美化、结构化处理与多语句切分（例如 `format("select * from user;", reindent=True, keyword_case='upper')` 应返回格式化后的 SQL 代码）。上述函数需要组合起来，构建完整的 SQL 解析与格式化工具包。项目最终应包含解析、格式化与切分等模块，以及典型测试用例，形成可复现的 SQL 处理流程。

7. 核心文件要求：项目必须包含完整的 pyproject.toml 文件，把项目配置为可安装包（支持 pip install），并声明完整的依赖清单（如 pytest 等）。`sqlparse/__init__.py` 作为统一 API 入口，从 parser、formatter、splitter 等模块导入核心函数，提供版本信息，并包含 `parsestream` 函数，使用户能通过 `from sqlparse import format, parse, split, SQLParseError, Lexer, parsestream` 访问主要功能。formatter.py 中需要有 `format_sql()` 函数，以支持多种格式化策略。grouping.py、keywords.py、tokenize.py 与 test_regressions.py 必须导入核心库 sqlparse。通过 `from sqlparse import sql, tokens as T, keywords, lexer, utils`，可实现核心模块的解析、词法分析与工具能力，包括 utils.py 的 `remove_quotes`、lexer.py 的 `tokenize` 函数，以及 sql.py 的 `Token` 类。cli.py 包含 `main` 函数，exceptions.py 包含 `SQLParseError` 类。sql.py 中有 `Parenthesis`、`Identifier`、`Assignment`、`TypedLiteral`、`Function` 与 `Token` 类；tokens.py 中包含 `T.Keyword`、`T.Operator`、`T.Name`、`T.String`、`T.Number`、`T.Punctuation`、`T.Literal` 与 `T.Whitespace`；lexer.py 中的 `Lexer` 类带有 `get_default_instance` 方法。

**考点**：把词法切分（`Lexer`/`tokenize`）、分组与语法树（`sql.py` 的 `Token`、`Parenthesis`、`Identifier` 等）以及可插拔 filter 串成 format/parse/split 三条链路，难点是多方言下多语句的边界切分、缩进与关键字大小写等格式化选项的组合，以及 `sqlparse/__init__.py` 导出面的完整性。

## 85. `stable-baselines3`（测试数 798）

**中文规格**

请创建一个名为 Stable-Baselines3 的 Python 项目，实现一个完整的强化学习算法库。项目应包含以下特性：

1. **算法实现模块**：能实现多种强化学习算法，包括策略梯度方法（PPO、A2C）、价值函数方法（DQN）、actor-critic 方法（SAC、TD3、DDPG）等。每种算法都应包含完整的训练逻辑、网络结构定义与超参数配置。

2. **环境接口的标准化**：实现与 Gymnasium 环境的无缝集成，支持向量化环境以提升训练效率，包括 DummyVecEnv、SubprocVecEnv 等，并支持 Monitor、VecNormalize 等环境包装器。

3. **模型管理功能**：提供完整的模型保存、加载与参数管理功能，支持模型检查点、参数提取与设置，以及跨平台兼容。

4. **训练过程控制**：实现回调函数系统，支持训练进度监控、模型保存、早停、评估等，并提供灵活的配置选项。

5. **数据处理与缓冲区**：实现多种经验回放缓冲区（ReplayBuffer、HerReplayBuffer 等），支持优先经验回放、HER（Hindsight Experience Replay）等技术。

6. **评估与测试工具**：提供模型评估、确定性测试、环境检查器等工具，以确保训练结果的可靠性与可复现性。

7. **核心文件要求**：项目必须包含完整的 pyproject.toml 与 pyproject.toml 文件（原文两处均写作 pyproject.toml），把项目配置为可安装包，声明完整的依赖清单（包括 torch、gymnasium、numpy、pandas、matplotlib、tensorboard 等），提供 `stable_baselines3/__init__.py` 作为统一 API 入口，从各算法模块导入核心类，使用户能通过简单的 `from stable_baselines3 import PPO, SAC, DQN` 语句访问所有主要功能。在 `stable_baselines3/common/base_class.py` 文件中，应有用于模型序列化与反序列化的 save 与 load 函数，以支持跨设备与断点续训。在 `stable_baselines3/common/utils.py` 文件中，应有 `set_random_seed` 函数，用于设置 numpy、random、torch 与环境的随机种子以保证可复现性，并由 `tests/test_utils.py` 中的 `test_set_random_seed` 验证。在 `stable_baselines3/common/env_checker.py` 文件中，应有 `check_env` 函数，用于校验自定义环境是否符合 Gymnasium 接口，并由 `tests/test_env_checker.py` 中 `test_check_env_*` 系列测试用例针对常见错误进行覆盖。在 `stable_baselines3/common/env_util.py` 文件中，应有 `make_vec_env` 函数，用于快速创建 DummyVecEnv/SubprocVecEnv，并由 `tests/test_env_util.py` 中的 `test_make_vec_env` 验证其并行与包装行为。在 `stable_baselines3/common/buffers.py` 文件中，应有 `ReplayBuffer.sample` 函数，用于返回训练批次，并由 `tests/test_buffers.py` 中的 `test_replaybuffer_sample` 验证采样形状与类型。在 `stable_baselines3/her/her_replay_buffer.py` 文件中，应有 `HerReplayBuffer.sample_transitions` 函数，用于实现 HER 目标重采样，并由 `tests/test_her.py` 中的 `test_her_relabeling` 验证重标注逻辑。在 `stable_baselines3/common/evaluation.py` 文件中，应有 `evaluate_policy` 函数，用于统计多个回合的平均奖励与标准差，并由 `tests/test_evaluation.py` 中的 `test_evaluate_policy` 验证统计结果的取值范围。在 `stable_baselines3/common/torch_layers.py` 文件中，应有 `create_mlp` 与 `BaseFeaturesExtractor`，用于构建策略网络，并由 `tests/test_torch_layers.py` 中的 `test_create_mlp_output_shape` 验证输出维度。在 `stable_baselines3/common/logger.py` 文件中，应有 `configure` 与 `Logger.record`/`dump` 函数，用于配置日志输出，并由 `tests/test_logger.py` 中的 `test_logger_records_and_dumps` 验证文件与 TensorBoard 输出。在 `stable_baselines3/common/save_util.py` 文件中，应有 `save_to_pkl` 与 `load_from_pkl`，用于持久化非模型对象，并由 `tests/test_save_util.py` 中的 `test_pkl_roundtrip` 验证序列化一致性。

**考点**：以统一的 `BaseAlgorithm`、回调系统、向量化环境与回放缓冲区为骨架复刻多种 RL 算法，难点是 HER 目标重采样与 `HerReplayBuffer`、`VecNormalize`/`check_env` 等环境侧约束，以及 `save`/`load` 在跨设备与断点续训下的可复现性。

## 86. `stamina`（测试数 129）

**中文规格**

请创建一个名为 Stamina 的 Python 项目，实现一个达到生产级水准的重试机制库。项目应包含以下特性：

1. 核心重试装饰器：实现 `@stamina.retry()` 装饰器，能依据指定的异常类型或判定函数执行智能重试。该装饰器应支持配置重试次数、超时、退避策略等参数，并保留被装饰函数的类型提示。

2. 指数退避与抖动机制：实现智能退避算法，初始延迟为 100ms，以 2 为底指数增长，最大延迟上限为 5 秒，并在每次重试时附加 0–1 秒的随机抖动，以避免惊群效应。退避公式应为：`min(5.0, 0.1 * 2.0^(attempt - 1) + random(0, 1.0))`。

3. 异步重试支持：实现 `@stamina.retry()` 装饰器对异步函数的自动支持，包括与 asyncio 及 Trio 异步库的兼容。异步重试应使用合适的异步休眠机制。

4. 上下文管理器重试：实现 `stamina.retry_context()` 函数，返回可迭代的上下文管理器，使任意代码块都能被重试。每个上下文管理器应提供当前重试次数与下次等待时间的信息。

5. 函数调用方：实现 `RetryingCaller` 与 `AsyncRetryingCaller` 类，为直接函数调用提供重试机制，并支持通过 `on()` 方法预先绑定异常类型。

6. 可观测性与监控：集成 Prometheus 指标采集（`stamina_retries_total` 计数器）、structlog 结构化日志，以及对标准 logging 模块的回退支持。提供 `instrumentation` 模块以支持自定义监控钩子。

7. 测试模式支持：实现测试配置功能，允许全局禁用重试、限制重试次数、去除退避延迟等，以便进行单元测试与集成测试。

8. 接口设计：为每个功能模块设计清晰的 API 接口，包括装饰器、上下文管理器、调用方类等。每个模块应定义清晰的输入输出格式与错误处理机制。

9. 示例与文档：提供完整的示例代码与测试用例，演示如何使用各种重试机制处理 HTTP 请求、数据库操作与 API 调用等常见场景。

10. 核心文件要求：项目必须包含配置良好的 pyproject.toml 文件，把项目配置为可安装包（支持 `pip install`），并声明完整的依赖清单（包括 tenacity>=8.2.3、typing-extensions>=4.12.2；python_version < '3.10'、trio>=0.25.0、anyio>=4.3.0、structlog>=24.1.0、prometheus-client>=0.20.0 等核心库）。需要提供 `stamina/__init__.py` 作为统一 API 入口，导出 retry、retry、AsyncRetryingCaller、retry_context、is_active、is_testing、set_active、set_testing、CONFIG、_Config、_Testing、_make_stop、RetryHookFactory、get_on_retry_hooks、set_on_retry_hooks、RetryDetails、guess_name、get_default_hooks、init_structlog 等核心函数与类，并提供版本信息，使用户能通过简单语句（`from stamina import **`、`from stamina._config import **`、`from stamina._core import **`、`from stamina.instrumentation import **`、`from stamina.instrumentation.** import **`）访问所有主要功能。

**考点**：以 tenacity 为底座把 `@retry`、`retry_context()` 与 `RetryingCaller` 三种重试入口统一起来，难点是同步、asyncio 与 trio 三套休眠机制及 hook 的一致行为、指数退避加抖动在测试中的确定性，以及测试模式下全局开关重试的配置设计。
