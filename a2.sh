#!/bin/sh

# Arch Installer
# Part 2: Install before reboot
# Does: locale, hostname, grub, programs, services, user, sudo file, dl 'a3.sh' 

clear
pacman -Suy --noconfirm sed

# Set paralell downloads
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

read -p $'\nChoose hostname: ' hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts

echo $'\nSet up root password'
passwd

read -p $'\nIs this a BIOS (not UEFI) setup? [y/N] ' bios_ans
if [[ $bios_ans = y ]] ; then
  # Install grub [BIOS]
  pacman -Suy --noconfirm grub
  echo ''
  lsblk
  read -p $'\nEnter the partitioned disk (not partition): ' grub_disk
  grub-install --target=i386-pc $grub_disk
else
  # Install grub [UEFI]
  pacman -Suy --noconfirm grub efibootmgr
  echo ''
  lsblk
  read -p $'\nEnter EFI partition: ' efi_part
  mkdir /boot/EFI
  mount $efi_part /boot/EFI 
  grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
fi
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub

read -p $'\nInstall AMD or Intel microcode packages? [a/i/N] ' ucode_ans
if [[ $ucode_ans = a ]] ; then
  pacman -Suy --noconfirm amd-ucode
elif [[ $ucode_ans = i ]] ; then
  pacman -Suy --noconfirm intel-ucode
fi
grub-mkconfig -o /boot/grub/grub.cfg

read -p $'\nInstall virtualbox-guest-utils? [y/N] ' vm_ans
if [[ $vm_ans = y ]] ; then
  pacman -Suy --noconfirm virtualbox-guest-utils
fi

# Install programs
pacman -Suy --noconfirm networkmanager neovim man-db wget git doas htop openssh exa `# basics` \
        zsh dash `# shells` \
        neovim `# editor` \
        xorg picom `# window system` \
        xmonad xmobar `# window manager ` \
        rofi `# launcher` \
        feh `# wallpaper` \
        kitty `# term` \
        zip unzip unrar p7zip gzip bzip2 `# archivers` \
        lightdm lightdm-gtk-greeter `# desktop manager` \
        neofetch figlet lolcat zathura tldr `# extras` \
        ghc python python-pip gcc `# languages` \
        imagemagick `# dep of icat kitten in kitty` \
        go `# dep of vim-hexokinase` \

# Install dash (breaks haskell-lens registration script, dep of haskell-dbus, dep of xmobar-git)
#rm /bin/sh
#ln -s dash /bin/sh

# Enable services for network and VM
systemctl enable NetworkManager.service
systemctl enable lightdm
if [[ $vm_ans = y ]] ; then
  systemctl enable vboxservice.service
fi

# Set VM resolution
if [[ $vm_ans = y ]] ; then
  sed -i "s/^#display-setup-script=$/display-setup-script=xrandr --output Virtual-1 --mode 1920x1080/" /etc/lightdm/lightdm.conf
  sed -i "s/^vsync = true;$/vsync = false;/" /etc/xdg/picom.conf
fi

# Create new user
read -p $'\nSet up new user\nEnter username: ' username
useradd -m -G wheel,audio,video,optical,storage -s /bin/zsh $username
passwd $username

# Give doas and sudo privileges
echo "permit $username as root" > /etc/doas.conf
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# avoid first start prompt
cd /home/$username
touch .zshrc
if [[ $vm_ans = y ]] ; then
   echo 'VBoxClient-all' > .zshrc
fi
chown $username:$username .zshrc

# Download the 'a3' and allow $username to execute it
wget https://raw.githubusercontent.com/nils-trubkin/tia/main/a3.sh
chown $username:$username a3.sh
chmod +x a3.sh

# Download barebones xmonad config for kitty
mkdir .xmonad
chown $username:$username .xmonad
wget https://raw.githubusercontent.com/nils-trubkin/tia/main/xmonad.hs -P .xmonad
chown $username:$username .xmonad/xmonad.hs

exit
