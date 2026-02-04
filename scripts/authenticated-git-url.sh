#!/usr/bin/env bash
# Build authenticated git URL: https://OWNER:TOKEN@host/path
# Owner/org is taken from the input path (same as username); only token from env.
# Usage: authenticated-git-url.sh <path-or-url>
#   github.com/DeepSpringAI/repo   → https://DeepSpringAI:GITHUB_TOKEN@github.com/DeepSpringAI/repo.git
#   dev.azure.com/intappdevops/... → https://intappdevops:AZURE_DEVOPS_TOKEN@dev.azure.com/intappdevops/...
# Credentials: env vars GITHUB_TOKEN, AZURE_DEVOPS_TOKEN (or ~/.config/personal-tokens.env).

set -e
PATH_RAW="${1:?Usage: $0 <path-or-url>}"

# Load personal tokens if present (do not fail if missing)
[[ -f "$HOME/.config/personal-tokens.env" ]] && source "$HOME/.config/personal-tokens.env" 2>/dev/null || true

# Normalize: strip protocol and trailing .git
path="${PATH_RAW#https://}"
path="${path#http://}"
path="${path%.git}"

if [[ "$path" == github.com/* ]]; then
  # Owner = first path segment (same as username in URL); we skip a separate GITHUB_USERNAME
  owner="${path#github.com/}"
  owner="${owner%%/*}"
  token="${GITHUB_TOKEN:-$GH_TOKEN}"
  token="${token:?Set GITHUB_TOKEN or GH_TOKEN}"
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
