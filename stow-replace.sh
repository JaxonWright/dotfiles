#!/bin/bash

# Usage: ./stow-replace.sh <package>
# Example: ./stow-replace.sh bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <package>"
  exit 1
fi

PACKAGE="$1"

echo "Adopting existing dotfiles for package: $PACKAGE..."

# Step 1: Adopt local files (moves them into repo and symlinks from original location)
stow --adopt "$PACKAGE"

echo "Restoring dotfiles repo to "
# Step 2: Restore repo to last committed state (keeps symlinks, restores contents)
git restore .

# Restow, to ensure all symlinks are present (typically not necessary)
stow "$PACKAGE"

echo "$PACKAGE dotfiles replaced with stowed versions"
