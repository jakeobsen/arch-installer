# Clean up
umount /mnt/boot
umount /mnt/home
umount /mnt
swapoff -a
lvchange -a n $(vgdisplay | grep "VG Name" | awk '{print $3}')
cryptsetup close cryptolvm