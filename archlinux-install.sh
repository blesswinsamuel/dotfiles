#!/usr/bin/env bash

####################
# Pre-installation #
####################

## Connect to WiFi and enable ssh
wifi-menu
passwd
systemctl enable sshd.socket

## Verify the boot mode
# If UEFI mode is enabled on an UEFI motherboard, Archiso will boot Arch Linux accordingly via systemd-boot. To verify this, list the efivars directory:
ls /sys/firmware/efi/efivars
# System booted in BIOS/CSM mode if directory doesn't exist

## Connect to the Internet
wifi-menu # for WiFi connection
curl archlinux.org

## Update the system clock
timedatectl set-ntp true
timedatectl status

## Partition the disks
fdisk -l
fdisk /dev/sda
# Type "n" for a new partition. Type in "p" for a primary partition and select the partition number.
# The First sector is automatically selected and you just need to press Enter. For Last sector, type the size you want to allocate for this partition.
# Create two more partitions similarly for home and swap, and press "w" to save the changes and exit.

parted /dev/sda
# run `mklabel msdos` to setup a new MBR/msdos partition (why not mklabel gpt? this is because VirtualBox offers an BIOS system)
# run `mkpart primary ext4 0% 100%`, `set 1 boot on`, and `quit`

# or
cfdisk /dev/sda
# Choose dos label type
# [New] to create partition, [primary] partition size, select [Bootable], [Write]
# or
cgdisk /dev/sda

# Verify that partitions are created
fdisk -l

## Format the partitions
mkfs.ext4 /dev/sda1
# For separate swap partition
mkswap /dev/sda3
swapon /dev/sda3

## Mount the file systems
mount /dev/sda1 /mnt
# genfstab will later detect mounted file systems and swap space.

# Create mount points for any remaining partitions and mount them accordingly:
# mkdir /mnt/boot
# mount /dev/sda2 /mnt/boot

################
# Installation #
################

## Select the mirrors
# Packages to be installed must be downloaded from mirror servers, which are defined in /etc/pacman.d/mirrorlist.
# The higher a mirror is placed in the list, the more priority it is given when downloading a package. You may want to edit the file accordingly, and move the geographically closest mirrors to the top of the list, although other criteria should be taken into account.

## Install the base packages
pacstrap /mnt base base-devel


########################
# Configure the system #
########################

## Generate an fstab file
genfstab -U /mnt >> /mnt/etc/fstab

## Change root into the new system
arch-chroot /mnt

## Set the time zone
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
# Run hwclock to generate /etc/adjtime
hwclock --systohc

## Localization
# Uncomment en_US.UTF-8 UTF-8 and other needed locales in /etc/locale.gen, and generate them with:
sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

## Network configuration
echo "arch-bless" > /etc/hostname

## Networking 
# For LAN
# systemctl enable dhcpcd
# For WiFi
# pacman -S --needed --noconfirm iw wpa_supplicant dialog wpa_actiond
# wifi-menu
# systemctl enable netctl-auto

## Set the root password
passwd

## Add user
USERNAME=arch
useradd --create-home ${USERNAME}
passwd ${USERNAME}
echo "${USERNAME} ALL=(ALL) ALL" | tee -a "/etc/sudoers"

## Install boot loader
pacman --noconfirm -S grub
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# For dual boot - https://lampjs.wordpress.com/2017/01/19/easy-installing-arch-linux-dual-boot-with-windows-uefi-or-mbr-for-beginners/
pacman --noconfirm -S efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Enable microcode updates
pacman -S --needed --noconfirm intel-ucode
grub-mkconfig -o /boot/grub/grub.cfg

# Install SSH
pacman -S --needed --noconfirm openssh
systemctl enable sshd.socket

###
# Reboot
###
exit
umount -R /mnt
swapoff /dev/sda5
reboot


mount /dev/sda6 /mnt
mount /dev/sda2 /mnt/boot
arch-chroot /mnt
exit
umount -R /mnt
swapoff /dev/sda5
reboot


#####################
# Post-installation #
#####################

# For virtualbox
pacman -S --needed --noconfirm virtualbox-guest-utils

# Intel graphics driver
pacman -S --needed --noconfirm xf86-video-intel

# input driver
pacman -S --needed --noconfirm xf86-input-libinput

# nmcli dev wifi con "EL-BETHEL" password "1502301195"
