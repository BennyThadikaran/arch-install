#!/bin/bash
# Arch Linux installation: pre-chroot phase
# This script sets up base system, mirrorlist, and fstab
set -e

packages=(
  base
  base-devel
  dosfstools
  linux-lts
  linux-zen
  linux-lts-headers
  linux-zen-headers
  linux-firmware
  grub
  efibootmgr
  amd-ucode
)

if ! mountpoint -q /mnt; then
  echo "/mnt is not mounted. Please mount your partitions before running this script."
  exit 1
fi

# 1. Enable NTP for system time synchronization
echo "Enabling system time synchronization"
timedatectl set-ntp true

# 4. Set up the mirrorlist using reflector
echo "Updating mirrorlist"
reflector -c IN --age 12 --sort rate --protocol https --save /etc/pacman.d/mirrorlist

# 5. Install essential packages
echo "Installing base system and essential packages"
pacstrap /mnt "${PACKAGES[@]}"

# 2. Generate fstab with UUIDs
echo "Generating fstab"
genfstab -U /mnt >>/mnt/etc/fstab

echo "Pre-chroot setup completed."
