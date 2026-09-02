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
install_app "Arctis Manager" lam-gui omarchy pkg aur add linux-arctis-manager
install_app "Solaar" solaar omarchy pkg add solaar
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