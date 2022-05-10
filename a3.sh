#!/bin/sh

# Arch Installer
# Part 3: aura, zsh, brave, nas, ssh, dl dot 

# Install aura
git clone https://aur.archlinux.org/aura-bin.git
cd aura-bin
makepkg -s
doas pacman --noconfirm -U aura-bin-*

# Install zsh 10k
sudo aura -A --noconfirm zsh-theme-powerlevel10k-git zsh-vi-mode brave-beta-bin

read -p $'\nConnect NAS? [y/N] ' nas_ans
if [[ $nas_ans = y ]] ; then
  read -p $'\nActivate VM clipboard? [y/N] ' vm_ans
  if [[ $vm_ans = y ]] ; then
     VBoxClient --clipboard
  fi
  read -p 'hostname: ' nas_host
  read -p 'user: ' nas_usr
  read -sp 'password: ' nas_psd
  id
  read -p $'\nuid: ' nas_uid
  read -p 'volume on NAS: ' nas_vol
  read -p 'local mount point: ' nas_mnt
  
  # Create mount point and mount NAS
  mkdir -p $nas_mnt
  doas pacman -Suy --noconfirm cifs-utils
  doas mount -t cifs -o username=$nas_user,password=$nas_pass,uid=$nas_uid //$nas_host/$nas_vol $nas_mnt
  
  read -p $'\nDownload SSH keys? [y/N] ' ssh_ans
  if [[ $ssh_ans = y ]] ; then
    cp $nas_mnt/ssh/id_ed25519* ~/.ssh/
    read -p $'\nDownload dot? [y/N] ' dot_ans
    if [[ $dot_ans = y ]] ; then
      echo 'git clone dot && run a4.sh'
      #git clone git@github.com:nils-trubkin/dot.git
    fi
  fi
fi

exit
