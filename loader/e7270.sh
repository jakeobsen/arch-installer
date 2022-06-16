#!/bin/bash
plugs=( cleanup env minimal ssh i3 archiso reboot )
for plug in "${plugs[@]}"; do curl -s "https://install.unlab.dev/plugs/$plug.sh" | bash; done
