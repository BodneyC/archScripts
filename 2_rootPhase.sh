#!/bin/bash #################################################################
#---------------------------------------------------------------------------#
#-------Name: rootPhase.sh--------------------------------------------------#
#---------------------------------------------------------------------------#
#-------Info: This script concerns commands after the first reboot whilst---#
#-------------logged in as root, this is general system configuration and---#
#-------------X install and configuration.----------------------------------#
#---------------------------------------------------------------------------#
#-------NOTE: DO NOT JUST RUN THIS SCRIPT, IT WILL NOT WORK-----------------#
#---------------------------------------------------------------------------#
#############################################################################

# Keyboard
localectl set-keymap --no-convert uk
loadkeys gb

# Wireless
#ip link ### Get device name
#systemctl stop dhcpcd@<device-name>.service
#wifi-menu -o <device-name> { 		### NEEDS AUTOMATING
#	follow on-screen instr
#}
#if netctl start <profile>; then
#	netctl enable <profile>
#else
#	netctl status <profile>
#fi
systemctl start NetworkManager.service
systemctl enable NetworkManager.service

### Check connection
ping -c 3 google.co.uk
rc=$?
if [[ $rc -ne 0 ]]; then
    echo Web connection required
	exit 1
fi

# User control
echo "Username: "
read USERNAME
useradd -m -G wheel,users -s /bin/bash $USERNAME
echo -e "a\na" | (passwd --stdin ${USERNAME})
sed -i '/%wheel ALL=(ALL) ALL/s/^#//' /etc/sudoers

# Configure repos
sed -i 's/#\[multilib\]/\[multilib\]/' /etc/pacman.conf
sed -i '/\[multilib\]/{n;s/^#//}' /etc/pacman.conf
pacman -Sy # update repos

#Install X and ting
printf "1) Nvidia (Nouveau)\n2) AMD\n3) VirtualBox\n4) Intel\n0) None"

while true
do
    read choiceVar

    case $choiceVar in
        1)
            pacman -S --noconfirm xf86-video-nouveau mesa-libgl libvdpau-va-gl; 
            break;;
        2)
            pacman -S  --noconfirm xf86-video-ati mesa-libgl mesa-vdpau libvdpau-va-gl; 
            break;;
        3)
            pacman -S --noconfirm virtualbox-guest-{dkms,iso,modules,dkms,utils} lib32-mesa;
            system_ctl disable ntpd;
            system_ctl enable vboxservice; 
            break;;
        4)
            pacman -S --no-confirm xf86-video-intel lib32-mesa; 
            break;;
        *)
            echo "Incorrect choice, [0-4] please";;
    esac
done

if [[ $choiceVar -eq [1-4] ]]; then
	pacman -S --noconfirm xorg-server xorg-apps xorg-server-xwayland xorg-xinit xorg-xkill xorg-xinput xf86-input-libinput mesa
fi

# Laptop?
printf "1) Laptop\n2) Other"

while true
do
    read lapChoice

    case $lapChoice in
    1)
        pacman -S --noconfirm libinput; break;;
    *)
	    echo "Incorrect choice, [1-1]..."; break;;
    esac
done

# Audio configuration
pacman -S --noconfirm alsa-utils pulseaudio
amixer sset Master unmute
#----TESTING ALSA
# systemctl status alsa-state.service
# systemctl start alsa-state.service
# systemctl enable alsa-state.service

# XFCE4 installation
pacman -S --noconfirm xfce4 xfce4-goodies

#############################################################################
#-------------------Reboot and login as ${USERNAME}:a-----------------------#
reboot                                                                      #
#--------------------------Post-installation--------------------------------#
#------------------------------.dotfiles------------------------------------#
#############################################################################
