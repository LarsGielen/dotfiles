# Hyprland Dotfiles

Welcome to my personal dotfiles for a **riced Hyprland** setup. This repository contains the configuration files and resources I use to customize and enhance my Linux desktop environment.

## 🖥️ Desktop Environment

- **Window Manager:** [Hyprland](https://github.com/hyprwm/Hyprland)
- **Status Bar:** [Waybar](https://github.com/Alexays/Waybar)
- **Wallpaper Daemon:** [Hyprpaper](https://github.com/hyprwm/hyprpaper)
- **Application Launcher:** [Rofi](https://github.com/davatorium/rofi)
- **Terminal:** Kitty

This setup is managed using [uwsm](https://wiki.hyprland.org/Useful-Utilities/Systemd-start/) — a Wayland session manager that handles launching and monitoring all components.

## 📁 Folder Structure

This repo uses **GNU Stow** to symlink configuration directories into `~/.config`. Each directory in the root is a self-contained module.

```bash
~/.config/
├── hypr/         # Hyprland configs
├── waybar/       # Waybar modules and styles
├── hyprpaper/    # Wallpaper config
├── rofi/         # Launcher themes and scripts
└── scripts/      # Custom shell scripts
```

## ⚙️ Installation

> ⚠️ These are my personal configs. Make backups before applying!

### 1. Clone the Repo

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Run install script

> ⚠️ I do not guarantee that these work on you're system

Needs to be run from git root folder

```bash
chmod +x ./install_scripts/dotfiles_install.sh
./postinstall.sh
```