#!/usr/bin/env bash
# 第二批（Terminal-Bench 4.0 + NL2Repo-Bench）离线运行入口。
#
# 在公司 Linux 宿主机（断网）执行；所有 harness 都跑在 runner 容器里。
#
# 关键设计：runner 容器把离线包目录以「相同绝对路径」挂进去（-v "$BUNDLE:$BUNDLE"），
# 因为 Harbor 的 docker compose / OpenHands 的 runtime 容器都是宿主 docker.sock 的
# 兄弟容器，bind mount 的源路径按宿主机解析；容器内路径必须与宿主机一致。
#
# 用法：
#   ./offline/run_batch2.sh tb4             # 跑 TB4 选中子集
#   ./offline/run_batch2.sh nl2repo         # 跑 NL2Repo 选中子集
#   ./offline/run_batch2.sh shell           # 进 runner 交互 shell（自检/调试）
#   ./offline/run_batch2.sh oracle          # TB4 oracle 自检（不需要模型）
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE="${BUNDLE_DIR:-$(cd "$HERE/.." && pwd)}"
MODE="${1:-shell}"
RUNNER_IMAGE="${RUNNER_IMAGE:-bench-eval-runner:v2}"

if [ ! -f "$BUNDLE/offline/env/company.env" ]; then
  echo "缺少 $BUNDLE/offline/env/company.env：先 cp offline/env/example.env 并填写" >&2
  exit 2
fi

# shellcheck disable=SC1091
set -a; . "$BUNDLE/offline/env/company.env"; set +a
: "${OPENAI_API_BASE:?company.env 需要 OPENAI_API_BASE}"
: "${MODEL_NAME:?company.env 需要 MODEL_NAME}"

docker run --rm -it \
  --name bench-eval-runner-batch2 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$BUNDLE:$BUNDLE" \
  -w "$BUNDLE" \
  --add-host host.docker.internal:host-gateway \
  -e BUNDLE_DIR="$BUNDLE" \
  -e NL2REPO_HOST_ROOT="$BUNDLE/data/nl2repo/harness" \
  -e OPENAI_API_BASE -e OPENAI_API_KEY -e MODEL_NAME \
  -e TB4_TASKS="${TB4_TASKS:-}" \
  -e TB4_N_CONCURRENT="${TB4_N_CONCURRENT:-2}" \
  -e TB4_AGENT_TIMEOUT_MULTIPLIER="${TB4_AGENT_TIMEOUT_MULTIPLIER:-0.05}" \
  -e NL2REPO_TASKS="${NL2REPO_TASKS:-}" \
  -e NL2REPO_MAX_POOL="${NL2REPO_MAX_POOL:-1}" \
  -e NL2REPO_MAX_ITERATIONS="${NL2REPO_MAX_ITERATIONS:-500}" \
  "$RUNNER_IMAGE" \
  bash -lc "exec bash '$BUNDLE/offline/run_batch2_inner.sh' '$MODE'"

cat <<EOF

结果位置：
  TB4     : $BUNDLE/results/tb4/<job>/<trial>/verifier/reward.txt 与 result.json
  NL2Repo : $BUNDLE/data/nl2repo/harness/result/*.json
EOF
