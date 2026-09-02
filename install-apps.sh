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
echo "==> Installing apps..."
install_app "Spotify" spotify omarchy install service spotify
install_app "Spicetify" spicetify omarchy pkg aur add spicetify-cli
install_app "Discord" discord omarchy pkg add discord
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
if have solaar; then
  echo "  → Solaar already installed"
else
  omarchy pkg add solaar
  echo "  ✓ Solaar"
fi

echo "  → Reloading Solaar udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger
if [ ! -f /usr/lib/udev/rules.d/42-logitech-unify-permissions.rules ]; then
  echo "  → Warning: Solaar udev rule not found on disk"
fi
echo "  ✓ Solaar udev rule active"

echo "  → Enabling Solaar at startup..."
AUTOSTART="$REPO_DIR/hypr/.config/hypr/autostart.lua"
if grep -qs 'solaar' "$AUTOSTART"; then
  echo "  → Already in Hyprland autostart"
else
  printf '\no.launch_on_start("solaar --window=hide")\n' >> "$AUTOSTART"
  echo "  ✓ Added to Hyprland autostart"
fi
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