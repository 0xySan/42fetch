#!/bin/bash

# Default values
_HOME_DIR=$(eval echo "~")
_BIN_DIR=""

_USE_SUDO=false

# Parse arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
		--bin-dir)
			shift
			_BIN_DIR="$1"
			;;
		--curl)
			CURL=true
			;;
		--sudo)
			_USE_SUDO=true
			;;
	esac
	shift
done

if [ -z "$_HOME_DIR" ]; then
	echo "Error: HOME_DIR is not set."
	exit 1
fi

if [ -z "$_BIN_DIR" ]; then
	_BIN_DIR="$_HOME_DIR/bin"
fi

if [ -f "$_BIN_DIR/42fetch" ]; then
	echo "42fetch is already installed in $_BIN_DIR. Update it or uninstall it first."
	exit 0
fi

[ -e "$_BIN_DIR" ] || mkdir -p "$_BIN_DIR"

if [ -e "$_HOME_DIR/.config" ]; then
	mkdir -p "$_HOME_DIR/.config/42fetch"
else
	mkdir "$_HOME_DIR/.config"
	mkdir "$_HOME_DIR/.config/42fetch"
fi

if [ -n "$CURL" ] && [ "$CURL" = "true" ] || [ -z "$(pwd | grep 42fetch)" ]; then
	git clone https://github.com/0xySan/42fetch.git tmp
	cp -r tmp/data "$_HOME_DIR/.config/42fetch"
	cp -r tmp/logo "$_HOME_DIR/.config/42fetch"
	if [ "$_USE_SUDO" = "true" ]; then
		sudo cp tmp/42fetch.sh "$_BIN_DIR/42fetch"
	else
		cp tmp/42fetch.sh "$_BIN_DIR/42fetch"
	fi
	rm -rf tmp
else
	cp -r data "$_HOME_DIR/.config/42fetch"
	cp -r logo "$_HOME_DIR/.config/42fetch"
	if [ "$_USE_SUDO" = "true" ]; then
		sudo cp 42fetch.sh "$_BIN_DIR/42fetch"
	else
		cp 42fetch.sh "$_BIN_DIR/42fetch"
	fi
fi

if [ "$_USE_SUDO" = "true" ]; then
	sudo chmod +x "$_BIN_DIR/42fetch"
else
	chmod +x "$_BIN_DIR/42fetch"
fi
if [ "$_USE_SUDO" = "true" ]; then
	sudo sed -i '8i _CONFIG_FOLDER="'"$_HOME_DIR"'/.config/42fetch"' "$_BIN_DIR/42fetch"
else
	sed -i '8i _CONFIG_FOLDER="'"$_HOME_DIR"'/.config/42fetch"' "$_BIN_DIR/42fetch"
fi

if [ "$1" = "1" ]; then
	exit 0
fi

if [ -n "$CURL" ] && [ "$CURL" = "true" ]; then
	printf "Using curl to download 42fetch, cannot read input from terminal.\nIf you want to use 42fetch everytime you launch a term, please add it to your .zshrc or .bashrc manually.\n"
else
	printf "Would you like to run 42fetch everytime you launch a term? [Y/n]: "
	read input
fi

if [ "$input" = "y" ] || [ "$input" = "" ] && [ ! -n "$CURL" ]; then
	if [ -e "$_HOME_DIR/.zshrc" ]; then
		echo "42fetch" >> "$_HOME_DIR/.zshrc"
		echo "42fetch added to .zshrc"
	elif [ -e "$_HOME_DIR/.bashrc" ]; then
		echo "42fetch" >> "$_HOME_DIR/.bashrc"
		echo "42fetch added to .bashrc"
	fi
fi

printf "42fetch installed successfully in $_BIN_DIR!\n"