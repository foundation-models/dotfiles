# Repo catalog and token handling

This folder holds a **searchable index of your repositories** (no tokens) so you or Cursor can find the right repo and build clone URLs on the fly using tokens stored elsewhere.

## Contents

| File | Purpose |
|------|---------|
| **repos.yaml** | Canonical list of repos: provider, owner, name, optional description/tags. No secrets. |
| **token-reference.md** | Which tokens exist and where to store them (env vars / dotfiles confidential). No actual values. |

## How to use with Cursor

1. **Search** — Ask Cursor to search `repos.yaml` by description, name, or tags (e.g. "find my repo for document AI", "repos tagged erpnext").
2. **URLs on the fly** — Tokens live in one place (see token-reference.md). Cursor (or a script) can:
   - Read the token from env or from dotfiles confidential.
   - Build the authenticated URL when needed: `https://<user>:<token>@github.com/<owner>/<name>.git`.
   - Run `git clone`, `git remote set-url`, or `git pull` without ever committing a token.
3. **Update token once** — When you rotate a PAT, update it in dotfiles confidential (or your env) and re-run `install-confidential`; all URLs built from it stay correct.

## Clone URL templates (no token in repo)

- **GitHub:** `https://github.com/{owner}/{name}.git` — use `GITHUB_TOKEN` (or credential helper) for HTTPS auth.
- **Hugging Face:** `https://huggingface.co/{owner}/{name}` — use `HF_TOKEN` or `HUGGING_FACE_HUB_TOKEN`.
- **Azure DevOps:** `https://dev.azure.com/{org}/{project}/_git/{name}` — use `AZURE_DEVOPS_TOKEN` (or PAT in URL when constructing locally).
- **GitLab:** `https://gitlab.com/{namespace}/{name}.git` — use `GITLAB_TOKEN`.

See **token-reference.md** for env var names and where to store tokens (e.g. dotfiles `confidential/`).

## Syncing the catalog

To refresh the list from GitHub/GitLab APIs (and get descriptions), see the design in [../chat-git-repos.md](../chat-git-repos.md). You can run a sync script that uses your tokens from env to fetch repo metadata and update `repos.yaml`.
