#!/bin/bash

echo "开始安装 Caddy..."

# 更新并安装必要的软件包
echo "正在安装 debian-keyring debian-archive-keyring 和 apt-transport-https..."
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
if [ $? -ne 0 ]; then
    echo "安装关键软件包失败，请检查网络连接或软件源。"
    exit 1
fi

# 获取并保存 Caddy 的 GPG 密钥
echo "正在下载并保存 Caddy 的 GPG 密钥..."
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
if [ $? -ne 0 ]; then
    echo "下载 Caddy GPG 密钥失败。"
    exit 1
fi

# 添加 Caddy 的稳定版本源
echo "正在添加 Caddy 的软件源..."
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
if [ $? -ne 0 ]; then
    echo "添加 Caddy 软件源失败。"
    exit 1
fi

# 更新软件包索引
echo "正在更新软件包索引..."
sudo apt update
if [ $? -ne 0 ]; then
    echo "更新软件包索引失败。"
    exit 1
fi

# 安装 Caddy
echo "正在安装 Caddy..."
sudo apt install -y caddy
if [ $? -ne 0 ]; then
    echo "安装 Caddy 失败。"
    exit 1
fi

# 验证 Caddy 版本
echo "已成功安装 Caddy, 当前版本为："
caddy version

# 重启 Caddy 服务
echo "正在重启 Caddy 服务..."
sudo systemctl reload caddy && sudo systemctl restart caddy
if [ $? -eq 0 ]; then
    echo "Caddy 服务重启成功。"
else
    echo "Caddy 服务重启失败。"
    exit 1
fi

echo "Caddy 已成功安装并运行。"
