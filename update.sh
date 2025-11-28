#!/bin/zsh
#
# Update script - pull latest dotfiles and re-run changed tasks
# Usage: ./update.sh [--tags homebrew,vscode,...]
#

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Developer/dotfiles}"

cd "$DOTFILES_DIR"

echo "🔄 Pulling latest changes..."
git pull --rebase

echo "📚 Updating Ansible collections..."
ansible-galaxy install -r requirements.yml --force

echo "🎯 Running Ansible playbook..."
if [[ -n "$1" ]]; then
    ansible-playbook main.yml "$@"
else
    ansible-playbook main.yml --ask-become-pass
fi

echo "✅ Update complete!"
