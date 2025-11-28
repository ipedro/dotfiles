#!/bin/zsh
#
# Bootstrap script for setting up a new Mac
# Run with: curl -fsSL https://raw.githubusercontent.com/ipedro/dotfiles/main/install.sh | zsh
# Or clone first: git clone https://github.com/ipedro/dotfiles.git ~/Developer/dotfiles && ~/Developer/dotfiles/install.sh
#

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Developer/dotfiles}"
REPO_URL="https://github.com/ipedro/dotfiles.git"

echo "🚀 Starting Mac setup..."

# -----------------------------------------------------------------------------
# 1. Install Xcode Command Line Tools
# -----------------------------------------------------------------------------
if ! xcode-select -p &>/dev/null; then
    echo "📦 Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "⏳ Please complete the Xcode CLI installation and re-run this script."
    exit 1
fi

# -----------------------------------------------------------------------------
# 2. Install Homebrew
# -----------------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# -----------------------------------------------------------------------------
# 3. Clone dotfiles repo if not present
# -----------------------------------------------------------------------------
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "📁 Cloning dotfiles repository..."
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

# -----------------------------------------------------------------------------
# 4. Install Ansible
# -----------------------------------------------------------------------------
if ! command -v ansible &>/dev/null; then
    echo "🤖 Installing Ansible..."
    brew install ansible
fi

# -----------------------------------------------------------------------------
# 5. Install Ansible requirements
# -----------------------------------------------------------------------------
echo "📚 Installing Ansible collections..."
ansible-galaxy install -r requirements.yml

# -----------------------------------------------------------------------------
# 6. Run the playbook
# -----------------------------------------------------------------------------
echo "🎯 Running Ansible playbook..."
ansible-playbook main.yml --ask-become-pass

# -----------------------------------------------------------------------------
# 7. Post-install reminders
# -----------------------------------------------------------------------------
echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Manual steps remaining:"
echo "   1. Edit ~/.zshrc.local with your secrets (API keys, etc.)"
echo "   2. Import SSH keys from secure backup or generate new ones"
echo "   3. Sign in to Mac App Store and install apps manually"
echo "   4. Import Sparkle signing key from Vaultwarden/backup"
echo "   5. Restart your terminal to apply shell changes"
echo ""
