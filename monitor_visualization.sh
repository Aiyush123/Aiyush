#!/bin/bash

# Default values for optional arguments
interval=0.5  # Default interval in seconds (supports milliseconds)

# Function to display usage
usage() {
  echo "Usage: $0 [--interval seconds]"
  echo "  --interval : Monitoring interval in seconds (e.g., 0.1 for 100ms, default: 0.5s)"
  exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --interval) interval="$2"; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown parameter: $1"; usage ;;
  esac
  shift
done

# Validate interval (must be a positive number)
if ! [[ "$interval" =~ ^[0-9]*\.?[0-9]+$ ]]; then
  echo "Error: Interval must be a positive number."
  exit 1
fi

# Function to collect system information
collect_info() {
  cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d'.' -f1)
  mem_info=$(free -m | awk '/Mem:/ {print $2, $3}')
  total_mem=$(echo $mem_info | awk '{print $1}')
  used_mem=$(echo $mem_info | awk '{print $2}')
  mem_usage=$((used_mem * 100 / total_mem))
  disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
}

# Function to draw a bar graph
draw_bar() {
  local label=$1
  local value=$2
  local total=$3
  local max_width=50
  local bar_width=$((value * max_width / total))
  local bar=$(printf "%${bar_width}s" | tr ' ' '=')
  local space=$(printf "%$((max_width - bar_width))s")
  echo -e "${label}: |${bar}${space}| ${value}%"
}

# Function to display real-time system report
display_report() {
  clear
  echo "Real-Time System Monitoring"
  echo "==========================="
  draw_bar "CPU Usage" "$cpu_usage" 100
  draw_bar "Memory Usage" "$mem_usage" 100
  draw_bar "Disk Usage" "$disk_usage" 100
}

# Function to check for warnings
check_warnings() {
  if ((cpu_usage > 80)); then
    echo "Warning: CPU usage is above 80%!"
  fi
  if ((mem_usage > 75)); then
    echo "Warning: Memory usage is above 75%!"
  fi
  if ((disk_usage > 90)); then
    echo "Warning: Disk space usage is above 90%!"
  fi
}

# Main execution loop
while true; do
  collect_info
  display_report
  check_warnings
  echo "------------------------------------"
  sleep "$interval"
done

