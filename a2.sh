#!/bin/sh

clear
pacman -Suy --noconfirm sed

# Set paralell downloads
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "\nChoose hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts

echo "\nSet up root password"
passwd

# Install grub
pacman --noconfirm -S grub efibootmgr
echo "Enter EFI partition: " 
read efipartition
mkdir /boot/EFI
mount $efipartition /boot/EFI 
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Install programs
pacman -Suy --noconfirm networkmanager neovim man-db wget git doas \ # basics
        zsh dash \ # shells
        neovim \ # editor
        xorg picom \ # wm
        xmonad xmonad-contrib xmobar \ # wm
        kitty ttf-fira-code \ # term
        zip unzip unrar p7zip gzip bzip2 \ # archivers
        virtualbox-guest-utils \ # vm
        feh lightdm lightdm-gtk-greeter rofi figlet \ # extras

# Install dash
rm /bin/sh
ln -s dash /bin/sh

# Enable services for network and VM
systemctl enable NetworkManager.service
systemctl enable vboxservice.service

# Create new user
echo "Enter username: "
read username
useradd -m -G wheel,audio,video,optical,storage -s /bin/zsh $username
passwd $username

# Give doas and sudo privileges
echo "permit $username as root" > /etc/doas.conf
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

exit
