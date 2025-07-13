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

# 1. GNOME Fractional Scaling
print_section "GNOME Fractional Scaling"
if ask_yes_no "Enable fractional scaling for GNOME?"; then
    print_status "Enabling fractional scaling..."
    gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
    print_status "Fractional scaling enabled"
fi

# 2. Oh-my-zsh Installation
print_section "Oh-my-zsh Installation"
if ask_yes_no "Install Oh-my-zsh?"; then
    print_status "Installing Oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
    print_status "Oh-my-zsh installation completed"
fi

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
    flatpak install -y org.kde.kmymoney com.jeffser.Alpaca dev.zed.Zed-Preview io.github.benini.scid io.github.dvlv.boxbuddyrs com.github.tchx84.Flatseal com.mattjakeman.ExtensionManager
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
    
    if ask_yes_no "Start OneDrive sync now?"; then
        onedrive --force --skip-dot-files --skip-dir venv --sync
        print_status "OneDrive sync completed"
    fi
fi

# 9. Stockfish Chess Engine
print_section "Stockfish Chess Engine"
if ask_yes_no "Install Stockfish chess engine?"; then
    print_status "Installing Stockfish..."
    cd ~/Downloads
    if [[ ! -d "Stockfish" ]]; then
        git clone --recurse-submodules https://github.com/official-stockfish/Stockfish.git
    fi
    
    if [[ -f "~/OneDrive/makeSF.sh" ]]; then
        cp ~/OneDrive/makeSF.sh .
        chmod +x ./makeSF.sh
        ./makeSF.sh
        
        # Copy utility scripts
        cp ~/OneDrive/updateStockfish.sh ~/
        cp ~/OneDrive/u.sh ~/
        cd ~
        chmod +x *.sh
        
        # Chess Python scripts
        cd ~/OneDrive/multipleChessPy/pyth*
        chmod +x *.sh
        chmod +x pgn-ex*
        
        print_status "Stockfish installation completed"
    else
        print_warning "makeSF.sh not found in OneDrive, skipping Stockfish compilation"
    fi
fi

# 10. Fastfetch Configuration
print_section "Fastfetch Configuration"
if ask_yes_no "Configure fastfetch?"; then
    if [[ -f "~/OneDrive/configFORfastfetchARCH.jsonc" ]]; then
        print_status "Copying fastfetch config..."
        fastfetch --gen-config
        mkdir -p ~/.config/fastfetch
        cp ~/OneDrive/configFORfastfetchARCH.jsonc ~/.config/fastfetch/config.jsonc
        print_status "Fastfetch configured"
    else
        print_warning "Fastfetch config not found in OneDrive"
    fi
fi

# 11. Tailscale
print_section "Tailscale"
if ask_yes_no "Setup Tailscale?"; then
    print_status "Starting Tailscale..."
    sudo systemctl enable --now tailscaled
    sudo tailscale up --ssh
    print_status "Tailscale setup completed"
fi

# 12. rclone Google Drive
print_section "rclone Google Drive"
if ask_yes_no "Setup rclone for Google Drive?"; then
    print_status "Starting rclone configuration..."
    rclone config
    
    mkdir -p ~/GoogleDrive
    mkdir -p ~/.config/systemd/user/
    
    if [[ -f "./rclone-mount.service" ]]; then
        cp ./rclone-mount.service ~/.config/systemd/user/
        systemctl --user enable --now rclone-mount.service
        systemctl --user start rclone-mount
        print_status "rclone Google Drive setup completed"
    else
        print_warning "rclone-mount.service not found"
    fi
fi

# 13. Warp Terminal
print_section "Warp Terminal"
if ask_yes_no "Install Warp terminal?"; then
    print_status "Preparing Warp terminal installation..."
    cd ~/Downloads
    
    pause_for_manual "Please manually download Warp terminal:
1. Go to https://app.warp.dev/get_warp?package=pacman&channel=preview
2. Download the package to ~/Downloads/
3. The file should be named something like 'warp-terminal*.pkg.tar.xz'"
    
    if ls ~/Downloads/warp-terminal* 1> /dev/null 2>&1; then
        print_status "Installing Warp terminal..."
        sudo pacman -U ~/Downloads/warp-terminal*
        print_status "Warp terminal installed"
    else
        print_error "Warp terminal package not found in ~/Downloads/"
    fi
fi

# 14. AppArmor Security
print_section "AppArmor Security"
if ask_yes_no "Install and configure AppArmor?"; then
    
    pause_for_manual "Please edit the boot configuration:
1. Edit /boot/limine.conf
2. Edit /etc/default/limine (if exists)
3. Add 'lsm=landlock,lockdown,yama,integrity,apparmor,bpf' after 'splash' in the kernel parameters
4. Save the files"
    
    print_status "Installing AppArmor..."
    sudo pacman -S apparmor apparmor.d-git
    print_status "Configuring AppArmor..."
    sudo systemctl enable --now apparmor.service
    
    # Configure AppArmor parser
    sudo bash -c 'echo -e "write-cache\nOptimize=compress-fast" > /etc/apparmor/parser.conf'
    
    print_status "AppArmor setup completed"
    print_warning "Please reboot after completing all installations"
fi

# 15. Virtualization (QEMU/KVM)
print_section "Virtualization Setup"
if ask_yes_no "Install QEMU/KVM virtualization?"; then
    print_status "Installing virtualization packages..."
    sudo pacman -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat dmidecode libguestfs edk2-ovmf swtpm
    
    sudo systemctl enable libvirtd.service
    sudo systemctl start libvirtd.service
    
    pause_for_manual "Please edit /etc/libvirt/libvirtd.conf:
1. Find and uncomment line ~85: unix_sock_group = 'libvirt'
2. Find and uncomment line ~102: unix_sock_rw_perms = '0770'
3. Save the file
4. You can use: sudo micro /etc/libvirt/libvirtd.conf"
    
    print_status "Configuring user permissions..."
    sudo usermod -a -G libvirt $(whoami)
    newgrp libvirt
    sudo systemctl restart libvirtd.service
    sudo virsh net-autostart default
    
    print_status "Virtualization setup completed"
fi

# 16. Systemd Timers
print_section "Systemd Timers"
if ask_yes_no "Setup systemd timers?"; then
    print_status "Setting up systemd timers..."
    mkdir -p ~/.config/systemd/user
    
    if [[ -d "~/OneDrive" ]]; then
        cp ~/OneDrive/schedule-* ~/.config/systemd/user/ 2>/dev/null || print_warning "Some schedule files not found"
        
        systemctl --user enable schedule-test.service
        systemctl --user enable schedule-stockfish.service
        systemctl --user enable schedule-test.timer
        systemctl --user enable schedule-test-two.timer
        systemctl --user enable schedule-stockfish.timer
        systemctl --user start schedule-test.timer
        systemctl --user start schedule-test-two.timer
        systemctl --user start schedule-stockfish.timer
        
        print_status "Systemd timers configured"
    else
        print_warning "OneDrive directory not found, skipping timer setup"
    fi
fi

# 17. OpenRGB
print_section "OpenRGB"
if ask_yes_no "Install OpenRGB for RGB lighting control?"; then
    print_status "Installing OpenRGB..."
    yay -S openrgb i2c-tools
    
    # Load i2c module
    sudo bash -c 'echo -e "i2c_dev" > /etc/modules-load.d/i2c-dev.conf'
    
    print_status "OpenRGB installed"
    print_warning "You may need to reboot and run 'sudo openrgb' first time to detect devices"
fi

# Final Summary
print_section "Installation Summary"
print_status "Setup script completed!"
echo -e "\n${YELLOW}Additional Manual Steps:${NC}"
echo "1. Install GNOME extensions:"
echo "   - tailscale@joaophi.github.com"
echo "   - search-light@icedman.github.com"
echo "   - gsconnect@andyholmes.github.io"
echo ""
echo "2. If your system supports rtcwake:"
echo "   - Copy ~/OneDrive/rtc-suspend.sh to ~/bin/"
echo "   - Copy ~/OneDrive/evening & morning to ~/.config/systemd/user/"
echo "   - Enable and start the services"
echo ""
echo "3. Consider enabling RDP if needed"
echo ""
echo "4. Reboot your system if you installed AppArmor"
echo ""
echo "5. For WOL, make sure sudo ethtool -s <interface_name> wol g

print_status "All done! Enjoy your CachyOS setup!"
