# NL2Repo-Bench 全题规格中文翻译 · Part 6（第 47–51 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。


## 46. `mechanicalsoup`（测试数 121）

**中文规格**

# MechanicalSoup_main 项目介绍

## 1. 项目概述与目标

MechanicalSoup 是一个基于 Python 的 Web 自动化交互库，旨在简化网页表单填写、页面导航与数据抓取等常见任务。它把 Requests（用于 HTTP 会话管理）与 BeautifulSoup（用于 HTML 解析与导航）结合起来，为用户提供类浏览器的自动化能力。本项目旨在让开发者用简洁的代码自动化网站交互流程，适用于网页爬虫、自动化测试、数据采集等场景。

## 2. 自然语言指令（Prompt）

请创建一个名为 MechanicalSoup_main 的 Python 项目，以支持自动化的 Web 操作与校验。项目应包含以下功能与测试点：

1. **网页表达式解析与表单结构识别**
   自动解析 HTML 页面与表单结构，提取输入控件（如文本框、单选按钮、复选框、下拉菜单、文件上传等）及其属性，并输出结构化对象，供后续的自动化操作与比较使用。

2. **自动化交互与等价性校验**
   支持自动模拟浏览器操作，包括页面请求、表单填写、提交、链接点击、页面跳转等，并能判断实际页面状态与表单内容是否与预期等价。
   支持对表单提交结果、页面跳转目标、响应内容等进行符号化的提取与比较。

3. **特殊结构与复杂场景处理**
   针对多选表单、动态生成的控件、复合输入、表单控件顺序变化等特殊结构，能智能判定等价性并处理错误。
   例如，顺序不同但内容相同的多选框应视为等价；当控件缺失或冗余时，应给出合理的提示与处理。

4. **接口设计与调用规范**
   每个功能模块（如解析、交互、等价判定等）都有独立的函数接口与命令行入口，支持直接从终端调用以及脚本集成。
   例如，`parse_form(html_str)` 返回结构化表单对象，`verify_form(expected, actual)` 返回布尔值。

5. **统一 API 入口与版本信息**
   项目必须包含完整的 `setup.py` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖列表（pytest >= 3.1.0、pytest-flake8 >= 1.3.0、requests_mock >= 1.3.0、werkzeug >= 3.0.3、pytest-cov、certifi >= 2022.12.7、urllib3 >= 2.2.2、pytest-httpbin、pytest-mock 等）。`setup.py` 应能验证所有功能模块是否正常工作。同时，需要在 `mechanicalsoup` 包中提供 `__init__.py` 作为统一的 API 入口，导出 `Browser`、`StatefulBrowser`、`Form`、`parse_form`、`verify_form` 等核心类与函数，并包含版本信息，方便用户通过 `from mechanicalsoup import ...` 或 `import mechanicalsoup` 访问所有主要功能。

6. **示例与评测脚本**
   提供丰富的示例代码与测试用例，演示如何使用 `parse_form()` 与 `verify_form()` 进行表单解析与自动化校验。
   例如，`verify_form(parse_form('<input name="a" value="1">'), parse_form('<input value="1" name="a">'))` 应返回 `True`。
   所有功能需组合起来，形成可复现的自动化 Web 操作与校验流程。

7. 依赖与环境配置
   各功能模块所需的所有第三方库（如 requests、beautifulsoup4、lxml、pytest 等）均在 setup.py 中以 name=about['__title__'] 完整声明，支持通过 pip install 一键安装并完成环境校验。

8. **边界与异常测试**
   覆盖表单缺失、页面 404 错误、控件异常、非法输入等边界与异常场景，确保各类异常都能被合理捕获与处理。


## 3. 环境配置（依赖库）

### Python 版本

当前项目使用的 Python 版本为：Python 3.10.18

**运行时依赖：**
```
attrs                     25.3.0
beautifulsoup4            4.13.4
blinker                   1.9.0
brotlicffi                1.1.0.0
certifi                   2025.7.14
cffi                      1.17.1
charset-normalizer        3.4.2
click                     8.2.1
coverage                  7.9.2
decorator                 5.2.1
exceptiongroup            1.3.0
execnet                   2.1.1
flake8                    7.3.0
flasgger                  0.9.7.1
Flask                     3.1.1
greenlet                  2.0.2
httpbin                   0.10.2
idna                      3.10
iniconfig                 2.1.0
itsdangerous              2.2.0
Jinja2                    3.1.6
jsonschema                4.25.0
jsonschema-specifications 2025.4.1
lxml                      6.0.0
MarkupSafe                3.0.2
mccabe                    0.7.0
mistune                   3.1.3
packaging                 25.0
pip                       25.1.1
pluggy                    1.6.0
pycodestyle               2.14.0
pycparser                 2.22
pyflakes                  3.4.0
Pygments                  2.19.2
pytest                    8.4.1
pytest-cov                6.2.1
pytest-flake8             1.3.0
pytest-httpbin            2.1.0
pytest-mock               3.14.1
pytest-xdist              3.8.0
PyYAML                    6.0.2
referencing               0.36.2
requests                  2.32.4
requests-mock             1.12.1
rpds-py                   0.26.0
setuptools                65.5.1
six                       1.17.0
soupsieve                 2.7
tomli                     2.2.1
typing_extensions         4.14.1
urllib3                   2.5.0
Werkzeug                  3.1.3
wheel                     0.45.1
```


## 4. 项目目录结构

```
workspace/
├── .coveragerc
├── .gitignore
├── .mention-bot
├── .readthedocs.yaml
├── CONTRIBUTING.rst
├── LICENSE
├── MANIFEST.in
├── README.rst
├── assets
├── mechanicalsoup
│   ├── __init__.py
│   ├── __version__.py
│   ├── browser.py
│   ├── form.py
│   ├── stateful_browser.py
│   ├── utils.py
└── setup.py

```

## 5. API 使用指南

### 5.1 核心类与函数

#### 5.1.1 模块导入
```python
import mechanicalsoup
```
#### 5.1.2 Browser 类

**功能说明**：`Browser` 是一个底层浏览器类，提供与网站交互的基础功能。它封装了 `requests` 库，并增加了 HTML 解析能力。

##### 5.1.2.1 初始化方法

```python
__init__(self, session=None, soup_config={'features': 'lxml'}, requests_adapters=None, raise_on_404=False, user_agent=None)
```

**参数**：
- `session`：可选的 `requests.Session` 实例
- `soup_config`：传给 BeautifulSoup 的配置，默认为 `{'features': 'lxml'}`
- `requests_adapters`：传给 requests 的适配器配置
- `raise_on_404`：若为 True，则访问页面返回 404 时抛出 `LinkNotFoundError`
- `user_agent`：设置 user agent 请求头

##### 5.1.2.2 主要方法

`request(method, url, **kwargs)`
**功能**：发送 HTTP 请求的底层方法
**参数**：
- `method`：HTTP 方法（GET、POST 等）
- `url`：请求 URL
- `**kwargs`：传给 `requests.Session.request` 的其他参数
**返回**：带有附加 `soup` 属性的 `requests.Response` 对象

`get(url, **kwargs)`
**功能**：发送 GET 请求
**参数**：
- `url`：请求 URL
- `**kwargs`：传给 `request` 方法的其他参数
**返回**：`requests.Response` 对象

`post(url, data=None, **kwargs)`
**功能**：发送 POST 请求
**参数**：
- `url`：请求 URL
- `data`：要发送的表单数据
- `**kwargs`：传给 `request` 方法的其他参数
**返回**：`requests.Response` 对象

`submit(form, url=None, **kwargs)`
**功能**：提交表单
**参数**：
- `form`：要提交的表单（bs4.element.Tag 或 Form 对象）
- `url`：包含该表单的页面 URL（当表单 action 为相对路径时必需）
- `**kwargs`：传给 `requests.Session.request` 的其他参数
**返回**：`requests.Response` 对象

`set_cookiejar(cookiejar)`
**功能**：替换当前会话的 cookie jar
**参数**：
- `cookiejar`：任何兼容 `http.cookiejar.CookieJar` 的对象

`set_user_agent(user_agent)`
**功能**：设置 user agent
**参数**：
- `user_agent`：user agent 字符串

`close()`
**功能**：关闭当前会话

`_request(form, url=None, **kwargs)`
**功能**：从表单中提取输入数据并发起请求（内部方法）
**参数**：
- `form`：要提交的表单
- `url`：包含该表单的页面 URL
- `**kwargs`：传给 `requests.Session.request` 的其他参数
**返回**：`requests.Response` 对象

`get_request_kwargs(form, url=None, **kwargs)`
**功能**：从表单中提取请求参数
**参数**：
- `form`：要处理的表单
- `url`：包含该表单的页面 URL
- `**kwargs`：其他参数
**返回**：包含请求参数的字典

`__looks_like_html(response)`
**功能**：静态方法，根据内容猜测响应内容是否为 HTML（内部使用）
**参数**：
- `response`：requests.Response 对象
**返回**：若为 HTML 返回 True，否则返回 False

`add_soup(response, soup_config)`
**功能**：静态方法，把 BeautifulSoup 对象附加到响应对象上（内部使用）
**参数**：
- `response`：requests.Response 对象
- `soup_config`：BeautifulSoup 配置

`get_cookiejar()`
**功能**：获取当前会话的 cookiejar
**返回**：当前会话的 cookiejar 对象

`put(url, data=None, **kwargs)`
**功能**：发送 PUT 请求
**参数**：
- `url`：请求 URL
- `data`：要发送的数据
- `**kwargs`：传给 `request` 方法的其他参数
**返回**：`requests.Response` 对象

`_get_request_kwargs(method, url, **kwargs)`
**功能**：获取请求参数的内部方法
**参数**：
- `method`：HTTP 方法
- `url`：请求 URL
- `**kwargs`：其他请求参数
**返回**：包含请求参数的字典

`__del__()`
**功能**：析构方法，确保资源被正确释放

`__enter__()`
**功能**：上下文管理器入口，支持 `with` 语句
**返回**：self

`__exit__(self, *args)`
**功能**：上下文管理器出口，确保资源被正确释放

`launch_browser(soup)`
**功能**：在浏览器中打开页面（用于调试）
**参数**：
- `soup`：要显示的页面内容（bs4 对象）

#### 5.1.3 StatefulBrowser 类

##### 5.1.3.1 概述

##### 5.1.3.2 初始化

```python
class mechanicalsoup.StatefulBrowser(
    session=None,
    soup_config={'features': 'lxml'},
    requests_adapters=None,
    raise_on_404=False,
    user_agent=None
)
```

**参数：**
- `session`：附加一个已有的 requests Session。
- `soup_config`：传给 BeautifulSoup 用于 HTML 解析的配置。
- `requests_adapters`：HTTP 请求的配置。
- `raise_on_404`：若为 True，则在 404 错误时抛出 `LinkNotFoundError`。
- `user_agent`：设置 User-Agent 请求头。

##### 5.1.3.3 特殊方法

###### __init__
```python
def __init__(self, session=None, soup_config={'features': 'lxml'}, requests_adapters=None, raise_on_404=False, user_agent=None)
```
初始化一个新的 StatefulBrowser 实例。

**参数：**
- `session`：可选，要使用的 requests.Session 实例。
- `soup_config`：传给 BeautifulSoup 用于 HTML 解析的配置。
- `requests_adapters`：可选，用于 requests 的适配器。
- `raise_on_404`：若为 True，则在 404 响应时抛出 LinkNotFoundError。
- `user_agent`：自定义 User-Agent 字符串。

###### __setitem__
```python
def __setitem__(self, name, value)
```
按名称设置表单控件的值。

**参数：**
- `name`：表单控件的名称。
- `value`：要设置的值。

##### 5.1.3.4 属性

###### page
```python
@property
def page(self)
```
**返回：** 当前页面，以 BeautifulSoup 对象表示。

###### url
```python
@property
def url(self)
```
**返回：** 当前已访问页面的 URL。

###### form
```python
@property
def form(self)
```
**返回：** 当前选中的表单，以 `Form` 对象表示。
**抛出：** 若未选中表单则抛出 `AttributeError`。

##### 5.1.3.5 核心方法

###### open
```python
def open(self, url, *args, **kwargs)
```
打开一个 URL 并更新浏览器状态。

**参数：**
- `url`：要打开的 URL。
- 其余参数转发给 `requests.Session.get()`。

**返回：** 响应对象。

###### open_fake_page
```python
def open_fake_page(self, page_text, url=None, soup_config=None)
```
用于测试的 `open()` 模拟版本。

**参数：**
- `page_text`：要解析的 HTML 内容。
- `url`：可选，伪造页面的 URL。
- `soup_config`：BeautifulSoup 的配置。

###### open_relative
```python
def open_relative(self, url, *args, **kwargs)
```
打开相对于当前页面的 URL。

**参数：**
- `url`：相对或绝对 URL。
- 其余参数转发给 `open()`。

###### refresh
```python
def refresh(self)
```
用相同的请求重新加载当前页面。

**抛出：** 若页面不可刷新则抛出 `ValueError`。
**返回：** 响应对象。

##### 5.1.3.6 表单处理

###### select_form
```python
def select_form(self, selector="form", nr=0)
```
选择当前页面上的一个表单。

**参数：**
- `selector`：用于定位表单的 CSS 选择器或 bs4.element.Tag。
- `nr`：当多个表单匹配该选择器时使用的零基索引。

**返回：** 选中的表单，以 BeautifulSoup 对象表示。

###### new_control
```python
def new_control(self, type, name, value, **kwargs)
```
在当前选中的表单中创建一个新的表单控件。

**参数：**
- `type`：控件类型（如 'text'、'hidden'）。
- `name`：控件名称。
- `value`：控件的初始值。
- `**kwargs`：控件的其他属性。

**返回：** 创建出的控件。

###### _merge_referer
```python
def _merge_referer(self, **kwargs)
```
为请求添加 Referer 请求头的辅助方法。

**参数：**
- `**kwargs`：请求参数。

**返回：** 带有 Referer 请求头的更新后请求参数。

###### _find_link_internal
```python
def _find_link_internal(self, link, args, kwargs)
```
带特殊情形处理的链接查找内部方法。

**参数：**
- `link`：链接元素或 URL 模式。
- `args`：链接查找的位置参数。
- `kwargs`：链接查找的关键字参数。

**返回：** 找到的链接元素。

###### launch_browser
```python
def launch_browser(self)
```
启动系统默认浏览器打开当前页面。

**注意：** 主要用于调试目的。

###### submit_selected
```python
def submit_selected(self, btnName=None, update_state=True, **kwargs)
```
提交当前选中的表单。

**参数：**
- `btnName`：要使用的提交按钮名称。
- `update_state`：若为 False，则提交后不更新浏览器状态。
- `**kwargs`：转发给 `requests.Session.post()`。

**返回：** 响应对象。

##### 5.1.3.7 导航

###### follow_link(link=None, *bs4_args, bs4_kwargs={}, requests_kwargs={}, **kwargs)
```python
def follow_link(self, link=None, *bs4_args, bs4_kwargs={}, requests_kwargs={}, **kwargs)
```
跟随当前页面上的一个链接。

**参数：**
- `link`：要匹配的链接元素或 URL 模式。
- `bs4_args`、`bs4_kwargs`：链接查找的参数。
- `requests_kwargs`：HTTP 请求的参数。

**返回：** 响应对象。

###### list_links
```python
def list_links(self, *args, **kwargs)
```
打印当前页面中的所有链接。

**参数：** 转发给 `links()`。

###### links
```python
def links(self, url_regex=None, link_text=None, *args, **kwargs)
```
查找当前页面中的链接。

**参数：**
- `url_regex`：用于匹配链接 URL 的正则表达式。
- `link_text`：要在链接文本中精确匹配的文本。
- 其余参数转发给 BeautifulSoup 的 `find_all()`。

**返回：** 匹配到的链接元素列表。

##### 5.1.3.8 工具方法

###### set

###### set_debug(debug)
```python
def set_debug(self, debug)
```
启用或禁用调试模式。

**参数：**
- `debug`：布尔值，用于启用/禁用调试模式。

###### set_verbose
```python
def set_verbose(self, verbose)
```
设置详细程度（verbosity）级别。

**参数：**
- `verbose`：0（无输出）、1（点号）、2（URL）。

###### get_verbose
```python
def get_verbose(self)
```
获取当前的详细程度级别。

**返回：** 当前的详细程度级别（0、1 或 2）。

###### get_debug
```python
def get_debug(self)
```
获取当前的调试模式状态。

**返回：** 表示调试模式是否启用的布尔值。

###### absolute_url
```python
def absolute_url(self, url)
```
把相对 URL 转换为绝对 URL。

**参数：**
- `url`：相对 URL。

**返回：** 绝对 URL。

##### 5.1.3.9 示例用法

```python
import mechanicalsoup

# 创建一个浏览器实例
browser = mechanicalsoup.StatefulBrowser()

# 打开一个网页
browser.open("http://example.com")

# 选择并填写一个表单
browser.select_form('form[action="/search"]')
browser["q"] = "MechanicalSoup"

# 提交表单
response = browser.submit_selected()

# 打印结果页面的标题
print(browser.page.title.text)

# 跟随一个链接
browser.follow_link(text="Next page")

# 关闭浏览器
browser.close()
```



#### 5.1.4 Form 类
```python
class mechanicalsoup.Form(form)
```
**功能**：表示一个 HTML 表单，提供字段操作与表单提交功能。

**主要方法**：

1. **set(name, value, force=False)**
   - 设置表单字段的值
   - 参数：
     - `name`：字段名
     - `value`：字段值
     - `force`：是否强制设置只读/禁用字段

2. **set_input(name, value, force=False)**
   - 设置输入字段（input）的值
   - 参数与 `set()` 相同

3. **set_textarea(name, value, force=False)**
   - 设置文本域（textarea）的值
   - 参数与 `set()` 相同

4. **set_select(name, value, force=False)**
   - 设置下拉选择框（select）的值
   - 参数与 `set()` 相同

5. **set_checkbox(name, value, force=False)**
   - 设置复选框（checkbox）的值
   - 参数与 `set()` 相同

6. **set_radio(name, value, force=False)**
   - 设置单选按钮（radio）的值
   - 参数与 `set()` 相同

7. **set_file(name, filename, file_content)**
   - 设置文件上传字段的值
   - 参数：
     - `name`：字段名
     - `filename`：文件名
     - `file_content`：文件内容（bytes）

8. **uncheck_all(name)**
   - 取消勾选指定名称的所有复选框与单选按钮
   - 参数：`name`：字段名

9. **choose_submit(button)**
   - 选择一个提交按钮
   - 参数：`button`：提交按钮的选择器或 `Tag` 对象

10. **print_summary()**
    - 打印表单摘要

11. **__getitem__(name)**
    - 获取字段的值
    - 参数：`name`：字段名
    - 返回：字段值

12. **__setitem__(name, value)**
    - 设置字段的值
    - 参数：
      - `name`：字段名
      - `value`：字段值

#### 5.1.5 LinkNotFoundError 类
```python
class LinkNotFoundError(Exception):
```
**功能**：当指定的链接或表单未被找到时抛出。

#### 5.2 用法示例

```python
# 基本用法
import mechanicalsoup

# 创建一个浏览器实例
browser = mechanicalsoup.StatefulBrowser(
    soup_config={'features': 'lxml'},
    raise_on_404=True,
    user_agent='MyBot/0.1'
)

# 打开一个网页
browser.open("https://example.com")

# 选择并填写一个表单
browser.select_form('form[action="/search"]')
browser["q"] = "MechanicalSoup"
browser.submit_selected()

# 获取当前页面的内容
print(browser.get_current_page().prettify())

# 下载一个文件
browser.download_link("https://example.com/file.pdf")

# 关闭浏览器
browser.close()
```

```python
# 处理登录
browser.open("https://example.com/login")
browser.select_form('form')
browser["username"] = "user"
browser["password"] = "pass"
response = browser.submit_selected()

# 处理文件上传
browser.open("https://example.com/upload")
browser.select_form('form[enctype="multipart/form-data"]')
browser.set_file("file_field", "example.txt", b"File content")
response = browser.submit_selected()
```

# MechanicalSoup 各功能详细实现节点完整分析

## 功能详细实现节点

### 节点 1：异常处理与错误管理
  - 输入：各类异常场景的触发条件
  - 输出：对应的异常类型与错误消息
  - 测试接口：
    - `test_LinkNotFoundError`（test_utils.py）
    - `test_no_404`（test_browser.py、test_stateful_browser.py）
    - `test_404`（test_browser.py、test_stateful_browser.py）
    - `test_download_link_404`（test_stateful_browser.py）
  - 说明：处理各种异常情况，包括链接未找到、404 错误、表单选择失败等。

  ```python
  def test_LinkNotFoundError():
      with pytest.raises(mechanicalsoup.LinkNotFoundError):
          raise mechanicalsoup.utils.LinkNotFoundError
      with pytest.raises(Exception):
          raise mechanicalsoup.utils.LinkNotFoundError

  def test_404(httpbin):
      browser = mechanicalsoup.Browser(raise_on_404=True)
      with pytest.raises(mechanicalsoup.LinkNotFoundError):
          browser.get(httpbin + "/nosuchpage")
      resp = browser.get(httpbin.url)
      assert resp.status_code == 200
  ```

### 节点 2：表单提交的核心功能
  - 输入：表单数据（以字典形式给出）
  - 输出：服务器响应（`Response` 对象）
  - 测试接口：
    - `test_submit_online`（test_browser.py、test_form.py、test_stateful_browser.py）
    - `test_submit_set`（test_form.py）
    - `test__request`（test_browser.py）
    - `test_submit_btnName`（test_stateful_browser.py）
    - `test_submit_no_btn`（test_stateful_browser.py）
  - 说明：提交包含文本输入框、单选按钮、复选框与文本域的表单。

  ```python
  def test_submit_online(httpbin):
      """填写并提交 http://httpbin.org/forms/post 上的披萨表单。"""
      browser = mechanicalsoup.Browser()
      page = browser.get(httpbin + "/forms/post")
      form = page.soup.form

      form.find("input", {"name": "custname"})["value"] = "Philip J. Fry"
      # custtel 留空，不设 value
      assert "value" not in form.find("input", {"name": "custtel"}).attrs
      form.find("input", {"name": "size", "value": "medium"})["checked"] = ""
      form.find("input", {"name": "topping", "value": "cheese"})["checked"] = ""
      form.find("input", {"name": "topping", "value": "onion"})["checked"] = ""
      form.find("textarea", {"name": "comments"}).insert(0, "freezer")

      response = browser.submit(form, page.url)

      # 好在表单提交到 http://httpbin.org/post，该地址会直接
      # 以 json 格式返回请求头
      json = response.json()
      data = json["form"]
      assert data["custname"] == "Philip J. Fry"
      assert data["custtel"] == ""  # 浏览器对留空的输入框会提交 ""
      assert data["size"] == "medium"
      assert data["topping"] == ["cheese", "onion"]
      assert data["comments"] == "freezer"

      assert json["headers"]["User-Agent"].startswith('python-requests/')
      assert 'MechanicalSoup' in json["headers"]["User-Agent"]
  ```

### 节点 3：Cookie 管理
  - 输入：Cookies（`RequestsCookieJar` 对象）
  - 输出：更新后的 Cookies
  - 测试接口：
    - `test_set_cookiejar`（test_browser.py）
    - `test_get_cookiejar`（test_browser.py）
    - `test_requests_session_and_cookies`（test_stateful_browser.py）
  - 说明：设置与获取浏览器会话的 Cookies。

  ```python
  def test_set_cookiejar(httpbin):
      """在本地设置 cookies，并测试远端能收到它们。"""
      # 构造一个假的 cookiejar 并挂到会话上
      jar = RequestsCookieJar()
      jar.set('field', 'value')
      assert jar.get('field') == 'value'

      browser = mechanicalsoup.Browser()
      browser.set_cookiejar(jar)
      resp = browser.get(httpbin + "/cookies")
      assert resp.json() == {'cookies': {'field': 'value'}}

  def test_get_cookiejar(httpbin):
      """测试远端主机设置的 cookies 会更新我们的会话。"""
      browser = mechanicalsoup.Browser()
      resp = browser.get(httpbin + "/cookies/set?k1=v1&k2=v2")
      assert resp.json() == {'cookies': {'k1': 'v1', 'k2': 'v2'}}

      jar = browser.get_cookiejar()
      assert jar.get('k1') == 'v1'
      assert jar.get('k2') == 'v2'
  ```

### 节点 4：HTTP 方法支持
  - 支持的方法：GET、POST、PUT
  - 测试接口：
    - `test_post`（test_browser.py）
    - `test_put`（test_browser.py）
    - `test_request_forward`（test_stateful_browser.py）
  - 说明：支持多种 HTTP 请求方法。

  ```python
  def test_post(httpbin):
      browser = mechanicalsoup.Browser()
      data = {'color': 'blue', 'colorblind': 'True'}
      resp = browser.post(httpbin + "/post", data)
      assert resp.status_code == 200 and resp.json()['form'] == data

  def test_put(httpbin):
      browser = mechanicalsoup.Browser()
      data = {'color': 'blue', 'colorblind': 'True'}
      resp = browser.put(httpbin + "/put", data)
      assert resp.status_code == 200 and resp.json()['form'] == data
  ```

### 节点 5：表单字段操作
  - 输入：字段名与字段值组成的字典
  - 输出：更新后的表单数据
  - 测试接口：
    - `test_form_set_radio_checkbox`（test_form.py、test_stateful_browser.py）
    - `test_set_select`（test_form.py）
    - `test_set_select_multiple`（test_form.py）
    - `test_form_check_uncheck`（test_form.py）
    - `test_new_control`（test_stateful_browser.py）
  - 说明：操作各种表单元素，包括文本输入框、单选按钮、复选框、下拉选择框等。

  ```python
  def test_form_set_radio_checkbox(capsys):
      browser = mechanicalsoup.StatefulBrowser()
      browser.open_fake_page(page_with_various_fields,
                            url="http://example.com/invalid/")
      form = browser.select_form("form")
      form.set_radio({"size": "small"})
      form.set_checkbox({"topping": "cheese"})
      browser.form.print_summary()
      out, err = capsys.readouterr()
      # 不同版本的 bs4 会输出 <input></input> 或
      # <input/>。比较前先做归一化。
      out = out.replace('></input>', '/>')
      assert out == """<input name="foo"/>
  <textarea name="bar"></textarea>
  <select name="entree">
  <option selected="selected" value="tofu">Tofu Stir Fry</option>
  <option value="curry">Red Curry</option>
  <option value="tempeh">Tempeh Tacos</option>
  </select>
  <input name="topping" type="checkbox" value="bacon"/>
  <input checked="" name="topping" type="Checkbox" value="cheese"/>
  <input name="topping" type="checkbox" value="onion"/>
  <input name="topping" type="checkbox" value="mushroom"/>
  <input checked="" name="size" type="Radio" value="small"/>
  <input name="size" type="radio" value="medium"/>
  <input name="size" type="radio" value="large"/>
  <button name="action" value="cancel">Cancel</button>
  <input type="submit" value="Select"/>
  """
      assert err == ""
  ```

### 节点 6：提交按钮的选择
  - 输入：按钮名称或 CSS 选择器
  - 输出：选中的提交按钮
  - 测试接口：
    - `test_choose_submit`（test_form.py）
    - `test_choose_submit_from_selector`（test_form.py）
    - `test_choose_submit_fail`（test_form.py）
    - `test_choose_submit_twice`（test_form.py）
    - `test_choose_submit_multiple_match`（test_form.py）
    - `test_choose_submit_buttons`（test_form.py）
  - 说明：在含有多个提交按钮的表单中选择特定的提交按钮。

  ```python
  @pytest.mark.parametrize("expected_post", [
      pytest.param(
          [
              ('text', 'Setting some text!'),
              ('comment', 'Testing preview page'),
              ('preview', 'Preview Page'),
          ], id='preview'),
      pytest.param(
          [
              ('text', '= Heading =\n\nNew page here!\n'),
              ('comment', 'Created new page'),
              ('save', 'Submit changes'),
          ], id='save'),
      pytest.param(
          [
              ('text', '= Heading =\n\nNew page here!\n'),
              ('comment', 'Testing choosing cancel button'),
              ('cancel', 'Cancel'),
          ], id='cancel'),
  ])
  def test_choose_submit(expected_post):
      browser, url = setup_mock_browser(expected_post=expected_post)
      browser.open(url)
      form = browser.select_form('#choose-submit-form')
      browser['text'] = dict(expected_post)['text']
      browser['comment'] = dict(expected_post)['comment']
      form.choose_submit(expected_post[2][0])
      res = browser.submit_selected()
      assert res.status_code == 200 and res.text == 'Success!'
  ```

### 节点 7：页面导航
  - 输入：URL 或相对路径
  - 输出：新页面的响应
  - 测试接口：
    - `test_open_relative`（test_stateful_browser.py）
    - `test_refresh_open`（test_stateful_browser.py）
    - `test_refresh_follow_link`（test_stateful_browser.py）
    - `test_refresh_form_not_retained`（test_stateful_browser.py）
    - `test_refresh_error`（test_stateful_browser.py）
  - 说明：处理相对与绝对 URL 的导航以及页面刷新功能。

  ```python
  def test_open_relative(httpbin):
      # 打开任意 httpbin 页面以设置当前 URL
      browser = mechanicalsoup.StatefulBrowser()
      browser.open(httpbin + "/html")

      # 打开一个相对页面，并确认远端主机与浏览器对 URL 的认识一致
      resp = browser.open_relative("/get")
      assert resp.json()['url'] == httpbin + "/get"
      assert browser.url == httpbin + "/get"

      # 测试向会话传递额外的 kwargs
      resp = browser.open_relative("/basic-auth/me/123", auth=('me', '123'))
      assert browser.url == httpbin + "/basic-auth/me/123"
      assert resp.json() == {"authenticated": True, "user": "me"}
  ```

### 节点 8：链接跟踪
  - 输入：链接文本、URL 或正则表达式
  - 输出：链接所指向的页面
  - 测试接口：
    - `test_follow_link_arg`（test_stateful_browser.py）
    - `test_follow_link_from_tag`（test_stateful_browser.py）
    - `test_follow_link_excess`（test_stateful_browser.py）
    - `test_follow_link_ua`（test_stateful_browser.py）
    - `test_link_arg_multiregex`（test_stateful_browser.py）
    - `test_links`（test_stateful_browser.py）
    - `test_find_link`（test_stateful_browser.py）
  - 说明：根据文本、URL 或正则表达式跟踪链接。

  ```python
  @pytest.mark.parametrize('expected, kwargs', [
      pytest.param('/foo', {}, id='none'),
      pytest.param('/get', {'string': 'Link'}, id='string'),
      pytest.param('/get', {'url_regex': 'get'}, id='regex'),
  ])
  def test_follow_link_arg(httpbin, expected, kwargs):
      browser = mechanicalsoup.StatefulBrowser()
      html = '<a href="/foo">Bar</a><a href="/get">Link</a>'
      browser.open_fake_page(html, httpbin.url)
      browser.follow_link(bs4_kwargs=kwargs)
      assert browser.url == httpbin + expected

  def test_links():
      browser = mechanicalsoup.StatefulBrowser()
      html = '''<a class="bluelink" href="/blue" id="blue_link">A Blue Link</a>
                <a class="redlink" href="/red" id="red_link">A Red Link</a>'''
      expected = [BeautifulSoup(html, "lxml").a]
      browser.open_fake_page(html)

      # 测试 StatefulBrowser.links 的 url_regex 参数
      assert browser.links(url_regex="bl") == expected
      assert browser.links(url_regex="bluish") == []

      # 测试 StatefulBrowser.links 的 link_text 参数
      assert browser.links(link_text="A Blue Link") == expected
      assert browser.links(link_text="Blue") == []
  ```

### 节点 9：文件上传
  - 输入：文件路径或文件对象
  - 输出：上传请求的响应
  - 测试接口：
    - `test_upload_file`（test_stateful_browser.py）
    - `test_upload_file_with_malicious_default`（test_stateful_browser.py）
    - `test_upload_file_raise_on_string_input`（test_stateful_browser.py）
    - `test_enctype_and_file_submit`（test_browser.py）
  - 说明：处理文件上传表单，包括安全校验与编码类型（enctype）的处理。

  ```python
  def test_upload_file(httpbin):
      browser = mechanicalsoup.StatefulBrowser()
      u
  ```

  （本段源文件在 `u` 处截断，`test_upload_file` 的剩余内容见第 3 段。）

```python
url = httpbin + "/post"
      file_input_form = f"""
      <form method="post" action="{url}" enctype="multipart/form-data">
          <input type="file" name="first" />
      </form>
      """

      # 创建两个临时文件用于上传
      def make_file(content):
          path = tempfile.mkstemp()[1]
          with open(path, "w") as fd:
              fd.write(content)
          return path
      path1 = make_file("first file content")
      path2 = make_file("second file content")

      browser.open_fake_page(file_input_form)
      browser.select_form()

      # 测试填充已有的输入控件，以及新建一个输入控件
      with open(path1, "rb") as value1, open(path2, "rb") as value2:
          browser["first"] = value1
          browser.new_control("file", "second", value2)
          response = browser.submit_selected()

      files = response.json()["files"]
      assert files["first"] == "first file content"
      assert files["second"] == "second file content"
  ```

### 节点 10：文件下载
  - 输入：目标文件路径（可选）
  - 输出：下载得到的文件内容，或已保存到指定路径
  - 测试接口：
    - `test_download_link` (test_stateful_browser.py)
    - `test_download_link_nofile` (test_stateful_browser.py)
    - `test_download_link_nofile_bs4` (test_stateful_browser.py)
    - `test_download_link_nofile_excess` (test_stateful_browser.py)
    - `test_download_link_nofile_ua` (test_stateful_browser.py)
    - `test_download_link_to_existing_file` (test_stateful_browser.py)
    - `test_download_link_referer` (test_stateful_browser.py)
  - 描述：下载某个链接的内容，并可选地将其保存到文件。

  ```python
  def test_download_link(httpbin):
      """测试把链接内容下载到文件。"""
      browser = mechanicalsoup.StatefulBrowser()
      open_legacy_httpbin(browser, httpbin)
      tmpdir = tempfile.mkdtemp()
      tmpfile = tmpdir + '/nosuchfile.png'
      current_url = browser.url
      current_page = browser.page
      response = browser.download_link(file=tmpfile, link='image/png')

      # 检查浏览器状态未发生变化
      assert browser.url == current_url
      assert browser.page == current_page

      # 检查文件已被下载
      assert os.path.isfile(tmpfile)
      assert file_get_contents(tmpfile) == response.content
      # 检查确实下载到了一个 PNG 文件
      assert response.content[:4] == b'\x89PNG'

  def test_download_link_nofile(httpbin):
      """测试下载链接内容但不保存到文件。"""
      browser = mechanicalsoup.StatefulBrowser()
      open_legacy_httpbin(browser, httpbin)
      current_url = browser.url
      current_page = browser.page
      response = browser.download_link(link='image/png')

      # 检查浏览器状态未发生变化
      assert browser.url == current_url
      assert browser.page == current_page

      # 检查确实下载到了一个 PNG 文件
      assert response.content[:4] == b'\x89PNG'
  ```

### 节点 11：请求头管理
  - 输入：自定义请求头
  - 输出：携带自定义请求头的请求
  - 测试接口：
    - `test_referer_submit` (test_stateful_browser.py)
    - `test_referer_submit_override` (test_stateful_browser.py)
    - `test_referer_submit_headers` (test_stateful_browser.py)
    - `test_referer_follow_link` (test_stateful_browser.py)
    - `test_user_agent` (test_stateful_browser.py)
    - `test_submit_dont_modify_kwargs` (test_stateful_browser.py)
  - 描述：管理 HTTP 请求头，例如 Referer 与 User-Agent。

  ```python
  def test_referer_submit(httpbin):
      browser = mechanicalsoup.StatefulBrowser()
      ref = "https://example.com/my-referer"
      page = submit_form_headers.format(httpbin.url + "/headers")
      browser.open_fake_page(page, url=ref)
      browser.select_form()
      response = browser.submit_selected()
      headers = response.json()["headers"]
      referer = headers["Referer"]
      actual_ref = re.sub('/*$', '', referer)
      assert actual_ref == ref

  @pytest.mark.parametrize("referer_header", ["Referer", "referer"])
  def test_referer_submit_override(httpbin, referer_header):
      """确保调用方可以覆盖 mechanicalsoup 通常会添加的 Referer 请求头。
      因为请求头不区分大小写，所以同时用 'Referer' 和 'referer' 测试。
      """

      browser = mechanicalsoup.StatefulBrowser()
      ref = "https://example.com/my-referer"
      ref_override = "https://example.com/override"
      page = submit_form_headers.format(httpbin.url + "/headers")
      browser.open_fake_page(page, url=ref)
      browser.select_form()
      response = browser.submit_selected(headers={referer_header: ref_override})
      headers = response.json()["headers"]
      referer = headers["Referer"]
      actual_ref = re.sub('/*$', '', referer)
      assert actual_ref == ref_override
  ```

### 节点 12：表单解析与构造
  - 输入：HTML 表单元素或 tag 对象
  - 输出：`Form` 对象
  - 测试接口：
    - `test_construct_form_fail` (test_form.py)
    - `test_form_print_summary` (test_form.py)
    - `test_select_form_nr` (test_stateful_browser.py)
    - `test_select_form_tag_object` (test_stateful_browser.py)
    - `test_select_form_associated_elements` (test_stateful_browser.py)
  - 描述：解析 HTML 表单结构并创建 `Form` 对象。

  ```python
  def test_construct_form_fail():
      """Form 对象必须由 form 类型的 HTML 元素构造。"""
      soup = bs4.BeautifulSoup('<notform>This is not a form</notform>', 'lxml')
      tag = soup.find('notform')
      assert isinstance(tag, bs4.element.Tag)
      with pytest.warns(FutureWarning, match="from a 'notform'"):
          mechanicalsoup.Form(tag)

  def test_select_form_nr():
      """测试 select_form 的 nr 选项。"""
      forms = """<form id="a"></form><form id="b"></form><form id="c"></form>"""
      with mechanicalsoup.StatefulBrowser() as browser:
          browser.open_fake_page(forms)
          form = browser.select_form()
          assert form.form['id'] == "a"
          form = browser.select_form(nr=1)
          assert form.form['id'] == "b"
          form = browser.select_form(nr=2)
          assert form.form['id'] == "c"
          with pytest.raises(mechanicalsoup.LinkNotFoundError):
              browser.select_form(nr=3)
  ```

### 节点 13：浏览器状态管理
  - 输入：浏览器状态变更操作
  - 输出：更新后的浏览器状态
  - 测试接口：
    - `test_properties` (test_stateful_browser.py)
    - `test_get_selected_form_unselected` (test_stateful_browser.py)
    - `test_submit_dont_update_state` (test_stateful_browser.py)
    - `test_with` (test_stateful_browser.py)
  - 描述：管理浏览器的页面、表单、URL 及其他状态信息。

  ```python
  def test_properties():
      """检查各属性返回的值与对应的 getter 一致。"""
      browser = mechanicalsoup.StatefulBrowser()
      browser.open_fake_page('<form></form>', url="http://example.com")
      assert browser.page == browser.get_current_page()
      assert browser.page is not None
      assert browser.url == browser.get_url()
      assert browser.url is not None
      browser.select_form()
      assert browser.form == browser.get_current_form()
      assert browser.form is not None

  def test_get_selected_form_unselected():
      browser = mechanicalsoup.StatefulBrowser()
      browser.open_fake_page('<form></form>')
      with pytest.raises(AttributeError, match="No form has been selected yet."):
          browser.form
      assert browser.get_current_form() is None
  ```

### 节点 14：编码处理
  - 输入：采用不同编码的网页内容
  - 输出：被正确解码的页面内容
  - 测试接口：
    - `test_encoding` (test_browser.py)
  - 描述：处理采用不同字符编码的网页内容。

  ```python
  @pytest.mark.parametrize("http_html_expected_encoding", [
      pytest.param((None, 'utf-8', 'utf-8')),
      pytest.param(('utf-8', 'utf-8', 'utf-8')),
      pytest.param(('utf-8', None, 'utf-8')),
      pytest.param(('utf-8', 'ISO-8859-1', 'utf-8')),
  ])
  def test_encoding(httpbin, http_html_expected_encoding):
      http_encoding = http_html_expected_encoding[0]
      html_encoding = http_html_expected_encoding[1]
      expected_encoding = http_html_expected_encoding[2]

      url = 'mock://encoding'
      text = (
          '<!doctype html>'
          + '<html lang="fr">'
          + (
              (
                  '<head><meta charset="'
                  + html_encoding
                  + '"><title>Titleéàè</title></head>'
              ) if html_encoding
              else ''
          )
          + '<body></body>'
          + '</html>'
      )

      browser, adapter = prepare_mock_browser()
      mock_get(
          adapter,
          url=url,
          reply=(
              text.encode(http_encoding)
              if http_encoding
              else text.encode("utf-8")
          ),
          content_type=(
              'text/html'
              + (
                  ';charset=' + http_encoding
                  if http_encoding
                  else ''
              )
          )
      )
      browser.open(url)
      assert browser.page.original_encoding == expected_encoding
  ```

### 节点 15：表单校验与错误处理
  - 输入：各种表单校验场景
  - 输出：校验结果或异常
  - 测试接口：
    - `test_form_not_found` (test_form.py)
    - `test_form_noaction` (test_form.py, test_stateful_browser.py)
    - `test_form_action` (test_form.py)
    - `test_form_noname` (test_stateful_browser.py)
    - `test_form_multiple` (test_stateful_browser.py)
    - `test__request_select_none` (test_browser.py)
    - `test__request_disabled_attr` (test_browser.py)
    - `test_request_keyword_error` (test_browser.py)
    - `test_get_request_kwargs_when_method_is_in_kwargs` (test_browser.py)
    - `test_get_request_kwargs_when_url_is_in_kwargs` (test_browser.py)
  - 描述：校验表单字段、处理表单错误以及边界条件。

  ```python
  def test_form_not_found():
      browser = mechanicalsoup.StatefulBrowser()
      browser.open_fake_page(page_with_various_fields)
      form = browser.select_form('form')
      with pytest.raises(mechanicalsoup.utils.LinkNotFoundError):
          form.input({'foo': 'bar', 'nosuchname': 'nosuchval'})
      with pytest.raises(mechanicalsoup.utils.LinkNotFoundError):
          form.check({'foo': 'bar', 'nosuchname': 'nosuchval'})
      with pytest.raises(mechanicalsoup.utils.LinkNotFoundError):
          form.check({'entree': 'cheese'})

  def test__request_disabled_attr(httpbin):
      """确保被禁用的表单控件不会被提交。"""
      form_html = f"""
      <form method="post" action="{httpbin.url}/post">
        <input disabled name="nosubmit" value="1" />
      </form>"""

      browser = mechanicalsoup.Browser()
      response = browser._request(BeautifulSoup(form_html, "lxml").form)
      assert response.json()['form'] == {}
  ```

### 节点 16：会话管理
  - 输入：会话对象或配置
  - 输出：已配置好的会话状态
  - 测试接口：
    - `test_requests_session_and_cookies` (test_stateful_browser.py)
    - `test_get_request_kwargs` (test_browser.py)
  - 描述：管理 HTTP 会话与请求配置。

  ```python
  def test_requests_session_and_cookies(httpbin):
      """检查传给 StatefulBrowser 构造函数的 session 对象是否真的被使用。"""
      s = requests.Session()
      requests.utils.add_dict_to_cookiejar(s.cookies, {'key1': 'val1'})
      browser = mechanicalsoup.StatefulBrowser(session=s)
      resp = browser.get(httpbin + "/cookies")
      assert resp.json() == {'cookies': {'key1': 'val1'}}

  def test_get_request_kwargs(httpbin):
      """在没有提交的情况下返回 kwargs"""
      browser = mechanicalsoup.Browser()
      page = browser.get(httpbin + "/forms/post")
      form = page.soup.form
      form.find("input", {"name": "custname"})["value"] = "Philip J. Fry"
      request_kwargs = browser.get_request_kwargs(form, page.url)
      assert "method" in request_kwargs
      assert "url" in request_kwargs
      assert "data" in request_kwargs
      assert ("custname", "Philip J. Fry") in request_kwargs["data"]
  ```

### 节点 17：调试功能
  - 输入：调试配置与设置
  - 输出：调试信息与状态
  - 测试接口：
    - `test_get_set_debug` (test_stateful_browser.py)
    - `test_list_links` (test_stateful_browser.py)
    - `test_launch_browser` (test_stateful_browser.py)
    - `test_verbose` (test_stateful_browser.py)
  - 描述：提供调试与诊断功能。

  ```python
  def test_get_set_debug():
      browser = mechanicalsoup.StatefulBrowser()
      # 调试模式默认关闭
      assert not browser.get_debug()
      browser.set_debug(True)
      assert browser.get_debug()

  def test_list_links(capsys):
      # capsys 是 pytest 的内置 fixture，可用来检查 std{err,out}
      browser = mechanicalsoup.StatefulBrowser()
      links = '''
       <a href="/link1">Link #1</a>
       <a href="/link2" id="link2"> Link #2</a>
  '''
      browser.open_fake_page(f'<html>{links}</html>')
      browser.list_links()
      out, err = capsys.readouterr()
      expected = f'Links in the current page:{links}'
      assert out == expected

  def test_verbose(capsys):
      '''测试 btnName 参数用于选择提交按钮。'''
      browser, url = setup_mock_browser()
      browser.open(url)
      out, err = capsys.readouterr()
      assert out == ""
      assert err == ""
      assert browser.get_verbose() == 0
      browser.set_verbose(1)
      browser.open(url)
      out, err = capsys.readouterr()
      assert out == "."
      assert err == ""
      assert browser.get_verbose() == 1
      browser.set_verbose(2)
      browser.open(url)
      out, err = capsys.readouterr()
      assert out == "mock://form.com\n"
      assert err == ""
      assert browser.get_verbose() == 2
  ```

### 节点 18：特殊表单处理
  - 输入：具有特殊结构的表单元素
  - 输出：被正确处理后的表单数据
  - 测试接口：
    - `test_issue158` (test_form.py)
    - `test_duplicate_submit_buttons` (test_form.py)
    - `test_issue180` (test_form.py)
    - `test_option_without_value` (test_form.py)
  - 描述：处理特殊的表单结构与边界条件。

  ```python
  def test_issue158():
      """测试表单元素按其在页面上的顺序被处理，
      且具有重复 name 属性的元素不会被覆盖。"""
      issue158_form = '''
  <form method="post" action="mock://form.com/post">
    <input name="box" type="hidden" value="1"/>
    <input checked="checked" name="box" type="checkbox" value="2"/>
    <input name="box" type="hidden" value="0"/>
    <input type="submit" value="Submit" />
  </form>
  '''
      expected_post = [('box', '1'), ('box', '2'), ('box', '0')]
      browser, url = setup_mock_browser(expected_post=expected_post,
                                        text=issue158_form)
      browser.open(url)
      browser.select_form()
      res = browser.submit_selected()
      assert res.status_code == 200 and res.text == 'Success!'
      browser.close()

  def test_option_without_value(fail, selected, expected_post):
      """select 中的 option 标签可以不带 value 选项"""
      text = """
      <form method="post" action="mock://form.com/post">
        <select name="selector">
          <option value="with_value">We have a value here</option>
          <option>Without value</option>
        </select>
        <button type="submit">Submit</button>
      </form>
      """
      browser, url = setup_mock_browser(expected_post=expected_post,
                                        text=text)
      browser.open(url)
      browser.select_form()
      if fail:
          with pytest.raises(mechanicalsoup.utils.LinkNotFoundError):
              browser['selector'] = selected
      else:
          browser['selector'] = selected

          res = browser.submit_selected()
          assert res.status_code == 200 and res.text == 'Success!'
  ```

**考点**：用 Browser/StatefulBrowser 两层封装把 requests 的会话、表单提交与链接导航包装成类浏览器 API，并按给定签名与默认值逐一实现。

## 47. `mootdx`（测试数 92）

**中文规格**

请创建一个名为 Mootdx 的 Python 项目，实现一个通达信数据读取接口库。项目应包含以下功能：

1. **离线数据读取器**：能够读取并解析本地通达信数据目录中的股票数据文件，支持日线数据（`.day` 文件）、分钟数据（`.1/.5/.lc1/.lc5` 文件）以及分笔（tick）数据。解析结果应为 pandas DataFrame 格式，包含开盘价、最高价、最低价、收盘价、成交量等字段。

2. **实时行情接口**：实现连接通达信服务器并获取实时行情数据的功能，包括 K 线数据、指数数据与分钟数据。应支持多线程连接、心跳检测、自动重连，以及前复权、后复权等数据复权功能。

3. **财务数据处理**：专门处理财务数据文件，包括获取财务数据文件列表、下载文件、解析数据等功能。支持批量下载与单文件处理，并能把财务数据转换为结构化格式。

4. **服务器管理**：实现服务器 IP 测速、最优服务器选择、连接状态监控等功能。支持自动测速服务器响应时间、选出连接质量最好的服务器，并提供连接池管理。

5. **命令行工具**：为每个功能模块设计独立的命令行接口，以支持终端调用测试。包含 `quotes`（实时行情）、`reader`（离线数据）、`affair`（财务数据）、`bestip`（服务器测速）等命令。每个模块应定义清晰的输入与输出格式。

6. **数据格式转换**：提供数据格式转换功能，支持 CSV、Excel、HDF5、JSON 等多种输出格式，以及数据缓存与定时更新机制。

以上功能需要组合起来，构建完整的通达信数据接口工具集。项目最终应包含离线读取、实时行情、财务数据、服务器管理、命令行工具等模块，并配有典型测试用例，形成可复现的数据获取流程。

7. **核心文件要求**：项目必须包含完整的 `pyproject.toml` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `tdxpy>=0.2.5`、`httpx>=0.25.0`、`tenacity>=8.1.0`、`pandas`、`numpy`、`click>=8.1.3`、`prettytable>=3.5.0`、`tqdm`、`mini-racer>=0.12.0`、`pytest>=7.3.1` 等核心库）。`pyproject.toml` 应能验证所有功能模块是否正常工作。此外，需要提供 `mootdx/__init__.py` 作为统一 API 入口：从 `reader`、`quotes`、`affair` 等模块导入 `Reader`、`Quotes`、`Affair` 等核心类；从 `utils` 模块导入 `get_config_path`、`get_stock_market`、`to_data`、`md5sum` 等工具函数；从 `consts` 模块导出 `MARKET_SH`、`MARKET_SZ`、`MARKET_BJ` 等市场常量；从 `tools.customize` 模块导出 `Customize` 自定义板块管理类。同时应提供版本信息，使用户能通过 `from mootdx/mootdx.affair/cache/consts/exceptions/logger/quotes/reader/tools/utils/contrib import *` 这样的简单语句访问所有主要功能。`quotes.py` 中应有一个 `factory()` 函数，用于为不同市场类型创建行情客户端。`reader.py` 中应有一个 `factory()` 函数，用于为不同市场类型创建数据读取器。`utils/__init__.py` 中应有一个 `get_stock_market()` 函数，用于判断股票代码对应的证券市场，以及一个 `to_data()` 函数，用于把数据转换为 DataFrame 格式。`tools/customize.py` 中应有一个 `Customize` 类，用于管理自定义板块的创建、查询、更新、删除等操作。

**考点**：用统一包入口把离线 `reader`、在线 `quotes`、财务 `affair` 三条数据通道串起来（通达信本地二进制文件解析 + 多线程行情连接），难点是 `.day`/`.lc1` 二进制结构与 `factory()` 按市场分派。

## 48. `more-Itertools`（测试数 682）

**中文规格**

请创建一个名为 More-Itertools 的 Python 项目，实现一个迭代器增强库。项目应包含以下功能：

1. 分组与切块功能：能够把可迭代对象切分为固定大小的块，支持严格模式与惰性切块，包括 `chunked()`、`ichunked()`、`sliced()`、`split_at()` 等函数。切块结果应为列表或生成器，支持不同大小的数据切分。

2. 预看与回看功能：实现不消耗迭代器即可预览迭代器元素的功能，支持 `peekable()`、`seekable()`、`spy()` 等操作。应支持 peek 预览、prepend 前置、seek 回溯等高级迭代器操作。

3. 窗口与滑动功能：专门处理滑动窗口、相邻元素对、三元组等，例如用 `windowed()` 生成滑动窗口、用 `pairwise()` 生成相邻元素对、用 `triplewise()` 生成三元组。

4. 接口设计：为每个功能模块（如分组、预看、窗口、增强、组合、汇总、选取、组合数学、包装、数学运算等）设计独立的函数接口，支持链式调用与组合使用。每个模块应定义清晰的输入与输出格式。

5. 示例与评测脚本：提供示例代码与测试用例，演示如何使用 `chunked()` 与 `windowed()` 函数进行数据切块与滑动窗口处理（例如 `chunked('ABCDEF', 3)` 应返回 `[['A', 'B', 'C'], ['D', 'E', 'F']]`）。以上功能需要组合起来，构建完整的迭代器增强工具集。最终项目应包含分组、预看、窗口、增强、组合、汇总、选取、组合数学、包装、数学运算等模块，并配有典型测试用例，形成可复现的增强流程。

6. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `Python >= 3.9` 与 `flit_core >= 3.12` 等核心库）。`pyproject.toml` 应能验证所有功能模块是否正常工作。此外，应提供 `more_itertools/__init__.py` 作为统一 API 入口，从 `more` 与 `recipes` 模块导入并导出核心函数、类等，并提供版本信息，使用户能通过 `from more_itertools import xxx` 或 `import more_itertools` 等简单语句访问所有主要功能。`more.py` 中应提供 `chunked()`、`windowed()` 等函数，以提供各种迭代器增强功能。

**考点**：把「不消耗源迭代器」的惰性语义做进切块、预看、窗口等近百个工具函数，难点是 `peekable`/`seekable` 的缓冲回溯与 `chunked` 严格/非严格模式的一致性。

## 49. `paillier`（测试数 234）

**中文规格**

请创建一个名为 Python-Paillier 的 Python 项目，实现一个完整的 Paillier 部分同态加密库。项目应包含以下功能：

1. **密钥生成模块**：实现 Paillier 密钥对的安全生成，支持自定义密钥长度（默认为 3072 位），并确保满足 128 位安全强度要求。包括公钥（n, g）与私钥（λ, μ）的生成与校验。

2. **加密运算模块**：提供针对整数与浮点数的加密函数，基于公钥实现数据加密，支持加密数据的序列化与反序列化，并处理大整数运算与模幂运算。

3. **同态运算引擎**：实现密文与未加密标量的乘法、以及密文之间的加法，支持链式运算（如 `a.encrypt() + b.encrypt() + c`），并保证同态性质在数学上的正确性。

4. **解密处理模块**：使用私钥解密密文，支持解密为整数或浮点数，处理大整数运算与模运算，并保证解密结果的精度与正确性。

5. **浮点数编码体系**：实现 `EncodedNumber` 类来处理浮点数编码，支持不同精度的浮点数表示，处理大整数运算中的精度问题，并保证数值计算的准确性。

6. **密钥管理系统**：实现 keyring（Keyring）来管理多个私钥，支持密钥的序列化与反序列化，提供安全的密钥存储与加载机制，并保证密钥管理的安全性。

7. **性能优化层**：集成 `gmpy2` 以加速大整数运算，实现惰性求值与延迟计算，优化内存使用，支持大数据集的处理，并提升加密、解密与同态运算的效率。

8. **安全防护机制**：实现随机数混淆以防止信息泄漏，防范时序攻击，校验输入参数的合法性，并保证系统在各种攻击场景下的安全性。

9. **测试验证体系**：提供覆盖全部核心功能的单元测试、评估运算效率的性能基准测试、边界情况测试（如边界值、空输入等）、兼容性测试（针对不同 Python 版本），并保证代码质量与稳定性。

10. **文档与示例**：提供完整的 API 文档、详细的使用示例与教程、性能对比与基准测试结果，以及开发指南与贡献规范，便于开发者理解和使用该库。

11. **核心文件要求**：项目必须包含完整的 `setup.py` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `pycrypto>=2.6.1`、`gmpy2>=2.0.4`、`numpy>=1.9.1`、`nose>=1.3.4` 等核心库）。`setup.py` 文件应能验证所有功能模块是否正常工作。同时应提供 `phe/__init__.py` 作为统一 API 入口，导入并导出 `cli`、`generate_paillier_keypair`、`PaillierPrivateKey`、`PaillierPublicKey`、`powmod`、`invert`、`getprimeover`、`isqrt`、`improved_i_sqrt`、`HAVE_GMP`、`HAVE_CRYPTO`、`extended_euclidean_algorithm`、`miller_rabin`、`first_primes`、`is_prime`、`int_to_base64`，以及主要的导入导出函数，并提供版本信息，使用户能通过简单的 `from phe import **` 或 `from phe.** import **` 语句访问所有主要功能。

**考点**：在 `EncodedNumber` 的定点编码上实现 Paillier 的加法同态与标量乘法同态，难点是大整数/浮点精度、编码指数对齐与 `gmpy2` 可选加速下的行为一致。

## 50. `pandarallel`（测试数 217）

**中文规格**

请创建一个名为 Pandarallel 的 Python 项目，实现一个简单高效的 pandas 并行化工具库。项目应包含以下功能：

1. 基础功能：支持对 DataFrame 与 Series 的并行操作，包括 `apply`、`map`、`applymap` 等常用方法。

2. 分组并行：支持对 DataFrameGroupBy 与 SeriesGroupBy 的并行操作。

3. 滚动窗口：支持 `rolling` 与 `expanding` 窗口函数的并行计算。

4. 进度条显示：提供美观的进度条，用于展示并行任务的执行进度。

5. 自动并行：自动探测系统 CPU 核心数并合理分配任务。

6. 内存优化：支持内存文件系统（如 `/dev/shm`）与管道两种通信方式，以优化大数据集的处理。

7. 异常处理：具备完整的错误处理与日志记录机制。

8. 配置管理：提供全局配置接口，用于设置工作进程数、是否显示进度条等参数。

9. 跨平台支持：兼容 Windows、Linux、macOS 等主流操作系统。

10. 核心文件要求：项目必须包含完整的 `setup.py` 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `pandas >= 1.0`、`dill >= 0.3.1`、`psutil`、`numpy`、`pytest` 等核心库）。`setup.py` 文件应能验证所有功能模块是否正常工作。同时需要提供 `pandarallel/__init__.py` 作为统一 API 入口，从 `pandarallel` 模块导入并导出核心函数，并提供版本信息，使用户能通过简单的 `from pandarallel import pandarallel` 语句访问所有主要功能。

**考点**：通过 monkey-patch 给 `DataFrame`/`Series`/`GroupBy`/`Rolling` 挂上 `.parallel_apply` 一族方法，把任务分片到多进程并回收结果，难点是大对象传输（`/dev/shm` 与管道两种通道）与结果顺序、dtype 的还原。

## 51. `parse`（测试数 96）

**中文规格**

请创建一个名为 Parse 的 Python 项目，实现一个字符串解析与模式匹配库。项目应包含以下功能：

1. 解析引擎：从输入的格式化字符串中提取并解析结构化数据，支持 Python `format()` 语法的逆向操作，包括对匿名字段、命名字段与格式化字段的解析。解析结果应为 Result 对象或等价的可比较形式，包含固定位置字段、命名字段、类型转换结果等。应支持多种解析模式（`parse`、`search`、`findall`、`compile`）、模式预编译，以及类型转换体系（从字符串转换到多种 Python 类型）。

2. 格式语法处理器：实现基于 Python `format()` 语法的解析模式的解析与处理功能，包括字段名处理、格式说明符解析、对齐与填充处理、精度与宽度控制等。应支持格式字符串语法解析、字段类型识别、对齐操作符处理以及特殊字符转义。相关功能包括 Parser API 管理、格式说明符解析、字段类型转换、对齐格式化处理、精度与宽度控制、特殊字符处理、格式校验以及语法错误处理。

3. 类型转换体系：管理内置与自定义类型转换，包括数值类型（整数、浮点数、二进制、八进制、十六进制）的特殊处理、日期时间类型（ISO 8601、RFC2822、全球格式、美国格式等）、字符串类型（字母、数字、空白字符等）。相关功能包括类型转换器管理、自定义类型注册、模式匹配校验、类型校验、转换错误处理、默认值处理以及类型推断。

4. 接口设计：为每个功能模块（如解析引擎、格式处理、类型转换、结果管理、模式编译等）设计独立的函数接口，支持多种调用方式。每个模块应定义清晰的输入与输出格式。核心接口包括 `parse()`、`search()`、`findall()`、`compile()`、`with_pattern()` 等。

5. 示例与评测脚本：提供示例代码与测试用例，演示如何使用 `parse()` 与 `search()` 函数进行字符串解析与模式匹配（例如 `parse("It's {}, I love it!", "It's spam, I love it!")` 应返回包含解析结果的 Result 对象）。以上功能需要组合起来，构建完整的字符串解析与模式匹配工具集。项目最终应包含解析引擎、格式处理、类型转换、结果管理、模式编译等模块，并配有典型测试用例，形成可复现的开发流程。

6. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整的依赖清单（包括 `setuptools` 等核心库）。`pyproject.toml` 应能验证所有功能模块是否正常工作。此外，需要提供 `parse.py` 文件作为统一 API 入口，从各模块导入核心函数并导出 `parse`、`search`、`findall`、`compile`、`with_pattern` 等核心函数，并提供版本信息，使用户能通过简单的 `from parse import parse, search, findall` 语句访问所有主要功能。`parse.py` 中需要有 `Parser`、`Result`、`Match` 等核心类，以多种策略管理字符串解析与模式匹配。

该项目应成为一个功能完整、高性能、易用的字符串解析与模式匹配库，为 Python 开发者提供强大的文本处理能力。

**考点**：把 `format()` 语法反向编译成正则并附带类型转换器，用 `Result` 承载定位置/命名/转换后的字段，难点是格式说明符（对齐、宽度、精度、类型字符）到正则的映射与 `search`/`Custom` 类型钩子的正确组合。
