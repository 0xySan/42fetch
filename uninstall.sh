_HOME_DIR=$(eval echo "~")

rm -rf "$_HOME_DIR/bin/42fetch"
rm -rf "$_HOME_DIR/.config/42fetch"

sed -i '/^42fetch/d' ~/.zshrc
sed -i '/^42fetch/d' ~/.bashrc

echo "42fetch uninstalled successfully!"