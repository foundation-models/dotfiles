# Dotfiles Makefile: encrypt/decrypt confidential with SOPS + age; clone repos with auth
#
# Prerequisites:
#   - sops: brew install sops (or apt install sops)
#   - age:  brew install age   (or apt install age-encryption)
#
# For encryption: set SOPS_AGE_RECIPIENTS to your age public key, or create
#   .sops-age-recipients with one line (your public key).
#   Get public key from existing secret key: age-keygen -y < path/to/keys.txt
#
# For decryption: set SOPS_AGE_KEY_FILE to your age secret key file
#   (e.g. $HOME/.config/sops/age/keys.txt or confidential/.config/sops/age/keys.txt)

DOTFILES_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
SOPS_AGE_RECIPIENTS ?= $(shell grep '^age' $(DOTFILES_DIR).sops-age-recipients 2>/dev/null | head -1 || true)
CONFIDENTIAL_ENC := confidential.tar.enc

.PHONY: encrypt-confidential decrypt-confidential commit-encrypted-confidential update-encrypted-confidential clone install-tailscale

# Encrypt entire confidential/ into confidential.tar.enc (SOPS + age).
# Requires: confidential/ to exist (run ./copy-confidential-from-machine.sh first).
# Requires: SOPS_AGE_RECIPIENTS set or .sops-age-recipients file with your age public key.
encrypt-confidential:
	@test -d confidential || (echo "Error: confidential/ not found. Run ./copy-confidential-from-machine.sh first." && exit 1)
	@test -n "$(SOPS_AGE_RECIPIENTS)" || (echo "Error: Set SOPS_AGE_RECIPIENTS or create .sops-age-recipients with your age public key (one line)." && exit 1)
	@rm -f confidential.tar
	tar -cf confidential.tar confidential
	SOPS_AGE_RECIPIENTS="$(SOPS_AGE_RECIPIENTS)" sops --encrypt --input-type binary --output-type binary --output $(CONFIDENTIAL_ENC) confidential.tar
	@rm -f confidential.tar
	@echo "Created $(CONFIDENTIAL_ENC). You can commit and push it."

# Decrypt confidential.tar.enc back into confidential/.
# Requires: SOPS_AGE_KEY_FILE pointing to your age secret key file.
decrypt-confidential:
	@test -f $(CONFIDENTIAL_ENC) || (echo "Error: $(CONFIDENTIAL_ENC) not found." && exit 1)
	@test -n "$$SOPS_AGE_KEY_FILE" || (echo "Error: Set SOPS_AGE_KEY_FILE to your age secret key file." && exit 1)
	sops --decrypt $(CONFIDENTIAL_ENC) | tar -xf -
	@echo "Extracted confidential/."

# Reconstruct all ~/.config/*.toml from the encrypted confidential.tar.enc.
# Prompts for SOPS age passphrase (and key file path if SOPS_AGE_KEY_FILE is not set).
# Run from dotfiles root. Requires: sops, age.
restore-config-toml:
	@$(DOTFILES_DIR)scripts/restore-config-toml.sh

# Install all desktop packages (Chrome, Pritunl, Docker, Slack, Telegram, Espanso, Tailscale, Solaar, ngrok, Howdy).
# Ubuntu/Debian only. Skips already-installed items. Run from dotfiles root; sudo used throughout.
# After: log out/in for docker group; run ./install.sh config for Espanso; run sudo tailscale up if needed.
install-desktop-packages:
	@$(DOTFILES_DIR)scripts/install-desktop-packages.sh

# Encrypt and stage the encrypted file for commit (does not commit or push).
commit-encrypted-confidential: encrypt-confidential
	git add $(CONFIDENTIAL_ENC)
	@echo "Staged $(CONFIDENTIAL_ENC). Run: git commit -m 'Update encrypted confidential' && git push"

# Copy confidential from this machine (including personal-tokens.env from ~/.config or workspace/.config),
# then encrypt and stage. Ensures the encrypted bundle in the repo includes personal-tokens.env.
# Run from dotfiles root (or any dir). Then: git commit -m 'Update encrypted confidential' && git push
update-encrypted-confidential:
	@cd $(DOTFILES_DIR) && ./copy-confidential-from-machine.sh
	@$(MAKE) -C $(DOTFILES_DIR) commit-encrypted-confidential

# Clone a repo using authenticated URL (GitHub or dev.azure.com/intappdevops).
# Uses scripts/authenticated-git-url.sh and personal tokens from env or ~/.config/personal-tokens.env.
#
# Usage:
#   make clone REPO=dev.azure.com/intappdevops/AI/_git/ai-helm-charts [DEST=../ai-helm-charts] [PERSONAL_TOKENS_HOME=/path/to/workspace]
#   make clone REPO=github.com/DeepSpringAI/repo [DEST=../repo]
#
#   REPO                  — path or URL (required)
#   DEST                  — clone destination dir (default: repo name, e.g. ai-helm-charts or repo)
#   PERSONAL_TOKENS_HOME  — if set, use as HOME when resolving personal-tokens.env (e.g. workspace path)
#
# Run from dotfiles repo root. Clone runs from CWD; use DEST=../ai-helm-charts to clone into parent (e.g. workspace).
clone:
	@test -n "$(REPO)" || (echo "Error: Set REPO= (e.g. dev.azure.com/intappdevops/AI/_git/ai-helm-charts or github.com/owner/repo)" && exit 1)
	@[ -n "$(PERSONAL_TOKENS_HOME)" ] && export HOME="$(PERSONAL_TOKENS_HOME)"; \
	url=$$($(DOTFILES_DIR)scripts/authenticated-git-url.sh "$(REPO)"); \
	git clone "$$url" "$(or $(DEST),$(notdir $(REPO)))"

# Install Tailscale on macOS (for SSH/remote access without port forwarding; see docs/mac-remote-login-ssh.md).
# Then open Tailscale app to sign in; remote users can ssh you@$(tailscale ip -4).
install-tailscale:
	@command -v brew >/dev/null 2>&1 || (echo "Error: Homebrew required. Run mac/install.sh first." && exit 1)
	brew install --cask tailscale
	@echo "Tailscale installed. Open Tailscale from Applications (or menu bar) to sign in and connect."
	@echo "Your Tailscale IP (after connecting): $$(tailscale ip -4 2>/dev/null || echo 'run after signing in')"
