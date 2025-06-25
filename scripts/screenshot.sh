#!/bin/bash

# Timestamped filename
FILENAME="$HOME/Pictures/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

# Show options
OPTION=$(echo -e "󰊓 Fullscreen\n Active Window\n󰩫 Selection" | rofi -dmenu -p "Take Screenshot")

case "$OPTION" in
"󰊓 Fullscreen")
  scrot "$FILENAME"
  notify-send "Screenshot" "Fullscreen saved to $FILENAME"
  ;;
" Active Window")
  scrot -u "$FILENAME"
  notify-send "Screenshot" "Active window saved to $FILENAME"
  ;;
"󰩫 Selection")
  scrot -s "$FILENAME"
  notify-send "Screenshot" "Selection saved to $FILENAME"
  ;;
*)
  notify-send "Screenshot" "Cancelled or Invalid option"
  echo "$(date): Invalid or cancelled option." >>"$LOG"
  ;;
esac
