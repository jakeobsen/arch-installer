source /tmp/env; [ "$envSourced" != "YES" ] && exit 255

if [ "$iWantReboot" == "yes" ]; then
    curl -s $serverURL/plugs/cleanup.sh | bash
    reboot
fi
