#!/bin/s

clear
pacman -Suy --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts

passwd

pacman --noconfirm -S grub efibootmgr
echo "Enter EFI partition: " 
read efipartition
mkdir /boot/EFI
mount $efipartition /boot/EFI 
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm networkmanager neovim man-db wget git doas \
        ttf-dejavu zip unzip unrar p7zip gzip bzip2 feh virtualbox-guest-utils-nox

systemctl enable NetworkManager.service

echo "Enter Username: "
read username
useradd -m -G wheel,audio,video,optical,storage -s /bin/zsh $username
passwd $username
echo "permit $username as root" > /etc/doas.conf

exit
