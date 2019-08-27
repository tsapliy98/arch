#!/bin/bash

loadkeys ru
setfont cyr-sun16

timedatectl set-ntp true

echo "Создание разделов"
(
    echo d;
    echo;
    
    echo g;
    
    echo n;
    echo;
    echo;
    echo;
    echo +512M;
    
    echo n;
    echo;
    echo;
    echo;
    echo +1024M;
    
    echo n;
    echo;
    echo;
    echo;
    echo +20G;
    
    echo n;
    echo;
    echo;
    echo;
    echo;
    
    echo w;
)   |   fdisk /dev/sda

echo "Форматирование дисков"
mkfs.vfat /dev/sda1 -L boot
mkswap /dev/sda2 -L swap
mkfs.ext4 /dev/sda3 -L root
mkfs.ext4 /dev/sda4 -L home

echo "Монтирование дисков"
mount /dev/sda3 /mnt
swapon /dev/sda2 
mkdir -p /mnt/boot/efi
mkdir -p /mnt/home
mount /dev/sda1 /mnt/boot/efi
mount /dev/sda4 /mnt/home

echo "Выбор зеркал"
echo "Server = http://archlinux.ip-connect.vn.ua/$repo/os/$arch" > /etc/pacman.d/mirrorlist

echo "Ставим основные пакеты"
pacstrap /mnt base base-devel

echo "fstab"
genfstab -pU /mnt >> /mnt/etc/fstab


arch-chroot /mnt sh -c "$(curl -fsSL git.io/arch2.sh)"


    
    
    