#!/bin/bash #################################################################
#---------------------------------------------------------------------------#
#-------Name: userPhase.sh--------------------------------------------------#
#---------------------------------------------------------------------------#
#-------Info: This script concerns commands after the creation of the main--#
#-------------user and the installation and configuration of a window-------#
#-------------manager. Personal touches and dotfile copying.----------------#
#---------------------------------------------------------------------------#
#-------NOTE: DO NOT JUST RUN THIS SCRIPT, IT WILL NOT WORK-----------------#
#---------------------------------------------------------------------------#
#############################################################################

mkdir -p ~/{gitclones,.vim,.tmux,.config/nvim,Documents/{Current,Programming/{CPP,bash,C,OpenMP,Go/{src,pkg,bin},LaTeX}}}

cd ~/gitclones

# Clones
git clone https://github.com/BodneyC/dotfiles.git
git clone https://github.com/BodneyC/vim-neovim-config.git

# Dotfiles
cd dotfiles
cp -r -t ~/ ./{.bashrc,.bash_aliases,.Xresources,.xinitrc,.bash_profile,multiplexing/{.tmux.conf,.tmux,.screenrc}} 
sed -i "/s/e\/\/D/e\/${USERNAME}\/D" profile
cp profile /etc/profile
cp local.conf /etc/fonts/
    # TMUX
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    # VIM/NVIM
cd ../vim-neovim-config
cp -r -t ~/{.vim,.config/nvim} config 
cp .vimrc ~/
cp init.vim ~/.config/nvim

# Vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
while true;
do
    read -p "Do you actually want to go through the ache of installing YCM? [y/n]" yn
    case $yn in
        [Yy]* ) 
            pacman -S --noconfirm build-essential clang cmake;
            vim +PlugInstall +quall && cd ~/.vim/plugged/YouCompleteMe/;
            ./install.py --clang-completer --system-libclang --gocode-completer;
            break;;
        [Nn]* ) echo "Good decision"; break;;
        * ) echo "Answer [y/n] pls";;
    esac
done
vim +PlugInstall

# nvim
mkdir -p ~/.config/nvim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall

# Xfce4-terminal colourschemes
cd ~/gitclones
git clone https://github.com/afg984/base16-xfce4-terminal.git
cp -r base16-xfce4-terminal/colorschemes/* /usr/share/xfce4/terminal/colorschemes/

# XFCE4 THEMES
cd dotfiles
tar -xvf Vertex_Maia.tar.gz
cp -r Vertex* /usr/share/themes
cd ..
wget https://dl.opendesktop.org/api/files/download/id/1461767736/90145-axiom.tar.gz
tar -xvf 90145-axiom.tar.gz
cp -r axiom* /usr/share/themes/

# XFCE4 FONT
	# DroidSans
wget https://www.fontsquirrel.com/fonts/download/droid-sans-mono
wget https://www.fontsquirrel.com/fonts/download/droid-sans
unzip droid-sans-mono
unzip droid-sans
cp DroidSansMono* /usr/share/fonts/TTF/

# XFCE4 ICONS
cd ~/gitclones/
git clone https://github.com/vinceliuice/vimix-icon-theme.git
cp -r vimix-icon-theme/{Paper-Vimix/,Vimix/} /usr/share/icons/
gtk-update-icon-cache /usr/share/icons/{Paper-Vimix,Vimix}

# Installing yaourt
echo "[archlinuxfr]\nSigLevel = Never\nServer = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf
pacman -Sy --noconfirm yaourt

# Additional apps
pacman -S atom htop firefox qbittorrent steam
yaourt -S discord spotify dropbox

# ZSH
while true;
do
    read -p "Install ZSH? [y/n]"
    case $yn in
        [Yy]* ) sh ~/gitclones/dotfile/inst-zsh.sh; break;;
        [Nn]* ) echo "Not installed"; break;;
        * ) echo "[y/n] please";;
    esac
done

# Alacritty
cd ~/gitclones
git clone https://aur.archlinux.org/alacritty-git.git
cd alacritty-git
makepkg -isr
