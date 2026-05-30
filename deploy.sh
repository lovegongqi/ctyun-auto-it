#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== 天翼云电脑手动登录部署 ===${NC}\n"

# 1. 环境检查
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[!] 错误: 未安装 Docker。${NC}"
    exit 1
fi

if [ ! -f "app/Dockerfile" ]; then
    echo -e "${RED}[!] 错误: 未找到 app/Dockerfile，请确认处于项目根目录。${NC}"
    exit 1
fi

# 2. 读取配置
read -e -p "账号 (APP_USER): " APP_USER
[ -z "$APP_USER" ] && {
    echo -e "${RED}[!] 账号不能为空。${NC}"
    exit 1
}

read -e -p "密码 (APP_PASSWORD): " APP_PASSWORD
echo ""
[ -z "$APP_PASSWORD" ] && {
    echo -e "${RED}[!] 密码不能为空。${NC}"
    exit 1
}

while true; do
    read -e -p "数据目录 [留空默认 ~/data]: " INPUT_DIR
    if [ -z "$INPUT_DIR" ]; then
        DATA_DIR="$HOME/data"
        break
    elif [[ "$INPUT_DIR" == /* ]]; then
        DATA_DIR="$INPUT_DIR"
        break
    elif [[ "$INPUT_DIR" == ~* ]]; then
        DATA_DIR="${INPUT_DIR/#\~/$HOME}"
        break
    else
        echo -e "${RED}[!] 请输入绝对路径（以 / 或 ~ 开头）。${NC}"
    fi
done

mkdir -p "$DATA_DIR"

# 3. 构建镜像
echo -e "${YELLOW}[*] 正在构建镜像...${NC}"
docker build -q -t ctyun-auto-sign:v1 ./app

CONTAINER_NAME="ctyun_sign_${APP_USER}"
if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
    docker rm -f "$CONTAINER_NAME" > /dev/null
fi

# 4. 启动容器（交互模式）
echo ""
echo -e "${YELLOW}======================================================${NC}"
echo -e "${YELLOW}  容器已启动，进入手动登录模式${NC}"
echo -e "${YELLOW}======================================================${NC}"
echo ""
echo -e "  登录命令: ${GREEN}dotnet CtYun.dll -u $APP_USER -p $APP_PASSWORD${NC}"
echo ""
echo -e "  首次登录需要短信验证码，请在终端输入。"
echo -e "  登录成功后设备会绑定，之后无需再验证。"
echo ""
echo -e "  ${YELLOW}保持容器后台运行: Ctrl+P, Ctrl+Q${NC}"
echo -e "  ${YELLOW}退出终端: exit${NC}"
echo -e "${YELLOW}======================================================${NC}"
echo ""

docker run -it \
  --name "$CONTAINER_NAME" \
  -e APP_USER="$APP_USER" \
  -e APP_PASSWORD="$APP_PASSWORD" \
  -v "$DATA_DIR":/app/data \
  --add-host "deskcdn.ctyun.cn:106.120.187.154" \
  --add-host "deskcdn.ctyun.cn.ctadns.cn:106.120.187.154" \
  --restart unless-stopped \
  ctyun-auto-sign:v1

echo ""
echo -e "${GREEN}[*] 部署完成！${NC}"
echo -e "容器名: ${CONTAINER_NAME}"
echo -e "数据目录: ${DATA_DIR}"
echo -e ""
echo -e "后续登录命令: ${YELLOW}docker exec -it ${CONTAINER_NAME} dotnet /app/CtYun.dll -u ${APP_USER} -p ${APP_PASSWORD}${NC}"
echo -e "查看日志: ${YELLOW}docker logs -f ${CONTAINER_NAME}${NC}"
