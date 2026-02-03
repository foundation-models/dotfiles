# Insights from mathiasbynens/dotfiles

[mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) is a widely used reference (~31k stars). Below are patterns we adopted and what’s worth knowing.

## Patterns we adopted

### 1. Modular shell config

- **Separate files** for exports, aliases, functions — easier to edit and reuse.
- **`~/.path`** (or in our case, PATH in one place) — extended first so later feature checks see the right binaries.
- **`~/.extra`** (we use **`~/.zsh_extra`**) — for private or machine-specific stuff (git user/email, tokens) that is **never committed**. Source it last so it can override anything.

### 2. Sourcing order (bash_profile-style)

1. `~/.path` — PATH only  
2. Prompt (optional; we keep a simple prompt)  
3. **Exports** — EDITOR, LANG, history size, etc.  
4. **Aliases**  
5. **Functions**  
6. **`~/.extra`** — private overrides  

We mirror this in `.zshrc` by sourcing `.zsh_exports`, `.zsh_aliases`, `.zsh_functions`, then `.zsh_extra` if present.

### 3. Sensible exports

- **EDITOR** — e.g. `vim` (or `code -w` for VS Code).
- **LANG / LC_ALL** — `en_US.UTF-8` to avoid encoding issues.
- **History** — larger `HISTSIZE` / `SAVEHIST`, ignore duplicates and leading-space lines.
- **GPG_TTY** — `$(tty)` so GPG works in the terminal.
- **NODE_REPL_HISTORY** — persistent Node REPL history if you use `node` interactively.

We put these in **`.zsh_exports`** (zsh equivalents where needed).

### 4. Aliases worth having

- **Navigation:** `..`, `...`, `....`, `-` (cd -).
- **ls:** Colorized long listing; `l`, `la`, `lsd`; respect GNU vs macOS `ls` (we use zsh `ls` and `LS_COLORS`/`LSCOLORS`).
- **grep:** `grep --color=auto` (and fgrep/egrep).
- **sudo:** `sudo ' '` so aliases expand after `sudo`.
- **Reload:** `reload` → re-exec login shell.
- **path:** Print each PATH entry on its own line.
- **macOS:** e.g. `flush` (DNS), `cleanup` (.DS_Store), `emptytrash`, `show`/`hide` (Finder hidden files), `cdf` (cd to Finder’s current dir).

We collected the portable and useful ones in **`.zsh_aliases`** and left out or made optional the very macOS-specific or heavy ones.

### 5. Small functions

- **mkd** — `mkdir -p "$@" && cd` into the last dir.
- **cdf** — cd to the frontmost Finder window (macOS).
- **fs** — disk usage for args or current dir.
- **reload** — `exec $SHELL -l`.

We put zsh-compatible versions in **`.zsh_functions`**.

### 6. Readline / input

- **`.inputrc`** — case-insensitive completion, history search on Up/Down, better completion behavior. Used by Bash and by Zsh when using readline-style line editing. We added **`.inputrc`** to the zsh package so it lives in `~` after stow.

### 7. Private config (never commit)

- **`~/.extra`** (mathias) / **`~/.zsh_extra`** (us) — git user.name, user.email, API keys, machine-specific PATH. Document that this file exists and is sourced, but don’t create it in the repo.

## What we didn’t add

- **Full bash_prompt** — Git branch, colors, etc. You can add a theme (e.g. Powerlevel10k) or a small `prompt_git` in zsh later if you want.
- **`.macos`** — Sensible macOS defaults script; you can add it under `mac/` if you want (e.g. `mac/.macos`).
- **`brew.sh`** — List of Homebrew formulae; optional, often kept as `mac/Brewfile` or similar.
- **Bootstrap script** — We use Stow + `install.sh` instead of a copy-based bootstrap.

## References

- Repo: [github.com/mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
- README: install options, `~/.path`, `~/.extra`, `.macos`, `brew.sh`.
