source /tmp/env; [ "$envSourced" != "YES" ] && exit 255

localSSHFiles="/usr/local/share/unlab/ssh/"

[ -d $localSSHFiles ] \
  && cp -r $localSSHFiles /mnt/home/$newUsername/.ssh/ \

[ ! -d $localSSHFiles ] \
  && mkdir -p /mnt/home/$newUsername/.ssh/ \
  && echo -e "Host gitlab.com\n\tStrictHostKeyChecking no\n" >  /mnt/home/$newUsername/.ssh/config \
  && arch-chroot /mnt ssh-keygen -t ed25519 -a 1000 -C $newUsername@$newHostname -f /home/$newUsername/.ssh/id_ed25519 -N $newPassword

arch-chroot /mnt chown $newUsername:$newUsername -R /home/$newUsername
chmod 600 /mnt/home/$newUsername/.ssh/*
