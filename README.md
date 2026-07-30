# dotfiles

dotfiles for my Linux configuration(s) — Omarchy Quattro.

## Prerequisites

```sh
# Install stow (Arch)
yay -S stow
```

## Setup

```sh
# Clone into any directory (e.g. ~/dotfiles)
git clone https://github.com/jaxon/dotfiles ~/dotfiles
cd ~/dotfiles

# Stow a package — creates symlinks from repo → system
# If the repo is NOT at ~/dotfiles, you need --target:
stow --target=$HOME <package>

# If the file already exists on the system, use --adopt to move it into the repo:
stow --adopt --target=$HOME <package>
```

## Packages

| Package | Purpose | Notes |
|---------|---------|-------|
| `bash` | Bash shell init (starship, nvm) | |
| `foot` | Foot terminal config | Delegates to Omarchy theme |
| `ghostty` | Ghostty terminal config | Delegates to Omarchy theme |
| `hypr` | Hyprland compositor (Lua config) | Quattro format |
| `spicetify` | Spotify client mod | |
| `starship` | Shell prompt | |
| `uwsm` | Universal Wayland Session Manager | |
| `walker` | Application launcher | |

> **Removed from old setup:** `waybar` (replaced by Omarchy Quickshell bar in `~/.config/omarchy/shell.json`), `hypridle` (now in `shell.json` idle section), `hyprlock` (Omarchy uses its own lockscreen), NVIDIA env vars (auto-handled by defaults).
