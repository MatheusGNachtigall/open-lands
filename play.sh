#!/bin/bash
# Runs the built player from WSL or Git Bash with the project's GameData (imported from LOL_GAME_DIR in .env
# the first time, see env.sh), passing extra arguments through
# (see Assets/Scripts/Autopilot.cs). Log: Logs/player.log.
#   bash play.sh --champion 0 --do "2:UpArrow,4:shot:Shots\\a.png" --quit-after 6
set -u
LOL_VIEW=${LOL_VIEW:-1600x1000}   # window size (tools/web_steps.py uses the same variable)
cd "$(dirname "$0")"
. ./env.sh
data="$(lol_game_data)" || exit 1
W="$(winpath "$PWD")"
timeout "${PLAY_TIMEOUT:-120}" ./Build/Windows/OpenLands.exe -screen-width "${LOL_VIEW%x*}" -screen-height "${LOL_VIEW#*x}" -screen-fullscreen 0 \
  --data "$(winpath "$data")" -logFile "$W\\Logs\\player.log" "$@" > /dev/null
grep -E "autopilot|Exception|Error|error" Logs/player.log | grep -v "memorysetup" | head -40
