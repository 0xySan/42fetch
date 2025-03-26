#!/bin/sh

logoName="ubuntu"
PROGRAM_NAME="42fetch"

command_exists()
	command -v "$1" > /dev/null 2>&1

printhelp()
{
    echo "Usage: $0 [-l=value | --logo=value] [-h|--help]"
}

for arg in "$@"; do
    case "$arg" in
        --logo)
            echo "Error: --logo must use the format --logo=value"
            exit 1
            ;;
        --logo?*)
            case "$arg" in
                --logo=*) ;;
                *)
                    printhelp
                    exit 1
                    ;;
            esac
            ;;
    esac
done

TEMP=$(getopt -o hl: --long logo:,help -- "$@") 2>/dev/null

if [ $? != 0 ]; then
    for arg in "$@"; do
        echo "$PROGRAM_NAME: unrecognized option '$arg'" >&2
        echo "Try '$PROGRAM_NAME -h|--help' for more information" >&2
        exit 1
    done
    echo "$PROGRAM_NAME: unknown error parsing options" >&2
    exit 1
fi

eval set -- "$TEMP"

while true; do
    case "$1" in
        -l)
            if echo "$2" | grep -qv '^='; then
                echo "Error: -l must use the format -l=value"
                printhelp
                exit 1
            fi
            logo=$(echo "$2" | sed 's/^=//')
            shift 2
            ;;
        --logo)
            logo="$2"
            shift 2
            ;;
        -h|--help)
            printhelp
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            break
            ;;
    esac
done

if [ -z "$logo" ]; then
    logo=blahaj
fi

echo "Logo: $logo"

get_max_line_length() {
	local file="$1"
	local max_length=0

	while IFS= read -r line; do
		local length=${#line}
		if [ "$length" -gt "$max_length" ]; then
			max_length=$length
		fi
	done < "$file"

	echo "$max_length"
}

if [ -z "$logo" ]; then
	startColumn=0
elif [ "$logo" = "blahaj" ] || [ "$logo" = "blåhaj" ]; then
	startColumn=$(get_max_line_length "logo/Blåhaj.txt")
elif [ "$logo" = "ubuntu" ]; then
	startColumn=$(get_max_line_length "logo/Ubuntu.txt")
fi

echo "startColumn: $startColumn"

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