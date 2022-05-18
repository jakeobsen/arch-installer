#!/bin/bash
plugs=( dialog wget menu_system )
for plug in "${plugs[@]}"; do curl -s "https://install.unlab.dev/plugs/$plug.sh" | bash; done
