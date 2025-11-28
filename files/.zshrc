# Load secrets from local file (not in git)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# VS Code shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"
