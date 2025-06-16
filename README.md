This is a collection of scripts for Arch Linux setup.

This is only for my personal use and currently being tested in a virtual machine.

Status: VM tested and works. Yet to test on live hardware

Example using curl to download the script inside arch install medium:

`curl -O https://raw.githubusercontent.com/BennyThadikaran/arch-install/refs/heads/main/install_script/partition.sh`

`chmod +x partition.sh`

## Order of Operations

1. Run `partition.sh /dev/sda`

2. Install packages

`pacstrap /mnt $(< base_packages.txt) $(< other_packages.txt)`

3. Generate file system table and chroot into /mnt

```
genfstab -U /mnt >>/mnt/etc/fstab
arch-chroot /mnt
```

5. Run `post_chroot.sh <username>`

6. Exit the chroot and unmount

```
exit
umount -R /mnt
reboot now
```

## Post Install and reboot

### Setup user folder encryption

1. Login as root and install fscrypt

2. Once reboot is complete, qtile should run with default configuration and terminal can be accessed with `SUPER + Enter`

3. Run the below commands to setup encryption of /home/username. (Ensure same password as user login)

```
fscrypt setup /
fscrypt setup /home
mkdir /home/<user>.bak
fscrypt encrypt /home/<user>.bak
cp -a -T /home/<user> /home/<user>.bak
rm -rf /home/<user>
mv /home/<user>.bak /home/<user>
```

4. Add the below lines to `/etc/pam.d/ly` and `/etc/pam.d/system-login` to allow decryption at login

```bash
auth optional pam_fscrypt.so
session optional pam_fscrypt.so
```

5. Reboot and login as `user`. Run `fscrypt status /home/user` to check status

## Final steps

1. Enable firewall

```
doas ufw enable
doas ufw logging off
```

2. Save Qtile and Rofi config from github repo into `~/.config` and make `autostart.sh` executable.
   - Edit xrandr settings in `autostart.sh` to set the correct screensize.
   - Run nitrogen to set the wallpaper.
   - Install [MesloLG Nerd font](https://www.nerdfonts.com/font-downloads) - Required for Qtile bar
   - Press `SUPER + SHIFT + r` to restart Qtile with new config
