# dotfiles

My Linux configuration — Omarchy Quattro.

## Setup

```sh
yay -S stow                                                  # prerequisite (Arch)
git clone https://github.com/JaxonWright/dotfiles ~/dotfiles   # any directory works
cd ~/dotfiles
./init.sh
```

`init.sh` stows every package, applies `shell.json`, registers plugins, and restarts the shell.

Two more scripts:

| Script | Installs |
|--------|----------|
| `./install-apps.sh` | Preferred apps, nvm + the latest Node LTS, Omarchy defaults (browser/editor/agent), the Midnight theme. Prompts for sudo/yay credentials. |
| `./install-plugins.sh` | Omarchy plugins: time machine, hyprmoncfg, omaproton-vpn, wavebar. |

## Packages

| Package | Purpose | Notes |
|---------|---------|-------|
| `bash` | Bash shell init (starship, nvm) | |
| `foot` | Foot terminal config | Delegates to Omarchy theme |
| `ghostty` | Ghostty terminal config | Delegates to Omarchy theme |
| `git` | Global git config (`~/.config/git/config`) | Replaces `~/.gitconfig` |
| `hypr` | Hyprland compositor (Lua config) | Quattro format |
| `omarchy` | `shell.json` reference copy | Copied, never stowed — see below |
| `spicetify` | Spotify client mod | |
| `starship` | Shell prompt | |
| `uwsm` | Universal Wayland Session Manager | |
| `walker` | Application launcher | |

To stow one package by hand:

```sh
stow --target=$HOME <package>           # fresh system
stow --adopt --target=$HOME <package>   # existing files — adopts them into repo
```

The Omarchy shell writes to `shell.json` at runtime, so that package is copied rather than symlinked. `init.sh` does this; to re-apply it later:

```sh
cp omarchy/.config/omarchy/shell.json ~/.config/omarchy/shell.json
```
