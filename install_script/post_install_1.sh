#!/bin/bash
set -e

# Effective User ID of the current user.
# Root has an EUID of 0
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

PACKAGES=(
  opendoas  # doas alternative to sudo
  qtile     # Window manager
  ly        # terminal desktop manager
  i3lock    # Screen locker
  alacritty # terminal
  nitrogen  # wallpaper
  # Qtile bar dependencies
  wireless-tools
  when
  brightnessctl
  pacman-contrib
  python-wheel
  python-psutil
  python-iwlib
  zram-generator # ZRAM swap
  # Audio tools
  pipewire
  pipewire-alsa
  pipewire-pulse
  pipewire-jack
  wireplumber
  pavucontrol
  alsa-utils
  # Bluetooth
  bluez
  bluez-utils
  blueman
  # notification
  dunst
  libnotify
  # pdf viewer
  zathura
  zathura-pdf-mupdf
  # x-server & utils
  xorg-server
  xorg-xinit
  xorg-xrandr
  # other essentials
  networkmanager
  firefox
  git
  man-db
  man-pages
  pcmanfm
  python-pip
  ufw
  xarchiver
  xclip
  neofetch
  ttf-ibm-plex
  fcron
)

if ! pacman -S --noconfirm --needed "${PACKAGES[@]}" 2>>/var/log/installation_errors.log; then
  echo "Error: Installation failed. Check the log for details."
  exit 1
else
  echo "All packages installed successfully."
fi
