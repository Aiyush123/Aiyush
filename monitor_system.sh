#!/bin/bash

# Default values
interval=5
format="text"
output_file="system_report"

# Function to display usage instructions
usage() {
  echo "Usage: $0 [interval] [format]"
  echo "  interval : Monitoring interval in seconds (default: 5)"
  echo "  format   : Output format: text, json, or csv (default: text)"
  exit 1
}

# Function to validate input values
validate_input() {
  if [[ ! "$interval" =~ ^[0-9]+$ ]]; then
    echo "Error: Interval must be a positive integer."
    exit 1
  fi

  if [[ "$format" != "text" && "$format" != "json" && "$format" != "csv" ]]; then
    echo "Error: Format must be text, json, or csv."
    exit 1
  fi
}

# Function to collect inputs interactively
get_user_input() {
  echo -n "Enter monitoring interval in seconds (default: 5): "
  read interval_input
  if [[ ! -z "$interval_input" && "$interval_input" =~ ^[0-9]+$ ]]; then
    interval=$interval_input
  fi

  echo -n "Enter output format (text, json, csv - default: text): "
  read format_input
  if [[ ! -z "$format_input" && ("$format_input" == "text" || "$format_input" == "json" || "$format_input" == "csv") ]]; then
    format=$format_input
  fi
}

# Check if script is run with arguments
if [[ $# -eq 0 ]]; then
  echo "No arguments provided. Enter details interactively:"
  get_user_input
elif [[ $# -eq 2 ]]; then
  interval=$1
  format=$2
else
  echo "Invalid number of arguments."
  usage
fi

# Validate inputs
validate_input
# Function to create progress bar
progress_bar() {
  local value=$1
  local max=$2
  local bar_length=50
  local filled_length=$((value * bar_length / max))
  local empty_length=$((bar_length - filled_length))
  local bar=$(printf "%${filled_length}s" | tr ' ' '=')
  local empty=$(printf "%${empty_length}s")
  echo -n "|$bar$empty| $value%"
}


# Main monitoring and logging functions
collect_info() {
  cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d'.' -f1)
  mem_info=$(free -m | awk '/Mem:/ {print $2, $3, $4}')
  total_mem=$(echo $mem_info | awk '{print $1}')
  used_mem=$(echo $mem_info | awk '{print $2}')
  free_mem=$(echo $mem_info | awk '{print $3}')
  mem_usage=$((used_mem * 100 / total_mem))
  disk_info=$(df -h --output=source,size,used,avail,pcent | tail -n +2)
  top_processes=$(ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 | tail -n 5)
}

log_data() 
{
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  if [[ "$format" == "text" ]]; then
    {
      echo "Timestamp: $timestamp"
      echo "CPU Usage: $cpu_usage%"
      progress_bar $cpu_usage 100
      echo ""
      echo "Memory Usage: Total=${total_mem}MB, Used=${used_mem}MB, Free=${free_mem}MB, Usage=${mem_usage}%"
      progress_bar $mem_usage 100
      echo ""
      echo "Disk Usage:"
      echo "$disk_info"
      echo "Top 5 CPU-consuming Processes:"
      echo "$top_processes"
      echo "-----------------------------------"
    } >> "${output_file}.txt"
  elif [[ "$format" == "json" ]]; then
    {
      echo "{"
      echo "  \"timestamp\": \"$timestamp\","
      echo "  \"cpu_usage\": \"$cpu_usage%\","
      echo "  \"memory\": { \"total\": \"$total_mem\", \"used\": \"$used_mem\", \"free\": \"$free_mem\", \"usage\": \"$mem_usage%\" },"
      echo "  \"disk_usage\": ["
      echo "$disk_info" | awk '{printf "    {\"filesystem\": \"%s\", \"total\": \"%s\", \"used\": \"%s\", \"available\": \"%s\", \"usage\": \"%s\"},\n", $1, $2, $3, $4, $5}' | sed '$ s/,$//'
      echo "  ],"
      echo "  \"Top 5 CPU-consuming Processes:\": ["
      echo "$top_processes" | awk '{printf "    {\"pid\": \"%s\", \"command\": \"%s\", \"cpu_usage\": \"%s\"},\n", $1, $2, $3}' | sed '$ s/,$//'
      echo "  ]"
      echo "}"
    } >> "${output_file}.json"
  elif [[ "$format" == "csv" ]]; then
	  
 # Write headers only if the file is new
    if [[ ! -f "${output_file}.csv" ]]; then
      echo "Timestamp,CPU_Usage,Total_Memory,Used_Memory,Free_Memory,Memory_Usage,Filesystem,Total_Size,Used,Available,Usage_Percentage,PID,Command,Process_CPU_Usage" > "${output_file}.csv"
    fi

    # Write system info
    echo "$timestamp,$cpu_usage,$total_mem,$used_mem,$free_mem,$mem_usage,,,,," >> "${output_file}.csv"

    # Write disk usage info
    echo "$disk_info" | awk '{printf ",,,,,,%s,%s,%s,%s,%s\n", $1, $2, $3, $4, $5}' >> "${output_file}.csv"

    # Write top processes info
    echo "$top_processes" | awk '{printf ",,,,,,,,,,%s,%s,%s\n", $1, $2, $3}' >> "${output_file}.csv"
  fi
}

check_alerts() {
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  if ((cpu_usage > 80)); then
    alert_message="[$timestamp] ALERT: CPU usage exceeds 80%! Current: $cpu_usage%"
    echo "$alert_message" | tee -a alert.log
  fi

  if ((mem_usage > 75)); then
    alert_message="[$timestamp] ALERT: Memory usage exceeds 75%! Total=${total_mem}MB, Used=${used_mem}MB, Free=${free_mem}MB, Usage=${mem_usage}%"
    echo "$alert_message" | tee -a alert.log
  fi

  echo "$disk_info" | while read -r filesystem total used available usage; do
    usage_percent=$(echo "$usage" | tr -d '%')
    if ((usage_percent > 90)); then
      alert_message="[$timestamp] ALERT: Disk usage for $filesystem exceeds 90%! Current: $usage"
      echo "$alert_message" | tee -a alert.log
    fi
  done
}

echo "Monitoring system performance every $interval seconds. Press Ctrl+C to stop."
while true; do
  collect_info
  log_data
  check_alerts
  sleep "$interval"
done

