#!/usr/bin/env bash
# 在 runner 容器内部执行（由 offline/run_batch2.sh 调用）。
# 约定：$BUNDLE_DIR 在宿主机与容器内是同一个绝对路径。
set -euo pipefail

MODE="${1:-shell}"
: "${BUNDLE_DIR:?}"
TB4_DIR="$BUNDLE_DIR/data/tb4/tasks"

run_tb4() {
  local agent_args=()
  if [ "${TB4_ORACLE:-0}" = "1" ]; then
    agent_args=(-a oracle)
  else
    agent_args=(-a mini-swe-agent -m "openai/${MODEL_NAME}" \
      --base-url "$OPENAI_API_BASE" --api-key-name OPENAI_API_KEY \
      --api-format openai_chat_completions)
  fi
  local include_args=()
  if [ -n "${TB4_TASKS:-}" ]; then
    IFS=',' read -ra names <<< "$TB4_TASKS"
    for n in "${names[@]}"; do include_args+=(-i "$n"); done
  fi
  echo "[TB4] jobs -> $BUNDLE_DIR/results/tb4"
  harbor run \
    -p "$TB4_DIR" \
    "${agent_args[@]}" \
    "${include_args[@]}" \
    --agent-timeout-multiplier "${TB4_AGENT_TIMEOUT_MULTIPLIER:-0.05}" \
    --n-concurrent "${TB4_N_CONCURRENT:-2}" \
    -o "$BUNDLE_DIR/results/tb4" \
    -y
}

run_nl2repo() {
  local harness="$BUNDLE_DIR/data/nl2repo/harness"
  local tasks="${NL2REPO_TASKS:-aiofiles,humanize,sqlparse}"
  local pool="${NL2REPO_MAX_POOL:-1}"
  local iters="${NL2REPO_MAX_ITERATIONS:-500}"
  local port_base="${NL2REPO_PORT_BASE:-3000}"
  local cleanup="${NL2REPO_CLEANUP:-0}"
  # 说明：容器内 venv 固定为 /opt/nl2repo-venv；NL2REPO_PYTHON 仅便于本机/CI 冒烟替换解释器。
  local py="${NL2REPO_PYTHON:-/opt/nl2repo-venv/bin/python}"
  local names
  IFS=',' read -ra names <<< "$tasks"
  echo "[NL2Repo] tasks=$tasks max_pool=$pool max_iterations=$iters port_base=$port_base cleanup=$cleanup"
  python3 - "$harness" "$MODEL_NAME" "$OPENAI_API_BASE" "${OPENAI_API_KEY:-}" \
    "$pool" "$iters" "$port_base" "$cleanup" "${names[@]}" <<'PY'
import json, sys
harness, model, base_url, key, pool, iters, port_base, cleanup, *tasks = sys.argv[1:]

def _truthy(v: str) -> bool:
    return str(v).strip().lower() in ("1", "true", "yes", "on")

cfg = {
    "startPro": [{
        "moduleName": f"openai/{model}" if "/" not in model else model,
        "baseUrl": base_url,
        "sk": key,
        "proNameList": tasks,
    }],
    "max_pool_size": int(pool),
    # 并发隔离参数（harness 优先读 config.json，其次读同名环境变量）
    "port_base": int(port_base),
    "cleanup": _truthy(cleanup),
}
with open(f"{harness}/config.json", "w", encoding="utf-8") as f:
    json.dump(cfg, f, ensure_ascii=False, indent=2)
print("config.json ready, tasks:", tasks, "port_base:", port_base, "max_pool_size:", pool)
# max_iterations 写进 config 模板（harness 会复制该模板到每个任务）
tpl = f"{harness}/template/config.template.toml"
text = open(tpl, encoding="utf-8").read()
import re
text = re.sub(r"^#?max_iterations = \d+", f"max_iterations = {int(iters)}", text, count=1, flags=re.M)
open(tpl, "w", encoding="utf-8").write(text)
print("template max_iterations =", int(iters))
PY
  ( cd "$harness" && "$py" main.py )
}

case "$MODE" in
  tb4) run_tb4 ;;
  oracle) TB4_ORACLE=1 run_tb4 ;;
  nl2repo) run_nl2repo ;;
  shell) exec bash ;;
  *) echo "未知模式: $MODE（tb4|oracle|nl2repo|shell）" >&2; exit 2 ;;
esac
