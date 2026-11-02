# NL2Repo-Bench 全题规格中文翻译 · Part 10（第 64–68 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 64. `pytestify`（测试数 122）

**中文规格**

请创建一个名为 Pytestify-Test 的 Python 测试脚本，全面验证 Pytestify 项目的功能。该测试脚本应包含以下测试场景：

1. 断言转换测试：验证全部受支持的断言方法（共 27 种）从 unittest 格式到 pytest 格式的正确转换，包括基本断言、二元断言、近似相等断言等。测试应覆盖单行与多行断言格式，以及带错误消息的断言。

2. 基类转换测试：验证测试类从继承 unittest.TestCase 转换为不继承任何基类，包括类名的规范化。测试应覆盖不同命名风格的测试类（如 TestThing、ThingTest、ThingTestCase 等）。

3. 方法名转换测试：验证生命周期方法（setUp/tearDown 等）与测试方法名的转换，包括把 camelCase 命名转换为 snake_case 命名的选项。测试应覆盖不同命名风格的测试方法。

4. 函数调用转换测试：验证把 unittest 函数调用转换为其 pytest 等价形式，包括异常断言、skip 装饰器与预期失败装饰器的转换。测试应覆盖各种使用场景与参数组合。

5. 导入管理测试：验证 pytest 导入的智能添加功能，确保在需要时自动添加 `import pytest` 语句，且不出现重复导入。

6. 组合功能测试：验证组合使用多个转换函数时的正确性，模拟真实项目中的复杂转换场景。

7. 错误处理测试：验证工具安全处理非法输入、语法错误等情况的能力。

8. 项目必须包含配置完善的 setup.py 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 tokenize-rt>=4.0.0、pytest>=6.2.5、mypy>=1.8.0、Sphinx>=7.2.6 等核心库）。该 setup.py 文件应能验证所有功能模块是否正常工作。同时应提供 pytestify/__init__.py 作为统一 API 入口，导入并导出 rewrite_asserts、remove_base_class、rewrite_pytest_funcs、add_pytest_import、rewrite_method_name、main 等主要导入导出函数，并提供版本信息，使用户通过 "from pytestify._main import *" 与 "from pytestify.fixes.asserts/base_class/funcs/imports/method_name import *" 这类简单语句即可访问所有主要功能。

**考点**：用 27 种断言的语法树级改写覆盖 unittest→pytest 迁移的全部边界（单行/多行、带消息、近似相等），并验证类名与方法名的命名风格转换、`import pytest` 的按需去重插入，以及 `pytestify/__init__.py` 的导出面完整性。

## 65. `python-dotenv`（测试数 209）

**中文规格**

请创建一个名为 python_dotenv 的 Python 项目，它是一个用于管理环境变量的 Python 库。项目应包含以下功能：

1. 环境变量加载：
 - 从 .env 文件把环境变量加载到 os.environ 中。
 - 支持通过 load_dotenv() 函数进行加载。
 - 支持从文件流加载环境变量。

2. 文件解析：
 - 解析 .env 文件格式。
 - 支持带引号与不带引号的值。
 - 支持行内注释。
 - 支持多行值（使用三引号）。

3. 变量解析：
 - 支持变量插值（例如 VAR1=foo 与 VAR2=${VAR1}/bar）。
 - 支持默认值（例如 ${VAR:-default}）。
 - 支持对环境变量的嵌套引用。

4. 命令行接口：
 - 列出所有环境变量。
 - 获取指定键的值。
 - 设置一个键值对。
 - 删除一个键值对。
 - 带环境变量运行命令。

5. 工具函数：
 - 在文件系统中查找 .env 文件。
 - 获取/设置/删除指定的键值对。
 - 覆盖写入 .env 文件。

6. 核心文件要求：项目必须包含完整的 setup.py 文件，该文件不仅要把项目配置为可安装包（支持 pip install），还要声明完整的依赖清单（包括 click>=5.0、pytest、pytest-cov、ipython、twine、wheel 等核心库）。该 setup.py 应能验证所有功能模块是否正常工作。同时需要提供 dotenv/__init__.py 作为统一 API 入口，从 dotenv 模块导入并导出核心函数，使用户通过 "from dotenv import get_cli_string as c" 或 "from dotenv.xx import xxx" 这类简单语句即可访问所有主要功能。

**考点**：`.env` 解析（引号、行内注释、三引号多行的换行拼接）与 `${VAR}`、`${VAR:-default}` 插值的组合语义，加上 cli/list/get/set/unset/run 命令面与 `dotenv` 包导出一致性。

## 66. `python-fsutil`（测试数 153）

**中文规格**

请创建一个名为 python-fsutil 的 Python 项目，实现一个高级的文件系统操作工具库。项目应包含以下功能：

1. 文件操作模块：提供创建、复制、移动、删除等基础文件操作，支持跨平台兼容性与错误处理。操作结果应为结构化的返回值或异常信息，便于后续处理与调试。

2. 目录操作模块：实现目录的创建、复制、移动、删除与清理等功能，支持递归操作与批量处理。应支持多种目录操作选项，以提升文件管理的灵活性与效率。

3. 路径处理模块：支持路径拼接、拆分、规范化与相对路径转换等操作，适用于复杂的文件路径处理场景。

4. 文件信息获取模块：提供获取文件大小、创建时间、修改时间、权限与哈希值等信息的功能，支持格式化输出与批量处理。

5. 压缩与解压模块：支持 tar、zip 等常见压缩格式的创建与解压，适用于文件打包与分发场景。

6. 文件读写模块：提供文本文件、JSON 文件与二进制文件等多种文件格式的读写功能，支持多种编码与错误处理。

7. 接口设计：为每个功能模块设计独立的函数接口，支持链式调用与批量操作。各模块应定义清晰的输入与输出格式，便于集成到自动化工具链中。

8. 示例与测试脚本：提供示例代码与测试用例，演示如何使用各种文件操作函数（如 create_file()、copy_dir()、get_file_size() 等）。上述功能需要组合起来构建完整的文件系统操作工具集。项目最终应包含文件操作、目录管理、路径处理、信息获取、压缩解压与文件读写等模块，并附带典型测试用例，形成可复现的文件管理流程。

9. 核心文件要求：项目必须包含完整的 pyproject.toml 文件，该文件需要把项目配置为可安装包（支持 pip install 与可编辑模式安装），声明完整的依赖清单——包括 pytest 等测试库与 requests 等运行时依赖（由 require_requests 依赖推断而来），并指定支持的 Python 版本范围。pyproject.toml 文件需要通过构建配置确保所有功能模块（如文件 IO、路径处理、压缩解压、权限管理等）在安装后正常工作，并支持通过测试命令触发全功能验证。同时需要提供 src/fsutil/__init__.py 作为统一 API 入口。该文件需要从 archives 模块导入核心压缩解压函数（create_zip_file、extract_zip_file、create_tar_file、extract_tar_file），从 checks 模块导入存在性与类型检查函数（exists、is_file、is_dir、is_empty），从 converters 模块导入格式转换工具（convert_size_bytes_to_string、convert_size_string_to_bytes），从 info 模块导入信息获取函数（get_file_size、get_file_hash、get_dir_size、get_file_creation_date），从 io 模块导入核心文件读写函数（create_file、read_file、write_file、read_file_lines、list_files），从 operations 模块导入文件操作工具（copy_dir、copy_dir_content、delete_dir、delete_dir_content、clean_dir、make_dirs、remove_dir_content、create_dir、get_unique_name），从 paths 模块导入路径处理函数（join_path、split_filename、get_file_basename、get_file_extension、get_filename、get_parent_dir、join_filename、join_filepath、split_filepath、transform_filepath、split_path、get_path），从 perms 模块导入权限管理工具（get_permissions、set_permissions）；此外还需要从 metadata 模块导入 author、version 等元数据信息，从 args 模块导入 get_path 等参数处理工具，从 deps 模块导入 require_requests 依赖检查工具，从 exceptions 模块导入 FSUtilError 异常类。该 API 入口需要整合上述导入，确保用户通过简单的 `import fsutil` 语句即可访问所有主要功能，包括文件 IO、路径解析、压缩解压、权限控制与依赖检查；同时通过 fsutil.__version__ 等属性暴露元数据。pyproject.toml 文件需要与 MANIFEST.in 配合，确保元数据文件、类型提示与核心模块被完整打包，保证安装后的功能可用性与 API 一致性。

**考点**：把 IO、目录、路径、元信息、压缩、权限等十余个子模块收敛到单一 `fsutil` 命名空间，难点是 `__init__.py` 导出清单的完整性、`pyproject.toml`+`MANIFEST.in` 的打包配置，以及跨平台文件操作与结构化返回值的错误处理约定。

## 67. `python-jose`（测试数 458）

**中文规格**

请创建一个名为 python-jose 的 Python 项目，实现一个完整的 JOSE（JavaScript Object Signing and Encryption）标准库。该项目应包含以下功能：

1. JWT 令牌管理：生成、验证与解析 JSON Web Token，支持对标准声明（如 exp、iat、nbf、aud、iss、sub、jti、at_hash）的自动校验，并支持多种签名算法（HS256、HS384、HS512、RS256、RS384、RS512、ES256、ES384、ES512 等）。

2. JWS 数字签名：实现 JSON Web Signature 功能，对数据进行数字签名与验证，支持多种签名算法与密钥格式，确保数据完整性与来源认证。

3. JWE 数据加密：实现 JSON Web Encryption 功能，对敏感数据进行加密与解密，支持对称加密（AES）与非对称加密（RSA），提供数据机密性保护。

4. JWK 密钥管理：支持 JSON Web Key 格式密钥的生成、导入、导出与管理，支持多种密钥类型（RSA、EC、oct、OKP）以及密钥集（JWK Set）操作。

5. 多后端加密支持：提供多种加密后端选项（cryptography、pycryptodome、native-python），满足不同的安全与性能要求，允许用户根据自身环境选择合适的加密实现。

6. 接口设计：为每个功能模块（如 JWT、JWS、JWE、JWK）设计清晰的 API 接口，支持简单易用的函数调用与高级配置选项。各模块应提供完整的错误处理与异常管理。

7. 示例与测试脚本：提供示例代码与测试用例，演示如何使用 encode()、decode()、sign()、verify()、encrypt()、decrypt() 等函数完成令牌操作、签名验证与加解密（例如 jwt.encode({'user_id': 123}, 'secret', algorithm='HS256') 应返回一个有效的 JWT 令牌）。上述功能需要整合起来，构建完整的 JOSE 标准实现库。项目最终应包含 JWT、JWS、JWE、JWK 等核心模块，并附带典型测试用例，形成可复现的安全令牌处理流程。

8. 核心文件要求：项目必须包含定义完善的 pyproject.toml 文件。该文件不仅要把项目配置为可安装包（支持 pip install），还要声明完整的依赖清单（包括 cryptography、pytest 等支撑加密算法、密钥处理与测试需求的核心库）。此外，需要提供 jose/__init__.py 作为统一 API 入口。该文件应从 jwt、jws、jwk、jwe 模块导入核心函数（jwt、jws、jwk、jwe）与工具函数，从 exceptions 模块导入 JWTError、JWSError、JWKError、JWEError、JWEParseError、JOSEError 等异常类，从 constants 模块导入 ALGORITHMS、ZIPS 等常量，从 backends 模块导入 RSAKey、ECKey、HMACKey、AESKey 等密钥处理类，从 backends.native 模块导入 NativeHMACKey 等原生实现类，从 jws 模块导入签名验证函数 verify，从 jwk 模块导入基础密钥类 Key。此外还应提供版本信息（如 `__version__`），确保用户通过 `from jose import jwt, jws, jwe, jwk, utils, ALGORITHMS` 这类简单语句即可访问所有主要功能。在 jwt.py 中应提供 encode() 与 decode() 函数以生成与验证 JWT 令牌；jws.py 应实现签名生成与验证函数（如 verify 函数）；jwk.py 应基于 Key 类提供密钥解析、生成与转换功能；jwe.py 应实现 JWE 的加解密逻辑，并提供 JWEError 等异常处理；各后端模块（backends）应提供不同算法的底层实现（如处理 RSA 算法的 RSAKey、处理 HMAC 算法的 HMACKey），以保证加密、签名等功能的完整性，且所有核心文件及其子文件必须严格位于 jose 包内，避免出现多个顶层包。

**考点**：在同一套 API 下同时打通 JWT/JWS/JWE/JWK 四条协议路径，并把 cryptography、pycryptodome、native-python 三种后端抽象成统一 `Key` 体系；难点是声明校验（exp/nbf/aud/iss…）、算法与密钥类型匹配，以及包内导入结构不产生多余顶层包。

## 68. `python-pathspec`（测试数 119）

**中文规格**

请创建一个名为 python-pathspec 的 Python 项目，实现一个文件路径模式匹配库。项目应包含以下功能：

1. **核心模式匹配引擎**：实现基于 Git wildmatch 算法的模式匹配系统，能够解析并应用类似 `.gitignore` 文件中的路径模式规则。支持通配符（如 `*.txt`、`**/build/`）、否定模式（如 `!*.tmp`）与目录标记（如 `src/`）等复杂模式语法。

2. **PathSpec 基类**：创建 `PathSpec` 类作为模式匹配的核心接口，提供 `from_lines()` 方法从文本行编译模式规则、`match_file()` 方法检查单个文件是否匹配、`match_files()` 方法批量匹配文件列表，以及 `match_tree_files()` 方法遍历目录树进行匹配。

3. **GitIgnore 规范实现**：实现 `GitIgnoreSpec` 类以准确复刻 Git 的 `.gitignore` 行为，包括模式优先级规则、目录匹配逻辑与否定模式处理。该类应继承 `PathSpec` 并重写匹配逻辑以符合 Git 规范。

4. **模式解析器**：创建 `GitWildMatchPattern` 类实现 Git wildmatch 算法，把模式字符串转换为正则表达式，并支持转义字符、注释处理与模式否定等功能。该类应继承 `RegexPattern` 基类。

5. **工具函数模块**：提供文件路径标准化、目录树遍历、模式查找等工具函数，如 `normalize_file()`、`iter_tree_files()`、`lookup_pattern()` 等，支持跨平台路径处理。

6. **接口设计**：为每个功能模块设计清晰的 API 接口，同时支持命令行与编程式调用。各模块应定义清晰的输入与输出格式，提供类型提示与文档字符串。

7. **示例**：提供示例代码，演示如何使用 `PathSpec.from_lines()` 编译模式规则、如何使用 `match_files()` 执行文件匹配，以及如何使用 `GitIgnoreSpec` 实现完整的 `.gitignore` 功能。

8. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件，以便把项目配置为可安装包（支持 `pip install`）并声明完整的依赖清单。需要提供 `pathspec/__init__.py` 作为统一 API 入口，使用户通过 `from pathspec import xxx` 这类简单语句即可访问所有主要功能。从 `pathspec.util` 模块导入 `RecursionError` 异常、`check_match_file` 函数、`iter_tree_entries` 函数、`iter_tree_files` 函数、`match_file` 函数、`normalize_file` 函数、`CheckResult` 类与 `lookup_pattern` 函数；从 `pathspec.patterns.gitwildmatch` 模块导入 `GitWildMatchPattern` 类、`GitWildMatchPatternError` 异常、`_BYTES_ENCODING` 变量与 `_DIR_MARK` 变量；从 `pathspec` 模块导入 `PathSpec` 类；从 `pathspec.gitignore` 模块导入 `GitIgnoreSpec` 类。版本信息通过 `pathspec/_meta.py` 文件提供，该文件定义 `__version__` 变量以指定版本号（`__version__ = "0.12.2.dev1"`）。

**考点**：`PathSpec` 与 `GitIgnoreSpec` 共用 `GitWildMatchPattern` 正则编译管线，难点是 `.gitignore` 的「后匹配优先 + 否定不可回退」语义与目录标记边界。
