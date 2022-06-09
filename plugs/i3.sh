source /tmp/env; [ "$envSourced" != "YES" ] && exit 255

if [ "$iWantReboot" == "yes" ]; then

# i3 packages
arch-chroot /mnt pacman -Sy --noconfirm \
    mesa \
    xf86-video-intel \
    xf86-video-fbdev \
    networkmanager \
    network-manager-applet \
    xorg-server \
    xorg-xinit \
    xorg-xprop \
    xorg-xev \
    i3 \
    i3blocks \
    dmenu \
    lightdm \
    lightdm-gtk-greeter \
    adobe-source-code-pro-fonts \
    cantarell-fonts \
    noto-fonts \
    noto-fonts-extra \
    noto-fonts-emoji \
    xorg-font-util \
    xorg-fonts-100dpi \
    xorg-fonts-75dpi \
    xorg-fonts-encodings \
    xorg-mkfontscale \
    xorg-xbacklight \
    xfce4-terminal \
    firefox \
    xwallpaper \
    pulseaudio \
    pavucontrol \
    pulsemixer \
    scrot \
    sxiv \
    unclutter \
    modemmanager \
    bluez \
    bluez-qt \
    bluez-utils \
    blueman \
    imagemagick \
    perl-gtk3 \
    pango-perl \
    cups \
    cups-pdf \
    fontconfig \
    powerline-fonts \
    powerline-vim \
    unclutter \
    feh

# Configure packages installed
arch-chroot /mnt systemctl enable ModemManager
arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt systemctl enable bluetooth
arch-chroot /mnt systemctl enable lightdm

# Terminal Config
mkdir -p /mnt/home/$newUsername/.config/xfce4/terminal/
wget -O /mnt/home/$newUsername/.config/xfce4/terminal/terminalrc $serverURL/files/xfce4-terminal-config

# Wallpaper
wget -O /mnt/home/$newUsername/.config/wallpaper.png $serverURL/files/wallpaper.png

# i3 config
mkdir -p /mnt/home/$newUsername/.config/i3
cat>/mnt/home/$newUsername/.config/i3/config<<EOF
set \$mod Mod4
font pango:Source Code Pro Regular 8

# Borders
for_window [class=".*"] border pixel 1
gaps outer 0
gaps inner 5
smart_gaps on
smart_borders on

# xss-lock grabs a logind suspend inhibit lock and will use i3lock to lock the
# screen before suspend. Use loginctl lock-session to lock your screen.
exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork

# NetworkManager is the most popular way to manage wireless networks on Linux,
# and nm-applet is a desktop environment-independent system tray GUI for it.
exec --no-startup-id nm-applet

# feh sets the screen background
exec --no-startup-id feh --bg-fill ~/.config/wallpaper.png

# unclutter hides the mouse cursor after a short period
exec --no-startup-id unclutter

# Screenshots
bindsym Print exec --no-startup-id scrot ~/\$(date '+%Y-%m-%d-%H%M%S_scrot.png')
bindsym --release shift+Print exec --no-startup-id scrot -s ~/\$(date '+%Y-%m-%d-%H%M%S_scrot.png')

# XF86 controls
set \$refresh_i3status killall -SIGUSR1 i3status
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && \$refresh_i3status
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && \$refresh_i3status
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && \$refresh_i3status
bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && \$refresh_i3status
bindsym XF86MonBrightnessUp exec xbacklight -inc 10
bindsym XF86MonBrightnessDown exec xbacklight -dec 10
# bindsym XF86Sleep exec --no-startup-id locksleep

# Use Mouse+\$mod to drag floating windows to their wanted position
floating_modifier \$mod

# start a terminal
bindsym \$mod+Return exec i3-sensible-terminal

# kill focused window
bindsym \$mod+Shift+q kill

# start dmenu (a program launcher)
bindsym \$mod+d exec --no-startup-id dmenu_run

# change focus
bindsym \$mod+j focus left
bindsym \$mod+k focus down
bindsym \$mod+l focus up
bindsym \$mod+semicolon focus right

# alternatively, you can use the cursor keys:
bindsym \$mod+Left focus left
bindsym \$mod+Down focus down
bindsym \$mod+Up focus up
bindsym \$mod+Right focus right

# move focused window
bindsym \$mod+Shift+j move left
bindsym \$mod+Shift+k move down
bindsym \$mod+Shift+l move up
bindsym \$mod+Shift+semicolon move right

# alternatively, you can use the cursor keys:
bindsym \$mod+Shift+Left move left
bindsym \$mod+Shift+Down move down
bindsym \$mod+Shift+Up move up
bindsym \$mod+Shift+Right move right

# split in horizontal orientation
bindsym \$mod+h split h

# split in vertical orientation
bindsym \$mod+v split v

# enter fullscreen mode for the focused container
bindsym \$mod+f fullscreen toggle

# change container layout (stacked, tabbed, toggle split)
bindsym \$mod+s layout stacking
bindsym \$mod+w layout tabbed
bindsym \$mod+e layout toggle split

# toggle tiling / floating
bindsym \$mod+Shift+space floating toggle

# change focus between tiling / floating windows
bindsym \$mod+space focus mode_toggle

# focus the parent container
bindsym \$mod+a focus parent

# Define names for default workspaces for which we configure key bindings later on.
# We use variables to avoid repeating the names in multiple places.
set \$ws1 "1"
set \$ws2 "2"
set \$ws3 "3"
set \$ws4 "4"
set \$ws5 "5"
set \$ws6 "6"
set \$ws7 "7"
set \$ws8 "8"
set \$ws9 "9"
set \$ws10 "10"

# switch to workspace
bindsym \$mod+1 workspace number \$ws1
bindsym \$mod+2 workspace number \$ws2
bindsym \$mod+3 workspace number \$ws3
bindsym \$mod+4 workspace number \$ws4
bindsym \$mod+5 workspace number \$ws5
bindsym \$mod+6 workspace number \$ws6
bindsym \$mod+7 workspace number \$ws7
bindsym \$mod+8 workspace number \$ws8
bindsym \$mod+9 workspace number \$ws9
bindsym \$mod+0 workspace number \$ws10

# move focused container to workspace
bindsym \$mod+Shift+1 move container to workspace number \$ws1
bindsym \$mod+Shift+2 move container to workspace number \$ws2
bindsym \$mod+Shift+3 move container to workspace number \$ws3
bindsym \$mod+Shift+4 move container to workspace number \$ws4
bindsym \$mod+Shift+5 move container to workspace number \$ws5
bindsym \$mod+Shift+6 move container to workspace number \$ws6
bindsym \$mod+Shift+7 move container to workspace number \$ws7
bindsym \$mod+Shift+8 move container to workspace number \$ws8
bindsym \$mod+Shift+9 move container to workspace number \$ws9
bindsym \$mod+Shift+0 move container to workspace number \$ws10

# reload the configuration file
bindsym \$mod+Shift+c reload
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym \$mod+Shift+r restart
# exit i3 (logs you out of your X session)
bindsym \$mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"

# resize window (you can also use the mouse for that)
mode "resize" {
        # These bindings trigger as soon as you enter the resize mode

        # same bindings, but for the arrow keys
        bindsym Left resize shrink width 10 px or 2 ppt
        bindsym Down resize grow height 10 px or 2 ppt
        bindsym Up resize shrink height 10 px or 2 ppt
        bindsym Right resize grow width 10 px or 2 ppt

        # back to normal: Enter or Escape or \$mod+r
        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym \$mod+r mode "default"
}

bindsym \$mod+r mode "resize"

# Start i3bar to display a workspace bar (plus the system information i3status
# finds out, if available)
bar {
  font pango:Source Code Pro Regular 8
  status_command i3blocks
  position top
  mode dock
  modifier None
}
EOF

# i3blocks
mkdir -p /mnt/home/$newUsername/.config/i3blocks
cat>/mnt/home/$newUsername/.config/i3blocks/config<<EOF
# i3blocks config file
#
# List of valid properties:
#
# align
# color
# command
# full_text
# instance
# interval
# label
# min_width
# name
# separator
# separator_block_width
# short_text
# signal
# urgent

command=~/.local/share/i3blocks/\$BLOCK_NAME
separator_block_width=15
markup=pango

[uptime]
label=🔼
interval=60

[temperature]
interval=3

[load_average]
label=🧠
interval=3

[memory]
label=📈
interval=10

[disk]
label=💻
command=df -h -P -l "/" | tail -n1 | awk '{print \$4}'
interval=60

[disk]
label=🏠
command=df -h -P -l "/home" | tail -n1 | awk '{print \$4}'
interval=60

[pacgrade]
interval=300

[nettraf]
interval=1

[battery]
interval=60

[pulse]
interval=60
signal=11

[date]
label=📆
command=date '+%b %d'
interval=3600

[emojitime]
interval=60
EOF

mkdir -p /mnt/home/$newUsername/.local/share/i3blocks/
wget -O /mnt/home/$newUsername/.local/share/i3blocks/i3blocks.tgz $serverURL/files/i3blocks.tgz
cd /mnt/home/$newUsername/.local/share/i3blocks/
tar xvzf i3blocks.tgz
rm i3blocks.tgz
chmod +x *
cd

# User own everything
arch-chroot /mnt chown $newUsername:$newUsername -R /home/$newUsername

fi