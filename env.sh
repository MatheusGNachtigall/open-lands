#!/bin/bash
# Sourced by the build and play scripts: the local settings in .env (see .env.example) and the paths they need,
# under WSL or Git Bash on Windows.
#   UNITY         the Unity editor (default: the project's version in the Hub's or the installer's folder)
#   LOL_GAME_DIR  the GOG Lands of Lore folder (GAME.DAT); lol_game_data imports it into GameData once
LOL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$LOL_ROOT/.env" ]; then set -a; . <(tr -d '\r' < "$LOL_ROOT/.env"); set +a; fi
export PATH="$HOME/.dotnet:$PATH"

# a path for Windows programs (C:\...) and one for this shell (/mnt/c/... or /c/...)
winpath() { if command -v wslpath > /dev/null; then wslpath -w "$1"; elif command -v cygpath > /dev/null; then cygpath -w "$1"; else echo "$1"; fi; }
unixpath() { if command -v wslpath > /dev/null; then wslpath -u "$1"; elif command -v cygpath > /dev/null; then cygpath -u "$1"; else echo "$1"; fi; }

if [ -n "${UNITY:-}" ]; then
  UNITY="$(unixpath "$UNITY")"
else
  v=$(sed -n 's/^m_EditorVersion: //p' "$LOL_ROOT/ProjectSettings/ProjectVersion.txt" | tr -d '\r')
  for c in "C:\\Program Files\\Unity\\Hub\\Editor\\$v\\Editor\\Unity.exe" "C:\\Program Files\\Unity $v\\Editor\\Unity.exe"; do
    UNITY="$(unixpath "$c")"; [ -f "$UNITY" ] && break
  done
fi

# The folder with the game's PAK files, GameData/DATA: imported from LOL_GAME_DIR when it is not there yet.
lol_game_data() {
  local data="$LOL_ROOT/GameData/DATA"
  if [ ! -f "$data/GENERAL.PAK" ]; then
    [ -n "${LOL_GAME_DIR:-}" ] || { echo "no game data in GameData/DATA: set LOL_GAME_DIR in .env" >&2; return 1; }
    local gog; gog="$(unixpath "$LOL_GAME_DIR")"
    [ -f "$gog/GAME.DAT" ] || { echo "no GAME.DAT in LOL_GAME_DIR ($LOL_GAME_DIR)" >&2; return 1; }
    echo "importing the game from $LOL_GAME_DIR into GameData" >&2
    dotnet run --project "$LOL_ROOT/tools/ImportGame" -c Release -- "$gog" "$LOL_ROOT/GameData" > /dev/null || return 1
    [ -f "$data/GENERAL.PAK" ] || { echo "the import left no GENERAL.PAK in GameData/DATA" >&2; return 1; }
  fi
  echo "$data"
}
