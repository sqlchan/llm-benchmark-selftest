# ProgramBench 离线评测修复镜像
# 背景：官方 eval/run.sh 会 `pip install pytest pytest-timeout pytest-xdist`；
#       断网环境会失败，导致 pytest 报 "unrecognized arguments: --timeout=30"，
#       programbench eval 报 results_read_failed。
# 做法：预装 pytest-timeout，并用本地 wheelhouse 让 eval 里的 pip install 离线成功。
# 构建（每个任务镜像做一次）：
#   docker build --build-arg BASE=programbench/<instance>:task_cleanroom_v6 \
#     -t pb-fix -f Dockerfile .
#   docker tag pb-fix programbench/<instance>:task_cleanroom_v6
ARG BASE
FROM ${BASE}
COPY wheels /opt/pip-wheels
RUN pip install --no-index --find-links=/opt/pip-wheels pytest-timeout \
 && printf '[global]\nno-index = true\nfind-links = /opt/pip-wheels\n' > /etc/pip.conf
