# Token reference (where to store — no values here)

Tokens are **never** listed in this repo. Store them in one place and construct URLs on the fly.

## Where to store

- **Preferred:** Dotfiles `confidential/` (e.g. a small config that lists env var names and paths). After `make decrypt-confidential` and `./install-confidential.sh`, scripts can read from `~/.config/` or a single credentials file.
- **Alternative:** Environment variables in your shell profile or a sourced file (e.g. `~/.local/bin/env`) that is not committed.

## Token types (from legacy notes)

Use these **env var names** (or keys in a confidential config) when building URLs or running APIs. Rotate tokens in one place; no need to grep through repos.

| Purpose | Env var (suggestion) | Used for |
|---------|----------------------|----------|
| GitHub | `GITHUB_TOKEN` or `GH_TOKEN` | Owner from path = username in URL; `https://owner:TOKEN@github.com/owner/repo.git` |
| GitLab | `GITLAB_TOKEN` or `GLPAT` | HTTPS clone, API |
| Hugging Face | `HF_TOKEN` or `HUGGING_FACE_HUB_TOKEN` | Clone HF repos, download models |
| Docker Hub | `DOCKER_PAT` or `DOCKER_TOKEN` | `docker login` (username + token) |
| Artifactory (Docker) | `ARTIFACTORY_DOCKER_TOKEN` | `docker login docker.artifactory.dev.intapp.com` |
| Artifactory (API) | `ARTIFACTORY_API_TOKEN` | Generic Artifactory API |
| Azure DevOps (dev.azure.com/intappdevops) | `AZURE_DEVOPS_TOKEN` or `INTAPP_DEVOPS_PAT` | Org from path = username; `https://org:TOKEN@dev.azure.com/org/...` |
| Intapp persona / MCP | (store in confidential app config) | App-specific; keep in dotfiles confidential |
| OpenAI / MCP | `OPENAI_API_KEY` | API calls (not for git) |
| Weights & Biases | `WANDB_API_KEY` | Experiment tracking |
| Voyage | `VOYAGE_API_KEY` | Embeddings API |
| Brave Search | `BRAVE_SEARCH_API_KEY` | Search API |
| Google / Gemini | (e.g. in project or confidential) | API (not for git) |

## Building authenticated URLs (example)

Owner/org is taken from the input path (same as username); we do not use a separate username env var.

```bash
# GitHub: owner from path (e.g. DeepSpringAI) = username in URL; only token from env
owner=DeepSpringAI repo=my-repo
git clone "https://${owner}:${GITHUB_TOKEN}@github.com/${owner}/${repo}.git"

# Or set remote from catalog + token
owner=foundation-models name=dotfiles
git remote set-url origin "https://${owner}:${GITHUB_TOKEN}@github.com/${owner}/${name}.git"
```

Cursor or a small script can read `owner`/`name` from `repos.yaml` and `GITHUB_TOKEN` from the environment and run the above without ever writing the token into a repo.

## Personal tokens placeholder (GitHub + dev.azure.com/intappdevops)

- **Template:** `config/personal-tokens.env.example` — copy to `~/.config/personal-tokens.env`, fill token values only. Owner/org comes from the path; we skip a separate username.
- **Building URLs:** When asked for a **github.com/...** or **dev.azure.com/intappdevops/...** URL, use **owner (or org) from the input path** as the username in the URL:
  - **GitHub:** `https://<owner-from-path>:${GITHUB_TOKEN}@github.com/owner/repo.git` (e.g. `github.com/DeepSpringAI/repo` → `https://DeepSpringAI:GITHUB_TOKEN@github.com/DeepSpringAI/repo.git`)
  - **Azure DevOps (intappdevops):** `https://<org-from-path>:${AZURE_DEVOPS_TOKEN}@dev.azure.com/org/proj/_git/repo`
- **Script:** From dotfiles repo root, run `./scripts/authenticated-git-url.sh <path>` — it parses owner/org from the path and prints the URL (token from env or `~/.config/personal-tokens.env`):
  ```bash
  ./scripts/authenticated-git-url.sh github.com/DeepSpringAI/repo
  ./scripts/authenticated-git-url.sh dev.azure.com/intappdevops/org/proj/_git/repo
  ```

## Rotation

When you change a token:

1. Update it in dotfiles confidential (or your env source file).
2. Re-run `./install-confidential.sh` if you use dotfiles to deploy it.
3. No need to search/replace across repos; URLs are built on the fly from the single source.
