#!/bin/bash
# 提示用户输入DNS服务器地址
echo "请输入要设置的DNS服务器地址（用空格分隔多个地址）："
read -r DNS_SERVERS
# 备份原始配置文件
sudo cp /etc/resolv.conf /etc/resolv.conf.bak
# 方法1：直接修改resolv.conf
echo "nameserver $DNS_SERVERS" | sudo tee /etc/resolv.conf > /dev/null
# 方法2：修改网络接口配置文件（如果存在）
if [ -f /etc/network/interfaces ]; then
    sudo sed -i '/dns-nameservers/d' /etc/network/interfaces
    echo "    dns-nameservers $DNS_SERVERS" | sudo tee -a /etc/network/interfaces > /dev/null
fi
# 方法3：使用resolvconf（如果已安装）
if command -v resolvconf &> /dev/null; then
    echo "nameserver $DNS_SERVERS" | sudo tee /etc/resolvconf/resolv.conf.d/head > /dev/null
    sudo resolvconf -u
fi
# 方法4：使用systemd-resolved（如果已安装）
if command -v systemd-resolve &> /dev/null; then
    # 修改systemd-resolved的配置文件
    sudo sed -i "s/^DNS=.*/DNS=$DNS_SERVERS/" /etc/systemd/resolved.conf
    # 禁用FallbackDNS
    sudo sed -i "s/^FallbackDNS=.*/FallbackDNS=/" /etc/systemd/resolved.conf
    # 确保resolv.conf指向systemd-resolved的配置
    sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    # 重启systemd-resolved服务
    sudo systemctl restart systemd-resolved
fi
# 验证DNS修改
echo "DNS已修改为：$DNS_SERVERS"
echo "正在验证DNS配置..."
nslookup google.com
echo "DNS修改完成！"
