#!/bin/bash
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

for i in `ls "$SCRIPTPATH/dotfiles"`; {
  ln -fsv "$SCRIPTPATH/dotfiles/$i" "$HOME/.$i"
}

mkdir -p "$HOME/.config"

for i in `ls "$SCRIPTPATH/config"`; {
  # FIXME: when is first time will show a error
  rm -vr "$HOME/.config/$i"
  ln -fsv "$SCRIPTPATH/config/$i" "$HOME/.config/$i"
}

# Instal OhMyZSH and theme
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
wget -O /home/shiryel/.oh-my-zsh/themes/bullet-train.zsh-theme https://raw.githubusercontent.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme
