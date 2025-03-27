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

# Define global variables
_min_option=0
_logo="42"
_logo_final="42"

# Manage flags
PrintHelp()
{
	echo "Usage: $0 [-l=value | --logo=value] [-h|--help]"
}

for arg in "$@"; do
	case "$arg" in
		--logo)
			echo "Error: --logo must use the format --logo=value"
			exit 1;;
		--logo?*)
			case "$arg" in
				--logo=*|--logo:*);;
				*)
					PrintHelp
					exit 1;;
			esac;;
	esac
done

TEMP=$(getopt -o hml: --long logo:,help,min -- "$@") 2>/dev/null

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
			if echo "$2" | grep -qv '^[=:]'; then
				echo "Error: -l must use the format -l=value"
				PrintHelp
				exit 1
			fi
			_logo=$(echo "$2" | sed 's/^[=:]//')
			shift 2;;
		--logo)
			_logo="$2"
			shift 2;;
		-m|--min)
			_min_option=1
			shift;;
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

if [ -z "$_logo" ]; then
	_logo=42
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
{
	command -v "$1" > /dev/null 2>&1
}

GetUser()
{
	who=$(whoami)
	printf "$who"
}

GetHostname()
{
	hostname=$(CommandExists hostname && hostname || echo "Unknown")
	printf "$hostname"
}

GetLengthUserHost()
{
	length=$(GetUser)
	length="$length@$(GetHostname)"
	length="${#length}"
	for i in $(seq 1 "$length"); do
		echo -n "-"
	done
}

GetDistro()
{
	distro=$(CommandExists lsb_release && lsb_release -d | awk -F"\t" '{print $2}' || echo "Unavailable")
	printf "OS: $distro"
}

GetHost()
{
	host=$(CommandExists hostnamectl && hostnamectl | grep "Hardware Model" | cut -d ':' -f2 | sed 's/^[ \t]*//' || echo "Unavailable")
	printf "Host: $host"
}

GetKernel()
{
	kernel=$(uname -r)
	printf "Kernel: $kernel"
}

GetUptime()
{
	uptime=$(uptime -p | sed 's/^up //')
	printf "Uptime: $uptime"
}

GetPackages()
{
	packages=""
	if CommandExists dpkg; then
		packages="$(dpkg --get-selections | wc -l) (dpkg)"
	elif CommandExists dnf; then
		packages="$(dnf list installed | wc -l) (dnf)"
	elif CommandExists pacman; then
		packages="$(pacman -Q | wc -l) (pacman)"
	elif CommandExists brew; then
		packages="$(brew list | wc -l) (brew)"
	elif CommandExists winget; then
		packages="$(winget list | wc -l) (winget)"
	fi
	if command -v snap > /dev/null 2>&1 && [ $(snap list | wc -l) -gt 0 ]; then
		if [ -z "$packages" ]; then
			packages="$(snap list | wc -l) (snap)"
		else
			packages="$packages, $(snap list | wc -l) (snap)"
		fi
	fi
	if command -v flatpak > /dev/null 2>&1 && [ $(flatpak list | wc -l) -gt 0 ]; then
		if [ -z "$packages" ]; then
			packages="$(flatpak list | wc -l) (flatpak)"
		else
			packages="$packages, $(flatpak list | wc -l) (flatpak)"
		fi
	fi
	
	printf "Packages: $packages"
}

GetShell()
{
    parentShell=$(ps -o comm= -p $(ps -o ppid= -p $$))
    shell=""

    if echo "$parentShell" | grep -q "zsh"; then
        shell=$($parentShell --version | sed 's/(.*)//')
    elif echo "$parentShell" | grep -q "bash"; then
        shell="bash $($parentShell --version | awk 'NR==1 {print $4}' | cut -d '(' -f 1)"
    else
        shell=$parentShell
    fi
	printf "Shell: $shell"
}

GetResolution()
{
	res=$(xrandr --current | grep '*' | awk '{gsub(/\+/,"",$2); r=int($2+0.5); print $1 " @ " r "Hz"}' | sort -t'@' -k2,2 -n -r | awk '{printf "%s%s", (NR==1 ? "" : ", "), $0}')
	
	printf "Resolution: %s\n" "$res"
}

GetDE()
{
	DE=""
	if ps -e | grep -q "gnome-session"; then
		DE="GNOME"
	elif ps -e | grep -q "startkde"; then
		DE="KDE"
	elif ps -e | grep -q "xfce4-session"; then
		DE="XFCE"
	elif ps -e | grep -q "cinnamon-session"; then
		DE="Cinnamon"
	elif ps -e | grep -q "mate-session"; then
		DE="MATE"
	elif ps -e | grep -q "lxsession"; then
		DE="LXDE"
	elif ps -e | grep -q "Hyprland"; then
		DE="Hyprland"
	fi

	printf "DE: $DE"
}

# GetWM()
	# TODO

GetTerminal()
{
	parent_pid=$(ps -o ppid= -p $$)
	grandparent_pid=$(ps -o ppid= -p $parent_pid)
	grandparent_command=$(ps -p $grandparent_pid -o comm=)

	terminal="Unknow"
	terminal="${grandparent_command%[: ]*}"
	if [ "$grandparent_command" = "gnome-terminal-" ]; then
		terminal="${grandparent_command%[-]*}"
	fi
	printf "Terminal: $terminal"
}

GetCpu()
{
	cpu=""
	cpuModel="Unknow"
	cpuCores="$(grep ^cpu\\scores /proc/cpuinfo | uniq |  awk '{print $4}')"
	cpuSpeed=$(grep "cpu MHz" /proc/cpuinfo | head -n 1 | awk '{print $4}')

	if command -v lscpu >/dev/null 2>&1; then
		cpuModel=$(lscpu | grep "Model name" | sed -E 's/Model name:\s+//')
	else
		cpuModel=$(grep -m 1 "model name" /proc/cpuinfo | sed -E 's/.*: //')
	fi

	cpu=$(echo "$cpuModel" | sed -E 's/\(R\)//g; s/\(TM\)//g; s/ CPU//g; s/ [0-9]+-Core Processor//g; s/ +/ /g; s/ @.*//')
	cpu="$cpu ($cpuCores)"
	cpu="$cpu @ $(echo "$cpuSpeed" | awk '{printf "%.1f", $1/1000}') Ghz"

	printf "CPU: $cpu"
}

GetGPU()
{
    gpu_info=$(lspci | grep -i vga)
    gpu=""

    while IFS= read -r line; do
        if echo "$line" | grep -qi "AMD"; then
            processed=$(echo "$line" | sed -E 's/.*(Radeon RX )([0-9]+)\/[0-9]+ XT.*/AMD \1\2 XT/')
        else
            processed=$(echo "$line" | sed -E 's/.*: ([^ ]+).* \[([^]]+)\].*/\1 \2/; s/ \/.*//')
        fi

        if [ -z "$gpu" ]; then
            gpu="$processed"
        else
            gpu="$gpu, $processed"
        fi
    done <<EOF
$gpu_info
EOF

    printf "GPU: %s" "$gpu"
}

GetFullMemory()
{
	memory_info=$(free -m | grep Mem)
	total_memory=$(echo $memory_info | awk '{print $2}')

	printf "$total_memory Mib"
}

GetUsedMemory()
{
	memory_info=$(free -m | grep Mem)
	used_memory=$(echo $memory_info | awk '{print $3}')

	printf "$used_memory Mib"
}

ipAddress=$(CommandExists hostname && (hostname -i || hostname -I) | awk '{print $1}' || echo "Unavailable")
publicIp=$(CommandExists curl && curl -s ifconfig.me || echo "Unavailable")
lastBoot=$(CommandExists who && who -b | awk '{print $3, $4}' || echo "Unavailable")
processCount=$(ps aux | wc -l)
rootPartition=$(df -h --output=target,used,avail,pcent | grep '/ ' | awk '{print $2 " " $3 " " $4}')
homePartition=$(df -h --output=target,used,avail,pcent | grep '/home' | awk '{print $2 " " $3 " " $4}')
cpuUsage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8 "%"}')

_logo="logo/"$(get_logo_file $_logo)

if [ "$((_min_option))" -eq 1 ]; then
	_logo_final="${_logo%.txt}-min.txt"
fi

[ -e "$_logo_final" ] || _logo_final="$_logo"

# Render
PrintLogo "$_logo_final"
printf "$(GetUser)@$(GetHostname)\n"
echo "$(GetLengthUserHost)"
printf "$(GetDistro)\n"
printf "$(GetHost)\n"
printf "$(GetKernel)\n"
printf "$(GetUptime)\n"
printf "$(GetPackages)\n"
printf "$(GetShell)\n"
printf "$(GetResolution)\n"
printf "$(GetDE)\n"
printf "$(GetTerminal)\n"
printf "$(GetCpu)\n"
printf "$(GetGPU)\n"
printf "Memory: $(GetUsedMemory) / $(GetFullMemory)\n"
printf "IP: $ipAddress\n"
printf "PIP: $publicIp\n"
printf "LastBoot: $lastBoot\n"
printf "PC: $processCount\n"
echo "Root: $rootPartition"
if [ -n "$homePartition" ]; then
	printf "Home: $homePartition"
fi