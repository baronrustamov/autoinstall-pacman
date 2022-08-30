#!/bin/bash
CONFIG_DIR="~/.config"

if [ $(logname) == "root" ]; then
    echo "User logged in as root, It is unsafe to run the program in root"
fi
if [ $USER != "root" ]; then
    echo "Program must be run with sudo"
fi
username=$(logname)

pre-requisites() {
    pacman -Sy --noconfirm git openssh
}

AUR() {
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay
    cd /tmp/yay; makepkg -sci --noconfirm; cd -
}

Packages() {
    cat ./packages.txt | while read -r line; do
        echo "Installing $line"
        sudo -u $username yay -Sy --needed --noconfirm $line 
        echo "$line Installed"
    done
}

Environment() {
    pacman -Sy sway swaybg swayidle swaylock waybar sddm ranger --noconfirm
}

Browser() {
    pacman -Sy firefox-developer-edition --noconfirm
    sudo -u $username timeout 10s firefox-developer-edition --headless --first-startup
    killall "firefox" "firefox-bin" "firefox-developer-edition" || true

    HomeDIR="~/.mozilla/firefox"
    release=$(sed -n "2p" ${HomeDIR}/installs.ini)
    release=$(echo $release | sed 's/^Default=//')
    cd "${HomeDIR}/${release}"; git clone https://github.com/MichaelPetersen22/asimov-firefox-css .; cd -
}

Shell() {
    pacman -Sy fish --noconfirm
    chsh -S /bin/fish
}

Terminal() {

}

Config() {
    systemctl enable sddm, firewalld
    git clone https://github.com/MichaelPetersen22/dotfiles ~/.config/dotfiles
    mv -rf ~/.config/dotfiles/* ~/.config/
}

Styles() {
    git clone https://github.com/vinceliuice/Fluent-gtk-theme /tmp/fluent
    git clone https://github.com/vinceliuice/Tela-icon-theme /tmp/tela
    cd /tmp/fluent; ./install.sh -c dark -n Fluent-Dark; cd -
    cd /tmp/tela; ./install.sh -c standard; cd -
}

GRUB() {
    pacman -Sy os-prober --noconfirm
    mount /dev/nvme0n1p1 /mnt
    git clone https://github.com/vinceliuice/grub2-themes /tmp/grub
    cd /tmp/grub; ./install.sh -t tela -i color -s 4k; cd -
}

pre-requisites
AUR
Packages
Environment
Browser
Shell
Terminal
Config
Styles
GRUB