# Espanso config (dotfiles)

**Source-of-truth files** (immune from backup/restore):

- `match/base.yml` — canonical; installed via symlink on macOS. Never overwrite from the installed location or from backup. `mac/install.sh` makes it read-only (chmod 444); to edit run `chmod u+w match/base.yml`.

Install flow: one-way only — dotfiles → install location (symlink). Never copy from install location into these paths.
