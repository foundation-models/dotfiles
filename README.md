# dotfiles

Personal dotfiles for macOS and Ubuntu, managed with [GNU Stow](https://www.gnu.org/software/stow/). This repo includes **confidential** files (credentials, .boto, .azure, .gsutil); use a separate script to copy and deploy them.

## Layout

- **`zsh/`** — `.zshrc`, `.zprofile`, `.zsh_exports`, `.zsh_aliases`, `.zsh_functions`, `.inputrc` (modular shell config; private overrides in `~/.zsh_extra`, never committed)
- **`git/`** — `.gitconfig`
- **`config/`** — `~/.config` contents: `fish/`, `goose/`, `espanso/`; `personal-tokens.env.example` is a placeholder for GitHub + dev.azure.com/intappdevops (copy to `~/.config/personal-tokens.env`, fill tokens only; owner/org from path = username in URL; use `./scripts/authenticated-git-url.sh <path>` to build URLs)
- **`scripts/authenticated-git-url.sh`** — Builds `https://owner:TOKEN@...` using owner/org parsed from the path (no separate username env)
- **`confidential/`** — credentials, `.boto`, `.azure`, `.gsutil`, all `~/.config/**/*.toml`, `personal-tokens.env`, `sops/age` (populated by `copy-confidential-from-machine.sh`)
- **`mac/`** — macOS-only install (Homebrew, espanso → `~/Library/Application Support/espanso`)
- **`linux/`** — Ubuntu/Linux install (apt, stow)
- **`docs/`** — Reference (e.g. `docs/HOSSEIN_MACBOOK_SPEC.md` for this machine’s hardware/OS and stack guidance)
- **`install.sh`** — Main installer: stows zsh, git, config; runs OS-specific scripts (does **not** install confidential)
- **`install-confidential.sh`** — Deploys `confidential/` to this machine (run after `./install.sh` if you want secrets)
- **`copy-confidential-from-machine.sh`** — Copies confidential files **from** this machine **into** the repo (run on each machine to refresh `confidential/`)

## Quick start

1. Clone into `~/.dotfiles` or `~/workspace/dotfiles` (or any path).
2. Install Stow:
   - **macOS:** `brew install stow`
   - **Ubuntu:** `sudo apt install stow`
3. From the repo root:
   ```bash
   ./install.sh
   ```
   This stows `zsh`, `git`, and `config` into your home (and `config` into `~/.config`), then runs `mac/install.sh` or `linux/install.sh`. On macOS, espanso `match/base.yml` is symlinked from dotfiles (source of truth) to `~/Library/Application Support/espanso/match/base.yml`.

4. **(Optional)** To deploy confidential files (credentials, .boto, .azure, .gsutil) on this machine:
   ```bash
   ./install-confidential.sh
   ```
   Requires `confidential/` to exist (see below).

## Confidential files

- **Copy from machine into repo** (run on a machine that has the files):
  ```bash
  ./copy-confidential-from-machine.sh
  ```
  This populates `confidential/` from `$HOME` and `$HOME/.config` (credentials, .boto, .azure, .gsutil, sops/age/keys.txt, etc.).

- **Encrypt and commit** (SOPS + age; so you can push without GitHub blocking secrets):
  ```bash
  make encrypt-confidential   # creates confidential.tar.enc from confidential/
  make commit-encrypted-confidential   # stages confidential.tar.enc
  git commit -m "Update encrypted confidential" && git push
  ```
  Requires: `sops`, `age`, and `.sops-age-recipients` with your age public key (or set `SOPS_AGE_RECIPIENTS`).

- **Decrypt on another machine** (restore `confidential/` from the repo):
  ```bash
  export SOPS_AGE_KEY_FILE=path/to/your/age/keys.txt   # or use confidential/.config/sops/age/keys.txt after first decrypt
  make decrypt-confidential
  ./install-confidential.sh
  ```

- **Deploy from repo to this machine** (after `confidential/` exists, e.g. after decrypt):
  ```bash
  ./install-confidential.sh
  ```
  Stows `confidential/` to `$HOME` (and `confidential/.config/*` to `$HOME/.config`).

## Install only some packages

```bash
./install.sh zsh git
./install.sh config   # stows config into ~/.config
```

## Notes

- **`.zprofile`** in `zsh/` is macOS-specific (Homebrew). On Linux you may want a different or empty `.zprofile`.
- Paths in `.zshrc` use `$HOME` so they work on both macOS and Linux.
- **Zsh:** `.zshrc` sources `.zsh_exports`, `.zsh_aliases`, `.zsh_functions`; create **`~/.zsh_extra`** for private overrides (git user/email, tokens, custom aliases) — it is sourced last and should never be committed. See `docs/insights-mathiasbynens.md` for the pattern (from mathiasbynens/dotfiles).
- **Espanso:** On macOS, `config/espanso/match/base.yml` is the source of truth; `mac/install.sh` symlinks it to `~/Library/Application Support/espanso/match/base.yml`. On Linux, it lives under `~/.config/espanso` via `./install.sh config`.
