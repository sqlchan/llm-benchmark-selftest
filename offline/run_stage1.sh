#!/usr/bin/env bash
# 公司离线环境·阶段 1 自检（模板，命令需按实际镜像/数据目录调整；TODO verify）
# 目标：先证明「端点通、数据在、镜像能起、判分能出」，再放量。
set -euo pipefail

: "${OPENAI_API_BASE:?请在 env/company.env 设置 OPENAI_API_BASE}"
: "${OPENAI_API_KEY:?请在 env/company.env 设置 OPENAI_API_KEY}"
: "${MODEL_NAME:?请在 env/company.env 设置 MODEL_NAME}"

DATA_DIR="${DATA_DIR:-/workspace/data}"
WORK_DIR="${WORK_DIR:-/workspace/jobs}"
mkdir -p "$WORK_DIR"

echo "== 1. 环境检查 =="
python3 --version
uv --version
docker --version
docker info --format '{{.ServerVersion}}' >/dev/null && echo "docker daemon: OK"

echo "== 2. 模型端点连通性 =="
curl -sS -m 20 "${OPENAI_API_BASE%/}/chat/completions" \
  -H "Authorization: Bearer ${OPENAI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"${MODEL_NAME}\",\"messages\":[{\"role\":\"user\",\"content\":\"ping\"}],\"max_tokens\":8}" \
  | head -c 400 || { echo "端点不通：检查反向代理/证书/网段"; exit 1; }
echo

echo "== 3. 数据检查 =="
ls -la "$DATA_DIR" 2>/dev/null || { echo "缺少 $DATA_DIR（docker-compose 挂载）"; exit 1; }

echo "== 4. Automation-Bench（最轻，先跑 5 题）=="
# TODO verify：仓库依赖是否已离线可用（uv sync --offline 需要构建时预热缓存）
cd "$DATA_DIR/AutomationBench"
uv run --offline auto-bench --model "$MODEL_NAME" \
  --base-url "$OPENAI_API_BASE" --api-key "$OPENAI_API_KEY" \
  --domains simple --num-examples 5 --max-concurrent 2 \
  --export-json "$WORK_DIR/automation_simple5.json"

echo "== 5. ProgramBench（1 题，验证任务容器 + 判分）=="
# 生成 mini-swe 的端点配置（避免把 key 写进文件）
cat > "$WORK_DIR/mini-swe-model.yaml" <<EOF
model:
  model_name: ${MODEL_NAME}
  model_kwargs:
    custom_llm_provider: openai
    api_base: ${OPENAI_API_BASE}
  cost_tracking: ignore_errors
EOF
# TODO verify：slice 与镜像清单一致；离线时任务镜像需已 docker load
cd "$DATA_DIR/programbench"
python3 -m pip show programbench >/dev/null 2>&1 || echo "警告：programbench 未安装，需在 runner 镜像中预装"
mini-extra programbench --model "$MODEL_NAME" --slice 0:1 --workers 1 -c "$WORK_DIR/mini-swe-model.yaml" || true

echo "== 阶段 1 自检完成；确认后再放量（见 report/api-only-5bench-plan.md）=="
