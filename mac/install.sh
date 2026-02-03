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
# Espanso on macOS uses ~/Library/Application Support/espanso (not ~/.config)
if command -v stow &>/dev/null && [[ -d "$DOTFILES_DIR/config/espanso" ]]; then
  mkdir -p "$HOME/Library/Application Support"
  stow --target="$HOME/Library/Application Support" --dir="$DOTFILES_DIR/config" --restow espanso 2>/dev/null || stow --target="$HOME/Library/Application Support" --dir="$DOTFILES_DIR/config" espanso
  echo "Installed: espanso -> ~/Library/Application Support/espanso"
fi
# Optional: brew bundle --file=Brewfile
# brew install stow nvm ...
