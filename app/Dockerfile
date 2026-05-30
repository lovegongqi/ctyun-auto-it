# 使用天翼云基础镜像
FROM su3817807/ctyun:latest

# 切换到 root 用户
USER root

# 设置时区
ENV TZ=Asia/Shanghai
ENV RUNNING_IN_DOCKER=true
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装必要工具
RUN apt-get update && apt-get install -y \
    cron \
    && rm -rf /var/lib/apt/lists/*

# 复制脚本（如果需要自定义）
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# 入口脚本只显示提示信息并保持容器运行
ENTRYPOINT ["/app/entrypoint.sh"]
