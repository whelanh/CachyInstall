# CachyOS Enhanced Setup Script

This repository contains an interactive shell script to help you set up and customize your CachyOS installation with optional components and manual intervention points. This set-up reflects my personal set-up. Once you've cloned (or forked) this repo, you can adjust for your preferences.

## Features

- **Interactive installation:** Choose which components to install or skip.
- **Component setup:** Includes GNOME fractional scaling, Oh-my-zsh, yay (AUR helper), package installation, Flatpak apps, chezmoi dotfiles, Python chess module, Homebrew, OneDrive CLI, Stockfish chess engine, fastfetch config, Tailscale, rclone Google Drive, Warp terminal, AppArmor, virtualization (QEMU/KVM), systemd timers, and OpenRGB.
- **Manual steps:** Prompts for manual actions where needed (e.g., downloading packages, editing configs).
- **Status messages:** Clear colored output for info, warnings, and errors.

## Getting Started

### 1. Clone the Repository

Open your terminal and run:

```bash
git clone https://github.com/yourusername/CachyInstall.git ~/Downloads/CachyInstall
cd ~/Downloads/CachyInstall
```

### 2. Run the Setup Script

Make sure you are **not** running as root. Start the script:

```bash
chmod +x install_CachyOS_Steps.sh
bash install_CachyOS_Steps.sh
```

The script will guide you through each step, asking for confirmation before installing or configuring each component.

## Notes

- Some steps require manual intervention (e.g., downloading Warp terminal, editing config files).
- You may need to reboot after certain installations (e.g., AppArmor).
- The script is designed for CachyOS: an Arch-based system See https://cachyos.org/ for more information.

## Additional Manual Steps

After running the script, consider:
- Installing recommended GNOME extensions.
- Setting up rtcwake scripts if supported.
- Enabling RDP if needed.

Enjoy
