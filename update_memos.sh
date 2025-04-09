#!/bin/bash

# 提示：备份数据库
echo "正在备份数据库..."
cp -r ~/.memos/memos_prod.db ~/.memos/memos_prod.db.bak
cp -r ~/.memos/memos_prod.db /mnt/one/backup/memos/memos_prod.db.bak
if [ $? -eq 0 ]; then
  echo "数据库备份成功！"
else
  echo "数据库备份失败，请检查！"
  exit 1
fi

# 提示：停止和移除容器
echo "正在停止并移除容器..."
docker stop memos && docker rm memos
if [ $? -eq 0 ]; then
  echo "容器已成功停止并移除！"
else
  echo "停止或移除容器失败，请检查！"
  exit 1
fi

# 提示：拉取最新镜像
echo "正在拉取最新镜像..."
docker pull neosmemo/memos:latest
if [ $? -eq 0 ]; then
  echo "最新镜像拉取成功！"
else
  echo "镜像拉取失败，请检查网络连接！"
  exit 1
fi

# 提示：安装
echo "正在安装并启动容器..."
docker run -d --name memos -p 5230:5230 -v ~/.memos/:/var/opt/memos neosmemo/memos:latest
if [ $? -eq 0 ]; then
  echo "容器安装并启动成功！"
else
  echo "容器启动失败，请检查！"
  exit 1
fi

echo "所有操作完成！Memos 已成功更新。"
