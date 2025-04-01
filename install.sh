_HOME_DIR=$(eval echo "~")

[ -e "$_HOME_DIR/bin" ] || mkdir "$_HOME_DIR/bin"

if [ -e "$_HOME_DIR/.config" ]; then
    mkdir -p "$_HOME_DIR/.config/42fetch"
else
    mkdir "$_HOME_DIR/.config"
    mkdir "$_HOME_DIR/.config/42fetch"
fi

cp -r data "$_HOME_DIR/.config/42fetch"
cp -r logo "$_HOME_DIR/.config/42fetch"

cp 42fetch.sh "$_HOME_DIR/bin/42fetch"

chmod +x "$_HOME_DIR/bin/42fetch"

sed -i '8i _CONFIG_FOLDER="$_HOME_DIR/.config/42fetch"' $_HOME_DIR/bin/42fetch

echo "42fetch installed successfully!"