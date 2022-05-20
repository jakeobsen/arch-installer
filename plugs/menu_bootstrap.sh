menu=""
d='dialog --clear --stdout --title Unlab.dev'

grep -qi "Latitude E7270" /sys/class/dmi/id/product_name && menu="e7270"

[ "$menu" == "" ] && menu=$(dialog --clear --stdout --title "Unlab.dev" --menu "" 0 0 1 \
        "e7270" "Bootstrap E7270" \
)

[ "$menu" != "" ] && curl -s https://install.unlab.dev/loader/$menu.sh | bash