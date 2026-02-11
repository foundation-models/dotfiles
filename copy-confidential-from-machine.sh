#!/usr/bin/env bash
# Copy confidential files FROM this machine INTO the dotfiles repo.
# Run from the dotfiles repo root. Uses $HOME and $HOME/.config.
# Use this script (not install.sh) when pulling credentials/secrets into the repo.

set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="$DOTFILES_DIR/confidential"
H="${HOME:-$HOME}"

mkdir -p "$CONF/.azure" "$CONF/.gsutil" "$CONF/.config"
mkdir -p "$CONF/.config/sops/age"

# Home dotfiles
[[ -f "$H/.boto" ]] && cp "$H/.boto" "$CONF/.boto" && echo "Copied .boto"

# Azure (config and profile only; skip token caches and logs)
for f in config clouds.config azureProfile.json az.json; do
  [[ -f "$H/.azure/$f" ]] && cp "$H/.azure/$f" "$CONF/.azure/$f" && echo "Copied .azure/$f"
done

# GSUtil
[[ -f "$H/.gsutil/credstore2" ]] && cp "$H/.gsutil/credstore2" "$CONF/.gsutil/credstore2" 2>/dev/null && echo "Copied .gsutil/credstore2" || true
[[ -f "$H/.gsutil/credstore2.lock" ]] && cp "$H/.gsutil/credstore2.lock" "$CONF/.gsutil/credstore2.lock" 2>/dev/null && echo "Copied .gsutil/credstore2.lock" || true

# Personal tokens for GitHub + dev.azure.com/intappdevops (see config/personal-tokens.env.example)
# Prefer $HOME/.config; fallback to workspace/.config when dotfiles lives under workspace (e.g. workspace/dotfiles)
if [[ -f "$H/.config/personal-tokens.env" ]]; then
  cp "$H/.config/personal-tokens.env" "$CONF/.config/personal-tokens.env" && echo "Copied .config/personal-tokens.env"
elif [[ -f "$DOTFILES_DIR/../.config/personal-tokens.env" ]]; then
  cp "$DOTFILES_DIR/../.config/personal-tokens.env" "$CONF/.config/personal-tokens.env" && echo "Copied .config/personal-tokens.env (from workspace)"
fi

# Every .toml under ~/.config (credentials and other secret config) — keep SOPS-encrypted copy in repo
while IFS= read -r -d '' f; do
  rel="${f#$H/.config/}"
  mkdir -p "$CONF/.config/$(dirname "$rel")"
  cp "$f" "$CONF/.config/$rel" && echo "Copied .config/$rel"
done < <(find "$H/.config" -name '*.toml' -type f -print0 2>/dev/null)

[[ -f "$H/.config/sops/age/keys.txt" ]] && cp "$H/.config/sops/age/keys.txt" "$CONF/.config/sops/age/" && echo "Copied .config/sops/age/keys.txt"

echo "Done. Confidential files are in $CONF/"
echo "Run ./install-confidential.sh to deploy them to this machine."
