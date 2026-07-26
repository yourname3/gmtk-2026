BUTLER="$HOME/Downloads/butler-linux-amd64/butler"
GAMETITLE="clock-chess"
ITCHGAME="some-games-by-bee/clock-chess"

"$BUTLER" push ".builds/win"                "$ITCHGAME:win"     # --userversion-file versionno.txt
"$BUTLER" push ".builds/linux"              "$ITCHGAME:linux"   # --userversion-file versionno.txt
"$BUTLER" push ".builds/mac"                "$ITCHGAME:macos"   # --userversion-file versionno.txt
"$BUTLER" push ".builds/web"                "$ITCHGAME:web"     # --userversion-file versionno.txt
#"$BUTLER" push ".builds/android"            "$ITCHGAME:android" # --userversion-file versionno.txt
