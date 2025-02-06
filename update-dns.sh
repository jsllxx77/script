#!/bin/bash

# 检查环境变量并设置默认值
dns1=${DNS1:-"8.8.8.8"}
dns2=${DNS2:-"8.8.4.4"}

# 提示用户输入 DNS 服务器（如果未通过环境变量传递）
if [ -z "$DNS1" ]; then
    read -p "请输入第一个 DNS 服务器: " dns1
fi

if [ -z "$DNS2" ]; then
    read -p "请输入第二个 DNS 服务器 (可选, 按回车跳过): " dns2
fi

# 备份原始的 resolv.conf 文件
sudo cp /etc/resolv.conf /etc/resolv.conf.bak

# 写入新的 DNS 服务器
if [ -z "$dns2" ]; then
    echo -e "nameserver $dns1" | sudo tee /etc/resolv.conf > /dev/null
else
    echo -e "nameserver $dns1\nnameserver $dns2" | sudo tee /etc/resolv.conf > /dev/null
fi

echo "DNS 服务器已更新。"
