#!/bin/sh

# Arch Installer
# Part 1: Before chroot
# Does: partition [UEFI], pacstrap, chroot with 'a2.sh' 

# To start:
# curl -L nils.tk/tia > a.sh
# chmod +x a.sh
# ./a.sh

# set font and colors
setfont ter-118n
printf %b '\e]P011161c' '\e]P7fafafa'
clear

# make a statement
echo -n $'this is art'
sleep 5
clear

sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf

timedatectl set-ntp true

# select drive
lsblk
echo -n $'\nEnter the drive (/dev/sda): '
read drv
drv=${drv:-/dev/sda} # set default value if empty
cfdisk $drv
clear

lsblk
echo -n $'\nEnter the linux partition: '
read lnx_part
mkfs.ext4 $lnx_part 

read -p $'\nDid you also create EFI partition? [y/N] ' efi_ans
if [[ $efi_ans = y ]] ; then
  read -p $'Enter EFI partition: ' efi_part
  mkfs.vfat -F 32 $efi_part
fi

read -p $'\nDid you also create swap partition? [y/N] ' swap_ans
if [[ $swap_ans = y ]] ; then
  echo -n $'\nEnter swap partition: '
  read swap_part
  mkswap $swap_part
  swapon $swap_part
fi

mount $lnx_part /mnt 
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

# this fixes an error about 'fstab changed but systemd uses old version' later on
systemctl daemon-reload

curl https://raw.githubusercontent.com/nils-trubkin/tia/main/a2.sh > /mnt/a2.sh
chmod +x /mnt/a2.sh

arch-chroot /mnt ./a2.sh

umount -l /mnt

# unmount iso [VM Optical]
umount -l /dev/sr0
eject -F /dev/sr0

reboot now
