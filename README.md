# dotfiles

My dotfiles, configurations, preferred programs, and plugins for Omarchy Linux. This repository allows me to quickly turn a fresh machine into my own; just how I like it.

Feel free to use this as inspiration, fork and tailor it to your own preferences.

## Setup

### Quick

On a fresh Omarchy machine, one command does everything:

```sh
curl init.jaxon.dev | bash
```

This clones this repo to `~/git/dotfiles` and runs `init.sh`, `install-apps.sh`, and
`install-plugins.sh` in that order. Re-running it pulls the latest commits first.

#### Optional Commands

```sh
curl init.jaxon.dev | bash -s -- --minimal        # just init.sh
curl init.jaxon.dev | bash -s -- --no-apps        # skip install-apps.sh
curl init.jaxon.dev | bash -s -- --no-plugins     # skip install-plugins.sh
curl init.jaxon.dev | bash -s -- --dir ~/dotfiles # custom directory
```
### Manual

If you don't trust the quick method, or just like wasting your own time, you can run stuff manually like so:

```sh
git clone https://github.com/JaxonWright/dotfiles ~/dotfiles   # any directory works
cd ~/dotfiles
./init.sh
```
Run other scripts as you desire.

## Scripts

| Script | Installs |
|--------|----------|
| `./init.sh` | Installs stow if it is missing and stows every package. |
| `./install-apps.sh` | Preferred apps, nvm + the latest Node LTS, Omarchy defaults (browser/editor/agent), the Midnight theme. Prompts for sudo/yay credentials. |
| `./install-plugins.sh` | Omarchy plugins: time machine, hyprmoncfg, omaproton-vpn, wavebar. |
| `./bootstrap.sh` | Clones the repo and runs the three scripts above. This is what `init.jaxon.dev` serves. |

## Packages

| Package | Purpose | Notes |
|---------|---------|-------|
| `bash` | Bash shell init (starship, nvm) | |
| `foot` | Foot terminal config | Delegates to Omarchy theme |
| `ghostty` | Ghostty terminal config | Delegates to Omarchy theme |
| `git` | Global git config (`~/.config/git/config`) | Replaces `~/.gitconfig` |
| `hypr` | Hyprland compositor (Lua config) | Quattro format |
| `starship` | Shell prompt | |
| `uwsm` | Universal Wayland Session Manager | |
| `walker` | Application launcher | |

To stow one package by hand:

```sh
stow --target=$HOME <package>           # fresh system
stow --adopt --target=$HOME <package>   # existing files, adopts them into repo
```

## Cloudflare Worker? Hardly Know 'er

You might be wondering why there is a cloudflare folder in here. Well, I decided to be extra and deploy a Cloudflare Worker so that I can run the simple command at the beginning of this README

`cloudflare/worker.js` is the Worker behind the URL: it serves `bootstrap.sh` to
curl and a page with the command to browsers. Deploy or update it with:

```sh
cd cloudflare
npx wrangler login     # once, opens a browser
npx wrangler deploy
```

`wrangler.toml` claims the `init.jaxon.dev` hostname and creates its DNS record,
so there is nothing to click in the dashboard. The Worker reads `bootstrap.sh`
from GitHub at request time, so it only needs redeploying when `worker.js`
itself changes.

> [!NOTE]
> Of course, this deployment process only works for Jaxon. I am not stupid enough to let anyone modify my Cloudflare stuff.