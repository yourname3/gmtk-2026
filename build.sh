GODOT="$HOME/Downloads/Godot_v4.6-stable_linux.x86_64"

rm -rf .builds/win
rm -rf .builds/mac
rm -rf .builds/linux
rm -rf .builds/web
rm -rf .builds/android

mkdir -p .builds
mkdir -p .builds/win
mkdir -p .builds/mac
mkdir -p .builds/linux
mkdir -p .builds/web
mkdir -p .builds/android

"$GODOT" --headless --export-release "Windows Desktop" .builds/win/clock-chess.exe
"$GODOT" --headless --export-release "Linux"           .builds/linux/mclock-chess.x86_64
"$GODOT" --headless --export-release "macOS"           .builds/mac/clock-chess.zip
"$GODOT" --headless --export-release "Web"             .builds/web/index.html
# "$GODOT" --headless --export-release "Android"         .builds/android/clock-chess.apk

rm -f .builds/android/clock-chess.apk.idsig
