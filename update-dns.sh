#!/bin/bash
# 提示用户输入DNS服务器地址
echo "请输入要设置的DNS服务器地址（用空格分隔多个地址）："
read -r DNS_SERVERS
# 备份原始配置文件
sudo cp /etc/resolv.conf /etc/resolv.conf.bak
# 使用systemd-resolved修改DNS
if command -v systemd-resolve &> /dev/null; then
    # 修改systemd-resolved的配置文件
    sudo sed -i "s/^DNS=.*/DNS=$DNS_SERVERS/" /etc/systemd/resolved.conf
    # 禁用FallbackDNS
    sudo sed -i "s/^FallbackDNS=.*/FallbackDNS=/" /etc/systemd/resolved.conf
    # 确保resolv.conf指向systemd-resolved的配置
    sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    # 强制更新systemd-resolved的DNS配置
    sudo resolvectl dns
    sudo resolvectl dns "" $DNS_SERVERS
    # 重启systemd-resolved服务
    sudo systemctl restart systemd-resolved
else
    echo "systemd-resolved 未安装，请确保系统支持。"
    exit 1
fi
# 验证DNS修改
echo "DNS已修改为：$DNS_SERVERS"
echo "正在验证DNS配置..."
nslookup google.com
echo "DNS修改完成！"
