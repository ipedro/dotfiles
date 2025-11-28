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
# 6. Sign in to Mac App Store (required for mas)
# -----------------------------------------------------------------------------
echo "🍎 Checking Mac App Store sign-in..."
if ! mas account &>/dev/null; then
    echo "⚠️  Please sign in to Mac App Store (System Settings > Apple ID) and re-run."
    echo "   Or continue without MAS apps by running: ansible-playbook main.yml --skip-tags mas"
fi

# -----------------------------------------------------------------------------
# 7. Configure Vaultwarden (optional)
# -----------------------------------------------------------------------------
if [[ -n "$BW_URL" ]]; then
    echo "🔐 Configuring Bitwarden CLI for Vaultwarden..."
    brew install bitwarden-cli
    bw config server "$BW_URL"
    echo "   Run 'bw login' to authenticate, then re-run the playbook with --tags secrets"
fi

# -----------------------------------------------------------------------------
# 8. Run the playbook
# -----------------------------------------------------------------------------
echo "🎯 Running Ansible playbook..."
ansible-playbook main.yml --ask-become-pass

# -----------------------------------------------------------------------------
# 9. Post-install reminders
# -----------------------------------------------------------------------------
echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Manual steps remaining:"
echo "   1. Configure Vaultwarden: export BW_URL='https://vault.yourdomain.com'"
echo "      Then: bw login && bw unlock && ansible-playbook main.yml --tags secrets"
echo "   2. Import SSH keys from secure backup or generate new ones"
echo "   3. Import Sparkle signing key from Vaultwarden"
echo "   4. Restart your terminal to apply shell changes"
echo ""
