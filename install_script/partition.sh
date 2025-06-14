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
# vda3  remaining EXT4 /home encrypted with luks

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
parted --script $DEVICE mklabel gpt

# Create EFI partition (512 MB)
parted --script $DEVICE mkpart primary fat32 1MiB 513MiB
parted --script $DEVICE set 1 boot on # Mark partition 1 as bootable (EFI)

# Create root partition (100 GB)
parted --script $DEVICE mkpart primary ext4 513MiB 100.5GiB

# Create home partition (remaining space)
parted --script $DEVICE mkpart primary ext4 100.5GiB 100%

# Print the partition table
parted $DEVICE print

# Format EFI partition
mkfs.fat -F32 "${DEVICE}1"

# Format root partition
mkfs.ext4 "${DEVICE}2"

# Encrypt the home partition
echo "Encrypting /home partition..."
cryptsetup luksFormat "${DEVICE}3"

echo "Disk encryption complete. Reenter passphrase to decrypt and mount home partition"
cryptsetup open "${DEVICE}3" crypt_home

# Format encrypted /home partition
mkfs.ext4 /dev/mapper/crypt_home

# Mount the partitions
echo "Mounting partitions..."
mount "${DEVICE}2" /mnt
mkdir /mnt/boot
mount "${DEVICE}1" /mnt/boot
mkdir /mnt/home
mount /dev/mapper/crypt_home /mnt/home

# Get the UUID using blkid
UUID=$(blkid -s UUID -o value "${DEVICE}3")

if [ -z "$UUID" ]; then
  echo "Error: UUID for $DEVICE not found!"
  exit 1
fi

CRYPTTAB_FILE="/etc/crypttab"

# Check if /etc/crypttab exists
if [ ! -f "$CRYPTTAB_FILE" ]; then
  echo "Error: $CRYPTTAB_FILE does not exist!"
  exit 1
fi

# Add the UUID to /etc/crypttab in the required format
echo "crypt-home UUID=$UUID none luks" >>"$CRYPTTAB_FILE"
echo "Successfully added UUID for ${DEVICE}3 to $CRYPTTAB_FILE"

echo "Partitions created and mounted successfully."
