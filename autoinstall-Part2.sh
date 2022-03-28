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
echo "::    localhost" >> /etc/hosts
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
EDITOR=nano visudo
clear
