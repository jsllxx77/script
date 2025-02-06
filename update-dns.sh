#!/bin/bash

# 提示用户输入 DNS 服务器
read -p "请输入第一个 DNS 服务器: " dns1
read -p "请输入第二个 DNS 服务器 (可选, 按回车跳过): " dns2

# 如果第二个 DNS 服务器为空，则只写入一个
if [ -z "$dns2" ]; then
    dns_content="nameserver $dns1"
else
    dns_content="nameserver $dns1\nnameserver $dns2"
fi

# 备份原始的 resolv.conf 文件
sudo cp /etc/resolv.conf /etc/resolv.conf.bak

# 写入新的 DNS 服务器
echo -e $dns_content | sudo tee /etc/resolv.conf > /dev/null

echo "DNS 服务器已更新。"
