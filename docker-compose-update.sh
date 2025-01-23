#!/bin/bash

# 拉取最新的镜像
docker-compose pull

# 构建并启动容器
docker-compose up -d --build
