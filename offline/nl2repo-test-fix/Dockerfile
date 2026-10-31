# NL2Repo 离线测试镜像：预装构建后端与项目依赖
# 构建上下文 = offline/nl2repo-test-fix/
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

USER root
COPY install_deps.py /tmp/install_deps.py
RUN python /tmp/install_deps.py
