#!/bin/bash

# 初始化 DEVICECODE
DEVICECODE_FILE="/app/data/.devicecode_${APP_USER}"
if [ -n "$APP_USER" ] && [ ! -f "$DEVICECODE_FILE" ]; then
    NEW_DEVICECODE="web_$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 32)"
    echo "$NEW_DEVICECODE" > "$DEVICECODE_FILE"
fi

# 如果有设备码文件，读取并导出
if [ -f "$DEVICECODE_FILE" ]; then
    export DEVICECODE=$(cat "$DEVICECODE_FILE")
    echo "[*] DEVICECODE: $DEVICECODE"
fi

# 启动 cron
service cron start

echo ""
echo "=========================================="
echo "  天翼云电脑手动登录"
echo "=========================================="
echo ""
echo "  登录命令: dotnet /app/CtYun.dll -u $APP_USER -p $APP_PASSWORD"
echo ""
echo "  首次登录需要短信验证码"
echo "  保持后台运行: Ctrl+P, Ctrl+Q"
echo "=========================================="
echo ""

# 等待用户输入命令
/bin/bash
