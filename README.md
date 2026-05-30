# 天翼云电脑手动登录工具

本项目用于手动登录天翼云电脑，支持容器化部署。

## 项目结构

```
ctyun-auto/
├── deploy.sh               # 交互式部署脚本
└── app/
    ├── Dockerfile           # 运行环境
    ├── entrypoint.sh        # 容器入口（手动登录模式）
    └── CtYun.dll            # 天翼云登录程序
```

## 快速开始

```bash
git clone https://github.com/lovegongqi/ctyun-auto-it.git
cd ctyun-auto/
bash deploy.sh
```

按提示输入：
- `APP_USER`：天翼云账号
- `APP_PASSWORD`：密码
- 数据目录：容器挂载目录（默认 `~/data`）

## 登录命令

### 方式一：进入容器终端登录

```bash
# 进入容器
docker exec -it ctyun_sign_<APP_USER> /bin/bash

# 在容器内执行登录
dotnet CtYun.dll -u <账号> -p <密码>
```

### 方式二：直接执行登录

```bash
docker exec -it ctyun_sign_<APP_USER> dotnet /app/CtYun.dll -u <账号> -p <密码>
```

## 首次登录说明

1. 首次运行会提示输入**短信验证码**
2. 在终端输入收到的验证码并回车
3. 登录成功后，设备码会自动保存到 `/app/data/.devicecode_<账号>` 文件
4. **设备绑定后**，后续登录无需再验证

## 常用命令

```bash
# 查看容器状态
docker ps -a | grep ctyun

# 查看日志
docker logs -f ctyun_sign_<APP_USER>

# 停止容器
docker stop ctyun_sign_<APP_USER>

# 启动容器
docker start ctyun_sign_<APP_USER>

# 重新登录（设备绑定后可自动登录）
docker exec -it ctyun_sign_<APP_USER> dotnet /app/CtYun.dll -u <账号> -p <密码>
```

## 注意事项

- 设备码保存在挂载的数据目录中，删除后需要重新验证
- 容器默认开启 cron 服务，可用于定时任务
