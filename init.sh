#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME"

# Determine if --target is needed (stow defaults to parent of stow dir)
if [ "$(dirname "$REPO_DIR")" != "$TARGET" ]; then
  TARGET_FLAG="--target=$TARGET"
else
  TARGET_FLAG=""
fi

STOWABLE="bash foot ghostty hypr spicetify starship uwsm walker"

stow_pkg() {
  local pkg="$1"
  if stow $TARGET_FLAG "$pkg" 2>/dev/null; then
    echo "  ✓ $pkg"
  else
    echo "  → $pkg: adopting existing files..."
    stow --adopt $TARGET_FLAG "$pkg"
    echo "  ✓ $pkg (adopted)"
  fi
}

echo "==> Stowing packages..."
for pkg in $STOWABLE; do
  [ -d "$REPO_DIR/$pkg" ] && stow_pkg "$pkg"
done

echo ""
echo "==> Stowing omarchy plugins..."
stow_pkg "omarchy"

echo ""
echo "==> Applying shell.json reference..."
mkdir -p "$TARGET/.config/omarchy"
cp "$REPO_DIR/omarchy/.config/omarchy/shell.json" "$TARGET/.config/omarchy/shell.json"
echo "  ✓ shell.json"

echo ""
echo "==> Registering cloned plugins..."
omarchy plugin rescan

echo ""
echo "==> Restarting shell..."
omarchy restart shell

echo ""
echo "Done. All dotfiles linked."
