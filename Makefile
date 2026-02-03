# Dotfiles Makefile: encrypt/decrypt confidential with SOPS + age
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

SOPS_AGE_RECIPIENTS ?= $(shell grep '^age' .sops-age-recipients 2>/dev/null | head -1 || true)
CONFIDENTIAL_ENC := confidential.tar.enc

.PHONY: encrypt-confidential decrypt-confidential commit-encrypted-confidential

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

# Encrypt and stage the encrypted file for commit (does not commit or push).
commit-encrypted-confidential: encrypt-confidential
	git add $(CONFIDENTIAL_ENC)
	@echo "Staged $(CONFIDENTIAL_ENC). Run: git commit -m 'Update encrypted confidential' && git push"
