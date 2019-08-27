#!/bin/bash

echo 'Установка расскадки и шрифтов'
loadkeys ru
setfont cyr-sun16

echo 'Синхронизация системных часов'
timedatectl set-ntp true

echo 'Создание разделов'
(
	echo g;
	
	echo n;
	echo;
	echo;
	echo +550M;
	echo y;

	echo n;	
	echo;
	echo;
	echo +1024M;

	echo n;	
	echo;
	echo;
	echo +20G;

	echo n;	
	echo;
	echo;
	echo;

	echo t;	
	echo 1;
	echo 1;

	echo t;	
	echo 2;
	echo 19;
	
	echo w;
)	| fdisk /dev/sda

echo 'Ваша разметка диска'
fdisk -l

echo 'Форматирование и монтирование дисков'
mkfs.fat -F32 /dev/sda1
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi

mkfs.ext4 /dev/sda3
mount /dev/sda3 /mnt

mkswap /dev/sda2
swapon /dev/sda2

mkfs.ext4 /dev/sda4
mkdir /mnt/home
mount /dev/sda4 /mnt/home

echo 'Выбор зеркал для загрузки'
echo "Server = http://archlinux.ip-connect.vn.ua/$repo/os/$arch" > /etc/pacman.d/mirrorlist

echo 'Установка базовой системы'
pacstrap /mnt base base-devel

echo 'FSTAB'
genfstab -U -p /mnt >> /mnt/etc/fstab

echo 'Переход в систему'
arch-chroot /mnt /bin/bash

read -p "Введите имя компьютера: " hostname
read -p "Введите имя пользователя: " username

echo 'Прописываем имя компьютера'
echo $hostname > /etc/hostname
ln -svf /usr/share/zoneinfo/Europe/Kiev /etc/localtime

echo 'Добавляем русскую локаль системы'
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_UA.UTF-8 UTF-8" >> /etc/locale.gen 

echo 'Указываем язык системы'
echo 'LANG="ru_UA.UTF-8"' > /etc/locale.conf

echo 'Вписываем KEYMAP=ru FONT=cyr-sun16'
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

echo 'Обновим текущую локаль системы'
locale-gen

echo 'Создадим загрузочный RAM диск'
mkinitcpio -p linux

echo '3.5 Устанавливаем загрузчик'
pacman -Syy
pacman -S grub efibootmgr --noconfirm 
grub-install /dev/sda

echo 'Обновляем grub.cfg'
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Ставим программу для Wi-fi'
pacman -S dialog wpa_supplicant --noconfirm 

echo 'Добавляем пользователя'
useradd -m -g users -G wheel -s /bin/bash $username

echo 'Создаем root пароль'
passwd

echo 'Устанавливаем пароль пользователя'
passwd $username

echo 'Устанавливаем SUDO'
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy

echo 'Ставим иксы'
pacman -S xorg xorg-xinit plasma-desktop sddm  --noconfirm



echo 'Ставим шрифты'
pacman -S ttf-liberation ttf-dejavu --noconfirm 

echo 'Ставим сеть'
pacman -S networkmanager  --noconfirm

systemctl enable sddm NetworkManager

