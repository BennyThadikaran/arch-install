#!/bin/bash

set -e

# Ensure the user provides a user name
if [ -z "$1" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

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
