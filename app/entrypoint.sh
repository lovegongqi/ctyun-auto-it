#!/bin/bash
set -e

DEVICECODE_FILE="/app/data/.devicecode_$APP_USER"

if [ ! -f "$DEVICECODE_FILE" ]; then
    export DEVICECODE="web_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
    echo "$DEVICECODE" > "$DEVICECODE_FILE"
fi

export DEVICECODE=$(cat "$DEVICECODE_FILE")
echo "[*] DEVICECODE: $DEVICECODE"

if [ ! -f "/etc/timezone" ]; then
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/timezone
fi

env >> /etc/environment

service cron start
echo "[*] Cron 定时服务已启动。"

echo ""
echo "======================================================"
echo "  欢迎使用天翼云电脑手动登录模式"
echo "======================================================"
echo ""
echo "  登录命令: dotnet CtYun.dll -u $APP_USER -p $APP_PASSWORD"
echo ""
echo "  首次登录需要短信验证码，请在终端输入。"
echo "  登录成功后设备会绑定，之后无需再验证。"
echo ""
echo "  保持容器后台运行: Ctrl+P, Ctrl+Q"
echo "  退出容器: exit"
echo "======================================================"
echo ""

# 启动交互式 bash，让用户可以直接输入命令并看到输出
exec /bin/bash
