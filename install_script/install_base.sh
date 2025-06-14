#!/bin/bash
# Arch Linux installation: pre-chroot phase
# This script sets up base system, mirrorlist, and fstab
set -e

if ! mountpoint -q /mnt; then
  echo "/mnt is not mounted. Please mount your partitions before running this script."
  exit 1
fi

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

# 4. Set up the mirrorlist using reflector
echo "Updating mirrorlist"
reflector -c IN --age 12 --sort rate --protocol https --save /etc/pacman.d/mirrorlist

echo "Installing base system and essential packages"
pacstrap /mnt "${PACKAGES[@]}" 2>&1 | tee -a pacstrap.log

echo "Base install complete. For output of pacstrap see pacstrap.log"
