"""最小 OpenAI Chat Completions mock server —— 用于断网/无 key 时验证评测链路。

不解题、不产生真实分数：任何请求都返回「无工具调用、直接结束」，因此任务必然是失败分（0），
但能完整验证：数据加载 → 环境初始化 → 模型请求 → 判分 → 结果导出。

用法：
    python mock_openai_server.py 8765
    # 另一个终端（AutomationBench 仓库内）：
    uv run auto-bench --model mock-model --base-url http://127.0.0.1:8765/v1 \
      --api-key dummy --api chat_completions --domains simple --num-examples 2 \
      --max-steps 3 --input-cost 0 --output-cost 0 --export-json mock_result.json

Windows 注意：自动化终端若为 GBK，先设 PYTHONUTF8=1 / PYTHONIOENCODING=utf-8，
否则 rich 打印 "✓" 时可能 UnicodeEncodeError（不影响已导出的 JSON）。
"""
import json
import sys
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8765


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        sys.stderr.write("[mock] " + fmt % args + "\n")

    def _json(self, code, payload):
        raw = json.dumps(payload).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def do_GET(self):
        if self.path.rstrip("/") in ("/v1/models", "/models"):
            return self._json(200, {"object": "list", "data": [{"id": "mock-model", "object": "model"}]})
        return self._json(404, {"error": {"message": f"no route {self.path}"}})

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body_raw = self.rfile.read(length) if length else b"{}"
        try:
            body = json.loads(body_raw)
        except json.JSONDecodeError:
            body = {}
        path = self.path.rstrip("/")
        if path not in ("/v1/chat/completions", "/chat/completions"):
            return self._json(404, {"error": {"message": f"no route {self.path}"}})

        self._json(200, {
            "id": "chatcmpl-mock",
            "object": "chat.completion",
            "created": int(time.time()),
            "model": body.get("model", "mock-model"),
            "choices": [{
                "index": 0,
                "message": {"role": "assistant", "content": "mock: 不调用工具，直接结束（链路验证用）。"},
                "finish_reason": "stop",
            }],
            "usage": {"prompt_tokens": 120, "completion_tokens": 20, "total_tokens": 140},
        })


if __name__ == "__main__":
    server = ThreadingHTTPServer(("127.0.0.1", PORT), Handler)
    print(f"mock server on http://127.0.0.1:{PORT}/v1", flush=True)
    server.serve_forever()
