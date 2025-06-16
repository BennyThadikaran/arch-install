#!/bin/bash
set -e

# WARNING: This will wipe out all data on disk.
#
# Configuration is hard-coded and assumes a 1TB harddisk
#
# Create a new partition table, passing the device name as an argument
#
# vda1  512MB EFI FAT32
# vda2  100GB EXT4 root
# vda3  /home remaining space

# Ensure the user provides a device name as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 /dev/sdX"
  exit 1
fi

# Set the device variable to the provided argument
DEVICE="$1"

# Check if the device exists
if [ ! -b "$DEVICE" ]; then
  echo "Error: Device $DEVICE not found!"
  exit 1
fi

echo "Partitioning $DEVICE..."

# Create GPT partition table
parted --align optimal --script $DEVICE mklabel gpt

# Create EFI partition (512 MB)
parted --script $DEVICE mkpart primary fat32 1MiB 513MiB
parted --script $DEVICE set 1 esp on

# Create root partition (100 GB)
parted --script $DEVICE mkpart primary ext4 513MiB 100.5GiB

# Create home partition (remaining space)
parted --script $DEVICE mkpart primary ext4 100.5GiB 100%

# Print the partition table
parted $DEVICE print

# Format partitions
mkfs.fat -F32 "${DEVICE}1"
mkfs.ext4 -F "${DEVICE}2"
mkfs.ext4 -O encrypt -F "${DEVICE}3"

# Mount the partitions
echo "Mounting partitions..."
mount "${DEVICE}2" /mnt
mkdir /mnt/{boot,home}
mount "${DEVICE}1" /mnt/boot
mount "${DEVICE}3" /mnt/home

echo "Partitions created and mounted successfully."

echo "Enabling system time synchronization"
timedatectl set-ntp true

echo "Updating mirrorlist"
reflector -c IN --age 12 --sort rate --protocol https --save /etc/pacman.d/mirrorlist
