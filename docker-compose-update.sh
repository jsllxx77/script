#!/bin/bash

echo "开始更新 Docker Compose 服务的过程..."

# 拉取最新的镜像
echo "步骤 1：正在拉取最新的镜像..."
docker-compose pull
echo "步骤 1 完成：最新的镜像已成功拉取。"

# 停止旧容器
echo "步骤 2：正在停止并移除旧的容器..."
docker-compose down
echo "步骤 2 完成：旧的容器已停止并移除。"

# 重建并启动更新后的容器
echo "步骤 3：正在重建并启动更新后的容器..."
docker-compose up -d
echo "步骤 3 完成：更新后的容器已成功启动。"

# 清理旧镜像和无用资源
echo "步骤 4：正在清理未使用的镜像和资源..."
docker image prune -f
echo "步骤 4 完成：未使用的镜像和资源已清理。"

echo "更新过程已成功完成！"
