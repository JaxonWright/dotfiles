#!/bin/bash
# Fresh-machine bootstrap. Clones the dotfiles repo and runs the setup scripts.
#
#   curl init.jaxon.dev | bash
#   curl init.jaxon.dev | bash -s -- --minimal
#
# Everything lives inside main() and is called on the last line, so a truncated
# download or an error page from the CDN can never run half of this.
set -euo pipefail

main() {
  local REPO_URL="${DOTFILES_REPO:-https://github.com/JaxonWright/dotfiles.git}"
  local REPO_DIR="${DOTFILES_DIR:-$HOME/git/dotfiles}"
  local BRANCH="${DOTFILES_BRANCH:-master}"

  local RUN_INIT=1 RUN_APPS=1 RUN_PLUGINS=1

  usage() {
    cat <<'USAGE'
Usage: curl init.jaxon.dev | bash -s -- [options]

  --minimal      Only clone and run init.sh (no apps, no plugins)
  --no-apps      Skip install-apps.sh
  --no-plugins   Skip install-plugins.sh
  --dir PATH     Clone into PATH (default: ~/dotfiles)
  -h, --help     Show this help
USAGE
  }

  while [ $# -gt 0 ]; do
    case "$1" in
      --minimal)    RUN_APPS=0; RUN_PLUGINS=0 ;;
      --no-apps)    RUN_APPS=0 ;;
      --no-plugins) RUN_PLUGINS=0 ;;
      --dir)        REPO_DIR="$2"; shift ;;
      -h|--help)    usage; return 0 ;;
      *)            echo "Unknown option: $1" >&2; usage >&2; return 1 ;;
    esac
    shift
  done

  # Piped into bash, stdin is the script itself, so sudo and yay prompts would
  # read garbage. Point stdin back at the terminal.
  if [ ! -t 0 ] && { : </dev/tty; } 2>/dev/null; then
    exec </dev/tty
  fi

  if [ ! -f /etc/arch-release ] || ! command -v omarchy >/dev/null 2>&1; then
    echo "This bootstrap expects an Omarchy (Arch) machine." >&2
    return 1
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "==> Installing git..."
    omarchy pkg add git
  fi

  if [ -d "$REPO_DIR/.git" ]; then
    echo "==> Updating $REPO_DIR..."
    git -C "$REPO_DIR" pull --ff-only
  elif [ -e "$REPO_DIR" ]; then
    echo "$REPO_DIR exists and is not a git checkout. Move it or pass --dir." >&2
    return 1
  else
    echo "==> Cloning into $REPO_DIR..."
    git clone --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"
  fi

  cd "$REPO_DIR"

  # init.sh first: it ends by reverting tracked changes in the repo, which would
  # undo the Hyprland autostart line install-apps.sh appends.
  if [ "$RUN_INIT" = 1 ]; then
    echo ""
    ./init.sh
  fi

  if [ "$RUN_APPS" = 1 ]; then
    echo ""
    ./install-apps.sh
  fi

  if [ "$RUN_PLUGINS" = 1 ]; then
    echo ""
    ./install-plugins.sh
  fi

  echo ""
  echo "Bootstrap complete. Repo at $REPO_DIR"
}

main "$@"
