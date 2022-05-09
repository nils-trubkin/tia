#!/bin/sh

# Install aura
git clone https://aur.archlinux.org/aura-bin.git
cd aura-bin
makepkg -s
doas pacman --noconfirm -U aura-bin-*

# Install zsh 10k
doas aura -A --noconfirm zsh-theme-powerlevel10k-git

read -p "Connect NAS? [y/N]" nas_ans
if [[ $nas_ans = y ]] ; then
  echo "hostname: "
  read nas_host
  echo "user: "
  read nas_usr
  echo "password: "
  read nas_psd
  id
  echo "uid: "
  read nas_uid
  echo "volume on NAS: "
  read nas_vol
  echo "local mount point: "
  read nas_mnt
  
  # Create mount point and mount NAS
  mkdir -p $nas_mnt
  doas pacman -Suy --noconfirm cifs-utils
  doas mount -t cifs -o username=$nas_user,password=$nas_pass,uid=$nas_uid //$hostname/$nas_vol $nas_mnt
  
  read -p "Download SSH keys? [y/N]" ssh_ans
    if [[ $ssh_ans = y ]] ; then
      cp $nas_mnt/ssh/id_ed25519* ~/.ssh/
      read -p "Download rmdp? [y/N]" rmdp_ans
      if [[ $rmdp_ans = y ]] ; then
        git clone git@github.com:nils-trubkin/rmdp.git
        chmod +x rmdp/a4.sh
    fi
fi

exit
