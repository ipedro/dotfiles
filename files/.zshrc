# =============================================================================
# Homebrew
# =============================================================================
eval "$(/opt/homebrew/bin/brew shellenv)"

# =============================================================================
# Zsh Plugins (installed via Homebrew)
# =============================================================================
# Syntax highlighting - colors commands as you type
if [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Autosuggestions - suggests commands based on history
if [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
fi

# Better completions
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
  autoload -Uz compinit
  compinit
fi

# =============================================================================
# direnv - auto-load project .envrc files
# =============================================================================
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# =============================================================================
# Load secrets from local file (not in git)
# =============================================================================
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# =============================================================================
# VS Code shell integration
# =============================================================================
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"
