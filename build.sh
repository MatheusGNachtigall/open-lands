#!/bin/bash
# Builds the engine DLL, then the Windows player, from WSL or Git Bash (the editor: UNITY in .env, see env.sh). The Unity editor must not have this
# project open (batch mode refuses a locked project).
#   bash build.sh            -> Build/Windows/OpenLands.exe
set -eu
cd "$(dirname "$0")"
. ./env.sh
bash build-engine.sh
# the page's own pictures (camp scene, errand / potion icons), served from StreamingAssets like the web root
# (they are in the repository too; the copy only refreshes them when the web project is here)
L="${LANDS:-$HOME/lands}"; [ -d "$L/src/assets" ] && mkdir -p Assets/StreamingAssets/web/src && cp -ru "$L"/src/assets Assets/StreamingAssets/web/src/
[ -f "$UNITY" ] || { echo "no Unity editor at $UNITY: set UNITY in .env"; exit 1; }
proj="$(winpath "$PWD")"
set +e
"$UNITY" -batchmode -nographics -quit -projectPath "$proj" -executeMethod Build.Windows -logFile "$proj\\Logs\\build.log"
code=$?
set -e
grep -E "error CS|BUILD RESULT|Exception|Shader error|Licensing::Module] Error: '.*' was not found" Logs/build.log | sort -u | head -40
# a shader that fails to compile does not fail the player build: fail the script on it
if grep -q "Shader error" Logs/build.log; then echo "SHADER ERRORS (see Logs/build.log)"; exit 1; fi
exit $code
