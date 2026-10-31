#!/usr/bin/env bash
# 公司 32C/64GB Linux 宿主机的第二批入口（TB4 / NL2Repo）。
#
# 作用：export PROFILE=32c64g 后转调 offline/run_batch2.sh，由后者在 source
# offline/env/company.env 之后再 source offline/config/32c64g.env，把并发/超时
# 预设注入 runner 容器。
#
# 用法（在离线包根目录执行）：
#   ./offline/run_batch2_32c64g.sh oracle     # TB4 oracle 自检（不需要模型）
#   ./offline/run_batch2_32c64g.sh tb4        # TB4 36 题，n_concurrent=3，超时倍数 1.0
#   ./offline/run_batch2_32c64g.sh nl2repo    # NL2Repo 10 题，max_pool=3
#   ./offline/run_batch2_32c64g.sh shell      # 进 runner 交互 shell（调试/手工跑其他基准）
#
# 依赖（重要）：
#   run_batch2.sh 必须支持 PROFILE 机制（第二批补丁：sourcing company.env 之后，
#   若 PROFILE 非空则 source "$BUNDLE/offline/config/$PROFILE.env"）。
#   未合入时本脚本会直接报错退出，避免「静默按默认冒烟参数（n=2、超时×0.05）跑
#   正式评测」。
#   无补丁时的等价手工写法（仅 TB4/oracle 可用；NL2Repo 并行依赖补丁）：
#     set -a; . offline/config/32c64g.env; set +a
#     ./offline/run_batch2.sh tb4
#
# 其他基准（DeepSWE / ProgramBench / Automation）不经过本脚本，命令见
# offline/config/32c64g.env 末尾注释与 report/company-32c64g-concurrency.md。
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE=32c64g
export PROFILE

if [ ! -f "$HERE/config/$PROFILE.env" ]; then
  echo "缺少 $HERE/config/$PROFILE.env（32C/64G 并发预设），无法继续" >&2
  exit 2
fi

if ! grep -q 'PROFILE' "$HERE/run_batch2.sh"; then
  echo "错误：$HERE/run_batch2.sh 尚不支持 PROFILE 机制（第二批补丁未合入）。" >&2
  echo "      本脚本必须先 export PROFILE=32c64g，再让 run_batch2.sh source config/$PROFILE.env；" >&2
  echo "      否则会按默认冒烟参数（TB4 并发 2、超时倍数 0.05）运行，正式分数不可比。" >&2
  echo "      临时替代（仅 TB4/oracle）：set -a; . \"$HERE/config/$PROFILE.env\"; set +a; ./offline/run_batch2.sh <mode>" >&2
  echo "      或等补丁合入后再用本 wrapper。" >&2
  exit 3
fi

exec bash "$HERE/run_batch2.sh" "$@"
