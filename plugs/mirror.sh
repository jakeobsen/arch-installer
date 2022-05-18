grep -s mirror.unlab.dev /etc/pacman.d/mirrorlist
if [ $? -ne 0 ]; then
    rm -R /var/lib/pacman/sync/
    echo 'Server = https://mirror.unlab.dev/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
    pacman -Sy --noconfirm archlinux-keyring
fi