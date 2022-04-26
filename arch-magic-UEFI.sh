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
echo -e "${yellowColour}[+]${endColour}\t${grayColour}Desea Formatear la boot?[y/n]${endColour}" && read answer
if [[ $answer = y ]]; then
  mkfs.fat -F32 $disk_boot
else
  echo -e "${yellowColour}[+]${endColour}\t${grayColour} LA BOOT NO SE VA A FORMATEAR${endColour}"
fi

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
# el comando de sed entero, copia el script desde la parte 2 (porq dice #part2) en adelante y lo mete en el directorio
# /mnt/arch_install2.sh 
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit


#part2

ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
hwclock --systohc
echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" >> /etc/locale.conf
echo "KEYMAP=es" >> /etc/vconsole.conf

clear
echo -e "${yellowColour}Hostname? (machine name)?${endColour} "
read Hostname
echo "$Hostname" >> /etc/hostname

echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1	localhost" >> /etc/hosts
echo "127.0.1.1 $Hostname.localdomain $Hostname" >> /etc/hosts

clear
echo -e "${yellowColour}Elija una contraseña para el usuario root${endColour}"
passwd

# Instalación de Grub

pacman --noconfirm -S grub efibootmgr networkmanager network-manager-applet wireless_tools wpa_supplicant dialog os-prober base-devel linux-headers reflector git cups bluez bluez-utils xdg-utils xdg-user-dirs pulseaudio alsa-utils

grub-install --target=x86_64-efi --efi-directory=/Boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# habilitar servicios

systemctl enable NetworkManager
systemctl enable Bluetooth
systemctl enable org.cups.cupsd

# crear nuevo usuario

clear
echo -e "${yellowColour}Escriba su Nombre de Usuario${endColour}"
read Usuario
useradd -mG wheel $Usuario

clear
echo -e "${yellowColour}Elija contraseña para el usuario creado${endColour}"
passwd $Usuario
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers 
clear
