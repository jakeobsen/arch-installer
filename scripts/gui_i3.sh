# i3 packages
pacman -Sy --noconfirm \
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
    mpv \
    arandr \
    powerline \
    powerline-fonts \
    scrot \
    sxiv \
    unclutter \
    wireshark-qt \
    modemmanager \
    rdesktop \
    bluez \
    bluez-qt \
    bluez-utils \
    blueman \
    tigervnc \
    rdesktop \
    imagemagick \
    geeqie \
    android-tools \
    perl-gtk3 \
    pango-perl \
    cups \
    cups-pdf \
    sqlitebrowser \
    fontconfig

# Configure packages installed
systemctl enable ModemManager
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable lightdm
