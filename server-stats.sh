#!/bin/bash

# server-stats.sh - A simple script to monitor server performance

echo "=========================================="
echo "          SERVER PERFORMANCE STATS        "
echo "=========================================="

# 1. OS Version and Uptime
echo -e "\n[System Information]"
echo "OS Version: $(grep PRETTY_NAME /etc/os-release | cut -d '"' -f 2)"
echo "Uptime: $(uptime -p | sed 's/up //')"
echo "Load Average: $(uptime | awk -F'load average:' '{ print $2 }')"
echo "Logged in Users: $(who | wc -l)"

# 2. Total CPU Usage
# Calculates usage by subtracting idle time from 100%
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
echo -e "\n[CPU Usage]"
echo "Total CPU Usage: $cpu_usage"

# 3. Memory Usage
echo -e "\n[Memory Usage]"
free -m | awk 'NR==2{printf "Used: %sMB / Total: %sMB (%.2f%%)\nFree: %sMB\n", $3, $2, $3*100/$2, $4}'

# 4. Disk Usage
echo -e "\n[Disk Usage]"
df -h --total | grep "total" | awk '{printf "Used: %s / Total: %s (%s)\nFree: %s\n", $3, $2, $5, $4}'

# 5. Top 5 Processes by CPU
echo -e "\n[Top 5 Processes by CPU Usage]"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6

# 6. Top 5 Processes by Memory
echo -e "\n[Top 5 Processes by Memory Usage]"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6

# 7. Failed Login Attempts (Stretch Goal)
echo -e "\n[Failed Login Attempts]"
if [ -f /var/log/auth.log ]; then
    grep "Failed password" /var/log/auth.log | wc -l
elif [ -f /var/log/secure ]; then
    grep "Failed password" /var/log/secure | wc -l
else
    echo "Log file not found (requires root/sudo permissions)."
fi

echo -e "\n=========================================="