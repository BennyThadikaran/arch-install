#! /usr/bin/env bash

# List available Wi-Fi networks
available_networks=$(nmcli -t -f ssid device wifi list)

# Show available networks in rofi
selected_ssid=$(echo "$available_networks" | rofi -dmenu -p "Select Wi-Fi Network.")

# If a network is selected, connect to it
if [ -n "$selected_ssid" ]; then
  nmcli device wifi connect "$selected_ssid" --ask
fi
