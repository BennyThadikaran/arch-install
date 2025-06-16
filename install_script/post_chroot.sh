#! /bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

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

# Set the device variable to the provided argument
USER="$1"

echo "Creating user ${USER}"
useradd -m -G wheel -s /bin/bash $USER

echo "Enter user password"
passwd $USER

echo "setting up doas"
cat <<EOF >/etc/doas.conf
permit persist :wheel

permit nopass $USER cmd /usr/bin/systemctl args poweroff
permit nopass $USER cmd /usr/bin/systemctl args reboot
EOF

chown -c root:root /etc/doas.conf
chmod -c 0400 /etc/doas.conf

echo "Adding qtile start to .xinitrc"
echo 'exec qtile start' >.xinitrc

# setup ZRAM
echo "setting up ZRAM"
cat <<EOF >/etc/systemd/zram-generator.conf
[zram0]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd
EOF

cat <<EOF >/etc/sysctl.d/99-vm-zram-parameters.conf
vm.swappiness=180
vm.watermark_boost_factor=0
vm.watermark_scale_factor=125
vm.page-cluster=0
EOF

sysctl --system

# SETUP AUDIO
echo "Setting up audio"
systemctl --user enable pipewire pipewire-pulse wireplumber
sudo usermod -aG audio $USER

echo "Enabling bluetooth, ly, networkmanager, and cron"
systemctl enable bluetooth.service
systemctl enable ly.service
systemctl enable NetworkManager.service
systemctl enable fcron

echo "System setup is complete. Exit chroot and run 'umount -R /mnt' to unmount, before rebooting."
