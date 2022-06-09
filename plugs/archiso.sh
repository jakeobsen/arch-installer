source /tmp/env; [ "$envSourced" != "YES" ] && exit 255

if [ "$iWantArchIso" == "yes" ]; then

# Cleanup
rm -rf /mnt/home/$newUsername/jakeobsen-archlive

# Allow running mkarchiso without password if in wheel
cat>/mnt/etc/sudoers.d/mkarchiso<<EOF
%wheel ALL = NOPASSWD: /usr/bin/mkarchiso
EOF

# Dependencies
arch-chroot /mnt pacman -Sy --noconfirm git archiso git

# Setup environment
mkdir -p /mnt/home/$newUsername/jakeobsen-archlive/temp
cd /mnt/home/$newUsername/jakeobsen-archlive
git clone https://github.com/jakeobsen/arch-archiso
cp -r /tmp/env /mnt/home/$newUsername/jakeobsen-archlive/arch-archiso/airootfs/etc/bootstrap

# Reset all perms
arch-chroot /mnt chown $newUsername:$newUsername -R /home/$newUsername

# Build
cat>>/mnt/home/$newUsername/jakeobsen-archlive/build.sh<<EOF
#!/bin/bash
rm -rf rm -rf /home/\$newUsername/jakeobsen-archlive/temp
mkdir -p rm -rf /home/\$newUsername/jakeobsen-archlive/temp
cd /home/\$newUsername/jakeobsen-archlive/
git pull
sudo mkarchiso -v -w /home/\$newUsername/jakeobsen-archlive/temp /home/\$newUsername/jakeobsen-archlive/arch-archiso
EOF
chmod +x /mnt/home/$newUsername/jakeobsen-archlive/build.sh
arch-chroot /mnt /home/$newUsername/jakeobsen-archlive/build.sh

# Reset all perms
arch-chroot /mnt chown $newUsername:$newUsername -R /home/$newUsername

fi
