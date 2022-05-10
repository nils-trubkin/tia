#!/bin/sh

# Arch Installer
# Part 1: partition [UEFI], pacstrap, dl & run 'a2.sh' 

# To start:
# curl https://raw.githubusercontent.com/nils-trubkin/rmd/master/a.sh > a.sh
# chmod +x a.sh
# ./a.sh

# set font and colors
setfont ter-118n
printf %b '\e]P011161c' '\e]P7fafafa'
clear

# make a statement
echo -e "this is art"
sleep 5
clear

sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf

timedatectl set-ntp true

# select drive
lsblk
echo -e "\nEnter the drive: "
read drv
cfdisk $drv

echo -e "\nEnter the linux partition: "
read lnx_part
mkfs.ext4 $lnx_part 

echo -e "\nEnter EFI partition: "
read efi_part
mkfs.vfat -F 32 $efi_part

read -p "\nDid you also create swap partition? [y/N]" swap_ans
if [[ $swap_ans = y ]] ; then
  echo "\nEnter swap partition: "
  read swap_part
  mkswap $swap_part
  swapon $swap_part
fi

mount $lnx_part /mnt 
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

# this fixes an error about 'fstab changed but systemd uses old version' later on
systemctl daemon-reload

curl https://raw.githubusercontent.com/nils-trubkin/rmd/master/a2.sh > /mnt/a2.sh
chmod +x /mnt/a2.sh

arch-chroot /mnt ./a2.sh

umount -l /mnt

# unmount iso [VM Optical]
umount -l /dev/sr0
eject -F /dev/sr0

reboot now
