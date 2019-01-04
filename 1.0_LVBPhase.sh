#!/bin/bash #################################################################
#---------------------------------------------------------------------------#
#-------Name: LVBPhase.sh---------------------------------------------------#
#---------------------------------------------------------------------------#
#-------Info: Work-in-progress shell script for setting up Arch linux-------#
#------------ from boot of live-media to completion. Whilst incomplete,-----#
#------------ this can be used as a guide (specifically for my setup I------#
#-------------suppose) in purley command form.------------------------------#
#---------------------------------------------------------------------------#
#-------NOTE: DO NOT JUST RUN THIS SCRIPT, IT WILL NOT WORK-----------------#
#---------------------------------------------------------------------------#
#############################################################################

# /dev/sdx
fdisk -l
read -p "Installation drive: /dev/" INST_DRIVE

# Check internet connection
ping -c 3 google.co.uk
rc=$?
if [[ $rc -ne 0 ]]; then
	echo "Internet connection required"
	exit 1
fi

# Partition prep
echo "mklabel msdos" > ./parted.txt
read -p "What percent of the disk should be /" ROOT_SZ
echo "mkpart primary ext4 1MiB ${ROOT_SZ}%" >> ./parted.txt
echo "set 1 boot on" >> ./parted.txt
read -p "What percent of the disk should be /home" HOME_SZ
echo "mkpart primary ext4 ${ROOT_SZ}% $(($HOME_SZ + $ROOT_SZ))%" >> parted.txt
echo "mkpart primary linux-swap $(($HOME_SZ + $ROOT_SZ))% 100%" >> parted.txt
echo "quit" >> parted.txt
parted /dev/${INST_DRIVE} < parted.txt
mkfs.ext4 /dev/${INST_DRIVE}1
mkfs.ext4 /dev/${INST_DRIVE}2
mkswap /dev/${INST_DRIVE}3
swapon /dev/${INST_DRIVE}3

# Mounting
mkdir /mnt/home
mount /dev/${INST_DRIVE}1 /mnt
mount /dev/${INST_DRIVE}2 /mnt/home

# Mirror list
grep -A 1 "## United Kingdom" --group-separator "" /etc/pacman.d/mirrorlist > /etc/pacman.d/mirrorlist.BAK && grep -A 1 -n "## United Kingdom" /etc/pacman.d/mirrorlist | sed -n 's/^\([0-9]\{1,\}\).*/\1d/p' | sed -f - /etc/pacman.d/mirrorlist >> /etc/pacman.d/mirrorlist.BAK
mv /etc/pacman.d/mirrorlist.BAK /etc/pacman.d/mirrorlist

# Install base system
yes "" | pacstrap -i /mnt base base-devel

# Fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Move LVB 1.5 to mount place
cp 1.5_LVB_P2.sh /mnt/home

#############################################################################
#---------------------------Chroot into system------------------------------#
arch-chroot /mnt                                                           #
#-------------------------Script needs splitting----------------------------#
#############################################################################

#############################################################################
#-------------------------Exit chroot and reboot----------------------------#
#-----------------------Remove installation media---------------------------#
# exit                                                                      #
umount -R /mnt                                                              #
shutdown now                                                                #
#--------------------------Boot; Login [root:a]-----------------------------#
#-------------------------Script needs splitting----------------------------#
#############################################################################
