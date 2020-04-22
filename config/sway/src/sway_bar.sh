# Date and time
date_and_week=$(date "+%Y/%m/%d (w%-V)")
current_time=$(date "+%H:%M")

# Battery or charger
battery_charge=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "percentage" | awk '{print $2}')
battery_status=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "state" | awk '{print $2}')

# Audio 
audio_volume=$(pamixer --sink `pactl list sinks short | grep RUNNING | awk '{print $1}'` --get-volume)
audio_is_muted=$(pamixer --sink `pactl list sinks short | grep RUNNING | awk '{print $1}'` --get-mute)

# multimedia
media_artist=$(playerctl --ignore-player=chromium metadata artist)
media_song=$(playerctl --ignore-player=chromium metadata title)
player_status=$(playerctl --ignore-player=chromium status)

# Network
network=$(ip route get 1.1.1.1 | grep -Po '(?<=dev\s)\w+' | cut -f1 -d ' ')
# interface_easyname grabs the "old" interface name before systemd renamed it
interface_easyname=$(dmesg | grep $network | grep renamed | awk 'NF>1{print $NF}')
ping=$(ping -c 1 www.google.es | tail -1| awk '{print $4}' | cut -d '/' -f 2 | cut -d '.' -f 1)

# systemload
loadavg_5min=$(cat /proc/loadavg | awk -F ' ' '{print $2}')

case $battery_status in
  discharging)
    battery='|⚠ $battery_pluggedin'
    ;;
  charging)
    battery='|⚡$battery_pluggedin'
    ;;
  *)
    battery=''
    ;;
esac

if ! [ $network ]
then
   network_active="⛔"
else
   network_active="⇆"
fi

if [ $player_status = "Playing" ]
then
    song_status='▶'
elif [ $player_status = "Paused" ]
then
    song_status='='
else
    song_status=''
fi

if [ $audio_is_muted = "true" ]
then
    audio_active='🔇'
else
    audio_active='🔊'
fi

song="🎧   $song_status  $media_artist - $media_song"
network="$network_active $interface_easyname ($ping ms)"
systemload="  $(echo $loadavg_5min | cut -d "." -f 2)%"
audio="$audio_active $audio_volume%$battery"
date_time=" $date_and_week ┇ 🕘 $current_time"

echo "$song  ┇  $network  ┇  $systemload  ┇  $audio  ┇  $date_time  "
