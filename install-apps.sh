#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Updating system packages..."
omarchy update -y
echo "  ✓ System up to date"

have() {
  command -v "$1" >/dev/null 2>&1
}

install_app() {
  local name="$1" binary="$2"
  shift 2
  if have "$binary"; then
    echo "  → $name already installed"
  else
    "$@"
    echo "  ✓ $name"
  fi
}

echo "==> Installing Midnight theme..."
if [ -d "$HOME/.config/omarchy/themes/midnight" ]; then
  echo "  → Midnight theme already installed"
else
  omarchy theme install https://github.com/JaxonWright/omarchy-midnight-theme
  echo "  ✓ Midnight theme installed"
fi
echo "  ✓ Applying Midnight"
omarchy theme set midnight

echo ""
echo "==> Installing browser..."
install_app "Brave" brave-browser omarchy install browser brave

echo ""
echo "==> Installing editor..."
install_app "VS Code" code omarchy install editor vscode

echo ""
echo "==> Installing AI apps..."
install_app "Grok Bot" grok-bot omarchy install and launch "Grok Bot" grok-bot grok-bot

echo "  → Applying Grok Bot OLED black theme..."
sudo install -d -m 755 /var/cache/grok-bot-oled
sudo cp -n "/opt/Grok Bot/resources/app.asar" /var/cache/grok-bot-oled/app.asar.orig
sudo install -m 755 -o root -g root "$REPO_DIR/grok-bot/grok-bot-oled-patch" /usr/local/bin/grok-bot-oled-patch
sudo install -d -m 755 /etc/pacman.d/hooks
sudo install -m 644 -o root -g root "$REPO_DIR/grok-bot/grok-bot-oled.hook" /etc/pacman.d/hooks/grok-bot-oled.hook
sudo /usr/local/bin/grok-bot-oled-patch
echo "  ✓ Grok Bot OLED black (pacman hook re-applies it on upgrade)"
install_claude() {
  omarchy install ai claude && return
  # Older Omarchy releases lack the action; do what it does by hand.
  echo "  → omarchy install ai claude unavailable; installing claude-desktop directly"
  omarchy pkg add claude-desktop
  setsid uwsm-app -- /usr/bin/claude-desktop >/dev/null 2>&1 &
}
install_app "Claude" claude-desktop install_claude

echo ""
echo "==> Installing apps..."
install_app "Spotifast" spotifast omarchy pkg aur add spotifast-bin
install_app "Discord" discord omarchy pkg add discord
install_app "Strata" strata omarchy pkg add strata
xdg-mime default io.github.lgse.Strata.desktop inode/directory
omarchy pkg drop nautilus-python nautilus sushi
echo "  ✓ Strata is the file manager (Nautilus removed)"
install_app "Signal" signal-desktop omarchy pkg add signal-desktop

echo "  → Applying Signal OLED black theme..."
sudo install -d -m 755 /var/cache/signal-oled
sudo cp -n /usr/lib/signal-desktop/resources/app.asar /var/cache/signal-oled/app.asar.orig
sudo install -m 755 -o root -g root "$REPO_DIR/signal/signal-oled-patch" /usr/local/bin/signal-oled-patch
sudo install -d -m 755 /etc/pacman.d/hooks
sudo install -m 644 -o root -g root "$REPO_DIR/signal/signal-oled.hook" /etc/pacman.d/hooks/signal-oled.hook
sudo /usr/local/bin/signal-oled-patch
echo "  ✓ Signal OLED black (pacman hook re-applies it on upgrade)"
install_app "Steam" steam omarchy install gaming steam
if have lam-gui; then
  echo "  → Arctis Manager already installed"
else
  omarchy pkg aur add linux-arctis-manager
  echo "  ✓ Arctis Manager"
fi

echo "  → Reloading Arctis Manager udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger
if [ ! -f /usr/lib/udev/rules.d/91-steelseries-arctis.rules ]; then
  echo "  → Warning: Arctis Manager udev rule not found on disk"
fi
echo "  ✓ Arctis Manager udev rule active"

echo "  → Enabling Arctis Manager background service..."
systemctl --user enable --now arctis-manager
echo "  ✓ Arctis Manager service enabled at startup"

echo "  → Enabling Arctis Manager system tray at login..."
mkdir -p "$HOME/.config/autostart"
cp -f /usr/share/applications/ArctisManagerSystray.desktop "$HOME/.config/autostart/"
echo "  ✓ Arctis Manager tray autostart configured"

install_app "OpenRGB" openrgb omarchy pkg add openrgb
install_app "rclone" rclone omarchy pkg add rclone
install_app "restic" restic omarchy pkg add restic
install_app "GitHub CLI" gh omarchy pkg add gh
if have bambu-studio; then
  echo "  → Bambu Studio already installed"
elif omarchy pkg aur accessible; then
  omarchy pkg aur add bambustudio-nvidia-bin
  echo "  ✓ Bambu Studio"
else
  echo "  → AUR unavailable; skipping Bambu Studio"
fi

echo ""
echo "==> Installing Starship prompt..."
omarchy pkg add starship
echo "  ✓ Starship"

echo ""
echo "==> Installing nvm and Node LTS..."
NVM_DIR="$HOME/.config/nvm"   # Matches the NVM_DIR exported in bash/.bashrc
if [ -s "$NVM_DIR/nvm.sh" ]; then
  echo "  → nvm already installed"
else
  git clone --quiet https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  git -C "$NVM_DIR" checkout --quiet \
    "$(git -C "$NVM_DIR" describe --abbrev=0 --tags --match 'v[0-9]*' \
       "$(git -C "$NVM_DIR" rev-list --tags --max-count=1)")"
  echo "  ✓ nvm $(git -C "$NVM_DIR" describe --tags)"
fi

export NVM_DIR
set +e
. "$NVM_DIR/nvm.sh"
nvm install --lts && nvm alias default 'lts/*' >/dev/null
NVM_STATUS=$?
set -e
if [ "$NVM_STATUS" -ne 0 ]; then
  echo "  → Warning: could not install Node LTS with nvm" >&2
else
  echo "  ✓ Node $(node --version) (LTS, nvm default)"
fi

echo ""
echo "==> Setting Omarchy defaults..."
omarchy default browser brave
omarchy default editor code

echo ""
echo "==> Setting OpenCode as the default agent..."
if ! have opencode; then
  mise use -g opencode || { echo "Could not install OpenCode with mise" >&2; exit 1; }
fi
mkdir -p "$HOME/.config/omarchy/defaults"
printf '%s\n' opencode > "$HOME/.config/omarchy/defaults/agent"
echo "  ✓ OpenCode"

echo ""
echo "Done. Open a new terminal for the Starship prompt to appear."