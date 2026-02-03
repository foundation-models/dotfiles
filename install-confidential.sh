#!/usr/bin/env bash
# Deploy confidential dotfiles (credentials, .boto, .azure, .gsutil) to this machine.
# Run from the dotfiles repo root. Uses GNU Stow to symlink confidential/ into $HOME.

set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

if ! command -v stow &>/dev/null; then
  echo "GNU Stow is required. Install it: brew install stow  # or apt install stow"
  exit 1
fi

if [[ ! -d confidential ]]; then
  echo "No confidential/ directory. Run ./copy-confidential-from-machine.sh on a machine first to populate it."
  exit 1
fi

stow --target="$HOME" --restow confidential 2>/dev/null || stow --target="$HOME" confidential
echo "Installed confidential dotfiles to $HOME"
