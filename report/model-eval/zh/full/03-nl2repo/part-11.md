# NL2Repo-Bench 全题规格中文翻译 · Part 11（第 69–74 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 69. `python-patterns`（测试数 68）

**中文规格**

请创建一个名为 python-patterns 的 Python 项目，实现一个设计模式示例库。项目应包含以下功能：

1. **设计模式实现**：收集并实现各类常见设计模式，包括创建型、结构型、行为型等，覆盖工厂、单例、建造者、适配器、装饰器、观察者、策略、模板方法等模式。每个模式都应配有简要说明与 Python 代码实现。

2. **代码示例与注释**：每个设计模式模块都应包含详细的模块级 docstring，说明模式原理、适用场景、优缺点，并尽可能提供 Python 生态中的实际应用案例。

3. **结构良好的目录**：按创建型、结构型、行为型等类别把不同类型的设计模式归入相应子目录，便于查阅与维护。

4. **测试用例**：为主要设计模式的实现提供独立测试用例，确保每个模式代码的正确性与可复现性，并支持自动化测试。

5. **贡献与协作规范**：项目应包含贡献指南，鼓励社区成员补充新模式、完善文档与测试，并对代码风格、文档格式等提出统一要求。

6. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `black==24.4.2`、`isort==5.13.2`、`pylint==3.2.2` 等核心库）。`pyproject.toml` 文件应能验证所有设计模式模块与测试用例是否正常工作。同时应提供 `patterns/__init__.py` 作为统一 API 入口，导入各类设计模式模块的主要类与函数，使用户通过简单的 `from patterns import Factory, Adapter, Observer ...` 语句即可访问所有主要功能。需要导入 `Dog`、`PetShop`、`patterns`、`Borg`、`YourBorg`、`ComplexHouse`、`Flat`、`House`、`construct_building`、`Circle`、`Rectangle`、`Position`、`GeometryTools`、`Data`、`DecimalViewer`、`HexViewer`、`Provider`、`Publisher`、`Subscriber`、`Order`、`on_sale_discount`、`ten_percent_discount`、`Radio`、`Proxy`、`client`、`RealSubject`、`Subject`、`BoldWrapper`、`ItalicWrapper`、`TextTag`、`ComputerFacade`、`Card`、`CircleShape`、`DrawingAPI1`、`DrawingAPI2`、`CompositeGraphic` 等类。`patterns/creational`、`patterns/structural`、`patterns/behavioral`、`patterns/fundamental`、`patterns/other` 等子目录存放各类设计模式的实现代码。每个模式位于单独文件中，文件应包含详细的 docstring、示例与参考链接，支持完整的测试验证（65 个测试函数）与代码质量检查（`black`、`isort`、`pylint`、`mypy`），确保项目可作为标准 Python 包分发、安装与使用。

**考点**：在一个包内组织创建型/结构型/行为型多类设计模式，难点是 `patterns/__init__.py` 的扁平化导出清单必须与各子目录中实现类名逐一对应，并且 65 个测试函数与 `black`/`isort`/`pylint`/`mypy` 四道质量门禁要同时通过。

## 70. `python-pytest-cases`（测试数 1372）

**中文规格**

请创建一个名为 Python-pytest-cases 的 Python 项目，实现一个用于测试用例分离管理的库。项目应包含以下功能：

1. **测试用例分离器**：应能从独立文件中收集与管理测试用例，支持多种命名约定（如 `case_*`、`data_*`、`user_*` 等）。分离器应自动发现测试用例文件（如 `test_foo_cases.py` 或 `cases_foo.py`），并把测试数据与测试逻辑分离。

2. **增强型参数化测试**：实现 `@parametrize_with_cases` 装饰器，它可替代标准的 `@pytest.mark.parametrize` 并提供更强大的参数化功能。它应支持多种数据源（模块、类、函数列表）、标签过滤、正则表达式匹配与动态测试用例生成。

3. **高级过滤与标记系统**：对测试用例进行智能过滤与标记，支持标签系统（`@case(tags=...)`）、正则表达式匹配、自定义过滤函数等。应提供 `has_tag`、`id_match_regex`、`CaseFilter` 等过滤机制。

4. **增强的 fixture 功能**：实现增强的 fixture 功能，包括 fixture 联合（fixture unions）、惰性值（lazy values）、fixture 参数化等。应支持在 fixture 中使用测试用例，并管理 fixture 之间的复杂依赖关系。

5. **接口设计**：为每个功能模块（如用例收集、参数化、过滤、fixture 增强等）设计独立接口，支持命令行调用与编程接口。每个模块应定义清晰的输入与输出格式，并提供完整的类型注解。

6. **示例与测试脚本**：提供示例代码与测试用例，演示如何使用 `@parametrize_with_cases` 实现测试用例分离（例如 `@parametrize_with_cases("a,b")` 装饰器结合 `case_two_positive_ints()` 函数应能自动运行测试）。上述功能需要组合起来，构建完整的测试用例管理工具包。

7. **核心文件要求**：项目必须包含配置良好的 `pyproject.toml` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `pytest>=6.0`、`makefun>=1.15.1`、`decopatch`、`packaging` 等核心库）。`pyproject.toml` 文件应能验证所有功能模块是否正常工作。同时需要提供 `src/pytest_cases/__init__.py` 作为统一 API 入口，从各模块导入核心函数与类，并导出 `parametrize_with_cases`、`case`、`current_cases` 等核心函数。其中 `parametrize_with_cases` 是用于给测试函数或 fixture 参数化的装饰器，可自动收集与过滤测试用例；`case` 装饰器用于自定义测试用例的 ID、标签与标记；`current_cases` 函数（或 fixture）用于获取当前测试所有用例参数的信息。用户通过简单的 `from pytest_cases import parametrize_with_cases, case` 语句即可访问所有主要功能。核心模块中需要有 `get_current_cases()` 函数以获取当前测试用例的详细信息，以及 `CaseFilter` 类以实现复杂的过滤逻辑。

**考点**：把用例数据外置到 `case_*` 文件并用 `@parametrize_with_cases` 重新接回 pytest 原生参数化语义，难点是标签/正则/`CaseFilter` 多层过滤与 fixture 联合、惰性值在 fixture 依赖图中的组合，以及 `current_cases` 对当前用例参数的运行期可达性。

## 71. `python-slugify`（测试数 82）

**中文规格**

请创建一个名为 Python-Slugify 的 Python 项目，实现一个 Unicode 字符串 slug 化库。项目应包含以下功能：

1. **Unicode 处理引擎**：能够智能处理中文、俄文、法文、德文、希腊文等多种语言的 Unicode 字符，并将其转换为 ASCII 格式的 URL 友好字符串。支持完整解析 HTML 实体（如把 `&amp;` 转为 `&`）、十进制编码（如把 `&#381;` 转为 `Ž`）与十六进制编码（如把 `&#x17D;` 转为 `Ž`）。

2. **智能文本转换**：实现核心 `slugify()` 函数，把任意 Unicode 文本转换为 slug 格式，包括字符规范化、大小写转换、特殊字符替换与重复字符清理。支持自定义分隔符、最大长度限制、词边界截断与停用词过滤等高级配置。

3. **特殊字符处理**：专门处理引号、数字、标点符号等。支持用户自定义替换规则（如 `[['|', 'or'], ['%', 'percent']]`）以及使用正则表达式模式自定义字符过滤。

4. **命令行接口**：提供完整的命令行工具，支持从标准输入或命令行参数读取文本，并支持 `slugify` 函数的全部参数选项，包括 `--separator`、`--max-length`、`--word-boundary`、`--stopwords`、`--replacements`、`--allow-unicode` 等。

5. **示例与使用说明**：提供丰富的示例代码，演示如何处理多种语言的文本（如把中文「影師嗎」转为 `ying-shi-ma`、法文 `C'est déjà l'été.` 转为 `c-est-deja-l-ete`、俄文 `Компьютер` 转为 `kompiuter` 等）以及各配置选项的用法。上述功能需要组合起来，构建完整的 Unicode 字符串 slug 化工具包。项目最终应包含 Unicode 处理、文本转换与命令行接口等模块，并附典型用法示例，形成可复现的 slug 化流程。

6. **核心文件要求**：项目必须包含完整的 `setup.py` 文件，该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `text-unidecode>=1.3`、`Unidecode>=1.1.1` 等核心库）。`setup.py` 文件从 `about` 字典中取得 `'__title__'` 键的值来设置项目名，并能验证所有功能模块是否正常工作。同时需要提供 `slugify/__init__.py` 作为统一 API 入口，从 `slugify` 与 `special` 模块导入 `slugify` 核心函数，导出 `DEFAULT_SEPARATOR`、`smart_truncate` 等工具函数，并提供版本信息，使用户通过简单的 `from slugify import slugify` 语句即可访问所有主要功能。`slugify.py` 文件中需要 `slugify()` 函数的完整实现，包含全部参数选项与 Unicode 处理逻辑。`slugify.py` 文件下应有 `smart_truncate` 函数用于智能截断字符串；`special.py` 文件中应有 `PRE_TRANSLATIONS`、`CYRILLIC`、`GERMAN`、`GREEK` 等常量，用于多语言字符的预定义转换规则；`__main__.py` 文件中应有 `slugify_params` 与 `parse_args` 函数用于命令行参数解析。

**考点**：在 `text-unidecode` 之上做多语言音译与 HTML 实体/数字实体解码，难点是中文按拼音逐字转写、停用词与词边界截断、`--replacements` 自定义替换的优先级，以及 CLI 参数与库函数参数的一一对应。

## 72. `pythonprojecttemplate`（测试数 36）

**中文规格**

请创建一个名为 FastVector 的 Python 项目，实现一个二维向量数学计算库。项目应包含以下功能：

1. **向量类设计**：实现一个 `Vector2D` 类，可表示二维向量，支持用多种数值类型（整数、浮点数）初始化，包含完整的参数校验与类型检查机制。该类应提供清晰的构造函数与属性访问方法。

2. **向量代数运算**：实现完整的向量代数运算，包括向量加法（`+`）、向量减法（`-`）、标量乘法（`*`）、向量除法（`/`）、点积运算（`*`）等。所有运算都应支持浮点精度，并正确处理零向量、负值向量等边界情况。

3. **向量比较与特殊方法**：基于向量模长比较实现向量比较运算（`==`、`<`、`>` 等）。同时实现字符串表示方法（`__repr__`、`__str__`）以提供清晰的向量显示格式。实现模长计算（`abs()`）与布尔值转换。

4. **错误处理与类型安全**：为所有运算提供完善的错误处理机制，包括类型错误、除零错误、不支持的操作等异常情况。确保类型安全，防止与不兼容类型进行运算。

5. **示例与测试脚本**：提供示例代码与完整测试用例，演示如何创建向量、执行各类运算、处理异常情况等。测试应覆盖所有核心功能、边界情况与错误处理。

6. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件，该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `numpy` 等核心库）。`pyproject.toml` 应能验证所有功能模块是否正常工作，同时提供 `fastvector/__init__.py` 作为统一 API 入口，从 `vector` 模块导入 `Vector2D` 核心类并提供版本信息，使用户通过简单的 `from fastvector import Vector2D` 语句即可访问所有主要功能。`vector.py` 中应有完整的 `Vector2D` 类实现，包含所有必要的双下划线（dunder）方法。

**考点**：用 `Vector2D` 演示「可安装模板项目」的最小闭环（打包元数据 + 单模块实现 + 测试），难点是同一运算符 `*` 同时承载标量乘法与点积时的类型分派，以及比较运算统一按模长排序而非按分量逐个比较。

## 73. `pytorch-grad-cam`（测试数 178）

**中文规格**

请创建一个名为 PyTorch Grad-CAM 的 Python 项目，实现一个面向计算机视觉的可解释 AI 工具包。项目应包含以下功能：

1. **多种 CAM 算法的实现**：实现多种类激活图方法，包括 GradCAM（基于梯度的类激活图）、HiResCAM（高分辨率 CAM）、ScoreCAM（基于分数的 CAM）、AblationCAM（基于消融的 CAM）、EigenCAM（基于特征值的类激活图）、GradCAM++（改进版 GradCAM）、XGradCAM（基于归一化梯度的 CAM）、LayerCAM（基于层的 CAM）、FullGrad（全梯度方法）、KPCA_CAM（基于核主成分分析的 CAM）、ShapleyCAM（基于 Shapley 值的 CAM）、FinerCAM（细粒度 CAM）、FEM（特征增强方法）等。每种方法都应提供独立的类实现，继承 `BaseCAM` 基类。

2. **多架构模型支持**：实现能适配不同深度学习架构的功能，包括 CNN 网络（ResNet、VGG、DenseNet 等）、Vision Transformer（ViT、DeiT 等）、Swin Transformer、目标检测网络（Faster R-CNN、YOLO 等）、语义分割网络等。应提供 `reshape_transform` 参数来处理不同架构下激活图的形状变换。

3. **多任务目标适配**：为不同计算机视觉任务提供专门的目标函数，包括图像分类（`ClassifierOutputTarget`、`ClassifierOutputSoftmaxTarget`）、目标检测（`FasterRCNNBoxScoreTarget`）、语义分割（`SemanticSegmentationTarget`）、嵌入相似度（`EmbeddingSimilarityTarget`）等。每个目标函数都应实现 `__call__` 方法以处理模型输出。

4. **图像处理与可视化工具**：提供完整的图像预处理与后处理功能，包括用于图像标准化的 `preprocess_image()` 函数、用于把 CAM 叠加到原图上的 `show_cam_on_image()` 函数、用于图像反标准化的 `deprocess_image()` 函数、用于调整 CAM 尺寸的 `scale_cam_image()` 函数等。支持 RGB/BGR 格式转换与多种颜色映射（colormap）。

5. **评测指标与测试框架**：实现多种 CAM 评测指标，包括 ROAD（Remove and Debias）指标（`ROADMostRelevantFirst`、`ROADLeastRelevantFirst`、`ROADCombined`）、置信度扰动指标（`PerturbationConfidenceMetric`）、多图 CAM 指标（`CamMultImageConfidenceChange`）等。提供完整的 pytest 测试框架，包含覆盖所有 CAM 方法与不同配置的 178 个测试用例。

6. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件，该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `torch>=1.7.1`、`torchvision>=0.8.2`、`opencv-python>=4.5.0`、`matplotlib>=3.3.0`、`scikit-learn>=0.24.0`、`numpy>=1.19.0`、`scipy>=1.5.0`、`ttach>=1.0.0`、`tqdm>=4.50.0`、`pytest>=6.0.0`、`psutil>=5.8.0`、`timm>=0.4.0` 等核心库）。`pyproject.toml` 文件应能验证所有功能模块是否正常工作。同时需要 `pytorch_grad_cam/__init__.py` 作为统一 API 入口，从各 CAM 模块导入全部 CAM 类，导出 `AGradCAM`、`ScoreCAM`、`GradCAMPlusPlus`、`AblationCAM`、`XGradCAM`、`EigenCAM`、`EigenGradCAM`、`LayerCAM`、`FullGrad`、`KPCA_CAM` 等核心类与函数并提供版本信息，使用户通过 `from pytorch_grad_cam import **`／`from pytorch_grad_cam.utils import **` 这类简单语句即可访问所有主要功能。`base_cam.py` 中需要 `BaseCAM` 基类来定义所有 CAM 方法的公共接口，包括用于执行 CAM 计算的 `__call__()` 方法、用于前向传播的 `forward()` 方法、用于获取 CAM 权重的 `get_cam_weights()` 方法等。

**考点**：用统一的 `BaseCAM`（`forward` → `get_cam_weights` → 加权求和）抽象出十余种 CAM 变体，难点是 `reshape_transform` 对 ViT/Swin 这类无 2D 特征的架构做激活图重塑，以及 `FasterRCNNBoxScoreTarget` 等在检测/分割输出结构上的目标函数适配。

## 74. `pytz`（测试数 235）

**中文规格**

请创建一个名为 pytz 的 Python 项目，实现一个完整的时区处理库。项目应包含以下功能：

1. **时区数据库解析器**：应能解析并加载 IANA（原 Olson）时区数据库中的全部标准时区定义，支持时区名称查询（如 `'US/Eastern'`、`'Europe/London'` 等）并创建时区对象。解析结果应为可用的时区对象，支持时区信息查询与转换操作。

2. **本地化时间处理**：实现处理本地时间的夏令时转换与歧义时间问题的功能。应支持通过 `localize()` 方法把不带时区信息的 naive `datetime` 对象转换为带时区信息的 `datetime` 对象，正确处理夏令时开始与结束时的歧义时间，并处理不存在的夏令时时间。

3. **时区转换系统**：实现完整的时区转换功能，包括 UTC 转换、时区之间的转换与时区偏移计算。应支持通过 `astimezone()` 方法在不同时区之间精确转换，并处理夏令时转换期间的复杂情况。

4. **特殊时区处理**：优化 UTC、GMT 等标准时区的实现，提供高效的 UTC 时区对象，并支持序列化与反序列化。同时处理历史时区变更与时区规则更新。

5. **接口设计**：为每个功能模块（如时区查询、本地化处理、时区转换、国家时区查询等）设计独立的函数接口，支持简单的 API 调用。每个模块应定义清晰的输入与输出格式。

6. **示例与评测脚本**：提供示例代码与测试用例，演示如何使用 `timezone()`、`localize()` 与 `astimezone()` 函数进行时区操作与转换（例如 `timezone('US/Eastern').localize(datetime(2002, 10, 27, 6, 0, 0))` 应返回正确的本地化时间对象）。上述功能需要组合起来，构建完整的时区处理工具包。最终项目应包含时区数据库、本地化处理与转换系统等模块，并附典型测试用例，形成可复现的时区处理流程。

7. **核心文件要求**：项目必须包含完整的 `setup.py` 文件。该文件应把项目配置为可安装包（支持 `pip install`）。`setup.py` 文件应能验证所有功能模块是否正常工作。同时需要提供 `pytz/__init__.py` 作为统一 API 入口，导入 `LazyList`、`LazySet`、`LazyDict`、`BaseTzInfo` 等核心类与函数，并提供版本信息，使用户通过 `import pytz` 与 `from pytz.lazy import ` 这类简单语句即可访问所有主要功能。`tzinfo.py` 中有一个 `BaseTzInfo` 类，使用多种策略处理时区信息与夏令时转换。

**考点**：以 `BaseTzInfo` 承载 IANA 时区规则并区分 `localize()`（naive→aware）与 `normalize()`/`astimezone()`（aware 跨时区换算），难点是夏令时切换窗口的歧义时间与非存在时间判定，以及 `LazyList`/`LazyDict` 对时区数据库的惰性加载。
