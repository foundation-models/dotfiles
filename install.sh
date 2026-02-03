#!/usr/bin/env bash
# Dotfiles installer using GNU Stow
# Usage: ./install.sh [packages...]
#   With no args: installs all packages for current OS.
#   With args: installs only listed packages (e.g. zsh git config).

set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Check for stow
if ! command -v stow &>/dev/null; then
  echo "GNU Stow is required. Install it:"
  echo "  macOS:   brew install stow"
  echo "  Ubuntu: sudo apt install stow"
  exit 1
fi

install_package() {
  local pkg="$1"
  local target="${2:-$HOME}"
  if [[ -d "$pkg" ]]; then
    stow --target="$target" --restow "$pkg" 2>/dev/null || stow --target="$target" "$pkg"
    echo "Installed: $pkg -> $target"
  fi
}

if [[ $# -ge 1 ]]; then
  for pkg in "$@"; do
    if [[ "$pkg" == "config" ]]; then
      install_package config "$HOME/.config"
    else
      install_package "$pkg"
    fi
  done
else
  # Default: install all
  install_package zsh
  install_package git
  install_package config "$HOME/.config"
  case "$(uname -s)" in
    Darwin)  [[ -d mac ]]   && (cd mac   && ./install.sh 2>/dev/null || true) ;;
    Linux)   [[ -d linux ]] && (cd linux && ./install.sh 2>/dev/null || true) ;;
  esac
fi
