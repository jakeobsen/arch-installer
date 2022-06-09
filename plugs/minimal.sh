source /tmp/env; [ "$envSourced" != "YES" ] && exit 255

## ~~~~~~~~~~ ##
## ENV CONFIG ##
## ~~~~~~~~~~ ##

loadkeys $newKeyboard
timedatectl set-ntp true

## ~~~~~~~~~~~ ##
## PARITIONING ##
## ~~~~~~~~~~~ ##

# Wipe disk filesystems
wipefs -a -f $targetDisk

# Create GPT partition layout
parted $targetDisk mklabel gpt

# Create ESP EFI boot partition
parted $targetDisk mkpart BOOT fat32 2048s 2099199s
parted $targetDisk set 1 esp on

# Create LUKS partition
parted $targetDisk mkpart ROOT ext4 2099200s 100%

# Assign disks
bootDisk=$(blkid | grep $targetDisk | grep BOOT | cut -d: -f1)
rootDisk=$(blkid | grep $targetDisk | grep ROOT | cut -d: -f1)

# Make encrypted partition
echo -n "$passwordLuks" | cryptsetup -y -v luksFormat $rootDisk - || exit
echo -n "$passwordLuks" | cryptsetup open $rootDisk cryptolvm - || exit

# Create LVM container
pvcreate /dev/mapper/cryptolvm
vgcreate $vgName /dev/mapper/cryptolvm

# Create LVM partitions
lvcreate -L 32G $vgName -n root
lvcreate -L 64G $vgName -n home
lvcreate -L 4G $vgName -n swap

# Create filesystems
mkfs.fat -F32 $bootDisk
mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0 $targetDisk
mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0 /dev/$vgName/root
mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0 /dev/$vgName/home
mkswap  /dev/$vgName/swap
swapon /dev/$vgName/swap

# Mount filesystems and prep basic structure
mount /dev/$vgName/root /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/$vgName/home /mnt/home
mount $bootDisk /mnt/boot

## ~~~~~~~~~~~~ ##
## BASE INSTALL ##
## ~~~~~~~~~~~~ ##

# Install OS
pacstrap /mnt base

# Update repo
rm -R /mnt/var/lib/pacman/sync/
echo 'Server = https://mirror.unlab.dev/archlinux/$repo/os/$arch' > /mnt/etc/pacman.d/mirrorlist
arch-chroot /mnt pacman -Syu
arch-chroot /mnt pacman -Sy --noconfirm archlinux-keyring

# Configure fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Setup system
arch-chroot /mnt ln -sf /usr/share/zoneinfo/$newTimezone /etc/localtime
arch-chroot /mnt hwclock --systohc
echo "$newLocale.UTF-8 UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "KEYMAP=$newKeyboard" > /mnt/etc/vconsole.conf
echo "$newHostname" > /mnt/etc/hostname
cat>/mnt/etc/hosts<<EOF
# Static table lookup for hostnames.
# See hosts(5) for details.
127.0.0.1   localhost
::1         localhost
127.0.1.1   $newHostname    $newHostname.local
# End of standard entries
EOF

# Install linux
arch-chroot /mnt pacman --noconfirm -Sy linux linux-headers linux-firmware mkinitcpio lvm2

# Customize initrd so we can decrypt disk
sed -i 's/HOOKS=(/#HOOKS=(/' /mnt/etc/mkinitcpio.conf
echo 'HOOKS=(base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems fsck)' >> /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -p linux

# Install systemd-boot
arch-chroot /mnt bootctl install
cat>/mnt/boot/loader/loader.conf<<EOF
default arch.conf
timeout 0
console-mode max
editor no
EOF

# Install boot menu entry
cryptline=cryptdevice=$(blkid | grep crypto_LUKS | awk '{print $2}' | sed 's/"//g'):cryptroot
rootline=root=$(blkid | grep root | awk '{print $2}' | sed 's/"//g')
cat>/mnt/boot/loader/entries/arch.conf<<EOF
title Boot System
linux /vmlinuz-linux
initrd /initramfs-linux.img
EOF
echo options $cryptline $rootline rw >> /mnt/boot/loader/entries/arch.conf

# Install basic packages
arch-chroot /mnt pacman -Sy --noconfirm \
    vim \
    git \
    dialog \
    ncurses \
    glibc \
    openssh \
    sudo \
    rsync \
    acpi \
    htop \
    gcc \
    gdb \
    make \
    wget \
    unzip \
    ufw \
    whois \
    dnsutils \
    pwgen \
    figlet \
    cowsay \
    fakeroot \
    man-db \
    nfs-utils \
    pciutils \
    usbutils \
    python3 \
    python-pylint \
    autopep8 \
    python-pip \
    go

# Firewall
arch-chroot /mnt systemctl enable ufw

# Setup sudo
cat>/mnt/etc/sudoers.d/wheel<<EOF
%wheel ALL=(ALL:ALL) ALL
EOF

# Setup user accounts
echo "Adding account"
arch-chroot /mnt useradd -c "$newUsernameName" -G "wheel" -m $newUsername
echo "Setting account passwords"
echo "$newUsername:$newPassword" | arch-chroot /mnt chpasswd
echo "root:$newPassword" | arch-chroot /mnt chpasswd

# SSH
mkdir -p /mnt/home/$newUsername/.ssh/
echo -e "Host gitlab.com\n\tStrictHostKeyChecking no\n" > /mnt/home/$newUsername/.ssh/config
chmod 600 /mnt/home/$newUsername/.ssh/config
arch-chroot /mnt ssh-keygen -t ed25519 -a 1000 -C $newUsername@$newHostname -f /home/$newUsername/.ssh/id_ed25519 -N $newPassword
chmod 600 /mnt/home/$newUsername/.ssh/id_ed25519 /mnt/home/$newUsername/.ssh/id_ed25519.pub

# Bash
# This bash configuration removes the bash config files from the home directory and also makes it
# easier to split up the bash config into multiple files. Splitting the bashrc file into multiple
# smaller files also makes it easier to write small blocks of individual bash code / aliases etc.
grep -q AAIBashInConfig /etc/bash.bashrc
[ $? -ne 0 ] && cat>>/mnt/etc/bash.bashrc<<EOF
[ -d \$HOME/.config/bash/ ] && source <(cat \$HOME/.config/bash/*) # AAIBashInConfig
EOF
rm /mnt/home/$newUsername/.bash*
mkdir -p /mnt/home/$newUsername/.config/bash/
mkdir -p /mnt/home/$newUsername/.cache/
cat>/mnt/home/$newUsername/.config/bash/00-ps1.sh<<EOF
export PS1='\[\e[0;1;93m\]\w \[\e[0;1;95m\]\\$ \[\e[0m\]'
EOF
cat>/mnt/home/$newUsername/.config/bash/00-history.sh<<EOF
HISTSIZE=5000
HISTFILESIZE=10000
HISTFILE="\$HOME/.cache/bash_history"
export PROMPT_COMMAND="history -a \$HISTFILE; history -c; history -r \$HISTFILE; \$PROMPT_COMMAND"
EOF
cat>/mnt/home/$newUsername/.config/bash/00-path.sh<<EOF
TMP_PATHS=( "\$HOME/.local/bin/" "\$HOME/.bin/" "\$HOME/bin/" )
for TMP_PATH in "\${TMP_PATHS[@]}"; do [ -d \$TMP_PATH ] && echo export PATH=\$TMP_PATH:\$PATH; done
unset paths
EOF

# Make user own everything
arch-chroot /mnt chown $newUsername:$newUsername -R /home/$newUsername
