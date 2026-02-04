#!/usr/bin/env bash
# macOS-specific setup (run from repo root or mac/)
# Install Homebrew if missing; stow espanso to ~/Library/Application Support.

set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v brew &>/dev/null || {
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"  # or bash
}
# Source-of-truth configs: dotfiles are canonical. We only ever create a symlink
# FROM dotfiles TO the install location. Never copy/overwrite from install → dotfiles;
# backup/restore must not overwrite these. They are made read-only so backup fails to overwrite.
SOURCE_OF_TRUTH_ESPANSO_BASE="$DOTFILES_DIR/config/espanso/match/base.yml"
if [[ -f "$SOURCE_OF_TRUTH_ESPANSO_BASE" ]]; then
  # Abort if dotfiles file is a symlink (someone reversed the link); it must stay the real file.
  if [[ -L "$SOURCE_OF_TRUTH_ESPANSO_BASE" ]]; then
    echo "Error: $SOURCE_OF_TRUTH_ESPANSO_BASE is a symlink; it must be the source-of-truth file. Fix and re-run." >&2
    exit 1
  fi
  INSTALLED_ESPANSO_BASE="$HOME/Library/Application Support/espanso/match/base.yml"
  mkdir -p "$(dirname "$INSTALLED_ESPANSO_BASE")"
  rm -f "$INSTALLED_ESPANSO_BASE"
  ln -sf "$SOURCE_OF_TRUTH_ESPANSO_BASE" "$INSTALLED_ESPANSO_BASE"
  chmod 444 "$SOURCE_OF_TRUTH_ESPANSO_BASE"
  echo "Installed: espanso match/base.yml -> dotfiles (symlink); source-of-truth file is read-only"
fi
# Optional: brew bundle --file=Brewfile
# brew install stow nvm ...
