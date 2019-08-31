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



echo 'Установка базовой системы'

pacstrap /mnt base base-devel

arch-chroot / mnt sh -c " $ ( curl -fsSL https://git.io/base2.sh) "
