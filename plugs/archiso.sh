source /tmp/env; [ "$envSourced" != "YES" ] && exit 255

if [ "$iWantArchIso" == "yes" ]; then

# Cleanup
rm -rf /mnt/home/$newUsername/unlab-archlive

# Allow running mkarchiso without password if in wheel
cat>/mnt/etc/sudoers.d/mkarchiso<<EOF
%wheel ALL = NOPASSWD: /usr/bin/mkarchiso
EOF

# Dependencies
arch-chroot /mnt pacman -Sy --noconfirm git archiso git

# Setup environment
mkdir -p /mnt/home/$newUsername/unlab-archlive/temp
cd /mnt/home/$newUsername/unlab-archlive
git clone https://github.com/jakeobsen/arch-archiso

# Reset all perms
arch-chroot /mnt chown $newUsername:$newUsername -R /home/$newUsername

# Build
touch /mnt/boot/archiso.iso
chown root:wheel /mnt/boot/archiso.iso
chmod 664 /mnt/boot/archiso.iso
cat>>/mnt/home/$newUsername/unlab-archlive/build.sh<<EOF
#!/bin/bash
rm -rf rm -rf /home/$newUsername/unlab-archlive/temp
mkdir -p rm -rf /home/$newUsername/unlab-archlive/temp
cd /home/$newUsername/unlab-archlive/
mkdir -p /home/$newUsername/unlab-archlive/arch-archiso/airootfs/usr/local/share/unlab/
cp -r /home/$newUsername/.ssh/* /home/$newUsername/unlab-archlive/arch-archiso/airootfs/usr/local/share/unlab/ssh/
git pull
sudo mkarchiso -v -w /home/$newUsername/unlab-archlive/temp /home/$newUsername/unlab-archlive/arch-archiso
sudo cp -r /home/$newUsername/unlab-archlive/out/unlab_archlinux-\$(date +%Y.%m.%d)-x86_64.iso /boot/archiso.iso
EOF
chmod +x /mnt/home/$newUsername/unlab-archlive/build.sh
arch-chroot /mnt /home/$newUsername/unlab-archlive/build.sh

# Recovery environment
cat>/mnt/boot/loader/entries/archiso.conf<<EOF
title Arch Linux Live/Rescue CD
linux /arch/boot/vmlinuz
initrd /arch/boot/archiso.img
options archisobasedir=arch archisolabel=ARCHISO img_dev=/dev/sda1 img_loop=/archiso.iso
EOF

# Reset all perms
arch-chroot /mnt chown $newUsername:$newUsername -R /home/$newUsername

fi
