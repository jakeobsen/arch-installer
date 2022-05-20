#!/bin/bash
[ -f /etc/bootstrap ] && cp /etc/bootstrap /tmp/env && exit 0

d='dialog --clear --stdout --title Unlab.dev'
[ -f /tmp/env ] && $d --yesno "Reuse pre-configured install environment?" 0 0
[ "$?" == "0" ] && exit 0 || rm /tmp/env

for d in /sys/block/*; do 
    if [ ! -d  $d/loop/ ] && [ $(cat $d/removable) -eq 0 ]; then
        targetDisk=/dev/$(grep DEVNAME $d/uevent | cut -d= -f2)
    fi
done

d='dialog --clear --stdout --title Unlab.dev'
message=$(echo "Please read all dialogs carefully. Any mistakes in dialog inputs cannot be undone, and you will have to start over.")
$d --msgbox "$message" 0 0
disclaimer=$(echo "This script is designed to bootstrap Arch Linux." \
           "If you choose to continue with this process, you do so at your own liability and any damage "\
           "this script does to your computer, or any outcome from running it is your responsibility.")
$d --msgbox "$disclaimer" 0 0
diskinfo=$(echo "Your target disk should be of at least 120GB - it WILL be erased during the install" \
                  "and formatted with LUKS disk encryption, a 32GB root LVM partition will be created" \
                  "on which the root file system will be installed. And a 64GB home LVM partition will" \
                  "be created and mounted in /home - and finally a 4GB LVM partition will be created for SWAP." \
                  "You can always resize these partitions with lvresize. All LVM partitions will have the EXT4 filesytem.")
$d --msgbox "$diskinfo" 0 0
$d --msgbox "The system will now attempt to auto locate your target disk." 0 0

targetDisk=$($d --no-cancel --ok-label Next --inputbox "[1/11] Target Disk" 0 0 "$targetDisk")
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

iWantReboot="no"
$d --yesno "Do you want to reboot automatically when the install is done?" 0 0
[ "$?" == "0" ] && iWantReboot="yes"

$d --yesno "This will erase all data on this system, are you sure you want to do this?" 0 0
[ "$?" != "0" ] && exit 1

cat>/tmp/env<<EOF
export serverURL='https://install.unlab.dev'
export targetDisk='$targetDisk'
export vgName='$vgName'
export newHostname='$newHostname'
export newUsername='$newUsername'
export newUsernameName='$newUsernameName'
export newPassword='$newPassword'
export newKeyboard='$newKeyboard'
export newLocale='$newLocale'
export newTimezone='$newTimezone'
export passwordLuks='$passwordLuks'
export iWantI3='$iWantI3'
export iWantReboot='$iWantReboot'
export envSourced='YES'
EOF