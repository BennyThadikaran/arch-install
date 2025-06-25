#!/bin/bash

# Define options
options=" Lock Screen\n Shutdown\n󰜉 Restart\n󰍃 Logout"

# Use rofi to display the menu
selected=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu")

# Perform the selected action
case "$selected" in
" Lock Screen")
  i3lock -c 002147
  ;;
" Shutdown")
  systemctl poweroff
  ;;
"󰜉 Restart")
  systemctl reboot
  ;;
"󰍃 Logout")
  qtile cmd-obj -o cmd -f shutdown
  ;;
*)
  # User cancelled or closed the menu
  exit 1
  ;;
esac
