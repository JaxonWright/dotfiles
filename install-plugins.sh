#!/bin/bash
set -e

PLUGINS=(
  "jankeesvw.time-machine|https://github.com/jankeesvw/omarchy-time-machine.git"
  "crmne.hyprmoncfg|https://github.com/crmne/omarchy-hyprmoncfg.git"
  "io.github.grichard99.omaproton-vpn|https://github.com/grichard99/omaproton-vpn.git"
  "io.github.erikburdett.wavebar|https://github.com/ErikBurdett/omarchy-wavebar.git"
)

echo "==> Installing Omarchy plugins..."
for entry in "${PLUGINS[@]}"; do
  id="${entry%%|*}"
  url="${entry##*|}"
  if omarchy plugin list --json 2>/dev/null | jq -e --arg id "$id" 'any(.[]; .id == $id)' >/dev/null 2>&1; then
    echo "  → $id already installed"
  else
    omarchy plugin add "$url" --enable --yes
    echo "  ✓ $id"
  fi
done

echo ""
echo "==> Rescanning plugins..."
omarchy plugin rescan
echo "  ✓ Plugins rescanned"

echo ""
echo "Done."