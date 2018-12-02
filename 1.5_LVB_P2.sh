#!/bin/bash #################################################################
#---------------------------------------------------------------------------#
#-------Name: LVB_P2.sh-----------------------------------------------------#
#---------------------------------------------------------------------------#
#-------Info: LVB phase two, once chrooted----------------------------------#
#---------------------------------------------------------------------------#
#-------NOTE: DO NOT JUST RUN THIS SCRIPT, IT WILL NOT WORK-----------------#
#---------------------------------------------------------------------------#
#############################################################################

# Locale Config
sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/g' /et/locale.gen
locale-gen
echo LANG=en_GB.UTF-8 > /etc/locale.conf
echo export KEYMAP=uk >> /etc/vconsole.conf

# TimeZone
echo Europe/London >> /etc/timezone
ln -s /usr/share/zoneinfo/Europe/London > /etc/localtime
sed -i '/#NTP=/d' /etc/systemd/timesyncd.conf
sed -i 's/#Fallback//' /etc/systemd/timesyncd.conf
echo \"FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org\" >> /etc/systemd/timesyncd.conf
hwclock --systohc --utc

# Additional tools
pacman -S --noconfirm dialog wpa_suppliant wireless_tools grub os-prober iw sudo bash-completion gvim git rofi p7zip wget unzip neovim networkmanager network-manager-applet reflector

# Boot Loader
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Host Info
read -p "Hostname: " HOSTNAME
echo $HOSTNAME > /etc/hostname
echo Enter root passwd\n
passwd 

# User
read "USERNAME?Username: "
useradd $USERNAME
echo $USERNAME password: 
passwd $USERNAME
usermod -aG wheel,users $USERNAME
mkdir /home/$USERNAME
chown ${USERNAME}:${USERNAME} /mnt/$USERNAME
sed -i 's/# \(%wheel ALL=(ALL) ALL\)$/\1/' /etc/sudoers

exit
