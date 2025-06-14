#!/bin/bash

set -e

# Ensure this script is run as root (within chroot environment)
# id -u returns the uid of user which is 0 for root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root or inside a chroot environment"
  exit 1
fi

# 1. Enable NTP for system time synchronization
timedatectl set-ntp true

# 5. Install essential packages
pacstrap /mnt base base-devel dosfstools linux-lts linux-zen linux-lts-headers linux-zen-headers linux-firmware grub efibootmgr amd-ucode xorg-server xorg-xinit xorg-xrandr networkmanager firefox alacritty dunst libnotify git man-db man-pages neovim python-neovim numlockx opendoas pcmanfm python-pip ufw xarchiver xclip zathura zathura-pdf-mupdf nitrogen neofetch ttf-ibm-plex fcron

# 2. Generate fstab with UUIDs
genfstab -U /mnt >>/mnt/etc/fstab
