#!/bin/bash 

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

echo 'Устанавливаем загрузчик'
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
pacman -S xorg xorg-xinit i3-wm 

echo 'Ставим шрифты'
pacman -S ttf-liberation ttf-dejavu --noconfirm 

echo 'Ставим сеть'
pacman -S networkmanager 

systemctl enable NetworkManager
