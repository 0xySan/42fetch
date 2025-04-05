_HOME_DIR=$(eval echo "~")

rm -rf "$_HOME_DIR/bin/42fetch"
rm -rf "$_HOME_DIR/.config/42fetch"

if [ "$1" = "1" ] && (grep -q "42fetch" ~/.zshrc 2>/dev/null || grep -q "42fetch" ~/.bashrc 2>/dev/null); then
	printf "Do you want to remove '42fetch' from your .zshrc or .bashrc? [y/N]: "

	read input
	if [ "$input" = "y" ]; then
		if [ -e "$_HOME_DIR/.zshrc" ]; then
			sed -i '/^42fetch/d' ~/.zshrc
			echo "42fetch removed of .zshrc"
		elif [ -e "$_HOME_DIR/.bashrc" ]; then
			sed -i '/^42fetch/d' ~/.bashrc
			echo "42fetch removed of .bashrc"
		fi
	fi
	exit 0
else
	sed -i '/^42fetch/d' ~/.bashrc
	sed -i '/^42fetch/d' ~/.zshrc
fi

echo "42fetch uninstalled successfully!"