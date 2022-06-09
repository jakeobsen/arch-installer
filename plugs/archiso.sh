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
cp -r /tmp/env /mnt/home/$newUsername/unlab-archlive/arch-archiso/airootfs/etc/bootstrap

# Reset all perms
arch-chroot /mnt chown $newUsername:$newUsername -R /home/$newUsername

# Build
cat>>/mnt/home/$newUsername/unlab-archlive/build.sh<<EOF
#!/bin/bash
rm -rf rm -rf /home/\$newUsername/unlab-archlive/temp
mkdir -p rm -rf /home/\$newUsername/unlab-archlive/temp
cd /home/\$newUsername/unlab-archlive/
git pull
sudo mkarchiso -v -w /home/\$newUsername/unlab-archlive/temp /home/\$newUsername/unlab-archlive/arch-archiso
EOF
chmod +x /mnt/home/$newUsername/unlab-archlive/build.sh
arch-chroot /mnt /home/$newUsername/unlab-archlive/build.sh

# Reset all perms
arch-chroot /mnt chown $newUsername:$newUsername -R /home/$newUsername

fi
