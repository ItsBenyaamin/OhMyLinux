#!/bin/bash

echo -e "  ___  _     __  __       _     _\n / _ \| |__ |  \/  |_   _| |   (_)_ __  _   ___  __\n| | | | '_ \| |\/| | | | | |   | | '_ \| | | \ \/ /\n| |_| | | | | |  | | |_| | |___| | | | | |_| |>  <\n \___/|_| |_|_|  |_|\__, |_____|_|_| |_|\__,_/_/\_\ \n                    |___/"
echo "Install programs, configs and dotFiles of mine"
echo "It's for ArchLinux & Hyprland"
echo "---------------------"
###############################
# Colors
###############################
green='\033[0;32m'
boldWhite='\033[1;37m'
boldBlue='\033[1;34m'
yellow='\033[0;33m'
noColor='\033[0m'

sleep 0.5

###############################
# Installing programs
###############################
pacmanPrograms=""
aurPrograms=""

need_to_install() {
    local app="$1"
    #if [[ ! -n "$(command -v $app)" ]]; then
    if pacman -Qs $app >/dev/null; then
        echo -e "${boldWhite}> ${app} ${green}already Installed${noColor}"
        return 1
    else
        echo -e "${boldWhite}> ${app} ${yellow}is not installed.${noColor}"
        return 0
    fi
}

# Check for Pacman programs
echo -e "${boldBlue}> Check for ${boldWhite}Pacman${noColor} ${boldBlue}installations...${noColor}"
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if need_to_install "${line}"; then
        pacmanPrograms="${pacmanPrograms}${line} "
    fi
done <pacman.txt

# Install pacman packages
if [[ -n $pacmanPrograms ]]; then
    sudo pacman -S --needed --noconfirm $pacmanPrograms
fi

# Check for AUR programs
echo -e "${boldBlue}> Check for ${boldWhite}AUR${noColor} ${boldBlue}installations...${noColor}"
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if need_to_install "${line}"; then
        aurPrograms="${aurPrograms}${line} "
    fi
done <aur.txt

# Install yay
if [[ ! -n "$(command -v yay)" ]]; then
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si
    cd ..
    rm -rf yay-bin
fi

# Install AUR packages with yay
if [[ -n $aurPrograms ]]; then
    yay -S --noconfirm $aurPrograms
fi

# Install Zed editor
if [[ ! -n "$(command -v zed)" ]]; then
    curl -f https://zed.dev/install.sh | sh
fi

sleep 0.5
###############################
# Change shell, installing zsh plugins
###############################
currentShell="$SHELL"
if [ $currentShell == "/usr/bin/zsh" ]; then
    echo -e "${boldWhite}> Shell is Already changed to Zsh.${noColor}"
else
    echo -e "${boldBlue}> Changing shell to zsh...${noColor}"
    while ! chsh -s $(which zsh); do
        echo -e "${red}ERROR: Authentication failed. Please enter the correct password.${noColor}"
        sleep 1
    done
    echo -e "${green}> Shell Changed.${noColor}"

    echo -e "${boldBlue}> Installing ohMyPosh...${noColor}"
    curl -s https://ohmyposh.dev/install.sh | bash -s

    echo -e "${boldBlue}> Installing OhMyZsh...${noColor}"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        cp ~/.config/ml4w/tpl/.zshrc ~/
    else
        echo -e "${green}> Already installed.${noColor}"
    fi

    echo -e "${boldBlue}> Installing zsh-autosuggestions...${noColor}"
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    else
        echo -e "${green}> Already installed.${noColor}"
    fi

    echo -e "${boldBlue}> Installing zsh-syntax-highlighting...${noColor}"
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    else
        echo -e "${green}> Already installed.${noColor}"
    fi

    echo -e "${boldBlue}> Installing fast-syntax-highlighting...${noColor}"
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting" ]; then
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
    else
        echo -e "${green}> Already installed.${noColor}"
    fi
fi

###############################
# Pre Configuring
###############################
mapfile -t configsList < <(find "configs/.config" -maxdepth 1 -mindepth 1 -printf "%f\n")
mapfile -t dotfilesList < <(find "dotfiles" -maxdepth 1 -mindepth 1 -printf "%f\n")

rm $HOME/.config/helpers
rm -rf $HOME/.config/hypr

for name in "${configsList[@]}"; do
    dest="${HOME}/.config/${name}"
    if [ -e "$dest" ]; then
        rm -rf $dest
    fi
done

for name in "${dofilesList[@]}"; do
    dest="${HOME}/${name}"
    if [ -e $dest ]; then
        rm -rf $dest
    fi
done

###############################
# Configuring
###############################
create_link() {
    local -n entries=$1
    local dir="$2"
    local dest="$3"
    for name in "${entries[@]}"; do
        ln -s "$dir/$name" $dest
    done
}

echo -e "${boldBlue}> Create link for helpers...${noColor}"
ln -s "${PWD}/helpers" "${HOME}/.config/"

echo -e "${boldBlue}> Create link for dotfiles...${noColor}"
create_link dotfilesList "${PWD}/dotfiles" $HOME

echo -e "${boldBlue}> Create link for configs...${noColor}"
create_link configsList "${PWD}/configs/.config" "${HOME}/.config"

###############################
# Post Configuration
###############################
ADD_LOCAL_BIN_TO_PATH="export PATH=\$PATH:$HOME/.local/bin"
echo -e "${boldBlue}> Post configuration...${noColor}"
echo "source ~/.benshrc" >>~/.zshrc
grep -q -x -F "$ADD_LOCAL_BIN_TO_PATH" ~/.zshrc
IsLocalBinExistInZshrc=$? # 0=true 1=false

echo -e "${boldBlue}> Check if [$HOME/.local/bin] exist in PATH${noColor}"
if [[ ":PATH:" != *":$HOME/.local/bin:"* ]]; then
    if [[ $IsLocalBinExistInZshrc == 1 ]]; then
        echo -e "${yellow}> Adding to PATH${noColor}"
        echo $ADD_LOCAL_BIN_TO_PATH >>~/.zshrc
    fi
else
    echo -e "${green}> PATH contains it${noColor}"
fi

go env -w GOPATH=/home/ben/.local/golang/
rustup default stable

# configure keyd to map copilet button to right ctrl
sudo cp -f configs/keyd.conf /etc/keyd/default.conf
sudo systemctl enable keyd --now
