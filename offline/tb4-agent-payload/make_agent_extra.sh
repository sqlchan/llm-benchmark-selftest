#!/bin/bash
# 在 payload 镜像内打包 mcp 补丁层内容（缺失的 site-packages 条目）
set -eu
OUT="$1"
SP=/opt/tb4-agent/tools/mini-swe-agent/lib/python3.12/site-packages
tr -d '\r' < /out/missing.txt > /tmp/missing-lf.txt
cd "$SP"
tar czf /out/agent-extra.tar.gz -T /tmp/missing-lf.txt
ls -l /out/agent-extra.tar.gz
