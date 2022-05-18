source /tmp/env; [ "$envSourced" != "YES" ] && exit 255

# i3 packages
arch-chroot /mnt pacman -Sy --noconfirm \
    mesa \
    xf86-video-intel \
    xf86-video-fbdev \
    networkmanager \
    network-manager-applet \
    xorg-server \
    xorg-xinit \
    xorg-xprop \
    xorg-xev \
    i3 \
    i3blocks \
    dmenu \
    lightdm \
    lightdm-gtk-greeter \
    adobe-source-code-pro-fonts \
    cantarell-fonts \
    noto-fonts \
    noto-fonts-extra \
    noto-fonts-emoji \
    xorg-font-util \
    xorg-fonts-100dpi \
    xorg-fonts-75dpi \
    xorg-fonts-encodings \
    xorg-mkfontscale \
    xfce4-terminal \
    firefox \
    xwallpaper \
    pulseaudio \
    pavucontrol \
    pulsemixer \
    scrot \
    sxiv \
    unclutter \
    modemmanager \
    bluez \
    bluez-qt \
    bluez-utils \
    blueman \
    imagemagick \
    perl-gtk3 \
    pango-perl \
    cups \
    cups-pdf \
    fontconfig \
    powerline-fonts \
    powerline-vim

# Configure packages installed
arch-chroot /mnt systemctl enable ModemManager
arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt systemctl enable bluetooth
arch-chroot /mnt systemctl enable lightdm

# Terminal Config
mkdir -p /mnt/home/$newUsername/.config/xfce4/terminal/
wget -O /mnt/home/$newUsername/.config/xfce4/terminal/terminalrc $serverURL/files/xfce4-terminal-config

# Wallpaper
wget -O /mnt/home/$newUsername/.config/wallpaper.png $serverURL/files/wallpaper.png

# User own everything
arch-chroot /mnt chown $newUsername:$newUsername -R /home/$newUsername

# mkdir -p /mnt/home/$newUsername/.local/share/
# wget -O /mnt/home/$newUsername/.local/share/fonts.tgz $serverURL/tarballz/fonts.tgz
# cd /mnt/home/$newUsername/.local/share/
# tar xvzf fonts.tgz
# cd
# arch-chroot /mnt chown $newUsername:$newUsername -R /home/$newUsername
# arch-chroot /mnt su $newUsername -c "fc-cache -f /home/$newUsername/.local/share/fonts"
