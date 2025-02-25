#!/bin/bash

log_file="update_log.txt"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

update_service() {
    echo "$1"
    log "$1"
    eval "$2"
    if [ $? -ne 0 ]; then
        echo "错误: $1 失败！"
        log "错误: $1 失败！"
        exit 1
    fi
}

echo "开始更新 Docker Compose 服务的过程..." | tee -a "$log_file"

update_service "步骤 1：正在拉取最新的镜像..." "docker-compose pull"
update_service "步骤 2：正在停止并移除旧的容器..." "docker-compose down"
update_service "步骤 3：正在重建并启动更新后的容器..." "docker-compose up -d"
update_service "步骤 4：正在清理未使用的镜像和资源..." "docker image prune -f"

echo "更新过程已成功完成！" | tee -a "$log_file"
