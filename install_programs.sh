#!/bin/bash

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# Mantain the sudo allong the script
sudo -v
$SCRIPTPATH/src/sudo_manager.sh &

## EXEC AS ROOT
if ! grep -Fxq "[multilib]" /etc/pacman.conf; then
	sudo echo '[multilib]' >> /etc/pacman.conf
	sudo echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
	sudo pacman -Syu
fi

#############
# FUNCTIONS #
#############

sudo_exec_command() {
	for i in "$@"; {
		sudo $i
	}
}

exec_command() {
	for i in "$@"; {
		$i
	}
}

install_pac() {
	sudo pacman --needed --noconfirm -S $@
}

install_opt() {
	sudo pacman --needed --noconfirm --asdeps -S $@
}

install_aur() {
	mkdir -p aur
	cd aur
	for i in "$@"; {
		git clone "https://aur.archlinux.org/$i.git"
		cd "$i"
		makepkg -si --needed --noconfirm
		cd ..
	}
	cd "$SCRIPTPATH"
}

########
# BASE #
########

base=(
"linux-lts"
"linux-lts-headers"
"dhcpcd"
"xwayland"
"weston"

# graphic cards #
"vulkan-icd-loader"
"lib32-vulkan-icd-loader"
"vulkan-radeon"
"amdvlk"

# base for scripts #
"kitty"
"img"
"playerctl" # works with cmus
"pamixer" # like amixer for alsa, but for pulseaudio
"rofi" # Window switcher, run dialog, ssh-launcher and dmenu

# thumbs on dolphin #
"kdegraphics-thumbnailers"
"ffmpegthumbs"
"taglib"
"kdesdk-thumbnailers"
"qt5ct" # to choose the theme

# dev #
"node"
"yarn"

# good existences #
"man"
"ttf-freefont"
"ttf-arphic-uming"
"ttf-baekmuk"
"ntfs-3g"

# Plugins for alsa
"alsa-oss"
"alsa-lib"

# Codecs
"a52dec"
"faac"
"faad2"
"flac"
"jasper"
"lame"
"libdca"
"libdv"
"libmad"
"libmpeg2"
"libtheora"
"libvorbis"
"libxv"
"wavpack"
"x264"
"xvidcore"
)

install_pac ${base[*]}

############
# PROGRAMS #
############

programs=(
"zsh"
"zsh-theme-powerlevel9k"
"neovim"
"ranger"
"cmus"
"pandoc"
"openssh"
"git"
"libreoffice"
"youtube-dl"
"android-file-transfer"
"libmtp"
"xreader"
"firefox"
"wget" # web downloads
"tree"
)

deps_programs=(
## noto-fonts and ttf-roboto deps
"noto-fonts-cjk"
"noto-fonts-emoji"
"noto-fonts-extra"

## neovim
"python2-neovim"
"python-neovim"
"xclip"
"xsel"

## pandoc
#"pandoc-citeproc"
#"pandoc-crossref"
"texlive-core"
)

install_pac ${programs[*]}
install_opt ${deps_programs[*]}

############
# NOTEBOOK #
############

notebook=(
"xf86-input-synaptcs" # touchpad driver
"network-manager-applet" # graphy network manager
"acpilight" # brightness for laptops

## Bluetooth
"bluez"
"blueman"
"bluez-utils"

## Printer
"ghostscript"
"cups"
"gsfonts"
"gutenprint"
"libcups"
"hplip"
"system-config-printer"
"gufw" # firewall
"linux-lts"
"linux-lts-headers" # optional
)

sudo_commands_notebook=(
"systemctl enable bluetooth" "systemctl start bluetooth"
"systemctl enable org.cups.cupsd.service" "systemctl start org.cups.cupsd.service"
"systemctl enable ufw.service" "systemctl start ufw.service"
"mkinitcpio -p linux-lts" "grub-mkconfig -o /boot/grub/grub.cfg"
"chmod 666 /sys/class/backlight/*/brightness"
)

# IF YOU ARE USING A NOTEBOOK UNCOMMENT THIS LINES:
#install_pac ${notebook[*]}
#sudo_exec_command "${sudo_commands_notebook[@]}"

#######
# AUR #
#######

aur=(
"nerd-fonts-complete" # Or exec only SourceCodePro-install.sh in .src/
"wlroots-git"
"sway-git"
"swaybg-git"
"preload"
"godot"
)

sudo_commands_aur=(
"systemctl enable preload"
"systemctl start preload"
)

commands_aur=(
"fc-cache -vf"
)

install_aur ${aur[*]}
sudo_exec_command "${sudo_commands_aur[@]}"
exec_command "${commands_aur[@]}"

#############
# OH MY ZSH #
#############

# ZSH COMMANDS
# https://github.com/ohmyzsh/ohmyzsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# https://github.com/zsh-users/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# https://github.com/zsh-users/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# https://github.com/caiogondim/bullet-train.zsh
wget https://raw.githubusercontent.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme -O ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/bullet-train.zsh-theme

##########
# OTHERS #
##########

## my nvim
cd ~/.config
git clone https://github.com/vinicius-molina/neoVim-configs.git
mv neoVim-configs nvim
cd nvim

# Install dotfiles
sudo $SCRIPTPATH/install_dotfiles.sh
cd "$SCRIPTPATH"

rm "$SCRIPTPATH"/src/sudo_status.txt
