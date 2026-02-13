# Dotfiles — Progress Report

## Top progress

- **Dotfiles layout** — Repo structure in place with GNU Stow: `zsh/`, `git/`, `config/` (fish, goose, espanso), plus `mac/` and `linux/` OS-specific scripts.
- **Install flow** — `install.sh` stows non-confidential dotfiles and runs `mac/install.sh` or `linux/install.sh`; espanso on macOS stowed to `~/Library/Application Support/espanso`.
- **Confidential handling** — Separate flow for secrets: `copy-confidential-from-machine.sh` populates `confidential/` from the machine; `install-confidential.sh` deploys it to home. Plaintext `confidential/` stays in `.gitignore`.
- **Encrypted confidential** — SOPS + age: `make encrypt-confidential` produces `confidential.tar.enc`; `make decrypt-confidential` restores `confidential/`. `confidential.tar.enc` is committed and pushed so GitHub secret scanning does not block.
- **Makefile** — Targets: `restore-config-toml`, `install-desktop-packages`, `encrypt-confidential`, `decrypt-confidential`, `commit-encrypted-confidential`, `update-encrypted-confidential`, `clone`. Age public key in `.sops-age-recipients`.
- **Desktop packages (Step 3)** — `make install-desktop-packages` runs all installs from `docs/setup-new-desktop.md`: Chrome, Pritunl, Docker, Slack, Telegram, Espanso, Tailscale, Solaar, ngrok, Howdy. Tailscale uses noarmor.gpg for apt verification. Espanso is registered and started as a system service (runs at login).
- **Personal tokens (GitHub + dev.azure.com/intappdevops)** — Placeholder `config/personal-tokens.env.example` (tokens only; owner/org from path = username in URL). Script `scripts/authenticated-git-url.sh` builds `https://owner:TOKEN@...` from path. Copy script pulls `personal-tokens.env` from `~/.config` or workspace `.config/`; encrypted in `confidential.tar.enc`. `make clone REPO=... [DEST=...] [PERSONAL_TOKENS_HOME=...]` clones with auth.
- **Helm chart model** — Generic Helm chart template under `templates/helm/generic-app/` (copied from solver-sandbox patterns) plus an AKS bravo/dev values example and usage doc.
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
| restore-config-toml (SOPS → ~/.config/*.toml) | Done |
| install-desktop-packages (Step 3) | Done |
| Espanso as system service    | Done     |

*Last updated: 2026-02-12*

## Changelog

- **2025-02-11:** `make install-desktop-packages` aligned with `docs/setup-new-desktop.md` Step 3: added Howdy (item 10); Tailscale repo uses noarmor.gpg for GPG verification; Espanso registered and started as system service (runs at login). Progress updated.
- **2025-02-11:** Copy script now includes every `~/.config/**/*.toml` (discovered via `find`) so all TOML config has a SOPS-encrypted copy in `confidential.tar.enc`. Removed hardcoded TOML list; README and progress updated.
- **2025-02-10:** Added `docs/HOSSEIN_MACBOOK_SPEC.md` — M3 Max, 36 GB, macOS Tahoe 26.2; strengths (local AI/MLX/MPS, full-stack, RAG) and limits (no CUDA, full pretraining → cloud).
- **2025-02-08:** Progress doc updated (changelog entry); committed and pushed.
- **2025-02-06:** Added Artifactory Docker credentials to `config/personal-tokens.env.example` (ARTIFACTORY_DOCKER_USER, ARTIFACTORY_DOCKER_TOKEN). Updated `~/.config/personal-tokens.env` and re-ran `copy-confidential-from-machine.sh` + `make encrypt-confidential` so `confidential.tar.enc` includes Artifactory tokens for solver-sandbox `make docker-push`.
- **2025-02-06:** Progress doc refreshed; Cursor rules (workspace + `cursor/` template) and docs (`docs/aks-intapp.md`, `docs/AKS Node Pool.json`) in repo.
- **2026-02-12:** Added reusable Helm chart model `templates/helm/generic-app/` plus doc `docs/HELM_CHART_MODEL.md` and AKS bravo/dev example values. Updated clone/auth scripts to support per-org GitHub tokens (`GITHUB_TOKEN_<Org>`), added Tailscale install helpers, and refreshed docs/progress logging.
