_HOME_DIR=$(eval echo "~")

if [ -z "$_HOME_DIR" ]; then
	echo "Error: HOME_DIR is not set."
	exit 1
fi

if [ -f "$_HOME_DIR/bin/42fetch" ]; then
	echo "42fetch is already installed. Update it or uninstall it first."
	exit 0
fi

[ -e "$_HOME_DIR/bin" ] || mkdir "$_HOME_DIR/bin"

if [ -e "$_HOME_DIR/.config" ]; then
	mkdir -p "$_HOME_DIR/.config/42fetch"
else
	mkdir "$_HOME_DIR/.config"
	mkdir "$_HOME_DIR/.config/42fetch"
fi

if [ -n "$CURL" ] && [ "$CURL" = "true" ] || [ -z $(pwd | grep 42fetch) ]; then
	git clone https://github.com/0xySan/42fetch.git tmp
	cp -r tmp/data "$_HOME_DIR/.config/42fetch"
	cp -r tmp/logo "$_HOME_DIR/.config/42fetch"
	cp tmp/42fetch.sh "$_HOME_DIR/bin/42fetch"
	rm -rf tmp
else
	cp -r data "$_HOME_DIR/.config/42fetch"
	cp -r logo "$_HOME_DIR/.config/42fetch"
	cp 42fetch.sh "$_HOME_DIR/bin/42fetch"
fi

chmod +x "$_HOME_DIR/bin/42fetch"

sed -i '8i _CONFIG_FOLDER="$_HOME_DIR/.config/42fetch"' $_HOME_DIR/bin/42fetch

if [ -n "$CURL" ] && [ "$CURL" = "true" ]; then
	printf "Using curl to download 42fetch, cannot read input from terminal.\n If you want to use 42fetch everytime you launch a term, please add it to your .zshrc or .bashrc manually."
else
	echo "Would you like to run 42fetch everytime you launch a term? (y/N) default: yes"
fi

read input

if [ "$input" = "y" ] || [ "$input" = "" ] && [ ! -n "$CURL" ] ; then
	if [ -e "$_HOME_DIR/.zshrc" ]; then
		echo "42fetch" >> "$_HOME_DIR/.zshrc"
		echo "42fetch added to .zshrc"
	elif [ -e "$_HOME_DIR/.bashrc" ]; then
		echo "42fetch" >> "$_HOME_DIR/.bashrc"
		echo "42fetch added to .bashrc"
	fi
fi

echo "42fetch installed successfully!"