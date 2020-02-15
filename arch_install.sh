#!/bin/bash
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
devBase=$1

if [[ $# -eq 0 ]]; then
  echo "plz insert the device name"
  exit 1
fi

if [[ `ping archlinux.org -c 1` ]]; then
  echo "network ok"
else
  echo "network fail"
  exit 1
fi

preChroot() {
loadkeys us-acentos
timedatectl set-ntp true

sgdisk --zap-all "$devBase"
partprobe "$devBase"

sgdisk -g "$devBase"
partprobe "$devBase"

# MORE IN: https://fitzcarraldoblog.wordpress.com/2017/02/10/partitioning-hard-disk-drives-for-bios-mbr-bios-gpt-and-uefi-gpt-in-linux/

# typecodes:
# ef02 -> EFI System
# 8304 -> Linux x86-64 root
# 8305 -> Linux ARM64 root
# 8200 -> Linux swap
# 8302 -> Linux /home

# OLD
#sgdisk -o "$devBase"
#sgdisk --new=1:0:+550M --typecode=1:ef02 "$devBase"
#sgdisk --new=2:0:+32G --typecode=2:8304 "$devBase"
#sgdisk --new=3:0:+12G --typecode=3:8200 "$devBase"
#sgdisk --new=4:0:100% --typecode=4:8302 "$devBase"

parted "$devBase" --script -- mklabel gpt
parted "$devBase" --script -- mkpart ESP fat32 '0%' 512MiB
parted "$devBase" --script -- name 1 boot
parted "$devBase" --script -- set 1 boot on

parted "$devBase" --script -- mkpart primary linux-swap -8GiB '100%'
parted "$devBase" --script -- name 2 swap
parted "$devBase" --script -- set 2 swap on
parted "$devBase" --script -- set 2 hidden on

parted "$devBase" --script -- mkpart primary 512MiB -8GiB
parted "$devBase" --script -- name 3 root

mkfs.vfat "$devBase"1
mkswap "$devBase"2
swapon "$devBase"2
mkfs.ext4 "$devBase"3

mount "$devBase"3 /mnt
mkdir -p /mnt/boot
mount "$devBase"1 /mnt/boot

pacstrap /mnt base base-devel

genfstab -U /mnt >> /mnt/etc/fstab

mkdir -p /mnt/chroot
cp $SCRIPT /mnt/chroot/arch-install.sh
arch-chroot /mnt /usr/bin/bash /chroot/arch-install.sh $devBase --chroot
}

posChroot() {
  ln -sf /usr/share/zoneinfo/Brazil/East /etc/localtime
  hwclock --systohc # Para gerar o /etc/adjtime // ele assume que o relogio do hardware é UTC

  echo "LANG=en_US.UTF-8" >> /etc/locale.conf
  echo "KEYMAP=us-acentos" >> /etc/vconsole.conf
  echo "en_US.UTF=8 UTF-8" >> /etc/locale.gen
  locale-gen

  mkinitcpio -p linux

  # Se usar processador intel:
  if [[ 0 -lt `lspci | grep -c Intel` ]]; then
    pacman --noconfirm -S intel-ucode
  fi
  pacman --noconfirm -S grub efibootmgr # necessario para o funcionamento do grub
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub
  grub-mkconfig -o /boot/grub/grub.cfg

  pacman --noconfirm -S wpa_supplicant dialog
  pacman --noconfirm -S bash-completion

  useradd -m -g users -G log,sys,wheel,rfkill,dbus -s /bin/bash vinicius

  sed -i '/%wheel ALL=(ALL) ALL/s/^#//' /etc/sudoers
  
  echo "root password"
  passwd
  echo "user password"
  passwd vinicius
  rm -rf /chroot
}

if [[ $2 == "--chroot" ]]; then
  posChroot
else
  preChroot
fi
