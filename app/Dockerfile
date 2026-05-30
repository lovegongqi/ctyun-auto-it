# 使用天翼云基础镜像
FROM su3817807/ctyun:latest

# 切换到 root 用户
USER root

# 设置时区
ENV TZ=Asia/Shanghai
ENV RUNNING_IN_DOCKER=true
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装必要的工具
RUN apt-get update && apt-get install -y \
    cron \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# 复制启动脚本
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# 入口脚本
ENTRYPOINT ["/app/entrypoint.sh"]
