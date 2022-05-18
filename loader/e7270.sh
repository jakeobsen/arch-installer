#!/bin/bash
plugs=( cleanup env minimal i3 reboot )
for plug in "${plugs[@]}"; do curl -s "https://install.unlab.dev/plugs/$plug.sh" | bash; done