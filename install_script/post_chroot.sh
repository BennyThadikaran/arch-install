#! /bin/bash

set -e

# 6. Set the correct time zone
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

# 7. Uncomment the en_US.UTF-8 locale
sed -i '/^#en_US.UTF-8/s/^#//' /etc/locale.gen

# 8. Generate the locales
locale-gen

# 9. Set hardware clock
hwclock --systohc

# 10. Set the system language
echo 'LANG=en_US.UTF-8' >/etc/locale.conf

# 11. Set the keyboard layout
echo 'KEYMAP=us' >/etc/vconsole.conf

# 12. Set the hostname
echo 'benny-Lenovo-ideapad-330-15ARR' >/etc/hostname

# 13. Set the root password
echo "Please enter root password for the system"
passwd

# 15. Install and configure GRUB bootloader
echo "Installing GRUB bootloader"
grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=GRUB

# 16. Generate GRUB config
echo "Generating GRUB config"
grub-mkconfig -o /boot/grub/grub.cfg

echo "System setup is complete. Exit chroot and run 'umount -R /mnt' to unmount, before rebooting."
