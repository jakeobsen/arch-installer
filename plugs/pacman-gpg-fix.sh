#!/bin/bash
killall gpg-agent
rm -rf /etc/pacman.d/gnupg/
pacman -Sy -noconfirm archlinux-keyring
killall gpg-agent
pacman-key --init
pacman-key --populate archlinux
# pacman-key --refresh-keys --keyserver pgp.mit.edu
