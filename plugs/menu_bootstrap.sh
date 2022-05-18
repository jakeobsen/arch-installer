menu=""
d='dialog --clear --stdout --title Unlab.dev'
menu=$(dialog --clear --stdout --title "Unlab.dev" --menu "" 0 0 1 \
        "e7270" "Bootstrap E7270" \
)
[ "$menu" != "" ] && curl -s https://install.unlab.dev/loader/$menu.sh | bash