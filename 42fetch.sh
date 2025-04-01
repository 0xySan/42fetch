#!/bin/sh

# 42fetch - A simple system information tool written in shell

# Define constants
_HOME_DIR=$(eval echo "~$USER")
_CONFIG_FOLDER=""
_PROGRAM_NAME="42fetch"
_COLORS_FILE="./data/colors.conf"

if [ -z "$_CONFIG_FOLDER" ]; then
	_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
else
	_SCRIPT_DIR="$_CONFIG_FOLDER"
fi

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
_minOption=0
_logo=""
_logoFinal=""
_configFile=""
_flag=""
_colors=""

# Manage flags
PrintHelp() {
	printf "Usage: $_PROGRAM_NAME [OPTION]...
A simple system information tool written in shell

With no OPTION, it will display the 42 logo with the default configuration file.

  -m, --min			 Makes the flag smaller if the logo supports it
  -l=value, --logo=value	 Specify the logo to use. ex: -l=42 would use the 42 logo
  -c=value, --config=value	 Specify the configuration file to use. ex: -c=default.cfg
  -f=value, --flag=value	 Specify the flag to use. ex: -f=pride would use the pride flag
  -h, --help			 Display this help message\n"
}

# Pre-validate arguments for --logo and --config using manual checks.
for arg in "$@"; do
	case "$arg" in
		--logo)
			echo "Error: --logo must use the format --logo=value" >&2
			exit 1 ;;
		--logo?*)
			case "$arg" in
				--logo=*) ;;
				*)
					PrintHelp
					exit 1 ;;
			esac ;;
		--config)
			echo "Error: --config must use the format --config=value" >&2
			exit 1 ;;
		--config?*)
			case "$arg" in
				--config=*) ;;
				*)
					PrintHelp
					exit 1 ;;
			esac ;;
		--flag)
			echo "Error: --flag must use the format --flag=value" >&2
			exit 1 ;;
		--flag?*)
			case "$arg" in
				--flag=*) ;;
				*)
					PrintHelp
					exit 1 ;;
			esac ;;
	esac
done

TEMP=$(getopt -o hml:c:f: --long flag:,logo:,config:,help,min -- "$@") 2>/dev/null

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

# Process the options

while true; do
	case "$1" in
		-l)
			if echo "$2" | grep -qv '^[=]'; then
				echo "Error: -l must use the format -l=value"
				PrintHelp
				exit 1
			fi
			_logo=$(echo "$2" | sed 's/^[=]//')
			shift 2;;
		-c)
			if echo "$2" | grep -qv '^[=]'; then
				echo "Error: -c must use the format -c=value"
				PrintHelp
				exit 1
			fi
			_configFile=$(echo "$2" | sed 's/^[=]//')
			shift 2;;
		-f)
			if echo "$2" | grep -qv '^[=]'; then
				echo "Error: -c must use the format -c=value"
				PrintHelp
				exit 1
			fi
			_flag=$(echo "$2" | sed 's/^[=]//')
			shift 2;;
		--config)
			_configFile="$2"
			shift 2;;
		--logo)
			_logo="$2"
			shift 2;;
		--flag)
			_flag="$2"
			shift 2;;
		-m|--min)
			_minOption=1
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

eval set -- "$TEMP"

GetLogo()
{
	logoList=$(echo "$_logo" | tr ',' ' ')
	logoList=$(echo "$logoList" | tr '[:upper:]' '[:lower:]')
	set -- $logoList
	numLogos=$#
	if [ "$numLogos" -gt 0 ]; then
		random_index=$(date +%3N)
		random_index=${random_index#0}
		random_index=$((random_index % numLogos))
		_logo=$(eval echo \$$((random_index + 1)))
		_logoFinal=$_logo
	else
		_logo=42
		_logoFinal=42
	fi
}

if [ -z "$_logo" ]; then
	_logo=42
	_logoFinal=42
else
	GetLogo
fi

CreateDefaultCfgFile()
{
	cat > "$_SCRIPT_DIR/default.cfg" <<EOF
\$user@\$hostmachine
\$lengthuh
OS: \$os
Host: \$hostmachine
Kernel: \$kernel
Uptime: \$uptime
Packages: \$packages
Shell: \$shell
Resolution: \$resolution
DE: \$de
Terminal: \$terminal
CPU: \$cpu
GPU: \$gpu
Memory: \$memory
IP: \$ip
PIP: \$pip
LastBoot: \$lastboot
PC: \$pc
Root: \$root
EOF
}

if [ -z "$_configFile" ] || [ ! -f "$_configFile" ]; then
	if [ ! -f "$_SCRIPT_DIR/default.cfg" ]; then
		CreateDefaultCfgFile
	fi
	_configFile="$_SCRIPT_DIR/default.cfg"
fi

# Get logo

getLogoFile()
{
	aliasInput="$1"
	aliasInput=$(echo "$aliasInput" | tr '[:upper:]' '[:lower:]')

	for logo in $_LOGOS; do
		eval "aliasVar=\${${logo}_ALIAS}"
		eval "fileVar=\${${logo}}"

		for word in $aliasVar; do
			if [ "$word" = "$aliasInput" ]; then
				echo "$fileVar" | cut -d' ' -f2-
				return
			fi
		done
	done

	echo "Alias not found"
}

GetColors() {
	flags_list=$(echo "$_flag" | tr ',' ' ')
	set -- $flags_list
	num_flags=$#
	if [ "$num_flags" -gt 0 ]; then
		random_index=$(date +%3N)
		random_index=${random_index#0}
		random_index=$((random_index % num_flags))
		chosen_flag=$(eval echo \$$((random_index + 1)))
		_colors=$(awk -v flag="$chosen_flag" '
			/^\[.*\]$/ { section=($0 == "[" flag "]") }
			section && /^colors=/ { sub("colors=", ""); print $0 }
		' "$_SCRIPT_DIR/$_COLORS_FILE")
	fi
}

GetMaxLineLength()
{
	local file="$1"
	local maxLenght=0

	while IFS= read -r line; do
		local length=${#line}
		if [ "$length" -gt "$maxLenght" ]; then
			maxLenght=$length
		fi
	done < "$file"

	echo "$((maxLenght + 4))"
}

PrintLogoWithCfg()
{
	local logoFile="$1"
	local cfgFile="$_configFile"
	local maxLenght
	maxLenght=$(GetMaxLineLength "$logoFile")
	
	export user="$(GetUser)"
	export hostmachine="$(GetHostname)"
	export lengthuh="$(GetLengthUserHost)"
	export os="$(GetDistro)"
	export kernel="$(GetKernel)"
	export uptime="$(GetUptime)"
	export packages="$(GetPackages)"
	export shell="$(GetShell)"
	export resolution="$(GetResolution)"
	export de="$(GetDE)"
	export terminal="$(GetTerminal)"
	export cpu="$(GetCpu)"
	export gpu="$(GetGPU)"
	export memory="$(GetUsedMemory) / $(GetFullMemory)"
	export ip="$ipAddress"
	export pip="$publicIp"
	export lastboot="$lastBoot"
	export pc="$processCount"
	export root="$rootPartition"
	export home="$homePartition"

	local tmp_cfg
	tmp_cfg=$(mktemp)
	envsubst < "$cfgFile" > "$tmp_cfg"

	exec 3< "$tmp_cfg"

	GetColors
	set -- $_colors
	local colorIndex=0
	local numColors=$#
	while IFS= read -r logo_line; do
		if IFS= read -r cfg_line <&3; then
			if [ -n "$_colors" ]; then
				currentColor=$(eval echo "\$$((colorIndex + 1))")
				printf "\e[38;2;${currentColor}m%-${maxLenght}s\e[0m%s\n" "$logo_line" "$cfg_line"
				colorIndex=$(( (colorIndex + 1) % numColors ))
			else
				printf "%-${maxLenght}s%s\n" "$logo_line" "$cfg_line"
			fi
		else
			if [ -n "$_colors" ]; then
				currentColor=$(eval echo "\$$((colorIndex + 1))")
				printf "\e[38;2;${currentColor}m%s\e[0m\n" "$logo_line"
				colorIndex=$(( (colorIndex + 1) % numColors ))
			else
				printf "%s\n" "$logo_line"
			fi
		fi
	done < "$logoFile"

	while IFS= read -r cfg_line <&3; do
		printf "%-${maxLenght}s%s\n" "" "$cfg_line"
	done

	exec 3<&-
	rm "$tmp_cfg"
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
	printf "$distro"
}

GetHost()
{
	host=$(CommandExists hostnamectl && hostnamectl | grep "Hardware Model" | cut -d ':' -f2 | sed 's/^[ \t]*//' || echo "Unavailable")
	printf "$host"
}

GetKernel()
{
	kernel=$(uname -r)
	printf "$kernel"
}

GetUptime()
{
	uptime=$(uptime -p | sed 's/^up //')
	printf "$uptime"
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
	
	printf "$packages"
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
	printf "$shell"
}

GetResolution()
{
	res=$(xrandr --current | grep '*' | awk '{gsub(/\+/,"",$2); r=int($2+0.5); print $1 " @ " r "Hz"}' | sort -t'@' -k2,2 -n -r | awk '{printf "%s%s", (NR==1 ? "" : ", "), $0}')
	
	printf "%s\n" "$res"
}

GetDE()
{
	DE=""
	if ps -e | grep -q "cinnamon-session"; then
		DE="Cinnamon"
	elif ps -e | grep -q "gnome-session"; then
		DE="GNOME"
	elif ps -e | grep -q "Hyprland"; then
		DE="Hyprland"
	elif ps -e | grep -q "ksmserver"; then
		DE="Plasma"
	elif ps -e | grep -q "lxsession"; then
		DE="LXDE"
	elif ps -e | grep -q "mate-session"; then
		DE="MATE"
	elif ps -e | grep -q "plasmashell"; then
		DE="Plasma"
	elif ps -e | grep -q "xfce4-session"; then
		DE="XFCE"
	fi

	printf "$DE"
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
	printf "$terminal"
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

	printf "$cpu"
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

	printf "$gpu"
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

_logo="$_SCRIPT_DIR/logo/"$(getLogoFile $_logo)

[ -e "$_logo" ] || _logo="$_SCRIPT_DIR/logo/42.txt"

if [ "$((_minOption))" -eq 1 ]; then
	_logoFinal="${_logo%.txt}-min.txt"
fi

[ -e "$_logoFinal" ] || _logoFinal="$_logo"

# Render
PrintLogoWithCfg "$_logoFinal"