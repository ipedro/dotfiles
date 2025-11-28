#!/bin/bash
#
# 🚀 Pedro's Mac Bootstrap
# One command to rule them all
#
# Usage: curl -fsSL https://raw.githubusercontent.com/ipedro/dotfiles/main/bootstrap.sh | bash
#

set -e

echo ""
echo "🚀 Pedro's Mac Bootstrap"
echo "========================"
echo ""

# Install Xcode Command Line Tools if needed
if ! xcode-select -p &> /dev/null; then
    echo "📦 Installing Xcode Command Line Tools..."
    xcode-select --install
    
    echo "⏳ Waiting for Xcode Command Line Tools..."
    until xcode-select -p &> /dev/null; do
        sleep 5
    done
    echo "✅ Xcode Command Line Tools installed"
fi

# Install Homebrew if needed
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add Homebrew to PATH for this session
eval "$(/opt/homebrew/bin/brew shellenv)"

# Clone dotfiles
DOTFILES_DIR="$HOME/Developer/dotfiles"
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "📂 Cloning dotfiles..."
    mkdir -p "$HOME/Developer"
    git clone https://github.com/ipedro/dotfiles.git "$DOTFILES_DIR"
else
    echo "📂 Updating dotfiles..."
    git -C "$DOTFILES_DIR" pull
fi

# Run interactive setup
echo ""
echo "🎯 Starting interactive setup..."
echo ""
cd "$DOTFILES_DIR"
exec ./setup.sh
