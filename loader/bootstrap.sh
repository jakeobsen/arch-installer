#!/bin/bash
plugs=( mirror dialog wget menu_bootstrap )
for plug in "${plugs[@]}"; do curl -s "https://install.unlab.dev/plugs/$plug.sh" | bash; done