#!/bin/bash

LOG_DIR="/var/log/caddy"

format_size() {
    local size=$(printf "%.0f" "$1")
    if (( size < 1024 )); then
        echo "${size} B"
    elif (( size < 1048576 )); then
        echo "$(( size / 1024 )) KB"
    elif (( size < 1073741824 )); then
        echo "$(( size / 1048576 )) MB"
    else
        echo "$(( size / 1073741824 )) GB"
    fi
}

list_sites() {
    local total_requests=0
    local total_traffic=0
    declare -A site_requests
    declare -A site_traffic

    echo "📌 站点列表:"
    for log_file in "$LOG_DIR"/*.log; do
        [[ -f "$log_file" ]] || continue
        site_name=$(basename "$log_file" .log)
        if [[ ! -f "$log_file" ]]; then
            echo "  ❌ $site_name (无日志)"
            continue
        fi

        requests=$(jq -r '.request.remote_addr' "$log_file" | wc -l)
        traffic=$(jq -r '.size // 0' "$log_file" | awk '{sum += $1} END {printf "%.0f", sum}')
        traffic=${traffic:-0}

        site_requests["$site_name"]=$requests
        site_traffic["$site_name"]=$traffic
        total_requests=$((total_requests + requests))
        total_traffic=$((total_traffic + traffic))

        echo "  ✅ $site_name - 请求数: $requests, 流量: $(format_size "$traffic")"
    done

    echo -e "\n📊 **站点总览**"
    echo "  🌐 站点总数: ${#site_requests[@]}"
    echo "  📥 总请求数: $total_requests"
    echo "  📊 总流量: $(format_size "$total_traffic")"

    echo -e "\n📈 **Top 5 站点 (按请求数)**"
    for site in "${!site_requests[@]}"; do
        echo "${site_requests[$site]} $site"
    done | sort -nr | head -n 5 | awk '{printf "  %-15s 请求数: %s\n", $2, $1}'

    echo -e "\n💾 **Top 5 站点 (按流量)**"
    for site in "${!site_traffic[@]}"; do
        echo "${site_traffic[$site]} $site"
    done | sort -nr | head -n 5 | while read -r size site; do
        echo "  $site 流量: $(format_size "$size")"
    done
}

extract_ip_logs() {
    local ip="$1"
    local output_file="$2"
    local found=0

    echo "📂 正在搜索与 IP $ip 相关的日志..."
    > "$output_file"
    for log_file in "$LOG_DIR"/*.log; do
        [[ -f "$log_file" ]] || continue
        if file "$log_file" | grep -q "gzip compressed data"; then
            zcat "$log_file" | jq -r "select(.request.remote_ip | contains(\"$ip\")) | tostring" >> "$output_file"
        else
            jq -r "select(.request.remote_ip | contains(\"$ip\")) | tostring" "$log_file" >> "$output_file"
        fi
        [[ -s "$output_file" ]] && found=1
    done

    if [[ $found -eq 1 ]]; then
        echo "✅ 日志已保存到: $output_file"
    else
        echo "❌ 没有找到与 $ip 相关的日志！"
    fi
}

analyze_site() {
    local site="$1"
    local log_path="$LOG_DIR/$site.log"

    if [[ ! -f "$log_path" ]]; then
        echo "错误: 访问日志 $log_path 不存在！"
        return 1
    fi

    echo "日志文件: $log_path"

    echo -e "\n📊 请求数最多的 IP:"
    jq -r '.request.remote_ip' "$log_path" | sort | uniq -c | sort -nr | head -n 10 | awk '{printf "  %-15s 请求数: %s\n", $2, $1}'

    echo -e "\n📊 消耗带宽最多的 IP:"
    jq -r 'select(.size != null) | [.request.remote_ip, .size] | join(" ")' "$log_path" \
        | awk '{traffic[$1] += $2} END {for (ip in traffic) printf "%.0f %s\n", traffic[ip], ip}' \
        | sort -nr | head -n 10 | while read -r size ip; do
        echo "  $ip 流量: $(format_size "$size")"
    done
}

show_menu() {
    echo "欢迎使用 Caddy 日志分析工具"
    echo "请选择功能："
    echo "  1) 列出所有站点并显示汇总数据"
    echo "  2) 查看指定站点的流量信息"
    echo "  3) 筛选出指定 IP 的日志并保存"
    echo "  4) 退出"
    echo -n "请输入选项 (1-4): "
}

main() {
    while true; do
        show_menu
        read choice
        case $choice in
            1)
                list_sites
                echo
                ;;
            2)
                echo -n "请输入站点名称（例如 caddy-web）: "
                read site
                analyze_site "$site"
                echo
                ;;
            3)
                echo -n "请输入要筛选的 IP 地址（例如 198.176.54.97）: "
                read ip
                echo -n "请输入输出文件名（例如 output.txt）: "
                read output_file
                extract_ip_logs "$ip" "$output_file"
                echo
                ;;
            4)
                echo "退出程序"
                exit 0
                ;;
            *)
                echo "无效选项，请输入 1-4"
                echo
                ;;
        esac
    done
}

main
