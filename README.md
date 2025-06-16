This is a collection of scripts for Arch Linux setup.

This is only for my personal use and currently being tested in a virtual machine.

Not meant to be run on a live disk yet.

Order of Operations

1. Run `partition.sh`

2. Install packages

`pacstrap /mnt $(< base_packages.txt) $(< other_packages.txt)`

3. Generate file system table

`genfstab -U /mnt >>/mnt/etc/fstab`

4. chroot into /mnt

`arch-chroot /mnt`

5. Run `post_chroot.sh`

6. Run `post_install.sh`
