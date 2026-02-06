# Dotfiles — Progress Report

## Top progress

- **Dotfiles layout** — Repo structure in place with GNU Stow: `zsh/`, `git/`, `config/` (fish, goose, espanso), plus `mac/` and `linux/` OS-specific scripts.
- **Install flow** — `install.sh` stows non-confidential dotfiles and runs `mac/install.sh` or `linux/install.sh`; espanso on macOS stowed to `~/Library/Application Support/espanso`.
- **Confidential handling** — Separate flow for secrets: `copy-confidential-from-machine.sh` populates `confidential/` from the machine; `install-confidential.sh` deploys it to home. Plaintext `confidential/` stays in `.gitignore`.
- **Encrypted confidential** — SOPS + age: `make encrypt-confidential` produces `confidential.tar.enc`; `make decrypt-confidential` restores `confidential/`. `confidential.tar.enc` is committed and pushed so GitHub secret scanning does not block.
- **Makefile** — Targets: `encrypt-confidential`, `decrypt-confidential`, `commit-encrypted-confidential`, `update-encrypted-confidential`, `clone`. Age public key in `.sops-age-recipients`.
- **Personal tokens (GitHub + dev.azure.com/intappdevops)** — Placeholder `config/personal-tokens.env.example` (tokens only; owner/org from path = username in URL). Script `scripts/authenticated-git-url.sh` builds `https://owner:TOKEN@...` from path. Copy script pulls `personal-tokens.env` from `~/.config` or workspace `.config/`; encrypted in `confidential.tar.enc`. `make clone REPO=... [DEST=...] [PERSONAL_TOKENS_HOME=...]` clones with auth.
- **Docs** — README with quick start, confidential workflow, encrypt/decrypt, personal-tokens and clone; `docs/repos/token-reference.md` with URL rules; `docs/init.md` with original design notes.

## Status

| Area              | Status   |
|-------------------|----------|
| Shell (zsh)       | Done     |
| Git config        | Done     |
| Config (fish, goose, espanso) | Done |
| Mac / Linux install scripts | Done |
| Confidential copy script    | Done |
| Confidential install script | Done |
| SOPS encryption   | Done     |
| Encrypted push    | Done     |
| Personal tokens placeholder + script | Done |
| Clone with auth (Makefile)   | Done     |
| update-encrypted-confidential | Done |
| Artifactory Docker in personal-tokens.env | Done |

*Last updated: 2025-02-06*

## Changelog

- **2025-02-06:** Added Artifactory Docker credentials to `config/personal-tokens.env.example` (ARTIFACTORY_DOCKER_USER, ARTIFACTORY_DOCKER_TOKEN). Updated `~/.config/personal-tokens.env` and re-ran `copy-confidential-from-machine.sh` + `make encrypt-confidential` so `confidential.tar.enc` includes Artifactory tokens for solver-sandbox `make docker-push`.
- **2025-02-06:** Progress doc refreshed; Cursor rules (workspace + `cursor/` template) and docs (`docs/aks-intapp.md`, `docs/AKS Node Pool.json`) in repo.
