# dotfiles
dotfiles for my Linux configuration(s)

## Prerequisites
This is managed using [GNU Stow](https://github.com/aspiers/stow). So, you must have that installed.

### Arch 
```sh
yay -S stow
```

### Ubuntu
```sh
sudo apt install stow
```

## Usage
1. Clone this repository somewhere that makes sense to you (like `~/dotfiles`)
2. Go to that directory in your terminal (`cd ~/dotfiles`)
3. Run `stow <name>` to automatically symlink that tool's dotfiles on your system (like `stow waybar`)
???
4. Profit
