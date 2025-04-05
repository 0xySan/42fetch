#!/bin/sh

# 42fetch - A simple system information tool written in shell

# Define constants
_HOME_DIR=$(eval echo "~")
_CONFIG_FOLDER=""
#if you need to edit this script make sure _CONFIG_FOLDER="" stays at the line #7 as it is needed in the ./install.sh exec.
_PROGRAM_NAME="42fetch"
_FLAG_COLORS_FILE="./data/flag.conf"
_LOGO_COLORS_FILE="./data/logo.conf"
_TOKEN=""
_SESSION=""
_LOGIN=$(whoami)

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
_logoUsed=""
_configFile=""
_flag=""
_colors=""
_configOption=0

# Manage flags
PrintHelp() {
	printf "Usage: $_PROGRAM_NAME [OPTION]...
A simple system information tool written in shell

With no OPTION, it will display the 42 logo with the default configuration file.

  -m, --min			 Makes the flag smaller if the logo supports it
  --no-config			 Doesnt output the config file
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

TEMP=$(getopt -o hml:c:f: --long flag:,logo:,config:,help,min,no-config -- "$@") 2>/dev/null

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
			_configOption=1
			shift 2;;
		--logo)
			_logo="$2"
			shift 2;;
		--no-config)
			_configOption="1"
			shift;;
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
		random_index=$(shuf -i 2000-65000 -n 1)
		random_index=$((random_index % numLogos))
		_logo=$(eval echo \$$((random_index + 1)))
		_logoFinal=$_logo
		_logoUsed=$_logo
	else
		_logo=42
		_logoFinal=42
		_logoUsed=42
	fi
}

if [ -z "$_logo" ]; then
	_logo=42
	_logoFinal=42
	_logoUsed=42
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
		random_index=$(shuf -i 2000-65000 -n 1)
		random_index=$((random_index % num_flags))
		chosen_flag=$(eval echo \$$((random_index + 1)))
		_colors=$(awk -v flag="$chosen_flag" '
			/^\[.*\]$/ { section=($0 == "[" flag "]") }
			section && /^colors=/ { sub("colors=", ""); print $0 }
		' "$_SCRIPT_DIR/$_FLAG_COLORS_FILE")
	else
		_colors=$(awk -v logo="$_logoUsed" '
			/^\[.*\]$/ { section=($0 == "[" logo "]") }
			section && /^colors=/ { sub("colors=", ""); print $0 }
		' "$_SCRIPT_DIR/$_LOGO_COLORS_FILE")
	fi
}

GetMaxLineLength()
{
	local file="$1"
	local maxLenght=0

	while IFS= read -r line; do
		i=0
		while [ "$i" -lt 10 ]; do
			line=$(echo "$line" | sed "s/\${$i}//g")
			i=$((i + 1))
		done
		local length=${#line}
		if [ "$length" -gt "$maxLenght" ]; then
			maxLenght=$length
		fi
	done < "$file"

	echo "$((maxLenght + 2))"
}

#42 api

RefreshToken() {
	export $(grep -v '^#' "$_SCRIPT_DIR/.env" | xargs)
	_TOKEN=$(curl -s -X POST "https://api.intra.42.fr/oauth/token" \
		-d "grant_type=client_credentials" \
		-d "client_id=$UID" \
		-d "client_secret=$SECRET" | awk -F'"' '{print $4}')
	echo "$_TOKEN"
}

Get42User() {
	_USER=$(curl -s -X GET "https://api.intra.42.fr/v2/users/$_LOGIN" -H "Authorization: Bearer $1")
	echo "$_USER"
}

GetLevel()
{
	decimalPart=$(echo "$1" | awk -F'.' '{print $2}')
	progress=$(echo "$decimalPart / 5" | bc)
	unfilled=$(( 20 - progress ))
	bar=$(printf "%-${progress}s" "#" | tr ' ' '#')
	empty=$(printf "%-${unfilled}s" "-" | tr ' ' '-')
	echo "[${bar}${empty}]"
}

GetSession()
{
	userId=$(echo "$1" | jq '.id')
	_SESSION=$(curl -s -X GET "https://api.intra.42.fr/v2/users/$userId/locations?page%5Bsize%5D=1" -H "Authorization: Bearer $2")
	echo "$_SESSION"
}

GetDuration()
{
	sessionHost=$(echo "$1" | jq -r '.[0].host // empty')
	beginAt=$(echo "$1" | jq -r '.[0].begin_at // empty')

	if [ -z "$sessionHost" ]; then
		echo "Session: No active session found."
	else
		startTimestamp=$(date -d "$beginAt" +%s)
		currentTimestamp=$(date +%s)
		sessionDuration=$((currentTimestamp - startTimestamp))

		hours=$((sessionDuration / 3600))
		minutes=$(((sessionDuration % 3600) / 60))
		seconds=$((sessionDuration % 60))

		printf "%02dh %02dm %02ds" "$hours" "$minutes" "$seconds"
	fi
}

ApplyColors()
{
	if [ -n "$_flag" ]; then
		logoLine=$(echo "$logoLine" | sed -E 's/\$\{[0-9]+\}//g')
		logoLine=$(printf '\033[38;2;%sm%s' "$currentColor" "$logoLine")
	else
		set -- $_colors
		numColors=$#
		i=0
		while [ "$i" -lt 10 ]; do
			currentColor=$(eval echo "\$$((i + 1))")
			colorSeq=$(printf '\033[38;2;%sm' "$currentColor")
			logoLine=$(echo "$logoLine" | sed "s/\${$i}/$colorSeq/g")
			i=$((i + 1))
		done
		if [ -n "$_colors" ]; then
			defaultColor=$(printf '\033[38;2;%sm' "$(echo "$_colors" | awk '{print $1}')")
			if [ "$logoLine" != $'\033'* ]; then
				logoLine="${defaultColor}${logoLine}"
			fi
		fi
	fi
}

strip_ansi()
{
	sed -r 's/\x1B\[[0-9;]*m//g'
}

PrintLogoWithCfg()
{
	local logoFile="$1"
	local cfgFile="$_configFile"
	local maxLenght
	local length
	maxLenght=$(GetMaxLineLength "$logoFile")
	local tmpCfg
	local termSize=$(GetTerminalSizeX)
	tmpCfg=$(mktemp)

	local needed_vars=$(grep -oE '\$(user|hostmachine|lengthuh|os|kernel|uptime|packages|shell|resolution|de|terminal|cpu|gpu|memory|ip|pip|lastboot|pc|root|home)' "$cfgFile" | sort -u)
	
	for var in $needed_vars; do
		case "$var" in
			"\$user") export user="$(GetUser)" ;;
			"\$hostmachine") export hostmachine="$(GetHostname)" ;;
			"\$lengthuh") export lengthuh="$(GetLengthUserHost)" ;;
			"\$os") export os="$(GetDistro)" ;;
			"\$kernel") export kernel="$(GetKernel)" ;;
			"\$uptime") export uptime="$(GetUptime)" ;;
			"\$packages") export packages="$(GetPackages)" ;;
			"\$shell") export shell="$(GetShell)" ;;
			"\$resolution") export resolution="$(GetResolution)" ;;
			"\$de") export de="$(GetDE)" ;;
			"\$terminal") export terminal="$(GetTerminal)" ;;
			"\$cpu") export cpu="$(GetCpu)" ;;
			"\$cpuusage") export cpu="$(GetCpuUsage)" ;;
			"\$gpu") export gpu=$(GetGPU) ;;
			"\$memory") export memory="$(GetUsedMemory) / $(GetFullMemory)" ;;
			"\$ip") export ip=$(GetIpAddress) ;;
			"\$pip") export pip=$(GetPublicIp) ;;
			"\$lastboot") export lastboot=$(GetLastBoot) ;;
			"\$pc") export pc=$(GetProcessCount) ;;
			"\$root") export root=$(GetRootPartition) ;;
			"\$home") export home=$(GetHomePartition) ;;
		esac
	done

	if [ ! -f "$_SCRIPT_DIR/.env" ]; then
		export level="Unavailable"
		export progressBar="Unavailable"
		export session="Unavailable"
		export duration="Unavailable"
		export correctionPts="Unavailable"
		export wallets="Unavailable"
	else
		token=$(RefreshToken)
		user42=$(Get42User "$token")
		session42=$(GetSession "$user42" "$token")
		export level=$(echo $user42 | jq '.cursus_users[] | select(.cursus_id == 21) | .level')
		export progressBar=$(GetLevel $level)
		export session=$(echo "$session42" | jq -r '.[0].host // empty')
		export duration=$(GetDuration "$session42")
		export correctionPts=$(echo $user42 | jq '.correction_point')
		export wallets=$(echo $user42 | jq '.wallet')
	fi

	envsubst < "$cfgFile" > "$tmpCfg"
	exec 3< "$tmpCfg"

	GetColors
	set -- $_colors
	local colorIndex=0
	local numColors=$#
	while IFS= read -r logoLine; do
		length=0
		if IFS= read -r cfgLine <&3; then
			if [ -n "$_flag" ] && [ -n "$_colors" ]; then
				currentColor=$(eval echo "\$$((colorIndex + 1))")
				ApplyColors
				visibleLogo=$(printf "%b" "$logoLine" | strip_ansi)
				visibleLen=${#visibleLogo}
				padLen=$(( maxLenght - visibleLen ))
				[ $padLen -lt 0 ] && padLen=0
				padding=$(printf "%*s" "$padLen" "")
				if [ $_configOption -eq 0 ]; then
					printf "%b%s\e[0m\t%s\n" "$logoLine" "$padding" "$cfgLine"
				else
					printf "%b%s\e[0m\t%s\n" "$logoLine" "$padding" ""
				fi
				colorIndex=$(( (colorIndex + 1) % numColors ))
			else
				ApplyColors
				visibleLogo=$(printf "%b" "$logoLine" | strip_ansi)
				visibleLen=${#visibleLogo}
				padLen=$(( maxLenght - visibleLen ))
				[ $padLen -lt 0 ] && padLen=0
				padding=$(printf "%*s" "$padLen" "")
				if [ $_configOption -eq 0 ]; then
					printf "%b%s\e[0m\t%s\n" "$logoLine" "$padding" "$cfgLine"
				else
					printf "%b%s\e[0m\t%s\n" "$logoLine" "$padding" ""
				fi
			fi
		else
			if [ -n "$_flag" ] && [ -n "$_colors" ]; then
				currentColor=$(eval echo "\$$((colorIndex + 1))")
				ApplyColors
				printf "%b%s\e[0m\t%s\n" "$logoLine"
				colorIndex=$(( (colorIndex + 1) % numColors ))
			else
				ApplyColors
				printf "%b%s\e[0m\t%s\n" "$logoLine"
			fi
		fi
	done < "$logoFile"

	if [ $_configOption -eq 0 ]; then
		while IFS= read -r cfgLine <&3; do
			printf "%-${maxLenght}s\t%s\n" "" "$cfgLine"
		done
	fi

	exec 3<&-
	rm "$tmpCfg"
}

# Get system information
CommandExists()
{
	command -v "$1" > /dev/null 2>&1
}

GetUser()
{
	local who=$(whoami)

	printf "$who"
}

GetHostname()
{
	local hostname=$(CommandExists hostname && hostname || echo "Unknown")

	printf "$hostname"
}

GetLengthUserHost()
{
	local length=$(GetUser)
	length="$length@$(GetHostname)"
	length="${#length}"
	for i in $(seq 1 "$length"); do
		echo -n "-"
	done
}

GetDistro()
{
	local distro=$(CommandExists lsb_release && lsb_release -d | awk -F"\t" '{print $2}' || echo "Unavailable")
	printf "$distro"
}

GetHost()
{
	local host=$(CommandExists hostnamectl && hostnamectl | grep "Hardware Model" | cut -d ':' -f2 | sed 's/^[ \t]*//' || echo "Unavailable")
	printf "$host"
}

GetKernel()
{
	local kernel=$(uname -r)
	printf "$kernel"
}

GetUptime()
{
	local uptime=$(uptime -p | sed 's/^up //')
	printf "$uptime"
}

GetPackages()
{
	local packages=""
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
	local parentShell=$(ps -o comm= -p $(ps -o ppid= -p $$))
	local shell=""

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
	local res=$(xrandr --current | grep '*' | awk '{gsub(/\+/,"",$2); r=int($2+0.5); print $1 " @ " r "Hz"}' | sort -t'@' -k2,2 -n -r | awk '{printf "%s%s", (NR==1 ? "" : ", "), $0}')
	
	printf "%s\n" "$res"
}

GetDE()
{
	local DE=""
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
	local parent_pid=$(ps -o ppid= -p $$)
	local grandparent_pid=$(ps -o ppid= -p $parent_pid)
	local grandparent_command=$(ps -p $grandparent_pid -o comm=)

	local terminal="Unknow"
	local terminal="${grandparent_command%[: ]*}"
	if [ "$grandparent_command" = "gnome-terminal-" ]; then
		terminal="${grandparent_command%[-]*}"
	fi
	printf "$terminal"
}

GetTerminalSizeX()
{
	local termsize=$(stty size | cut -d' ' -f2-)

	echo $termsize
}

GetCpu()
{
	local cpu=""
	local cpuModel="Unknow"
	local cpuCores="$(grep ^cpu\\scores /proc/cpuinfo | uniq |  awk '{print $4}')"
	local cpuSpeed=$(grep "cpu MHz" /proc/cpuinfo | head -n 1 | awk '{print $4}')

	if command -v lscpu >/dev/null 2>&1; then
		cpuModel=$(lscpu | grep "Model name" | sed -E 's/Model name:\s+//')
	else
		cpuModel=$(grep -m 1 "model name" /proc/cpuinfo | sed -E 's/.*: //')
	fi

	local cpu=$(echo "$cpuModel" | sed -E 's/\(R\)//g; s/\(TM\)//g; s/ CPU//g; s/ [0-9]+-Core Processor//g; s/ +/ /g; s/ @.*//')
	cpu="$cpu ($cpuCores)"
	cpu="$cpu @ $(echo "$cpuSpeed" | awk '{printf "%.1f", $1/1000}') Ghz"

	printf "$cpu"
}

GetGPU()
{
	local gpu_info=$(lspci | grep -i vga)
	local gpu=""

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
	local memory_info=$(free -m | grep Mem)
	local total_memory=$(echo $memory_info | awk '{print $2}')

	printf "$total_memory Mib"
}

GetUsedMemory()
{
	local memory_info=$(free -m | grep Mem)
	local used_memory=$(echo $memory_info | awk '{print $3}')

	printf "$used_memory Mib"
}

GetIpAddress()
{
	local ipAddress=$(CommandExists hostname && (hostname -i || hostname -I) | awk '{print $1}' || echo "Unavailable")
	
	printf "$ipAddress"
}

GetPublicIp()
{
	local publicIp=$(CommandExists curl && curl -s ifconfig.me || echo "Unavailable")

	printf "$publicIp"
}

GetLastBoot()
{
	local lastBoot=$(CommandExists who && who -b | awk '{print $3, $4}' || echo "Unavailable")

	printf "$lastBoot"
}

GetProcessCount()
{
	local processCount=$(ps aux | wc -l)

	printf "$processCount"
}

GetRootPartition()
{
	local rootPartition=$(df -h --output=target,used,avail,pcent | grep '/ ' | awk '{print $2 " " $3 " " $4}')

	echo "$rootPartition"
}

GetHomePartition()
{
	local homePartition=$(df -h --output=target,used,avail,pcent | grep '/home' | awk '{print $2 " " $3 " " $4}')

	echo "$homePartition"
}

GetCpuUsage()
{
	local cpuUsage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8 "%"}')

	printf "$cpuUsage"
}

_logo="$_SCRIPT_DIR/logo/"$(getLogoFile $_logo)

[ -e "$_logo" ] || _logo="$_SCRIPT_DIR/logo/42.txt"

if [ "$((_minOption))" -eq 1 ]; then
	_logoFinal="${_logo%.txt}-min.txt"
fi

[ -e "$_logoFinal" ] || _logoFinal="$_logo"

# Render
PrintLogoWithCfg "$_logoFinal"
