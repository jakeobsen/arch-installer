#!/bin/bash
d='dialog --clear --stdout --title Unlab.dev'

message=$(echo "Please read all dialogs carefully. Any mistakes in dialog inputs cannot be undone, and you will have to start over.")
$d --msgbox "$message" 0 0

disclaimer=$(echo "This script is designed to bootstrap Arch Linux onto a Dell Latitude E7270 laptop." \
           "If you choose to continue with this process, you do so at your own liability and any damage "\
           "this script does to your computer, or any outcome from running it is your responsibility.")

$d --msgbox "$disclaimer" 0 0

diskinfo=$(echo "Your target disk should be of at least 120GB - it WILL be erased during the install" \
                  "and formatted with LUKS disk encryption, a 32GB root LVM partition will be created" \
                  "on which the root file system will be installed. And a 64GB home LVM partition will" \
                  "be created and mounted in /home - and finally a 4GB LVM partition will be created for SWAP." \
                  "You can always resize these partitions with lvresize. All LVM partitions will have the EXT4 filesytem.")

$d --msgbox "$diskinfo" 0 0

targetDisk=$($d --no-cancel --ok-label Next --inputbox "[1/11] Target Disk" 0 0 "/dev/sda")
bootDisk=${targetDisk}1
rootDisk=${targetDisk}2
vgName=$($d --no-cancel --ok-label Next --inputbox "[2/11] Volume Group Name" 0 0)
newHostname=$($d --no-cancel --ok-label Next --inputbox "[3/11] Hostname" 0 0)
newUsername=$($d --no-cancel --ok-label Next --inputbox "[4/11] Username" 0 0)
newUsernameName=$($d --no-cancel --ok-label Next --inputbox "[5/11] Real name" 0 0)
newPassword=$($d --no-cancel --ok-label Next --insecure --passwordbox "[6/11] User Password" 0 0)
newKeyboard=$($d --no-cancel --ok-label Next --inputbox "[7/11] Keyboard layout" 0 0 "uk")
newLocale=$($d --no-cancel --ok-label Next --inputbox "[8/11] System locale" 0 0 "en_UK")
newTimezone=$($d --no-cancel --ok-label Next --inputbox "[9/11] Timezone" 0 0 "UTC")
passwordLuks=$($d --no-cancel --ok-label Next --insecure --passwordbox "[10/11] LUKS Password" 0 0)

iWantI3="no"
$d --yesno "[11/11] Do you want to install the i3 window manager?" 0 0
[ "$?" == "0" ] && iWantI3="yes"

# DMI Decode to detect snowflake hardwre
if [ ! -f /usr/bin/dmidecode ]; then
    pacman -Sy --noconfirm dmidecode
fi
MOTHERBOARD=$(dmidecode -t 2 2>/dev/null | grep 'Version:' | awk '{print $2}')

installMacBookAir61WiFi="no"
if [ $MOTHERBOARD == "MacBookAir6,1" ]; then
    $d --yesno "11\" Apple Macbook Air mid-2013 has been detected, this model require a special non-free wifi driver not included in the default installer. Would you like to install it?" 0 0
    [ "$?" == "0" ] && installMacBookAir61WiFi="yes"
fi

iWantReboot="no"
$d --yesno "Do you want to reboot automatically when the install is done?" 0 0
[ "$?" == "0" ] && iWantReboot="yes"

$d --yesno "This will erase all data on this system, are you sure you want to do this?" 0 0
[ "$?" != "0" ] && exit 1


if [ "$installMacBookAir61WiFi" == "yes" ]; then
    curl https://install.unlab.dev/scripts/macbookair61-wifi.sh | bash
fi

exit 0

# targetDisk="/dev/sda"
# bootDisk=${targetDisk}1
# rootDisk=${targetDisk}2
# vgName="vg0"
# newHostname="test"
# newUsername="test"
# newUsernameName="test"
# newPassword="test"
# newKeyboard="dk"
# newLocale="en_DK"
# newTimezone="Europe/Dublin"
# passwordLuks="test"
# iWantI3="yes"
# iWantReboot="yes"

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
parted $targetDisk mkpart fat32 2048s 264191s
parted $targetDisk set 1 esp on

# Create LUKS partition
parted $targetDisk mkpart ext4 264192s 100%

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
arch-chroot /mnt pacman --noconfirm -Sy linux linux-headers mkinitcpio lvm2

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
    openssh \
    sudo \
    rsync \
    acpi \
    htop \
    irssi \
    python3 \
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
    python-pylint \
    autopep8 \
    python-pip \
    man-db \
    nfs-utils \
    linux-headers \
    linux-firmware \
    pciutils \
    usbutils

# Firewall
arch-chroot /mnt systemctl enable ufw

# Setup sudo
sed -i '0,/# %wheel/s/# %wheel/%wheel/' /mnt/etc/sudoers

# Setup user accounts
echo "Adding account"
arch-chroot /mnt useradd -c "$newUsernameName" -G "wheel" -m $newUsername
echo "Setting account passwords"
echo "$newUsername:$newPassword" | arch-chroot /mnt chpasswd
echo "root:root" | arch-chroot /mnt chpasswd

# SSH
mkdir -p /mnt/home/$newUsername/.ssh/
echo -e "Host gitlab.com\n\tStrictHostKeyChecking no\n" > /mnt/home/$newUsername/.ssh/config
chmod 600 /mnt/home/$newUsername/.ssh/config

# Vim
mkdir -p /mnt/home/$newUsername/.config/
wget -O /mnt/home/$newUsername/.config/vim.tgz https://install.unlab.dev/tarballz/vim.tgz
cd /mnt/home/$newUsername/.config/
tar xvzf vim.tgz
rm vim.tgz
cd

# bash
curl https://install.unlab.dev/config/bashrc > /mnt/home/$newUsername/.bashrc

# Make user own everything
arch-chroot /mnt chown $newUsername:$newUsername -R /home/$newUsername

##
## Snowflake shit
##

# Install Apple Wifi Driver
if [ "$installMacBookAir61WiFi" == "yes" ]; then
    curl https://install.unlab.dev/scripts/macbookair61-wifi.sh | bash
fi

## ~~~~~~~~~~~~~~~~~~~ ##
## GRAPHIC ENVIRONMENT ##
## ~~~~~~~~~~~~~~~~~~~ ##

if [ "$iWantI3" == "yes" ]; then
    curl https://install.unlab.dev/scripts/gui_i3.sh | arch-chroot /mnt bash

    # Terminal Config
    mkdir -p /mnt/home/$newUsername/.config/xfce4/terminal/
    wget -O /mnt/home/$newUsername/.config/xfce4/terminal/terminalrc https://install.unlab.dev/config/terminalrc

    mkdir -p /mnt/home/$newUsername/.local/share/
    wget -O /mnt/home/$newUsername/.local/share/fonts.tgz https://install.unlab.dev/tarballz/fonts.tgz
    cd /mnt/home/$newUsername/.local/share/
    tar xvzf fonts.tgz
    cd
    arch-chroot /mnt chown $newUsername:$newUsername -R /home/$newUsername
    arch-chroot /mnt su $newUsername -c "fc-cache -f /home/$newUsername/.local/share/fonts"

else
    arch-chroot /mnt pacman -Sy --noconfirm dhcpcd wpa_supplicant netctl ifplugd
    arch-chroot /mnt systemctl enable dhcpcd
    arch-chroot /mnt systemctl enable netctl-ifplugd@$(ls /sys/class/net | egrep '^e').service
fi



## ~~~~~~ ##
## REBOOT ##
## ~~~~~~ ##

if [ "$iWantReboot" == "yes" ]; then
    curl https://install.unlab.dev/scripts/reboot.sh | bash
fi
