#!/bin/bash

log_file="update_log.txt"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$log_file" # 修改：同时输出到控制台和日志文件
}

update_service() {
    local step_description="$1"
    local command_to_run="$2"
    
    log "$step_description" # 日志记录步骤开始

    echo "正在执行: $command_to_run" # 输出到控制台
    
    eval "$command_to_run"
    
    if [ $? -ne 0 ]; then
        echo "错误: \"$step_description\" 失败！请查看日志文件 ($log_file) 获取更多详情。" | tee -a "$log_file" # 错误信息同时输出到控制台和日志
        exit 1
    fi
    echo "\"$step_description\" 完成。" # 步骤完成提示输出到控制台
}

echo "==================================================" | tee -a "$log_file"
log "开始更新 Docker Compose 服务的过程..."
echo "==================================================" | tee -a "$log_file"


# 将 docker-compose pull 修改为 docker compose pull
update_service "步骤 1：正在拉取最新的镜像..." "docker compose pull"

# 将 docker-compose down 修改为 docker compose down
update_service "步骤 2：正在停止并移除旧的容器..." "docker compose down"

# 将 docker-compose up -d 修改为 docker compose up -d
update_service "步骤 3：正在重建并启动更新后的容器..." "docker compose up -d"

# docker image prune -f 这个命令本身就是 docker 命令，不需要修改
update_service "步骤 4：正在清理未使用的镜像和资源..." "docker image prune -f"

echo "==================================================" | tee -a "$log_file"
log "更新过程已成功完成！"
echo "==================================================" | tee -a "$log_file"

