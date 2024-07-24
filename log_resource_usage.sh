#!/bin/bash

# 로그 파일 위치 설정
LOG_FILE="/var/log/resource_usage.log"

# 현재 시간 가져오기
CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")

# CPU 사용량 가져오기
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | \
           sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
           awk '{print 100 - $1"%"}')

# 메모리 사용량 가져오기
MEMORY_USAGE=$(free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3, $2, $3*100/$2 }')

# 디스크 사용량 가져오기
DISK_USAGE=$(df -h | awk '$NF=="/"{printf "Disk Usage: %d/%dGB (%s)\n", $3, $2, $5}')

# 로그 파일에 기록
echo "$CURRENT_TIME CPU Usage: $CPU_USAGE, $MEMORY_USAGE, $DISK_USAGE" >> $LOG_FILE