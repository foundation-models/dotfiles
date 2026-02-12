#!/usr/bin/env bash
# Build authenticated git URL: https://OWNER:TOKEN@host/path
# Owner/org is taken from the input path (same as username); token from env, per-org overrides supported.
# Usage: authenticated-git-url.sh <path-or-url>
#   github.com/DeepSpringAI/repo     → https://DeepSpringAI:GITHUB_TOKEN_DeepSpringAI@... (or GITHUB_TOKEN)
#   github.com/foundation-models/repo → https://foundation-models:GITHUB_TOKEN_foundation_models@...
#   dev.azure.com/intappdevops/...   → https://intappdevops:AZURE_DEVOPS_TOKEN@dev.azure.com/intappdevops/...
# Credentials: ~/.config/personal-tokens.env or env. GitHub: GITHUB_TOKEN or GITHUB_TOKEN_<Org> (e.g. GITHUB_TOKEN_DeepSpringAI, GITHUB_TOKEN_foundation_models).

set -e
PATH_RAW="${1:?Usage: $0 <path-or-url>}"

# Load personal tokens if present (do not fail if missing)
[[ -f "$HOME/.config/personal-tokens.env" ]] && source "$HOME/.config/personal-tokens.env" 2>/dev/null || true

# Normalize: strip protocol and trailing .git
path="${PATH_RAW#https://}"
path="${path#http://}"
path="${path%.git}"

if [[ "$path" == github.com/* ]]; then
  # Owner = first path segment (same as username in URL)
  owner="${path#github.com/}"
  owner="${owner%%/*}"
  # Per-org token: GITHUB_TOKEN_<Org> with hyphens → underscores (e.g. foundation-models → foundation_models)
  org_key="${owner//-/_}"
  var_name="GITHUB_TOKEN_${org_key}"
  token="${!var_name:-${GITHUB_TOKEN:-$GH_TOKEN}}"
  token="${token:?Set GITHUB_TOKEN, GH_TOKEN, or ${var_name} for github.com/${owner}}"
  # https://owner:TOKEN@github.com/owner/repo.git
  [[ "$path" == *.git ]] || path="${path}.git"
  echo "https://${owner}:${token}@${path}"
elif [[ "$path" == dev.azure.com/* ]]; then
  # Org = first path segment after host (same as username in URL)
  org="${path#dev.azure.com/}"
  org="${org%%/*}"
  token="${AZURE_DEVOPS_TOKEN:-$INTAPP_DEVOPS_PAT}"
  token="${token:?Set AZURE_DEVOPS_TOKEN or INTAPP_DEVOPS_PAT}"
  # https://org:TOKEN@dev.azure.com/org/proj/_git/repo
  echo "https://${org}:${token}@${path}"
else
  echo "Unsupported host. Use github.com/owner/repo or dev.azure.com/intappdevops/org/proj/_git/repo" >&2
  exit 1
fi
