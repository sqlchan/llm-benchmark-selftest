# NL2Repo-Bench 全题规格中文翻译 · Part 5（第 43–45 题）

> 来源：官方仓库 `multimodal-art-projection/NL2RepoBench` @ commit `781a1da` 的 `test_files/<task>/start.md`「Natural Language Instruction」段；测试数取自 `test_case_count.txt`；本文件只含中文译文。

## 43. `markdownify`（测试数 83）

**中文规格**

请创建一个名为 Python-Markdownify 的 Python 项目，实现一个 HTML 转 Markdown 的转换库。项目应包含以下功能：

1. **HTML 解析器**：能解析 HTML 字符串并提取其标签结构，支持多种 HTML 标签（如 `<a>`、`<b>`、`<h1>` - `<h6>`、`<ul>`、`<ol>`、`<table>`、`<code>`、`<pre>` 等）。解析结果应为可遍历并操作 DOM 树结构的 BeautifulSoup 对象。

2. **标签转换器**：实现把 HTML 标签转换为对应 Markdown 语法的函数，包括链接转换（`<a href="url">text</a>`  -> `[text](url)`）、标题转换（`<h1>text</h1>`  -> `# text`）、列表转换（`<ul><li>item</li></ul>`  -> `* item`）、表格转换、代码块转换等。

3. **格式保持与处理**：保持原文档的结构与格式，包括嵌套列表的正确缩进、表格对齐、代码块语法高亮以及空白字符的处理。应支持多种 Markdown 语法风格（ATX 标题、SETEXT 标题、不同列表标记等）。

4. **自定义转换规则**：实现 strip 与 convert 选项，让用户能精确控制哪些标签需要转换、哪些需要忽略。支持 autolinks、heading_style、bullets、strong_em_symbol 等配置选项。

5. **接口设计**：为每个功能模块设计独立的函数接口与命令行接口，支持终端调用进行测试。每个模块应定义清晰的输入与输出格式，包括 `markdownify()` 主函数与 `MarkdownConverter` 类。

6. **示例与测试脚本**：提供示例代码与测试用例，演示如何使用 `markdownify()` 函数进行 HTML 转 Markdown 转换（例如 `markdownify('<b>Hello</b> <a href="http://github.com">GitHub</a>')` 应返回 `'**Hello** [GitHub](http://github.com)'`）。上述功能需要组合起来，构建完整的 HTML 转 Markdown 转换工具包。

7. **核心文件要求**：项目必须包含完整的 pyproject.toml 文件。该文件不仅要把项目配置为可安装包（支持 `pip install`），还要声明完整依赖清单（包括 beautifulsoup4>=4.9,<5、six>=1.15,<2 等核心库）。pyproject.toml 应能验证所有功能模块是否正常工作。此外，需要提供 markdownify/__init__.py 作为统一 API 入口，从 MarkdownConverter 类导入 markdownify 核心函数，导出 ATX、ATX_CLOSED、UNDERLINED、SPACES、BACKSLASH、ASTERISK、UNDERSCORE、LSTRIP、RSTRIP、STRIP、STRIP_ONE 等常量，并提供版本信息，使用户能通过简单的 "from markdownify import markdownify, MarkdownConverter" 语句访问所有主要功能。在 markdownify/__init__.py 中，必须实现完整的 MarkdownConverter 类及其所有方法（convert()、convert_soup()、process_tag()、process_text()、get_conv_fn()、should_convert_tag()、escape()、underline() 等），以支持完整的 HTML 转 Markdown 转换功能。必须实现所有 HTML 标签转换方法，包括 convert_a()、convert_b()、convert_blockquote()、convert_br()、convert_code()、convert_del()、convert_div()、convert_em()、convert_hN()、convert_hr()、convert_i()、convert_img()、convert_li()、convert_list()、convert_p()、convert_pre()、convert_q()、convert_script()、convert_style()、convert_strong()、convert_sub()、convert_sup()、convert_table()、convert_td()、convert_th()、convert_tr()、convert_ul()、convert_ol()、convert_video() 等，以及抽象方法 abstract_inline_conversion() 与辅助函数 chomp()、strip_pre()、strip1_pre() 等。在 main.py 中，需要提供命令行接口以支持多种参数选项，包括 strip、convert、autolinks、heading_style、bullets、strong_em_symbol、newline_style、code_language、escape_asterisks、escape_underscores、escape_misc、keep_inline_images_in、table_infer_header、wrap、wrap_width、strip_document、strip_pre、bs4_options 等。

**考点**：用 BeautifulSoup 遍历 DOM 并按标签名派发到 `convert_*` 方法，难点在空白与缩进的归一化、表格和 `<pre>` 代码块的保留，以及 strip/convert 黑白名单与多项样式选项的组合。

## 44. `markupsafe`（测试数 39）

**中文规格**

请创建一个名为 MarkupSafe 的 Python 项目，实现一个安全处理 HTML/XML 标记的库。项目应包含以下功能：

1. 实现 `escape(s)` 函数，能把字符串中的特殊字符（如 `&`、`<`、`>`、`'`、`"`）转义为 HTML 安全序列，防止 XSS 攻击。

2. 实现 `Markup` 类，它继承自 `str`，表示已经安全转义或本身即安全的 HTML 字符串。该类应支持字符串拼接、格式化、插值等常见操作，并保证结果仍然安全。

3. `escape(s)` 函数应支持自动识别实现了 `__html__` 方法的对象，直接返回其安全的 HTML 表示。

4. 实现 `escape_silent(s)` 函数，在遇到 `None` 时返回空字符串 `Markup('')`，而不是字符串 `'None'`。

5. 实现 `soft_str(s)` 函数，能安全地把对象转换为字符串，且不对 `Markup` 类型做二次转义。

6. `Markup` 类应支持 `unescape()` 方法（把 HTML 实体还原为原字符）与 `striptags()` 方法（去除所有 HTML 标签，只保留文本内容）。

7. `Markup` 类应重载常见字符串方法（如 `split`、`replace`、`format`、`join` 等），保证链式操作的结果仍然返回 `Markup` 类型。

8. 项目应支持 C 扩展（`_speedups`），在可用时自动启用以提高转义性能；否则回退到纯 Python 实现（`_native`）。

9. 项目应包含类型注解，并支持 `mypy`/`pyright` 等类型检查工具。

10. 核心文件要求：项目必须包含完整的 `pyproject.toml` 文件，把项目配置为可安装包（支持 `pip install`）并声明完整依赖清单（如 `setuptools>=78`、`mypy>=1.6`、`pyright>=1.1`、`ruff>=0.1.0`、`pre-commit>=3.3.0` 等实际使用的核心库）。`pyproject.toml` 应确保所有核心功能模块都能正常工作。同时应提供 `src/markupsafe/__init__.py` 作为统一 API 入口，导入并导出 `escape`、`escape_silent`、`soft_str`、`Markup`、`_escape_inner` 以及主要的导入导出函数，并提供版本信息，使用户能通过 `import markupsafe`、`from markupsafe import *` 等简单语句访问所有主要功能。

**考点**：用 `str` 子类承载「已安全」语义，让所有字符串操作与格式化的结果重新获得安全性，并在 C 加速实现与纯 Python 后端之间无缝切换。

## 45. `math-verify`（测试数 192）

**中文规格**

请创建一个名为 Math-Verify 的 Python 项目，实现一个数学答案校验库。项目应包含以下功能：

1. **表达式解析器**：能从输入字符串中提取并解析数学表达式，支持 LaTeX 格式（如 `\\frac{1}{2}`、集合表达式等）与纯文本数学（如 `x^2 + 3*x`）。解析结果应为 SymPy 符号对象或等价的可比较形式。

2. **等价性检查**：实现比较两个数学表达式是否等价的函数（或脚本），包括数值比较与符号比较。应支持分数与小数的近似比较、符号表达式的化简判定，以及关系式/不等式的等价判定。

3. **特殊结构处理**：对集合、区间、矩阵、百分数、单位符号等做特殊处理。例如 `{1,2,3}` 与 `{3,2,1}` 应视为等价，区间 `[0,1]` 应与 `[1,0]` 等价。

4. **接口设计**：为各模块（如解析、数值比较、符号比较、关系比较等）设计独立的命令行或函数接口，支持终端测试。每个模块都应有明确定义的输入/输出格式。

5. **示例与评测脚本**：提供示例代码与测试用例，演示如何使用 parse() 与 verify() 函数进行输入解析与答案校验（例如 `verify(parse("${1,3}\\cup{2,4}$"), parse("${1,2,3,4}$"))` 应返回 True）。上述功能应组合起来，构建完整的数学校验工具包。最终项目应包含解析、比较与整体校验模块，以及典型测试用例，形成可复现的校验流程。

6. **核心文件要求**：项目必须包含完整的 pyproject.toml 文件，不仅要把项目配置为可安装包（支持 pip install），还要声明完整依赖清单（包括 sympy==1.14.0、latex2sympy2_extended==1.10.1、mpmath==1.3.0、numpy、pandas、antlr4-python3-runtime、pytest 等核心库）。pyproject.toml 应验证所有功能模块是否正常工作。此外，提供 math_verify/__init__.py 作为统一 API 入口，从 parser 与 verifier 模块导入核心的 parse 与 verify 函数，并导出 LatexExtractionConfig、ExprExtractionConfig、StringExtractionConfig 等配置类。包含版本信息，使用户能通过简单的 "from math_verify import parse, verify" 语句访问所有主要功能。在 grader.py 中实现 sympy_expr_eq() 函数，用多种策略比较两个 SymPy 表达式是否等价。

**考点**：把 LaTeX/纯文本答案解析成 SymPy 表达式再做多策略等价判定，难点在集合、区间、百分数等结构的归一化，以及「判等价」不等于「判字符串相等」。
