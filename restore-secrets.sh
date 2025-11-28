#!/bin/zsh
#
# Restore secrets from Vaultwarden
# Requires: bw login && export BW_SESSION=$(bw unlock --raw)
#

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Developer/dotfiles}"

# Check if logged in and unlocked
if ! bw status | grep -q '"status":"unlocked"'; then
    echo "🔐 Please login and unlock Bitwarden first:"
    echo "   bw login"
    echo "   export BW_SESSION=\$(bw unlock --raw)"
    exit 1
fi

echo "🔑 Restoring secrets from Vaultwarden..."

cd "$DOTFILES_DIR"
ansible-playbook main.yml --tags secrets

echo "✅ Secrets restored!"
echo "   - API keys written to ~/.zshrc.local"
echo "   - SSH keys restored to ~/.ssh/"
echo "   - Sparkle key added to Keychain"
