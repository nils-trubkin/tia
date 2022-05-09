#!/bin/sh

# Install aura
git clone https://aur.archlinux.org/aura-bin.git
cd aura-bin
makepkg -s
doas pacman -U aura-bin-*



exit
