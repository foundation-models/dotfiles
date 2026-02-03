# Dotfiles — Progress Report

## Top progress

- **Dotfiles layout** — Repo structure in place with GNU Stow: `zsh/`, `git/`, `config/` (fish, goose, espanso), plus `mac/` and `linux/` OS-specific scripts.
- **Install flow** — `install.sh` stows non-confidential dotfiles and runs `mac/install.sh` or `linux/install.sh`; espanso on macOS stowed to `~/Library/Application Support/espanso`.
- **Confidential handling** — Separate flow for secrets: `copy-confidential-from-machine.sh` populates `confidential/` from the machine; `install-confidential.sh` deploys it to home. Plaintext `confidential/` stays in `.gitignore`.
- **Encrypted confidential** — SOPS + age: `make encrypt-confidential` produces `confidential.tar.enc`; `make decrypt-confidential` restores `confidential/`. `confidential.tar.enc` is committed and pushed so GitHub secret scanning does not block.
- **Makefile** — Targets: `encrypt-confidential`, `decrypt-confidential`, `commit-encrypted-confidential`. Age public key in `.sops-age-recipients`.
- **Docs** — README with quick start, confidential workflow, and encrypt/decrypt steps; `docs/init.md` with original design notes.

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
