#!/bin/sh

command_exists()
    command -v "$1" > /dev/null 2>&1

get_cpu()
{
    cpu=$(command_exists lscpu && lscpu | grep "Model name" | awk -F: '{print $2}' | xargs || echo "Unavailable")
    echo "CPU: "$cpu
}

who=$(whoami)
hostname=$(command_exists hostname && hostname || echo "Unknown")
os=$(uname -o)
distro=$(command_exists lsb_release && lsb_release -d | awk -F"\t" '{print $2}' || echo "Unavailable")
kernel=$(uname -r)
uptime=$(uptime -p)
memory=$(command_exists free && free -h | awk '/Mem:/ {print $2 " total, " $3 " used"}' || echo "Unavailable")
ip_address=$(command_exists hostname && (hostname -I || hostname -i) | awk '{print $1}' || echo "Unavailable")
public_ip=$(command_exists curl && curl -s ifconfig.me || echo "Unavailable")
last_boot=$(command_exists who && who -b | awk '{print $3, $4}' || echo "Unavailable")
process_count=$(ps aux | wc -l)
root_partition=$(df -h --output=target,used,avail,pcent | grep '/ ' | awk '{print $2 " " $3 " " $4}')
home_partition=$(df -h --output=target,used,avail,pcent | grep '/home' | awk '{print $2 " " $3 " " $4}')
memory_usage=$(free -g | awk '/Mem:/ {printf "%d%% used (%d/%d GB)", $3/$2*100, $3, $2}')
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8 "% used"}')

echo "$who\n$hostname\n$os\n$distro\n$kernel\n$uptime\n$(get_cpu) : $cpu_usage\n$memory : $memory_usage\n$ip_address\n$public_ip\n$last_boot\n$process_count\n$root_partition\n$home_partition"