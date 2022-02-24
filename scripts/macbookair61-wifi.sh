# Mount filesystems and prep basic structure

# i3 packages
pacman -Sy --noconfirm \
    linux-headers \
    broadcom-wl-dkms

mkinitcpio -p linux