#/bin/bash

loadkeys es
clear

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


lsblk
echo -e "\n${greenColour}[+]${endColour}\t${yellowColour}Indtroduzca el nombre del disco duro / ssd (ejemplo: sda)${endColour}"
read -p disk
cfdisk /dev/$disk


clear
echo -e "\n${greenColour}[+]${endColour}\t${yellowColour} nombre de su particion boot (solo nombre ejemplo: sda1)${endColour}"
read -p disk_boot

clear
echo -e "\n${greenColour}[+]${endColour}\t${yellowColour} nombre de su particion swap (dejar en blanco si no hay) (ejemplo: sda3)${endColour}"
read -p disk_swap

clear
echo -e "\n${greenColour}[+]${endColour}\t${yellowColour} nombre de su particion del tipo: Linux File System (ejemplo: sda2)${endColour}"
read -p disk_Linux_File_System


# formateo de particiones
mkfs.vfat -F 32 /dev/$disk_boot
mkfs.ext4 /dev/$disk_Linux_File_System

if [[ $disk_swap -ne "" ]]; then
  mkswap /dev/$disk_swap
  swapon /dev/$disk_swap
fi


mount /dev/$disk_Linux_File_System /mnt
mkdir /mnt/boot
mount /dev/$disk_boot /mnt/boot

pacstrap /mnt linux linux-firmware networkmanager grub wpa_supplicant base base-devel

genfstab -U /mnt > /mnt/etc/fstab

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
echo -e "\n${greenColour}[+]${endColour}\t${yellowColour}Hostname? (machine name)?${endColour}\n"
read Hostname
echo "$Hostname" >> /etc/hostname

echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1	localhost" >> /etc/hosts
echo "127.0.1.1 $Hostname.localdomain $Hostname" >> /etc/hosts

clear
echo -e "\n${greenColour}[+]${endColour}\t${yellowColour}Elija una contraseña para el usuario root${endColour}\n"
passwd

###### Instalacion del grub

grub-install /dev/$disk
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

clear
echo -e "\n${greenColour}[+]${endColour}\t${yellowColour}Escriba su Nombre de Usuario${endColour}\n"
read Usuario
useradd -mG wheel $Usuario

clear
echo -e "\n${greenColour}[+]${endColour}\t${yellowColour}Elija contraseña para el usuario creado${endColour}\n"
passwd $Usuario
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers 
clear

