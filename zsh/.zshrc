# Main zsh config. Modular bits: .zsh_exports, .zsh_aliases, .zsh_functions.
# Private overrides: ~/.zsh_extra (create locally, never commit).

setopt INTERACTIVE_COMMENTS

# PATH: ~/.path is sourced first if it exists (mathiasbynens pattern)
[[ -r ~/.path && -f ~/.path ]] && source ~/.path

# NVM
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"

# Local env (tokens, extra PATH)
[[ -r "$HOME/.local/bin/env" && -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# LM Studio CLI
export PATH="${PATH:+$PATH:}$HOME/.lmstudio/bin"

# PATH
export PATH="$HOME/bin:$PATH"
export PATH="${PATH:+$PATH:}$HOME/Library/Python/3.9/bin"
export PATH="${PATH:+$PATH:}$HOME/.local/bin"

# Modular config (exports, aliases, functions)
for f in ~/.zsh_exports ~/.zsh_aliases ~/.zsh_functions; do
  [[ -r "$f" && -f "$f" ]] && source "$f"
done
unset f

# Short list (reverse time, all, classify)
alias l='ls -lrtFa'

# Private overrides (git user, tokens, machine-specific) — do not commit
[[ -r ~/.zsh_extra && -f ~/.zsh_extra ]] && source ~/.zsh_extra

# Prompt (simple: cwd and %#)
PS1='%1~ %# '

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/Hossein.Akhlaghpour/.lmstudio/bin"
# End of LM Studio CLI section

