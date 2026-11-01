# ProgramBench 离线评测修复镜像（COPY 版，避免 build 期 pip 在该镜像里“返回成功但文件不落盘”的问题）
# 背景：官方 eval/run.sh 会 `pip install pytest pytest-timeout pytest-xdist`；
#       断网环境会失败，导致 pytest 报 "unrecognized arguments: --timeout=30"，
#       programbench eval 报 results_read_failed。
# 做法：
#   1) 把 pytest-timeout 2.4.0 的 wheel 解包到 site/（pytest_timeout.py + dist-info），
#      直接用 COPY 放进镜像的 dist-packages（COPY 层可靠持久化；该镜像里 RUN pip install 不可靠）；
#   2) 用 /etc/pip.conf 让 eval 里的 pip install 在离线时“已满足/无网也可返回”。
#   3) wheels/ 保留作参考（旧做法）；实际构建不再依赖它。
#
# 构建（每个任务镜像做一次）：
#   docker build --build-arg BASE=programbench/<instance>:task_cleanroom_v6 \
#     -t programbench/<instance>:task_cleanroom_v6 -f Dockerfile offline/programbench-eval-fix
ARG BASE
FROM ${BASE}
COPY site/pytest_timeout.py /usr/local/lib/python3.10/dist-packages/pytest_timeout.py
COPY site/pytest_timeout-2.4.0.dist-info /usr/local/lib/python3.10/dist-packages/pytest_timeout-2.4.0.dist-info
COPY pip.conf /etc/pip.conf
