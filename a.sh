#!/bin/sh

# Arch Installer
# curl https://raw.githubusercontent.com/nils-trubkin/rmd/master/a.sh > a.sh
# chmod +x a.sh
# ./a.sh

# set font and colors
setfont ter-114n
printf %b '\e]P011161c' '\e]P7fafafa'
clear
# make a statement
echo "this is art"
sleep 5

sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman -Suy --noconfirm archlinux-keyring
timedatectl set-ntp true
lsblk
echo "Enter the drive: "
read drv
cfdisk $drv
clear

echo "Enter the linux partition: "
read lnx_part
mkfs.ext4 $lnx_part 

echo "Enter EFI partition: "
read efi_part
mkfs.vfat -F 32 $efi_part

read -p "Did you also create swap partition? [y/N]" swap_ans
if [[ $swap_ans = y ]] ; then
  echo "Enter swap partition: "
  read swap_part
  mkswap $swap_part
  swapon $swap_part
fi

mount $lnx_part /mnt 
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

echo "Will download a2"
sleep 3

curl https://raw.githubusercontent.com/nils-trubkin/rmd/master/a2.sh > /mnt/a2.sh
chmod +x /mnt/a2.sh

echo "Will run a2"
sleep 3

arch-chroot /mnt ./a2.sh

echo "Returned from a2, will umount and shutdown"
sleep 3

#umount -l /mnt
#shutdown
