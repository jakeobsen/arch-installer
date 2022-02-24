# Mount filesystems and prep basic structure
d='dialog --clear --stdout --title Unlab.dev'

targetDisk=$($d --no-cancel --ok-label Next --inputbox "[1/3] Target Disk" 0 0 "/dev/sda")
bootDisk=${targetDisk}1
rootDisk=${targetDisk}2
vgName=$($d --no-cancel --ok-label Next --inputbox "[2/3] Volume Group Name" 0 0)
passwordLuks=$($d --no-cancel --ok-label Next --insecure --passwordbox "[3/3] LUKS Password" 0 0)

echo -n "$passwordLuks" | cryptsetup open $rootDisk cryptolvm - || exit
mount /dev/$vgName/root /mnt
mount /dev/$vgName/home /mnt/home
mount $bootDisk /mnt/boot