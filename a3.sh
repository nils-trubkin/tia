#!/bin/bash

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
  read -p 'hostname: ' nas_host
  read -p 'user: ' nas_usr
  read -sp 'password: ' nas_psd
  echo ''
  id
  read -p 'uid: ' nas_uid
  read -p 'volume on NAS (do not use quotes): ' nas_vol
  read -p 'local mount point (absolute path): ' nas_mnt
  
  # Create mount point and mount NAS
  mkdir -p $nas_mnt
  doas pacman -Suy --noconfirm cifs-utils
  doas mount -t cifs -o username="$nas_usr",password="$nas_psd",uid="$nas_uid" //"$nas_host"/"$nas_vol" "$nas_mnt"
  
  read -p $'\nDownload SSH keys? [y/N] ' ssh_ans
  if [[ $ssh_ans = y ]] ; then
    mkdir ~/.ssh
    cp $nas_mnt/ssh/id_ed25519* ~/.ssh/
    chmod 600 ~/.ssh/*
    chmod 644 ~/.ssh/*.pub
    read -p $'\nDownload dot? [y/N] ' dot_ans
    if [[ $dot_ans = y ]] ; then
      git clone --separate-git-dir=$HOME/dot git@github.com:nils-trubkin/dot.git $HOME/dot-tmp
      chmod +x ~/dot-tmp/a4.sh
      ~/dot-tmp/a4.sh
      #cp ~/myconf-tmp/.gitmodules ~  # If you use Git submodules
      rm -r ~/dot-tmp/
      git --git-dir=$HOME/dot/ --work-tree=$HOME restore .
      read -p $'\nReboot? [y/N] ' rb_ans
      if [[ $rb_ans = y ]] ; then
        systemctl reboot
      fi  
    fi
  fi
fi

exit
