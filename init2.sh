#!/bin/bash

sudo pacman -S --needed base-devel git 
cd ~/Downloads
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
yay -S --needed --noconfirm  - < archpkgs.txt 

flatpak install com.visualstudio.code com.jeffser.Alpaca dev.zed.Zed-Preview io.github.benini.scid io.github.dvlv.boxbuddyrs com.github.tchx84.Flatseal

chezmoi init --apply https://github.com/whelanh/dotfiles.git

# Create arch linux distrobox container
# distrobox create --name archcontainer --image archlinux:latest --home ~/distrobox-arch --additional-packages "git base-devel micro"

# Install Python chess module
pip install chess --break-system-packages

# Install Brew.  Used for OneDrive integration (could also do Tailscale that way)
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
# Install Stockfish chess engine
cd ~/Downloads
git clone --recurse-submodules https://github.com/official-stockfish/Stockfish.git
cp ~/OneDrive/makeSF.sh .
chmod +x ./makeSF.sh
./makeSF.sh

# Initiate Tailscale
sudo systemctl enable --now tailscaled
sudo tailscale up --ssh

rclone config

mkdir ~/GoogleDrive
cd ~/.config/systemd/user/
cp ~/OneDrive/rclone-mount.service .
systemctl --user enable --now rclone-mount.service
systemctl --user start rclone-mount

# Warp
wget https://app.warp.dev/get_warp?package=pacman&channel=preview
cd ~/Downloads
sudo pacman -U ./warp-terminal*
