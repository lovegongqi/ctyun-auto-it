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

# 4. 删除旧容器（如果存在）
if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
    echo -e "${YELLOW}[*] 删除旧容器...${NC}"
    docker rm -f "$CONTAINER_NAME" > /dev/null
fi

# 5. 创建容器（不启动）
echo -e "${YELLOW}[*] 正在创建容器...${NC}"
docker create \
  --name "$CONTAINER_NAME" \
  -e APP_USER="$APP_USER" \
  -e APP_PASSWORD="$APP_PASSWORD" \
  -v "$DATA_DIR":/app/data \
  --add-host "deskcdn.ctyun.cn:106.120.187.154" \
  --add-host "deskcdn.ctyun.cn.ctadns.cn:106.120.187.154" \
  --restart unless-stopped \
  ctyun-auto-sign:v1

echo ""
echo -e "${GREEN}[*] 容器创建成功！${NC}"
echo ""
echo -e "${YELLOW}======================================================${NC}"
echo -e "${YELLOW}  下一步操作：${NC}"
echo -e "${YELLOW}======================================================${NC}"
echo ""
echo -e "  1. 进入容器终端："
echo -e "     ${GREEN}docker exec -it ${CONTAINER_NAME} /bin/bash${NC}"
echo ""
echo -e "  2. 在容器内执行登录命令："
echo -e "     ${GREEN}dotnet CtYun.dll -u ${APP_USER} -p ${APP_PASSWORD}${NC}"
echo ""
echo -e "  首次登录需要短信验证码，输入后回车即可。"
echo -e "  登录成功后设备会绑定，之后无需再验证。"
echo -e "${YELLOW}======================================================${NC}"
echo ""
echo -e "容器名: ${CONTAINER_NAME}"
echo -e "数据目录: ${DATA_DIR}"
