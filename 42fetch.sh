#!/bin/sh

# 42fetch - A simple system information tool written in shell


# Define constants
_PROGRAM_NAME="42fetch"

_LOGOS="_ARCH _BLAHAJ _FT _UBUNTU"

_ARCH="_ARCH_ALIAS Arch.txt"
_BLAHAJ="_BLAHAJ_ALIAS Blåhaj.txt"
_FT="_FT_ALIAS 42.txt"
_UBUNTU="_UBUNTU_ALIAS Ubuntu.txt"

_ARCH_ALIAS="arch"
_BLAHAJ_ALIAS="blahaj blåhaj"
_FT_ALIAS="42 ft fortytwo forty-two"
_UBUNTU_ALIAS="ubuntu"


# Manage flags
PrintHelp()
	echo "Usage: $0 [-l=value | --logo=value] [-h|--help]"

for arg in "$@"; do
	case "$arg" in
		--logo)
			echo "Error: --logo must use the format --logo=value"
			exit 1;;
		--logo?*)
			case "$arg" in
				--logo=*);;
				*)
					PrintHelp
					exit 1;;
			esac;;
	esac
done

TEMP=$(getopt -o hl: --long logo:,help -- "$@") 2>/dev/null

if [ $? != 0 ]; then
	for arg in "$@"; do
		echo "$_PROGRAM_NAME: unrecognized option '$arg'" >&2
		echo "Try '$_PROGRAM_NAME -h|--help' for more information" >&2
		exit 1
	done
	echo "$_PROGRAM_NAME: unknown error parsing options" >&2
	exit 1
fi

eval set -- "$TEMP"

while true; do
	case "$1" in
		-l)
			if echo "$2" | grep -qv '^='; then
				echo "Error: -l must use the format -l=value"
				PrintHelp
				exit 1
			fi
			logo=$(echo "$2" | sed 's/^=//')
			shift 2;;
		--logo)
			logo="$2"
			shift 2;;
		-h|--help)
			PrintHelp
			exit 0;;
		--)
			shift
			break;;
		*)
			break;;
	esac
done

if [ -z "$logo" ]; then
	logo=42
fi

# Get logo

get_logo_file() {
    alias_input="$1"
	alias_input=$(echo "$alias_input" | tr '[:upper:]' '[:lower:]')

    for logo in $_LOGOS; do
        eval "alias_var=\${${logo}_ALIAS}"
        eval "file_var=\${${logo}}"

        for word in $alias_var; do
            if [ "$word" = "$alias_input" ]; then
                echo "$file_var" | cut -d' ' -f2-
                return
            fi
        done
    done

    echo "Alias not found"
}

GetMaxLineLength() {
	local file="$1"
	local max_length=0

	while IFS= read -r line; do
		local length=${#line}
		if [ "$length" -gt "$max_length" ]; then
			max_length=$length
		fi
	done < "$file"

	echo "$((max_length + 4))"
}

PrintLogo() {
	local file="$1"
	local max_length=$(GetMaxLineLength "$file")
	while IFS= read -r line; do
		printf "%-${max_length}s:\n" "$line"
	done < "$file"
}


# Get system information
CommandExists()
	command -v "$1" > /dev/null 2>&1

GetCpu()
{
	cpu=$(CommandExists lscpu && lscpu | grep "Model name" | awk -F: '{print $2}' | xargs || echo "Unavailable")
	echo "CPU: "$cpu
}

who=$(whoami)
hostname=$(CommandExists hostname && hostname || echo "Unknown")
os=$(uname -o)
distro=$(CommandExists lsb_release && lsb_release -d | awk -F"\t" '{print $2}' || echo "Unavailable")
kernel=$(uname -r)
uptime=$(uptime -p)
memory=$(CommandExists free && free -h | awk '/Mem:/ {print $2 " total, " $3 " used"}' || echo "Unavailable")
ipAddress=$(CommandExists hostname && (hostname -I || hostname -i) | awk '{print $1}' || echo "Unavailable")
publicIp=$(CommandExists curl && curl -s ifconfig.me || echo "Unavailable")
lastBoot=$(CommandExists who && who -b | awk '{print $3, $4}' || echo "Unavailable")
processCount=$(ps aux | wc -l)
rootPartition=$(df -h --output=target,used,avail,pcent | grep '/ ' | awk '{print $2 " " $3 " " $4}')
homePartition=$(df -h --output=target,used,avail,pcent | grep '/home' | awk '{print $2 " " $3 " " $4}')
memoryUsage=$(free -g | awk '/Mem:/ {printf "%d%% used (%d/%d GB)", $3/$2*100, $3, $2}')
cpuUsage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8 "% used"}')


# Render
PrintLogo "logo/$(get_logo_file "$logo")"
echo "$who\n$hostname\n$os\n$distro\n$kernel\n$uptime\n$(GetCpu) : $cpuUsage\n$memory : $memoryUsage\n$ipAddress\n$publicIp\n$lastBoot\n$processCount\n$rootPartition\n$homePartition"