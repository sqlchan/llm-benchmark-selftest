# NL2Repo-Bench 全题规格中文翻译 · Part 17（第 100–103 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 100. `voluptuous`（测试数 152）

**中文规格**

请创建一个名为 voluptuous 的 Python 项目，实现一个 Python 数据校验库。项目应包含以下功能：

1. 基础类型校验测试：
    - int 类型校验：校验整数输入（123）与非法输入（"abc"）。
    - str 类型校验：校验字符串输入（"text"）与非法输入（123）。
    - float 类型校验：校验浮点数输入（3.14）与非法输入（"a"）。
    - bool 类型校验：校验布尔输入（True/False）与非法输入（1）。

2. 复杂数据结构测试：
    - 嵌套字典校验：{"user": {"name": str, "age": int}}。
    - 列表校验：[int]（校验 [1,2,3] 与 [1,"a",3]）。
    - 元组校验：(str, int)（校验 ("a",1) 与 (1,"a")）。
    - 混合结构校验：{"data": [{"id": int}]}。

3. 标记（Marker）测试：
    - Required 测试：校验必填字段缺失时的错误上报。
    - Optional 测试：校验可选字段的默认值功能。
    - Exclusive 测试：校验互斥字段的「多选一」逻辑。
    - Inclusive 测试：校验关联字段的「共存」要求。
    - Remove 测试：校验字段移除功能。

4. 内置校验器测试：
    - All 校验器：测试多个条件同时满足。
    - Any 校验器：测试任意一个条件满足即可。
    - Range 校验器：测试数值范围限制。
    - Length 校验器：测试长度限制。
    - Email 校验器：测试邮箱格式校验。
    - Url 校验器：测试 URL 格式校验。

5. 错误处理测试：
    - 单错误测试：校验单个错误的抛出与错误信息。
    - 多错误测试：校验 MultipleInvalid 中对多个错误的收集。
    - 错误路径测试：校验嵌套结构的错误路径追踪。
    - 自定义消息测试：校验自定义错误信息的展示。

6. 性能测试：
    - 小数据集测试：校验 100 条记录的耗时。
    - 大数据集测试：校验 100,000 条记录的耗时。
    - 复杂结构测试：校验深层嵌套结构的性能。
    - 缓存测试：校验重复校验场景下的性能优化。

7. 边界条件测试：
    - None 值测试：校验 None 值的处理逻辑。
    - 空字符串测试：校验 "" 的特殊处理。
    - 空列表测试：校验 [] 的特殊处理。
    - 边界值测试：校验 int 最大值等边界条件。

8. 自定义校验器测试：
    - 简单自定义校验器：测试偶数校验器。
    - 复杂自定义校验器：测试业务规则校验器。
    - 带参数的校验器：测试可配置参数的校验器。
    - 组合校验器：测试自定义校验器与内置校验器的组合。

9. Schema 推断测试：
    - 简单结构推断：测试对 {"a":1} 的自动推断。
    - 复杂结构推断：测试对嵌套结构的自动推断。
    - 混合类型推断：测试对多类型数据的推断。
    - 推断结果校验：测试推断出的 Schema 的可用性。

10. 装饰器测试：
    - 函数参数校验：测试 @validate 装饰器对参数的校验。
    - 返回值校验：测试 @validate 装饰器对返回值的校验。
    - 错误处理：测试装饰器的错误捕获。
    - 性能影响：测试装饰器带来的性能损耗。

11. 示例与评测脚本：提供示例代码与测试用例，演示如何使用 Schema() 与 validate() 函数完成数据结构校验与数据完整性检查（例如 validate(Schema({'name': str, 'age': int}), {'name': 'Tom', 'age': 25}) 应返回校验后的数据）。上述功能需组合起来，构建完整的数据校验工具集。项目最终应包含 Schema 构建、校验器组合、错误处理等模块以及典型测试用例，形成可复现的校验流程。

12. 核心文件要求：项目必须包含完整的 pyproject.toml 文件。该文件不仅要把项目配置为可安装包（支持 pip install），还要声明完整的依赖列表（包括 setuptools: 65.5.0、pytest: 7.1.2、pytest-cov: 3.0.0、coverage: 6.4.1、black: 22.3.0、isort: 5.10.1、flake8: 4.0.1、mypy: 0.940 等开发依赖）。pyproject.toml 应能验证所有功能模块是否正常工作。同时需要提供 voluptuous/__init__.py 作为统一 API 入口，导入 ALLOW_EXTRA、PREVENT_EXTRA、REMOVE_EXTRA、All、AllInvalid、Any、Clamp、Coerce、Contains、ContainsInvalid、Date、Datetime、Email、EmailInvalid、Equal、ExactSequence 等核心类与函数，导出 Invalid、MultipleInvalid 等错误类型，并提供版本信息，使用户通过简单的 "from voluptuous import *" 语句即可访问全部主要功能。在 validators.py 中需要提供 validate() 函数，以便使用多种策略校验数据结构的完整性与正确性。

**考点**：以 Schema 为中心的声明式校验组合，覆盖类型/嵌套结构的递归校验、Required/Optional/Exclusive/Inclusive/Remove 五个标记的语义、All/Any/Range/Length/Email/Url 等内置校验器，以及 MultipleInvalid 的多错误与错误路径收集；还需验证 @validate 装饰器与 Schema 推断。

## 101. `wifiphisher`（测试数 43）

**中文规格**

请创建一个名为 WiFiPhisher 的 Python 项目，实现一个 WiFi 安全测试框架。项目应包含以下功能：

1. **无线网络接口管理**：应能检测与管理无线网络接口，支持 AP 模式与 Monitor 模式，自动识别可用的无线网卡并配置其工作模式。需要实现接口 MAC 地址随机化、虚拟接口创建以及与网络管理器集成等功能。

2. **伪造接入点创建**：实现伪造 WiFi 接入点的创建与管理，支持 WPA/WPA2 加密配置，集成 DHCP 与 DNS 服务器，能够为接入的客户端分配 IP 地址并提供网络服务。

3. **WiFi 攻击技术实现**：实现多种 WiFi 攻击技术，包括 Evil Twin 攻击（创建与目标网络完全相同的伪造 AP）、KARMA 攻击（响应客户端的 probe 请求）、Known Beacons 攻击（广播已知网络名称）等。

4. **钓鱼页面系统**：提供多种钓鱼场景的模板，包括固件升级页面、OAuth 登录页面、插件更新页面、WiFi 连接页面等，并支持动态内容生成与用户交互处理。

5. **可扩展系统架构**：设计模块化的扩展体系，支持 deauth（解除认证攻击）、lure10（位置欺骗攻击）、wpspbc（WPS 按键攻击）、knownbeacons（已知信标攻击）等扩展模块。

6. **网络流量管理**：实现防火墙规则管理、NAT 配置、流量重定向等功能，保证钓鱼页面的正常访问与网络隔离。

7. **用户界面系统**：提供基于 curses 的文本用户界面，支持接入点选择、钓鱼场景选择、实时状态显示等功能。

8. **受害设备管理**：实现受害设备的识别、跟踪与管理，包括 MAC 地址匹配、操作系统识别与设备厂商识别。

9. **凭据捕获系统**：实现用户输入的捕获与处理，支持获取多种认证方式的凭据，包括 WiFi 密码与社交账号。

10. **运行模式管理**：支持单网卡模式、双网卡模式、三网卡模式等多种运行模式的配置，并根据硬件配置自动选择最优模式。

11. **网络侦察功能**：实现无线网络扫描、接入点发现、客户端探测等功能，为攻击目标选择提供支持。

12. **安全校验系统**：集成 WPA 握手校验与密码强度检查等功能，确保攻击的有效性与安全性。

13. **核心文件要求**：项目必须包含完整的 setup.py 文件，应把项目配置为可安装包（支持 pip install 与可编辑模式安装）并声明完整的依赖列表——包括 scapy（网络数据包处理）、tornado（Web 服务构建）、pyric（无线网卡管理）、roguehostapd（伪造接入点）、pbkdf2（密码哈希计算）等核心库——以保证攻击过程中的抓包、接入点模拟、Web 钓鱼页面部署等功能具备正常依赖。setup.py 应通过配置验证所有功能模块（如接入点伪造、客户端欺骗、钓鱼模板加载、扩展插件运行）的有效性，支持通过测试命令触发全功能验证，覆盖无线接口配置、攻击流程联动、异常场景处理等关键环节。同时需要提供 wifiphisher/__init__.py 作为统一 API 入口。该文件应整合各核心模块的关键组件：从 common 模块导入 AccessPoint（伪造接入点管理类）、victim（受害设备信息处理）、interfaces（网络接口管理工具）与 constants（攻击常量定义）；从 extensions 模块导入 ExtensionManager（扩展插件管理类）与具体的扩展功能（如 deauth（客户端断连攻击）、lure10（诱饵攻击插件））；从 template 模块导入 PhishingTemplate（钓鱼页面模板处理类）；此外导出 Extension（扩展基类）等核心组件，并通过 __version__ 提供版本信息，确保用户通过 `from wifiphisher import AccessPoint, ExtensionManager` 这样的简单语句即可访问全部主要功能，覆盖接入点配置、扩展插件调用、钓鱼流程控制等核心能力。在 pywifiphisher.py 中，WifiphisherEngine 类应作为攻击流程的核心管理者，协调各模块的工作：通过 AccessPoint 创建伪造热点，使用 interfaces 把无线网卡配置为监听模式；调用 extensions.deauth 发送解除认证帧断开目标设备，并结合 lure10 扩展诱导设备接入伪造网络；使用 ExtensionManager 加载并运行各类攻击插件，通过 victim 模块跟踪受害设备状态；联动 PhishingTemplate 部署钓鱼页面（依赖 tornado 搭建临时 Web 服务），最终完成从设备欺骗到信息窃取的全流程攻击编排，确保各模块按攻击逻辑有序联动，提高攻击成功率。

**考点**：以伪造 AP（roguehostapd + tornado 钓鱼页面）为中枢的攻击链编排——网卡模式切换与 MAC 随机化、deauth/karma/knownbeacons/lure10 等扩展插件的加载调度、受害设备跟踪与凭据捕获，最终由 WifiphisherEngine 串成从设备欺骗到信息窃取的完整流程。

## 102. `wsgidav`（测试数 36）

**中文规格**

请创建一个名为 WsgiDAV 的 Python 项目，实现一个 WebDAV 服务器。项目应包含以下特性：

1. **WebDAV 文件共享服务**：支持通过 WebDAV 协议共享本地文件系统、虚拟目录或自定义存储后端。用户可以使用 Windows 资源管理器、macOS Finder、Linux 文件管理器、MS Office 以及各类 WebDAV 客户端等工具，像操作本地文件一样访问、上传、下载、重命名与删除远程文件。

2. **标准 WebDAV 协议支持**：完整实现 WebDAV 协议（RFC 4918）中的核心方法，包括 GET、PUT、DELETE、PROPFIND、PROPPATCH、MKCOL、COPY、MOVE、LOCK、UNLOCK、OPTIONS 等，并兼容主流 WebDAV 客户端与自动化脚本。

3. **灵活的认证与权限管理**：支持匿名访问与内置的简单用户名密码认证，并可扩展集成 NT 域、PAM、LDAP、OAuth 等多种认证方式。可按需为不同目录配置访问权限，实现多用户隔离与安全控制。

4. **属性与元数据管理**：支持 WebDAV 扩展属性（如自定义元数据、文档属性）的读写，便于实现文档管理、打标签、备注等高级功能。

5. **锁与并发控制**：实现 WebDAV 锁机制，支持独占锁与共享锁等多种模式，保证多用户协作时的数据一致性与并发安全。

6. **可扩展的存储后端**：通过自定义 Provider 机制，开发者可以把数据库、云存储、对象存储、虚拟文件系统等任意数据源以 WebDAV 协议暴露出来，满足企业级集成与二次开发需求。

7. **WSGI 标准集成与中间件扩展**：既可以作为独立服务运行，也可以作为 WSGI 应用集成进 Django、Flask、FastAPI 等 Python Web 项目。支持自定义中间件，灵活扩展日志、CORS、调试、权限等功能。

8. **跨平台与易部署**：兼容 Windows、Linux 与 macOS，支持 pip 安装、Docker 部署、命令行快速启动，以及通过配置文件灵活管理。

9. **丰富配置与自动化测试**：支持 YAML/JSON/Python dict 等多种配置方式，并内置详尽的自动化测试用例，便于持续集成与功能验证。

WsgiDAV 适用于企业文件网关、私有云盘、数据平台、虚拟文件系统、自动化办公、异构存储整合等多种场景，可显著提升数据共享、协作与自动化能力。

---

10. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件，需要把项目配置为可安装包（支持 `pip install`）并声明完整的依赖列表（如 `defusedxml==0.7.1`、`Jinja2==3.1.6`、`json5==0.12.1`、`PyYAML==6.0.2` 等实际使用的核心库）。`pyproject.toml` 文件应确保所有核心功能模块都能正常工作。同时应提供 `wsgidav/__init__.py` 作为统一 API 入口，导入并导出全部关键功能，使用户通过 `from wsgidav import *` 这样的简单语句即可访问全部主要功能。

**考点**：完整落地 RFC 4918 的核心方法集与 LOCK/UNLOCK 并发语义，叠加 Provider 抽象（本地文件/虚拟目录/自定义后端）与 WSGI 中间件链；难点在 PROPFIND/PROPPATCH 的 XML 属性映射和 YAML/JSON/dict 多配置来源的统一。

## 103. `xlrd`（测试数 84）

**中文规格**

请创建一个名为 `Excel-Reader` 的 Python 项目，实现一个读取 Excel 文件数据的库。项目应包含以下功能：

1. Excel 文件读取：应能读取 `.xls` 格式的 Excel 文件，并支持从文件中提取数据与格式信息。不支持读取 `.xlsx` 格式文件，建议改用 `openpyxl` 作为替代方案。

2. 数据解析：实现解析 Excel 文件中数据的函数（或脚本），包括单元格内容、工作表名称、行数、列数等信息。解析结果应转换为 Python 数据结构（如列表、字典等）或其他等价的可操作形式。

3. 特殊内容处理：Excel 文件中的特殊内容（如图表、宏、图片、嵌入对象、VBA 模块、公式、批注、超链接、自动筛选、高级筛选、数据校验等）应做特殊处理，这些内容将被安全忽略。

4. 接口设计：为每个功能模块（如文件读取、数据解析等）设计独立的命令行接口或函数接口，以支持终端调用测试。每个模块应定义清晰的输入与输出格式。

5. 示例与评测脚本：提供示例代码与测试用例，演示如何使用 `open_workbook()` 等函数完成文件读取与数据解析。例如 `open_workbook("myfile.xls")` 应能成功打开并读取文件内容。上述功能需组合起来，构建完整的 Excel 读取工具集。最终项目应包含文件读取、数据解析等模块以及典型测试用例，形成可复现的读取流程。

6. 核心文件要求：项目必须包含完整的 `setup.py` 文件。该文件需要把项目配置为可安装包（支持 `pip install`）并声明完整的依赖列表（如 coverage==7.2.7、exceptiongroup==1.3.0 等实际使用的核心库）。`setup.py` 文件应确保所有核心功能模块都能正常工作。同时需要提供 `xlrd/__init__.py` 作为统一 API 入口，导入并导出 open_workbook、XLRDError、xldate、inspect_format、biffh、XL_CELL_TEXT、xrange、UNICODE_LITERAL、Book 等类与主要导入导出函数，并提供版本信息，使用户通过 `import xlrd` 以及 `from xlrd.biffh/timemachine/book import **` 这样的简单语句即可访问全部主要功能。

**考点**：解析 `.xls` 的二进制容器与记录流，把工作簿/工作表结构、单元格值（含 XL_CELL_TEXT 等类型常量）、格式索引与日期序列值转换（xldate）暴露为稳定 API，同时对图表、宏、VBA、批注等特殊记录安全跳过；并明确划出「不支持 `.xlsx`」的边界。
