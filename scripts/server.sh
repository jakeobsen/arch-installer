#!/bin/bash

apt update && apt upgrade -y && apt install -y git vim

curl https://install.unlab.dev/config/bashrc.server > ~/.bashrc

rm ~/.vimrc ~/.viminfo
rm -rf ~/.config/vim/
mkdir -p ~/.config/
wget -O ~/.config/vim.tgz https://install.unlab.dev/tarballz/vim.server.tgz
cd ~/.config/
tar xvzf vim.tgz
rm vim.tgz
cd

echo reboot
