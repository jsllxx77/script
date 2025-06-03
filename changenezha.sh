#!/bin/bash

# 定义配置文件路径
CONFIG_PATH="/opt/nezha/agent"

# 检查路径是否存在
if [ ! -d "$CONFIG_PATH" ]; then
  echo "错误：路径 $CONFIG_PATH 不存在。"
  exit 1
fi

# 1. 修改配置文件
echo "开始修改配置文件..."
for file in $(find "$CONFIG_PATH" -name "config*.yml"); do
  if [ -f "$file" ]; then
    echo "正在处理文件: $file"
    # 使用 sed 命令进行替换
    # 修改 server 字段
    sed -i 's/^server:.*/server: zz.wi11.de:443/' "$file"
    # 修改 tls 字段
    sed -i 's/^tls:.*/tls: true/' "$file"
    echo "文件 $file 修改完成。"
  else
    echo "警告：$file 不是一个有效文件。"
  fi
done
echo "配置文件修改完毕。"
echo ""

# 2. 重启 nezha 服务
echo "开始查找并重启 nezha 服务..."
# 查找包含 nezha 的服务名称
services=$(systemctl list-units --type=service --all | grep 'nezha' | awk '{print $1}')

if [ -z "$services" ]; then
  echo "未找到包含 'nezha' 的 systemd 服务。"
else
  echo "找到以下 nezha 服务："
  echo "$services"
  echo "正在重启这些服务..."
  # 逐个重启服务
  for service in $services; do
    echo "正在重启服务: $service"
    systemctl restart "$service"
    if [ $? -eq 0 ]; then
      echo "服务 $service 重启成功。"
    else
      echo "错误：服务 $service 重启失败。"
    fi
  done
  echo "所有找到的 nezha 服务已尝试重启。"
fi

echo ""
echo "脚本执行完毕。"
