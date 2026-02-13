#!/usr/bin/env bash
# Restore all ~/.config/*.toml from the encrypted confidential.tar.enc in this repo.
# Prompts for SOPS age passphrase (and key file path if SOPS_AGE_KEY_FILE is not set).
# Run from the dotfiles repo root.
#
# Prerequisites: sops, age (e.g. apt install sops age-encryption  or  brew install sops age)

set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIDENTIAL_ENC="$DOTFILES_DIR/confidential.tar.enc"
CONF="$DOTFILES_DIR/confidential"
HOME_CONFIG="${HOME:?}/.config"

cd "$DOTFILES_DIR"

if [[ ! -f "$CONFIDENTIAL_ENC" ]]; then
  echo "Error: $CONFIDENTIAL_ENC not found." >&2
  exit 1
fi

# Key file: use env or prompt
if [[ -z "${SOPS_AGE_KEY_FILE:-}" ]]; then
  default_key="$HOME/.config/sops/age/keys.txt"
  read -r -p "Path to age secret key file [${default_key}]: " key_path
  SOPS_AGE_KEY_FILE="${key_path:-$default_key}"
fi
if [[ ! -f "$SOPS_AGE_KEY_FILE" ]]; then
  echo "Error: Age key file not found: $SOPS_AGE_KEY_FILE" >&2
  exit 1
fi
export SOPS_AGE_KEY_FILE

# Passphrase (for passphrase-protected age keys; harmless if key is not protected)
read -s -r -p "SOPS age passphrase: " AGE_IDENTITY_PASSPHRASE
echo
export AGE_IDENTITY_PASSPHRASE

# Decrypt archive into confidential/
echo "Decrypting confidential.tar.enc ..."
sops --decrypt "$CONFIDENTIAL_ENC" | tar -xf - -C "$DOTFILES_DIR"
unset AGE_IDENTITY_PASSPHRASE

if [[ ! -d "$CONF/.config" ]]; then
  echo "No confidential/.config in archive; nothing to restore."
  exit 0
fi

# Copy every .toml under confidential/.config to ~/.config (preserve layout)
count=0
while IFS= read -r -d '' f; do
  rel="${f#$CONF/.config/}"
  dest="$HOME_CONFIG/$rel"
  mkdir -p "$(dirname "$dest")"
  cp "$f" "$dest" && echo "Restored .config/$rel" && ((count++)) || true
done < <(find "$CONF/.config" -name '*.toml' -type f -print0 2>/dev/null)

echo "Done. Restored $count TOML file(s) to $HOME_CONFIG/"
echo "Decrypted confidential/ is still in the repo (in .gitignore). Run ./install-confidential.sh to deploy all confidential files, or remove confidential/ if you only needed TOMLs."
