# 代码 / Agent 类基准自测调研（2026-10-30）

对应 DeepSeek-V4.1-Flash-1017 模型卡里的四个基准：Terminal-Bench 4.0、DeepSWE v1.1、ProgramBench、NL2Repo-Bench。结论先行：**四个基准的数据/评测器都能拿到**（DeepSWE 的 HF 数据集需要登录接受 gated 条款，但题目本身在 GitHub 公开），没有「只有榜单、拿不到题」的情况。区别在于**跑起来贵不贵、工程坑多不多**：DeepSWE 最适合个人自测，Terminal-Bench 次之（要 GPU sandbox 和预算），ProgramBench 评测便宜但推理极贵，NL2Repo-Bench 是长程重活、工具链最粗糙。

| 基准 | 版本 | 数据 | 题量 | 判分 | 官方 harness | 整轮成本（官方数据） | 自测可行性 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Terminal-Bench 4.0 | v4.0.0（2026-08-26） | 公开，Apache-2.0 | 66 | 单测/verifier，5 次平均 | Harbor | $634–$7,334 | hard |
| DeepSWE v1.1 | v1.1（2026-06-14） | 题目公开；HF gated | 113 | 行为 verifier（binary reward） | Pier + mini-swe-agent | $27–$1,515 | medium |
| ProgramBench | 2026-10-22 更新 | 公开，MIT | 200 | 隐藏行为测试，全过=Resolved | programbench CLI | 约 $7.3k（$36/题） | medium |
| NL2Repo-Bench | arXiv v2（2026-01-08） | 仓库内公开，无 LICENSE | 104 | 上游 pytest 通过率 | OpenHands 0.56 headless | unknown | hard |

## 1. Terminal-Bench 4.0（终端 / CLI Agent）

**能不能跑、怎么跑**：能，题、verifier、参考解都在 Harbor Hub 和 GitHub 上公开（Apache-2.0），官方用 Harbor 在容器里跑，命令是 `harbor run -d terminal-bench/terminal-bench@4.0.0 -e modal -a <agent> -m <model> -k 5`。但部分任务需要 GPU，官方自己用 Modal 的 GPU sandbox（Daytona 也支持），没有 GPU 云账号的人只能跑掉一部分题。榜单是 66 题 × 5 次 = 330 trials；版本从 3.0 的 74 题删掉 8 题、修了 19 题，单题超时统一成 8 小时，且是「连续基准」，不锁 4.0.0 的话分数会漂。

**值不值得跑**：整轮成本按官方榜单在 $634–$7,334（不同模型 / effort 档位），个人自测建议先 `--agent oracle` 验证 sandbox，再抽 5–10 题跑 1 次。要特别注意 Epoch AI 2026-09 的复核：4.0.0 有 30/66 题存在奖励 hack、答案泄漏、假阴/假阳等评分缺陷，被评为 Flawed。所以它适合做「相对能力 smoke test / 和自己历史版本比」，不适合拿单次分数对外宣称。另外榜单的 resolve rate 和模型卡里的 42.3 是同一 harness 口径（Claude Code）才可比，换 agent 后不能直接对比。

## 2. DeepSWE v1.1（代码修复 / 长程 SWE）

**能不能跑、怎么跑**：四个里最容易自己复现的。113 道原创长程题，来自 91 个活跃开源仓库、5 种语言（TS/Go/Python/JS/Rust），任务定义（`task.toml`、`instruction.md`、`environment/Dockerfile`、`tests/`）都在 GitHub 公开；只有 HF 上的 parquet/轨迹是 `gated: auto`，需要 HF 账号点接受条款。官方用 Pier + mini-swe-agent 跑：`pier run -p deep-swe/tasks --agent mini-swe-agent --model <provider/model>`，支持 `--n-tasks 10 --sample-seed 0` 确定性抽样，也支持单题。v1.1 的判分改成「agent 在隔离环境 commit → collect hook 抽 patch → 在全新干净容器里跑手写行为 verifier」，所以必须 Pier > 0.3.0。

**值不值得跑**：很值得。成本按官方博客的「Avg cost per task」是 $0.24–$13.41/题，全量 113 题大约 $27–$1,515（不含重试），10 题抽样基本就是一顿饭钱级别；判分是行为测试而非 gold patch，支持任意正确实现，比 SWE-bench 系干净。坑有三个：首跑要拉各任务的预构建镜像（磁盘/带宽大）；模型卡写的是 Mini-SWE-V2 harness、官方文档用 mini-swe-agent，跨来源比分要注明口径；gated 数据集记得先接受条款，否则会卡在下载。

## 3. ProgramBench（从二进制重建整个程序）

**能不能跑、怎么跑**：能，评测侧很友好：测试集在 HF（MIT、非 gated），运行镜像在 DockerHub（tag `task_cleanroom_v6`），装 `programbench` 后 `programbench eval <run-dir>` 就能判分；提交物是每个任务目录下的 `submission.tar.gz`。但**所有镜像只有 linux/amd64**，Windows 上要 WSL2 或远程 Linux，QEMU 模拟很慢。推理时容器必须断网，二进制只有执行权限（不能 `strings`/`objdump`/反编译），专门防作弊。

**值不值得跑**：评测便宜（CPU + Docker），贵的是推理：官方榜单给的平均 API 成本是 $36.36/题（Opus 5.5），200 题全量约 $7.3k，FAQ 也说个别 run 到过 $5k。个人自测只建议挑 2–5 个中等规模任务（如 jq、ripgrep、fzf）体验，不要全量。另一个口径坑：榜单主指标是 **Resolved（该题全部测试通过）**，Opus 5.5 也只有 18.5%；模型卡里的 29.1 没标统计口径，大概率是平均测试通过率，和 Resolved 不能直接比。论文（2026-05）当时 9 个模型甚至没有一个完全解出任一题。

## 4. NL2Repo-Bench（自然语言 → 完整仓库）

**能不能跑、怎么跑**：能拿到数据和评测器，但工具链是四个里最「研究代码」的：104 题、9 类 Python 库，任务规格和测试在仓库 `test_files/`，评测靠本地 Docker + 两个 OpenHands 0.56 镜像（`openhands:0.56`、`runtime:0.56-nikolaik`），改 `config.json`（`baseUrl`/`sk`/`proNameList`）后 `python main.py`。它**只支持本地 Docker**（python-on-whales 管理容器），多机要 NFS 共享文件；没有官方汇总脚本，结果按随机 UUID 落 `result/`，平均通过率要自己算。

**值不值得跑**：它是四个里最接近「从零建一个完整仓库」的长程任务，单题平均输入规格约 18.8k tokens、交互可到数百轮且无轮数上限，所以**非常慢、非常贵**；论文和仓库都没给成本数据（cost 只能填 unknown）。仓库还**没有 LICENSE 文件**，再分发前要联系作者。建议只把 `proNameList` 留 1–2 题做长程能力探索，不适合全量。口径提醒：模型卡写 68.2、论文里最强 agent 只有 40.2，这是不同代模型 + 不同 harness（模型卡未说明具体 harness）的结果，别当成同一版本直接横向对比。

## 统一口径提醒与建议顺序

- 模型卡四行的 harness 是：Terminal-Bench 4.0 用 Claude Code、DeepSWE v1.1 用 Mini-SWE-V2；另外两个未说明。**模型分数是自报值，不是第三方复现**，自测时务必固定：数据集版本（4.0.0 / v1.1 / 200-task 快照 / 104-task 仓库快照）、agent scaffold、判分脚本、重试次数。
- 数据可得性排序：DeepSWE ≈ ProgramBench ≈ Terminal-Bench > NL2Repo（无 license，需谨慎）。没有任何一个是「仅榜单」。
- 个人预算下的建议顺序：**DeepSWE 抽 10 题（约 $2.4–$134）→ Terminal-Bench 先 oracle 再抽 5 题（需 GPU/Modal）→ ProgramBench 挑 2–3 题（约 $70–$110）→ NL2Repo-Bench 只跑 1 题体验长程**。

字段级细节与全部来源链接见 [benchmarks.json](./benchmarks.json)。
