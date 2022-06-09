#!/bin/bash
plugs=( pacman-gpg-fix mirror dialog wget git menu_bootstrap )
for plug in "${plugs[@]}"; do curl -s "https://install.unlab.dev/plugs/$plug.sh" | bash; done
