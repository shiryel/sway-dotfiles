# This presupposes that you have imv with a bind to set the wallpaper on ~/.cache/wallpaper
# And create a default wallpaper when not defined

if [[ ! -f "$HOME/.cache/wallpaper" ]]; then
  mkdir -p "$HOME/.cache"
  cp -f "/usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png" "$HOME/.cache/wallpaper"
fi

#swaymsg output "*" "$HOME/.cache/wallpaper" fill
#swaybg -o "*" -i "$HOME/.cache/wallpaper" -m fill
