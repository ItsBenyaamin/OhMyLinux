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
# Helper Functions
###############################
need_to_install() {
    local app="$1"
    if pacman -Q $app >/dev/null; then
        echo -e "${boldWhite}> ${app} ${green}already Installed${noColor}"
        return 1
    else
        echo -e "${boldWhite}> ${app} ${yellow}is not installed.${noColor}"
        return 0
    fi
}

file_contains() {
    local sentence="$1"
    local file=$2
    if [[ $(grep $sentence $file) ]] ; then
       return 0
    else
       return 1
    fi
}

file_exists() {
    local file=$1
    if [ -f file ]; then
        return 1
    else
	return 0
    fi
}

create_link() {
    local -n entries=$1
    local dir="$2"
    local dest="$3"
    for name in "${entries[@]}"; do
        ln -s "$dir/$name" $dest
    done
}

###############################
# Installing programs
###############################
pacmanPrograms=""
aurPrograms=""

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
    sudo pacman -Syu --needed --noconfirm $pacmanPrograms
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


# Install latest node lts
if file_exists /usr/share/nvm/init-nvm.sh;then
    if [[ ! -n "$(command -v zed)" ]]; then
        echo -e "${boldWhite}> Install latest lts version.${noColor}"
        source /usr/share/nvm/init-nvm.sh
        nvm install --lts
    fi
fi

sleep 0.5
###############################
# Change shell, installing zsh plugins
###############################
currentShell="$SHELL"
if [ $currentShell == "/bin/zsh" ]; then
    echo -e "${boldWhite}> Shell is Already changed to Zsh.${noColor}"
else
    echo -e "${boldBlue}> Changing shell to zsh...${noColor}"
    while ! sudo usermod -s /bin/zsh $USER; do
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
echo -e "${boldBlue}> Create link for helpers...${noColor}"
ln -s "${PWD}/helpers" "${HOME}/.config/"

echo -e "${boldBlue}> Create link for dotfiles...${noColor}"
create_link dotfilesList "${PWD}/dotfiles" $HOME

echo -e "${boldBlue}> Create link for configs...${noColor}"
create_link configsList "${PWD}/configs/.config" "${HOME}/.config"

echo -e "${boldBlue}> Install SDDM theme...${noColor}"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"


#echo -e "${boldBlue}> Use cyberpunk SDDM theme...${noColor}"
#new_theme="cyberpunk"
#sudo sed -i "s|^ConfigFile=Themes/.*\.conf$|ConfigFile=Themes/${new_theme}.conf|" usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop

###############################
# Post Configuration
###############################
ADD_LOCAL_BIN_TO_PATH="export PATH=\$PATH:$HOME/.local/bin"
echo -e "${boldBlue}> Post configuration...${noColor}"

if ! file_contains ".benshrc" ~/.zshrc; then
    echo "source ~/.benshrc" >>~/.zshrc
fi

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

echo -e "${boldBlue}> Configuring FingerPrint...${noColor}"
if fprintd-list "$USER" 2>/dev/null | grep -q "no fingers enrolled"; then
    echo -e "${boldBlue}> Roll your finger...${noColor}"
    fprintd-enroll $USER
else
    echo -e "${boldBlue}> ${yellow}Fingerprint already enrolled! ${noColor}"
fi

if ! file_contains "pam_fprintd.so" /etc/pam.d/sddm; then
    echo -e "${boldBlue}> Add FingerPrint auth to Login page(SDDM)...${noColor}"
    sudo sed -i '2i auth            sufficient                      pam_fprintd.so
    ' /etc/pam.d/sddm
else
    echo -e "${boldBlue}> ${yellow}FingerPrint for Login page is already in use.${noColor}"
fi

if ! file_contains "pam_fprintd.so" /etc/pam.d/system-auth; then
    echo -e "${boldBlue}> Adding PAM to system auth...${noColor}"
    sudo sed -i '2i auth            sufficient                      pam_fprintd.so
    ' /etc/pam.d/system-auth
else
    echo -e "${boldBlue}> ${yellow}FingerPrint for System auth is already in use.${noColor}"
fi

echo -e "${boldBlue}> Enable & start fprintd service...${noColor}"
sudo systemctl start fprintd

echo -e "${boldBlue}> Enable & start waybar service...${noColor}"
systemctl --user enable --now waybar
