#!/bin/bash

# CachyOS Enhanced Setup Script
# This script allows selective installation of components with manual intervention points

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Function to ask yes/no questions
ask_yes_no() {
    local question="$1"
    local default="${2:-n}"
    
    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$question (Y/n): " answer
            answer=${answer:-y}
        else
            read -p "$question (y/N): " answer
            answer=${answer:-n}
        fi
        
        case $answer in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to pause for manual intervention
pause_for_manual() {
    echo -e "\n${YELLOW}MANUAL INTERVENTION REQUIRED${NC}"
    echo "$1"
    echo "Press Enter when you have completed the above steps..."
    read
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    exit 1
fi

print_section "CachyOS Enhanced Setup Script"
echo "This script will guide you through setting up your CachyOS system."
echo "You can choose which components to install and skip sections as needed."

# 3. AUR Helper (yay) Installation
print_section "AUR Helper (yay) Installation"
if ask_yes_no "Install yay AUR helper?"; then
    print_status "Installing base development tools..."
    sudo pacman -S --needed base-devel git
    
    print_status "Installing yay..."
    cd ~/Downloads
    if [[ ! -d "yay" ]]; then
        git clone https://aur.archlinux.org/yay.git
    fi
    cd yay
    makepkg -si --noconfirm
    print_status "yay installation completed"
fi

# 4. Package Installation from archpkgs.txt
print_section "Package Installation"
if ask_yes_no "Install packages from archpkgs.txt?" && [[ -f "~/Downloads/CachyInstall/archpkgs.txt" ]]; then
    print_status "Installing packages from archpkgs.txt..."
    cd ~/Downloads/CachyInstall
    yay -S --needed --noconfirm - < archpkgs.txt
    print_status "Package installation completed"
else
    print_warning "Skipping package installation (archpkgs.txt not found or skipped)"
fi

# 5. Flatpak Applications
print_section "Flatpak Applications"
if ask_yes_no "Install Flatpak applications?"; then
    print_status "Installing Flatpak applications..."
    flatpak install -y \
        be.alexandervanhee.gradia \
        com.github.xournalpp.xournalpp \
        org.kde.kmymoney \
        dev.zed.Zed-Preview \
        io.github.benini.scid \
        io.github.dvlv.boxbuddyrs \
        com.github.tchx84.Flatseal \
        com.mattjakeman.ExtensionManager \
        com.discordapp.Discord \
        com.google.ChromeDev 
    print_status "Flatpak applications installed"
fi

# 6. Chezmoi Dotfiles
print_section "Dotfiles Management"
if ask_yes_no "Initialize chezmoi dotfiles?"; then
    print_status "Initializing chezmoi dotfiles..."
    chezmoi init --apply https://github.com/whelanh/dotfiles.git
    print_status "Dotfiles initialized"
fi

# 7. Python Chess Module
print_section "Python Chess Module"
if ask_yes_no "Install Python chess module?"; then
    print_status "Installing Python chess module..."
    pip install chess --break-system-packages
    print_status "Python chess module installed"
fi

# 8. Homebrew and OneDrive
print_section "Homebrew and OneDrive"
if ask_yes_no "Install Homebrew and OneDrive CLI?"; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add brew to shell configs
    echo >> ~/.config/fish/config.fish
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.config/fish/config.fish
    echo >> ~/.zshrc
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
    print_status "Installing OneDrive CLI..."
    brew install onedrive-cli
    brew services start onedrive-cli
    brew install Valkyrie00/homebrew-bbrew/bbrew 
    
    if ask_yes_no "Start OneDrive sync now?"; then
        onedrive --force --skip-dot-files --skip-dir venv --sync
        print_status "OneDrive sync completed -- Good time to exit terminal and go to next script"
    fi
fi
