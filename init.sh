#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME"

if ! command -v stow >/dev/null 2>&1; then
  echo "==> Installing stow..."
  sudo apt-get install -y stow
  echo "  ✓ stow"
fi

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
echo "==> Reverting config files overwritten by --adopt..."
if command -v git >/dev/null 2>&1 && git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  MODIFIED="$(git -C "$REPO_DIR" diff --name-only; git -C "$REPO_DIR" diff --cached --name-only)"
  if [ -n "$MODIFIED" ]; then
    git -C "$REPO_DIR" checkout -- .
    echo "  ✓ Reverted tracked config changes:"
    echo "$MODIFIED" | sort -u | sed 's/^/      - /'
  else
    echo "  → Nothing to revert."
  fi
  ADOPTED="$(git -C "$REPO_DIR" ls-files --others --exclude-standard)"
  if [ -n "$ADOPTED" ]; then
    echo "  → New files adopted into the repo (left in place, review manually):"
    echo "$ADOPTED" | sed 's/^/      - /'
  fi
else
  echo "  → Not a git repo; skipping."
fi

echo ""
echo "Done. All dotfiles linked."
