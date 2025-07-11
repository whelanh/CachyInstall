#!/bin/bash

ask_continue() {
    read -p "Proceed with $1? (y/N): " answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        echo "Skipping $1."
        return 1
    fi
    return 0
}

# 1. Fractional Scaling
if ask_continue "enabling fractional scaling"; then
    echo "Enabling fractional scaling..."
    gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
fi

# 2. Oh-my-zsh
if ask_continue "installing Oh-my-zsh"; then
    echo "Installing Oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 3. yay AUR Helper
if ask_continue "installing yay AUR helper"; then
    sudo pacman -S --needed base-devel git
    cd ~/Downloads
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
fi

# 4. Install Packages from archpkgs.txt
if ask_continue "installing packages from archpkgs.txt"; then
    cd ~/Downloads/CachyInstall
    yay -S --needed --noconfirm - < archpkgs.txt
fi

# 5. Flatpak Apps
if ask_continue "installing Flatpak apps"; then
    flatpak install com.jeffser.Alpaca dev.zed.Zed-Preview io.github.benini.scid io.github.dvlv.boxbuddyrs com.github.tchx84.Flatseal com.mattjakeman.ExtensionManager
fi

# 6. chezmoi Dotfiles
if ask_continue "applying chezmoi dotfiles"; then
    chezmoi init --apply https://github.com/whelanh/dotfiles.git
fi

# 7. Python Chess Module
if ask_continue "installing Python chess module"; then
    pip install chess --break-system-packages
fi

# 8. Homebrew & OneDrive
if ask_continue "installing Homebrew and OneDrive CLI"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/hugh/.config/fish/config.fish
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/hugh/.zshrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew install onedrive-cli
    brew services start onedrive-cli
    onedrive --force --skip-dot-files --skip-dir venv --sync
    read -p "You should start OneDrive now. Press enter to continue..."
fi

# 9. Stockfish Chess Engine
if ask_continue "installing Stockfish chess engine"; then
    cd ~/Downloads
    git clone --recurse-submodules https://github.com/official-stockfish/Stockfish.git
    cp ~/OneDrive/makeSF.sh .
    chmod +x ./makeSF.sh
    ./makeSF.sh
    cp ~/OneDrive/updateStockfish.sh ~/
    cp ~/OneDrive/u.sh ~/
    cd ~
    chmod +x *.sh
    cd ~/OneDrive/multipleChessPy/pyth*
    chmod +x *.sh
    chmod +x pgn-ex*
fi

# 10. Fastfetch Config
if ask_continue "copying fastfetch config"; then
    cp ~/OneDrive/configFORfastfetchARCH.jsonc ~/.config/fastfetch/config.jsonc
fi

# 11. Tailscale
if ask_continue "enabling Tailscale"; then
    sudo systemctl enable --now tailscaled
    sudo tailscale up --ssh
fi

# 12. rclone Google Drive
if ask_continue "configuring rclone for Google Drive"; then
    rclone config
    mkdir ~/GoogleDrive
    cd ~/.config/systemd/user/
    cp ~/OneDrive/rclone-mount.service .
    systemctl --user enable --now rclone-mount.service
    systemctl --user start rclone-mount
fi

# 13. Warp Terminal (Manual Download Required)
if ask_continue "installing Warp terminal"; then
    cd ~/Downloads
    echo "Manual step required: Download the Warp terminal package from:"
    echo "  https://app.warp.dev/get_warp?package=pacman&channel=preview"
    read -p "After downloading, press enter to continue..."
    sudo pacman -U ./warp-terminal*
fi

# 14. AppArmor & Limine Config (Manual Edit Required)
if ask_continue "configuring AppArmor and Limine"; then
    echo "Manual step required: Edit /boot/limine.conf and /etc/default/limine"
    echo "Add: lsm=landlock,lockdown,yama,integrity,apparmor,bpf after splash"
    read -p "After editing, press enter to continue..."
    sudo pacman -S apparmor apparmor.d-git
    sudo systemctl enable --now apparmor.service
    sudo bash -c 'echo -e "write-cache\nOptimize=compress-fast" > /etc/apparmor/parser.conf'
    echo "AppArmor config updated. Please reboot after completion."
fi

# 15. GNOME Extensions
if ask_continue "installing GNOME extensions"; then
    echo "Install these extensions manually:"
    echo "  tailscale@joaophi.github.com"
    echo "  search-light@icedman.github.com"
    echo "  gsconnect@andyholmes.github.io"
fi

# 16. Virt Manager & Libvirt (Manual Edit Required)
if ask_continue "installing Virt Manager and configuring libvirtd"; then
    sudo pacman -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat dmidecode libguestfs edk2-ovmf swtpm
    sudo systemctl enable libvirtd.service
    sudo systemctl start libvirtd.service
    echo "Manual step required: Edit /etc/libvirt/libvirtd.conf"
    echo "Set (around line 85): unix_sock_group = 'libvirt'"
    echo "Set (around line 102): unix_sock_rw_perms = '0770'"
    echo "Run: sudo micro /etc/libvirt/libvirtd.conf"
    read -p "After editing, press enter to continue..."
    sudo usermod -a -G libvirt $(whoami)
    newgrp libvirt
    sudo systemctl restart libvirtd.service
    sudo virsh net-autostart default
fi

# 17. Systemd Timers
if ask_continue "enabling systemd timers"; then
    cd ~/.config/systemd/user
    cp ~/OneDrive/schedule-*
    systemctl --user enable schedule-test.service
    systemctl --user enable schedule-stockfish.service
    systemctl --user enable schedule-test.timer
    systemctl --user enable schedule-test-two.timer
    systemctl --user enable schedule-stockfish.timer
    systemctl --user start schedule-test.timer
    systemctl --user start schedule-test-two.timer
    systemctl --user start schedule-stockfish.timer
    systemctl --user status schedule-test
fi

# 18. OpenRGB
if ask_continue "installing OpenRGB"; then
    yay -S openrgb i2c-tools
    sudo bash -c 'echo -e "i2c_dev" > /etc/modules-load.d/i2c-dev.conf'
    sudo openrgb
fi

echo "All done! Review any manual steps above before rebooting."

