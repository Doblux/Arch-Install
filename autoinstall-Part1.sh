#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# MIRRORLIST, TIEMPO Y SINCRONIZACION DE REPOSITORIO PACMAN

loadkeys es
timedatectl set-ntp true
pacman -Syyy
pacman -S --noconfirm reflector
reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syyy
clear

# ALMACENAR VARIABLES DE DISCO

lsblk
echo -e "${yellowColour}[+]${endColour}\t${grayColour}What is your disk (only name (example: nvme0n1))?${endColour}"
read disk
cfdisk /dev/$disk

clear
lsblk
echo -e "${yellowColour}[+]${endColour}\t${grayColour}Nombre de su Boot Partition (poner completo /dev/name...)${endColour}"
read disk_boot

clear
lsblk
echo -e "${yellowColour}[+]${endColour}\t${grayColour}Nombre de su Swap Partition (poner completo /dev/name...)(si no hay swap dejar en blanco)${endColour}"
read disk_swap

clear
lsblk
echo -e "${yellowColour}[+]${endColour}\t${grayColour}Nombre de su Linux Filesystem Partition (poner completo /dev/name...)${endColour}"
read disk_Linux_File_System

# FORMATEO COMPLETO Y ACTIVAR LA SWAP
mkfs.fat -F32 $disk_boot

if [[ $disk_swap = "" ]]; then
  echo -e "${yellowColour}[+]${endColour}\t${grayColour}NO HAY SWAP, PASANDO A LA SIGUIENTE FASE${endColour}"
  sleep 2
else
	mkswap $disk_swap
	swapon $disk_swap
fi

mkfs.ext4 $disk_Linux_File_System

# MONTAR LAS PARTICIONES

mount $disk_Linux_File_System /mnt
mkdir /mnt/Boot
mount $disk_boot /mnt/Boot

# INSTALACIÓN BASE

pacstrap /mnt base linux linux-firmware nano

# Fichero FSTAB

genfstab -U /mnt >> /mnt/etc/fstab

# Arch-Chroot
arch-chroot /mnt
