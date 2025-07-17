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
    print_status "Oh-my-zsh installation completed.  NEED TO EXIT TERMINAL & RESTART TO BE IN ZSH"
fi
