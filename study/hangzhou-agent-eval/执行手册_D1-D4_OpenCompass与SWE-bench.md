# 执行手册 D1–D4：OpenCompass + SWE-bench 逐条命令清单

> **用途**：照做即可完成《深学清单》里 D1–D2（OpenCompass）和 D3–D4（SWE-bench）。
> **每步格式**：目的 → 命令 → 预期输出 → 常见报错与处理。
> **版本说明**：OpenCompass 文档为 0.5.4（2026-11）；SWE-bench 为 v5 CLI。命令随版本可能微调，以 `--help` 和官方文档为准。

---

## 〇、通用环境准备（约 1 小时，一次做完）

### 0.1 为什么必须用 Linux

两者都依赖 Docker + Linux 文件权限；Windows 原生跑会很痛苦。**推荐路径（选一）**：

| 方案 | 适合 | 说明 |
|---|---|---|
| **A. WSL2 + Docker Desktop** | 本机有 Windows + 至少 150GB 空闲磁盘 | 最省事，教程最多 |
| **B. 云主机（Ubuntu 22.04）** | 本机磁盘/内存不足 | 按量付费，跑完即释放；SWE-bench 更推荐 |
| **C. 纯云评测（Modal 等）** | 只想体验判分链路 | SWE-bench / Harbor 都支持云上跑 |

### 0.2 WSL2 安装（管理员 PowerShell）

```powershell
wsl --install -d Ubuntu-22.04
wsl --set-default-version 2
wsl --list --verbose
```

- **预期**：重启后进入 Ubuntu，设置用户名密码；`wsl -l -v` 显示 `Ubuntu-22.04  Running  2`。
- **报错**：`WslRegisterDistribution failed` → 开启 BIOS 虚拟化；`需要启用虚拟机平台` → `dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart` 后重启。

### 0.3 Docker

- Windows 装 **Docker Desktop**，在 Settings → Resources → WSL Integration 里勾选 Ubuntu-22.04。
- 或在云主机：`curl -fsSL https://get.docker.com | sh && sudo usermod -aG docker $USER`（重新登录生效）。

```bash
docker run --rm hello-world
```

- **预期**：打印 "Hello from Docker!"。
- **报错**：`permission denied while trying to connect to the Docker daemon socket` → `sudo usermod -aG docker $USER` 后重新登录；WSL 里无 docker 命令 → 检查 Docker Desktop 的 WSL Integration。

### 0.4 基础工具与磁盘

```bash
df -h            # SWE-bench 需要 ≥120GB 可用；建议 150GB+
nproc; free -g   # 建议 ≥8 核 / ≥16GB 内存
git --version
```

安装 conda（OpenCompass 推荐）或 uv：

```bash
# 方式一：Miniforge（推荐）
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh -b -p ~/miniforge3
~/miniforge3/bin/conda init bash && source ~/.bashrc

# 方式二：uv（SWE-bench/Harbor 用得上）
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 0.5 目录与 API Key

```bash
mkdir -p ~/eval-lab && cd ~/eval-lab
export OPENAI_API_KEY="sk-..."        # 换成你自己的 key
export OPENAI_BASE_URL="https://api.openai.com/v1"   # 若用兼容接口，改成你的 base_url
```

> 把这两行写进 `~/.bashrc`，避免每次重设；**不要提交到 git**。

---

## 一、D1：OpenCompass 跑通（约 1 天）

### Step 1.1 安装

```bash
conda create -n oc python=3.12 -y
conda activate oc
cd ~/eval-lab
git clone https://github.com/open-compass/opencompass.git
cd opencompass
pip install -e .
opencompass --help
```

- **预期**：`opencompass --help` 打印参数说明（有 `--dry-run`、`--work-dir`、`--debug` 等）。
- **报错**：
  - 依赖冲突 → 确认在新 conda 环境里；必要时 `pip install -U opencompass`（PyPI 版）替代源码安装；
  - `opencompass: command not found` → 没激活 conda 环境，或 `pip show opencompass` 检查是否装到别的 Python。

### Step 1.2 找到可用的模型与数据集配置

```bash
python tools/list_configs.py gsm8k
python tools/list_configs.py openai      # 或 qwen / deepseek / claude
```

- **预期**：列出 config 文件名（不带 `.py`），例如数据集 `demo_gsm8k_chat_gen`、模型 `gpt_...` / `qwen_...`。
- **操作**：打开对应模型配置文件（`opencompass/configs/models/<provider>/<name>.py`），按需填 `key` 或读取环境变量。
- **用第三方 OpenAI 兼容接口**：参考同目录下支持 `base_url` 的配置写法（不同版本字段名可能不同，以文件内注释/文档为准），不要自己发明参数。

### Step 1.3 最小评测（CLI，先 `--debug`）

```bash
opencompass \
  --models <你的模型config名> \
  --datasets demo_gsm8k_chat_gen \
  --work-dir outputs/d1_cli \
  --debug
```

- **预期**：终端逐步打印推理与评分日志；`outputs/d1_cli/<时间戳>/` 下生成 `configs/`、`predictions/`、`results/`、`summary/`。
- **报错**：
  - `401/403` → key 无效或 base_url 不对；
  - `429` → 并发过高，减小 `--max-num-workers` 或分批；
  - 数据集下载失败 → 检查网络/代理，或按文档配置数据缓存目录。

### Step 1.4 看结果

```bash
ls outputs/d1_cli/*/summary
cat outputs/d1_cli/*/summary/*.csv
ls outputs/d1_cli/*/predictions | head
```

- **预期**：CSV 里能看到数据集与指标列；`predictions/` 是逐样本输出，可抽查 prompt 与答案抽取是否正确。

### Step 1.5 配置化复现（推荐方式）

新建 `quick_start_eval.py`：

```python
from mmengine.config import read_base

with read_base():
    from opencompass.configs.datasets.demo.demo_gsm8k_chat_gen import gsm8k_datasets
    from opencompass.configs.models.openai.gpt_6_astra import models as gpt_models

datasets = gsm8k_datasets
models = gpt_models
```

然后：

```bash
opencompass quick_start_eval.py --dry-run          # 只解析配置，不推理
opencompass quick_start_eval.py --work-dir outputs/d1_config --debug
```

- **预期**：`--dry-run` 打印任务划分；正式跑出的 `configs/` 是本次配置快照（可复现的关键）。
- **注意**：把示例里的模型换成你自己有的（如 Qwen/DeepSeek/兼容接口），别照抄不存在的模型。

### Step 1.6 加一个中文数据集，做对比

```bash
python tools/list_configs.py ceval
opencompass --models <模型config名> \
  --datasets demo_gsm8k_chat_gen,<ceval相关config> \
  --work-dir outputs/d1_two_datasets --debug
```

- **预期**：一次运行完成两个数据集；对照两种数据集的分数与样本量，记录**分数可比性**（提示模板、few-shot、答案抽取方式是否一致）。

### Step 1.7 接一个自定义数据集（D2 的核心）

1. 准备本地 jsonl，字段至少包含 `question`（或 prompt）与 `answer`；
2. 按文档 [Add a dataset](https://opencompass.readthedocs.io/en/latest/extension/new_dataset.html) 写 config；想先跑通可以看 [Dataset Quick Evaluation Tutorial](https://opencompass.readthedocs.io/en/latest/extension/custom_dataset.html)；
3. 评分先用规则匹配，再加 [LLM as Judge](https://opencompass.readthedocs.io/en/latest/evaluation/llm_judge.html)；
4. 跑通后用 `python tools/list_configs.py` 确认 config 被识别。

- **验收**：自定义数据集能重复跑出同一分数；judge 判分有可解释的 reason。

### D1 当日产出（写进笔记的模板）

```markdown
# OpenCompass 评测记录
- 环境：Ubuntu 22.04 / Python 3.12 / OpenCompass 0.5.4
- 模型：xxx，接口：xxx；数据集：xxx（样本数）
- 配置：提示模板 / few-shot / evaluator（规则 or judge）
- 结果：指标 x.xx；与 CompassRank 同类模型差异及原因
- 发现的问题：xxx
- 结论：xxx
```

---

## 二、D2：OpenCompass 进阶（约 1 天）

1. **LLM-as-Judge**：给主观任务配 judge，比较 judge 与人工抽检 20 条的一致性；记录 judge 偏差（位置、长度、风格）。
2. **重复评测/稳定性**：参考 [Repeated Evaluation](https://opencompass.readthedocs.io/en/latest/evaluation/repeated_evaluation.html)，同一配置跑 3 次，算均值与波动，回答"分数差多少才算真实提升"。
3. **错误分析**：用 `tools/` 下的预测分析工具抽查 badcase，按"知识缺失/推理错误/格式抽取失败"分类。
4. **可选**：跑一次 Agent 相关配置或了解 AgentCompass 如何接入（同生态）。

**D2 产出**：一份《评测方法可靠性小报告》（judge 一致性 + 重复评测方差 + 5 个 badcase 归因）。

---

## 三、D3：SWE-bench 判分链路（约 1–2 天）

### Step 3.1 资源与架构确认

```bash
uname -m                      # 需要 x86_64（ARM 支持实验性）
df -h                         # ≥120GB 可用
nproc; free -g                # 建议 8 核 / 16GB+
docker info | head -20
```

- **报错**：磁盘不足 → `docker system prune -a` 清理，或换云盘；ARM Mac → 换 x86 云主机/云评测。

### Step 3.2 安装 SWE-bench

```bash
cd ~/eval-lab
git clone https://github.com/SWE-bench/SWE-bench.git
cd SWE-bench
pip install -e .
swebench --help
```

- **预期**：`swebench --help` 显示 `eval / infer / report / images / dataset / submit` 等子命令。
- **报错**：`docker` 相关 → 回 Step 0.3；`swebench` 命令不存在 → 确认 `pip install -e .` 在当前环境。

### Step 3.3 准备任务仓库并自检

```bash
git clone --depth 1 https://github.com/SWE-bench/swe-bench-tasks.git ./swe-bench-tasks
swebench dataset check ./swe-bench-tasks
```

- **预期**：输出任务仓库校验通过。
- **报错**：克隆网络失败 → 重试/代理；`task-repo` 路径不对 → 用绝对路径。

### Step 3.4 用参考补丁验证判分链路（不花 token）

```bash
swebench eval verified --gold \
  -i sympy__sympy-20590 \
  --run-id validate-gold \
  --task-repo ./swe-bench-tasks
```

- **预期**：日志显示构建镜像 → 应用 patch → 跑测试 → 该实例判定 resolved；`logs/evaluation/validate-gold/results.json` 里出现结果。
- **报错**：镜像构建失败（网络/空间）→ 检查 Docker 网络与磁盘；`docker` 无权限 → 回 0.3。

### Step 3.5 看判分产物

```bash
ls logs/build_images 2>/dev/null | head
cat logs/evaluation/validate-gold/results.json
```

- **重点**：找到该实例的测试输出，理解 FAIL_TO_PASS 与 PASS_TO_PASS 分别代表什么。

### Step 3.6 生成预测（需要模型 key）

```bash
export OPENAI_API_KEY="sk-..."
swebench infer verified -m <model名> -o preds -w 8
ls preds
```

- **预期**：`preds/` 下生成预测文件（每个实例一条 patch）。
- **报错**：`401` → key/base_url；`429` → 降低 `-w`（并发）；模型名不支持 → 用 `swebench infer --help` 看命名方式（mini-SWE-agent 走 litellm，provider 前缀如 `openai/...`、`anthropic/...`）。

> **没有 API key 的替代方案**：手工构造预测文件练习判分。格式为每行一个 JSON：
> ```json
> {"instance_id": "sympy__sympy-20590", "model_name_or_path": "manual", "model_patch": "<git diff 内容>"}
> ```
> 再用 `swebench eval verified -p <文件> --run-id manual-run` 判分。

### Step 3.7 判分

```bash
swebench eval verified -p preds --run-id my-run -j 8
swebench report my-run -d verified
```

- **预期**：终端输出 resolved 统计；report 显示总解决率。
- **报错/坑**：**换 patch 必须换 run_id**（缓存按 run_id+instance_id，复用旧结果会误判）；并发过高导致 OOM → 降 `-j`。

### Step 3.8 子集练习（避免全量跑一天）

先用单实例闭环，再挑 5–10 个实例跑；例如：

```bash
swebench eval verified --gold -i <instance_1> -i <instance_2> --run-id subset-test --task-repo ./swe-bench-tasks
```

> `-i` 是否支持重复传参以 `swebench eval --help` 为准；不支持就逐条跑。

---

## 四、D4：失败分析与产出（约 1 天）

### 4.1 挑 3–5 个未 resolved 的实例，逐个归类

| 失败类型 | 判断依据（看日志/预测） |
|---|---|
| 定位失败 | patch 改的文件/函数与 issue 无关 |
| 补丁错误 | 改对了位置但逻辑不对，测试仍失败 |
| 回归破坏 | FAIL_TO_PASS 过了，PASS_TO_PASS 挂了 |
| 环境问题 | 镜像/依赖导致测试本身跑不起来 |
| 测试本身问题 | 测试覆盖不到真实修复，或测试不稳定 |

### 4.2 D3–D4 产出模板

```markdown
# SWE-bench 评测记录
- 环境：x86_64 / 8C16G / 120GB；Docker 版本 xxx
- 实例：Verified 子集 10 个；模型：xxx
- 结果：resolved 3/10 = 30%；平均耗时/成本
- 失败分析：定位失败 x2、补丁错误 x2、回归破坏 x1、环境 x1、测试问题 x1（附证据）
- 结论：resolved 率的局限（测试覆盖、环境成本、可被针对性优化）
```

---

## 五、时间盒与验收

| 时段 | 任务 | 完成标志 |
|---|---|---|
| D1 上午 | 环境（WSL2/Docker/conda） | `docker run hello-world` 通过 |
| D1 下午 | OpenCompass 安装 + 最小评测 + 看结果 | `summary/*.csv` 出现 |
| D2 上午 | 配置化 + 第二数据集 + 自定义数据集 | 自定义数据集可重复跑 |
| D2 下午 | LLM-as-Judge / 重复评测 / badcase | 方法可靠性小报告 |
| D3 上午 | SWE-bench 安装 + gold 单实例 | `results.json` 出现 resolved |
| D3 下午 | 生成预测 + 判分 | report 出 resolved 率 |
| D4 上午 | 子集实验（5–10 实例） | 子集结果 + 日志 |
| D4 下午 | 失败归类 + 报告 | D3–D4 评测记录 |

**验收清单**

- [ ] OpenCompass：模型 + 数据集跑通，summary 可读
- [ ] OpenCompass：自定义数据集可重复复现
- [ ] OpenCompass：judge 与人工抽检一致性有记录
- [ ] SWE-bench：gold patch 判分通过
- [ ] SWE-bench：至少 3 个实例的真实预测被判分
- [ ] SWE-bench：resolved 率能正确解释，失败有归因

---

## 六、报错速查表

| 报错关键词 | 原因 | 处理 |
|---|---|---|
| `permission denied ... docker.sock` | Docker 权限 | `sudo usermod -aG docker $USER` 后重登 |
| `No space left on device` | 镜像/容器占满磁盘 | `docker system prune -a`；扩容 |
| `opencompass: command not found` | 环境未激活/装错 Python | `conda activate oc`；`which python` |
| `401 / 403` | API key 或 base_url 错 | 检查环境变量与配置文件 |
| `429 / rate limit` | 并发过高 | 降 workers / 分批 |
| `Image build failed`（SWE-bench） | Docker 网络/空间/架构 | 重试、清盘、换 x86 机器 |
| 判分结果与预期不符 | 命中 run_id 缓存 | 换新 run_id 重跑 |
| WSL 磁盘只增不减 | 虚拟磁盘不自动收缩 | `wsl --manage <distro> --resize` 或定期清理镜像后压缩 vhdx |

---

## 七、成本与替代方案

- **API 成本**：GSM8K demo 64 题很便宜；SWE-bench 单实例判分免费（本地 Docker），但**推理**按模型计费，先跑 3–5 个实例看 token 成本再放量。
- **时间成本**：SWE-bench 镜像构建是主要等待来源（尤其第一次），可提前 `swebench images build verified -j 8` 预构建（按官方文档）。
- **没条件跑全量**：OpenCompass 用 `--debug` 或精选数据集；SWE-bench 用 `-i` 单实例 + 手工预测文件，同样能讲清判分机制。

---

## 八、参考链接

- OpenCompass：[Quick Start](https://opencompass.readthedocs.io/en/latest/get_started/quick_start.html) · [Add a dataset](https://opencompass.readthedocs.io/en/latest/extension/new_dataset.html) · [LLM as Judge](https://opencompass.readthedocs.io/en/latest/evaluation/llm_judge.html) · [重复评测](https://opencompass.readthedocs.io/en/latest/evaluation/repeated_evaluation.html)
- SWE-bench：[GitHub](https://github.com/SWE-bench/SWE-bench) · [Docs](https://swebench.com/SWE-bench/) · [Verified 数据集](https://huggingface.co/datasets/SWE-bench/SWE-bench_Verified)
- 环境：WSL2 官方文档、Docker Desktop 文档、Miniforge 文档
