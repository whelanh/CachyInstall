#!/bin/bash

echo "allow fractional scaling"
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

echo "Oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

sudo pacman -S --needed base-devel git 
cd ~/Downloads
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ../CachyInstall
yay -S --needed --noconfirm  - < archpkgs.txt 

flatpak install com.jeffser.Alpaca dev.zed.Zed-Preview io.github.benini.scid io.github.dvlv.boxbuddyrs com.github.tchx84.Flatseal com.mattjakeman.ExtensionManager

chezmoi init --apply https://github.com/whelanh/dotfiles.git

# Create arch linux distrobox container
# distrobox create --name archcontainer --image archlinux:latest --home ~/distrobox-arch --additional-packages "git base-devel micro"

# Install Python chess module
pip install chess --break-system-packages

echo "Install Brew.  Used for OneDrive integration (could also do Tailscale that way)"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> /home/hugh/.config/fish/config.fish
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/hugh/.config/fish/config.fish
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install onedrive
brew services start onedrive-cli
onedrive --force --skip-dot-files --skip-dir venv --sync

read -p "You should start OneDrive now. Do you want to proceed with the updates? (y/N): " answer

if [[ "$answer" =~ ^[Nn]$ || -z "$answer" ]]; then
    echo "Update canceled."
    exit 0
fi

echo "Install Stockfish chess engine"
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

echo "Initiate Tailscale"
sudo systemctl enable --now tailscaled
sudo tailscale up --ssh

echo "rclone google drive"
rclone config

mkdir ~/GoogleDrive
cd ~/.config/systemd/user/
cp ~/OneDrive/rclone-mount.service .
systemctl --user enable --now rclone-mount.service
systemctl --user start rclone-mount

echo "Warp"
cd ~/Downloads
echo "wget https://app.warp.dev/get_warp?package=pacman&channel=preview"
read -p "Do you want to proceed with the updates? (y/N): " answer

if [[ "$answer" =~ ^[Nn]$ || -z "$answer" ]]; then
    echo "Update canceled."
    exit 0
fi
sudo pacman -U ./warp-terminal*

echo "apparmor"
echo "Edit /boot/limine.conf  and /etc/default/limine"
echo "add  lsm=landlock,lockdown,yama,integrity,apparmor,bpf after splash"

read -p "Do you want to proceed with the updates? (y/N): " answer

if [[ "$answer" =~ ^[Nn]$ || -z "$answer" ]]; then
    echo "Update canceled."
    exit 0
fi

sudo pacman -S apparmor apparmor.d-git
systemctl enable --now apparmor.service

echo "edit /etc/apparmor/parser.conf"
echo "Add the following lines:"
echo "write-cache"
echo "Optimize=compress-fast"

echo "Then save the file and reboot"

sudo bash -c 'echo -e "write-cache\nOptimize=compress-fast" > /etc/apparmor/parser.conf'


#forge@jmmaranan.com 
#appindicatorsupport@rgcjonas.gmail.com 
#tailscale@joaophi.github.com 
#blur-my-shell@aunetx  
#search-light@icedman.github.com 
#logomenu@aryan_k 
#gsconnect@andyholmes.github.io 
#dash-to-dock@micxgx.gmail.com

# if system can do rtcwake, cp ~/OneDrive/rtc-suspend.sh to ~/bin/  and copy ~/OneDrive/evening & morning to
# ~/.config/systemctl/user and enable, start etc.
echo "virt manager"
read -p "Do you want to proceed with the updates? (y/N): " answer

if [[ "$answer" =~ ^[Nn]$ || -z "$answer" ]]; then
    echo "Update canceled."
    exit 0
fi

sudo pacman -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat dmidecode libguestfs edk2-ovmf swtpm
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service


echo "Set the UNIX domain socket group ownership to libvirt, (around line 85)"
echo "unix_sock_group = 'libvirt'"
echo "Set the UNIX socket permissions for the R/W socket (around line 102)"
echo "unix_sock_rw_perms = '0770'"
echo "sudo micro /etc/libvirt/libvirtd.conf"
if [[ "$answer" =~ ^[Nn]$ || -z "$answer" ]]; then
    echo "Update canceled."
    exit 0
fi
sudo usermod -a -G libvirt $(whoami)
newgrp libvirt
sudo systemctl restart libvirtd.service
sudo virsh net-autostart default 

echo "enable rdp"
echo "systemd timers"

read -p "Do you want to proceed with the updates? (y/N): " answer

if [[ "$answer" =~ ^[Nn]$ || -z "$answer" ]]; then
    echo "Update canceled."
    exit 0
fi
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

echo "openrgb"

read -p "Do you want to proceed with the updates? (y/N): " answer

if [[ "$answer" =~ ^[Nn]$ || -z "$answer" ]]; then
    echo "Update canceled."
    exit 0
fi

yay -S openrgb i2c-tools
sudo bash -c 'echo -e "i2c_dev" > /etc/modules-load.d/i2c-dev.conf'
sudo openrgb
