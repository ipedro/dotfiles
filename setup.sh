#!/bin/bash
#
# 🚀 Pedro's Mac Setup Script
# Interactive guide for setting up a new Mac
#

set -e

# =============================================================================
# Colors and formatting
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# =============================================================================
# Helper functions
# =============================================================================
print_header() {
    echo ""
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${MAGENTA}  $1${NC}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${BOLD}${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${DIM}  $1${NC}"
}

wait_for_user() {
    echo ""
    echo -e "${BOLD}${YELLOW}Press Enter to continue...${NC}"
    read -r
}

ask_yes_no() {
    while true; do
        echo -e "${BOLD}${BLUE}$1 [y/n]${NC} "
        read -r yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

check_command() {
    command -v "$1" &> /dev/null
}

# =============================================================================
# Welcome
# =============================================================================
clear
echo ""
echo -e "${BOLD}${MAGENTA}"
cat << "EOF"
    ____           __           _          __  ___           
   / __ \___  ____/ /________  ( )_____   /  |/  /___ ______
  / /_/ / _ \/ __  / ___/ __ \|// ___/  / /|_/ / __ `/ ___/
 / ____/  __/ /_/ / /  / /_/ / (__  )  / /  / / /_/ / /__  
/_/    \___/\__,_/_/   \____/ /____/  /_/  /_/\__,_/\___/  
                                                           
         ____       __                 _____           _       __ 
        / __/___   / /_ __  __ ____   / ___/ ____ ____(_)___  / /_
        \__ \/ _ \/ __// / / // __ \  \__ \ / __// __// // _ \/ __/
       ___/ /  __/ /_ / /_/ // /_/ / ___/ // /_ / /  / // /_/ / /_  
      /____/\___/\__/ \__,_// .___/ /____/ \__//_/  /_// .___/\__/  
                           /_/                        /_/           
EOF
echo -e "${NC}"
echo -e "${DIM}  Automated Mac development environment setup${NC}"
echo ""
echo -e "${CYAN}  This script will guide you through:${NC}"
echo -e "  ${DIM}1.${NC} Installing Xcode Command Line Tools"
echo -e "  ${DIM}2.${NC} Installing Homebrew"
echo -e "  ${DIM}3.${NC} Installing Ansible"
echo -e "  ${DIM}4.${NC} Signing into Mac App Store"
echo -e "  ${DIM}5.${NC} Setting up SSH keys"
echo -e "  ${DIM}6.${NC} Configuring Vaultwarden/Bitwarden"
echo -e "  ${DIM}7.${NC} Running the Ansible playbook"
echo ""

wait_for_user

# =============================================================================
# Step 1: Xcode Command Line Tools
# =============================================================================
print_header "Step 1/7: Xcode Command Line Tools"

if xcode-select -p &> /dev/null; then
    print_success "Xcode Command Line Tools already installed"
else
    print_step "Installing Xcode Command Line Tools..."
    print_info "A dialog will appear. Click 'Install' and wait for it to complete."
    echo ""
    xcode-select --install 2>/dev/null || true
    
    echo ""
    print_warning "Waiting for Xcode Command Line Tools installation..."
    print_info "This can take 5-10 minutes. The script will continue when done."
    echo ""
    
    # Wait for installation to complete
    until xcode-select -p &> /dev/null; do
        sleep 5
    done
    
    print_success "Xcode Command Line Tools installed!"
fi

# =============================================================================
# Step 2: Homebrew
# =============================================================================
print_header "Step 2/7: Homebrew"

if check_command brew; then
    print_success "Homebrew already installed"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    print_step "Installing Homebrew..."
    print_info "You may be prompted for your password."
    echo ""
    
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add to current shell
    eval "$(/opt/homebrew/bin/brew shellenv)"
    
    print_success "Homebrew installed!"
fi

# Update Homebrew
print_step "Updating Homebrew..."
brew update --quiet
print_success "Homebrew updated"

# =============================================================================
# Step 3: Ansible
# =============================================================================
print_header "Step 3/7: Ansible"

if check_command ansible; then
    print_success "Ansible already installed"
else
    print_step "Installing Ansible..."
    brew install ansible
    print_success "Ansible installed!"
fi

# =============================================================================
# Step 4: Mac App Store
# =============================================================================
print_header "Step 4/7: Mac App Store Sign-in"

print_info "The setup will install apps from the Mac App Store."
print_info "You need to be signed in for this to work."
echo ""

if ask_yes_no "Are you signed into the Mac App Store?"; then
    print_success "Mac App Store ready"
else
    print_step "Opening Mac App Store..."
    open -a "App Store"
    echo ""
    print_warning "Please sign in to the Mac App Store with your Apple ID."
    print_info "Go to the bottom left corner and click 'Sign In'"
    wait_for_user
fi

# Install mas CLI if needed
if ! check_command mas; then
    print_step "Installing mas (Mac App Store CLI)..."
    brew install mas
fi

# Verify sign-in
if mas account &> /dev/null; then
    print_success "Mac App Store signed in as: $(mas account)"
else
    print_warning "Could not verify Mac App Store sign-in."
    print_info "MAS apps will be skipped if not signed in."
fi

# =============================================================================
# Step 5: SSH Keys
# =============================================================================
print_header "Step 5/7: SSH Keys for GitHub"

SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_PUB="$HOME/.ssh/id_ed25519.pub"

if [[ -f "$SSH_KEY" ]]; then
    print_success "SSH key already exists"
else
    print_info "An SSH key is needed for:"
    print_info "  • Cloning your private repositories"
    print_info "  • Signing Git commits"
    echo ""
    
    if ask_yes_no "Do you have your SSH key backed up in Vaultwarden?"; then
        print_info "Great! We'll restore it from Vaultwarden in step 6."
        RESTORE_SSH_FROM_VAULT=true
    else
        if ask_yes_no "Generate a new SSH key?"; then
            print_step "Generating SSH key..."
            mkdir -p "$HOME/.ssh"
            chmod 700 "$HOME/.ssh"
            
            echo -e "${CYAN}Enter your email for the SSH key:${NC}"
            read -r ssh_email
            
            ssh-keygen -t ed25519 -C "$ssh_email" -f "$SSH_KEY"
            
            # Start ssh-agent and add key
            eval "$(ssh-agent -s)"
            ssh-add "$SSH_KEY"
            
            print_success "SSH key generated!"
            echo ""
            print_warning "You need to add this key to GitHub."
            echo ""
            echo -e "${BOLD}Your public key:${NC}"
            echo ""
            cat "$SSH_PUB"
            echo ""
            
            # Copy to clipboard
            cat "$SSH_PUB" | pbcopy
            print_success "Public key copied to clipboard!"
            echo ""
            
            if ask_yes_no "Open GitHub SSH settings page?"; then
                open "https://github.com/settings/ssh/new"
            fi
            
            print_info "Paste the key, give it a name, and click 'Add SSH Key'"
            wait_for_user
        fi
    fi
fi

# Test GitHub connection if key exists
if [[ -f "$SSH_KEY" ]]; then
    print_step "Testing GitHub SSH connection..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        print_success "GitHub SSH connection working!"
    else
        print_warning "GitHub SSH test inconclusive. You may need to add the key to GitHub."
    fi
fi

# =============================================================================
# Step 6: Vaultwarden/Bitwarden
# =============================================================================
print_header "Step 6/7: Vaultwarden (Secrets)"

print_info "Your API keys, SSH keys, and Apple ID credentials are stored in Vaultwarden."
print_info "Server: vault.pedro.am"
echo ""

# Install Bitwarden CLI if needed
if ! check_command bw; then
    print_step "Installing Bitwarden CLI..."
    brew install bitwarden-cli
fi

if ask_yes_no "Set up Vaultwarden now? (required for secrets and Xcode install)"; then
    # Configure server
    print_step "Configuring Vaultwarden server..."
    bw config server https://vault.pedro.am
    
    # Check if already logged in
    if bw status 2>/dev/null | grep -q '"status":"unlocked"'; then
        print_success "Already logged in and unlocked"
    elif bw status 2>/dev/null | grep -q '"status":"locked"'; then
        print_step "Vault is locked. Please unlock..."
        export BW_SESSION=$(bw unlock --raw)
        print_success "Vault unlocked!"
    else
        print_step "Please log in to Vaultwarden..."
        echo ""
        bw login
        export BW_SESSION=$(bw unlock --raw)
        print_success "Logged in and unlocked!"
    fi
    
    # Restore SSH key if needed
    if [[ "$RESTORE_SSH_FROM_VAULT" == "true" ]] && [[ ! -f "$SSH_KEY" ]]; then
        print_step "Restoring SSH key from Vaultwarden..."
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        
        bw get notes "SSH Private Key (ed25519)" > "$SSH_KEY"
        chmod 600 "$SSH_KEY"
        ssh-keygen -y -f "$SSH_KEY" > "$SSH_PUB"
        chmod 644 "$SSH_PUB"
        
        eval "$(ssh-agent -s)"
        ssh-add "$SSH_KEY"
        
        print_success "SSH key restored from Vaultwarden!"
    fi
    
    VAULTWARDEN_READY=true
else
    print_warning "Skipping Vaultwarden setup."
    print_info "Secrets role will be skipped during playbook run."
    VAULTWARDEN_READY=false
fi

# =============================================================================
# Step 7: Run Ansible Playbook
# =============================================================================
print_header "Step 7/7: Running Ansible Playbook"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

print_info "This will configure your entire Mac:"
echo ""
echo -e "  ${CYAN}•${NC} Homebrew packages, casks, and Mac App Store apps"
echo -e "  ${CYAN}•${NC} Shell configuration (zsh plugins, direnv)"
echo -e "  ${CYAN}•${NC} Git configuration with SSH signing"
echo -e "  ${CYAN}•${NC} VS Code extensions and settings"
echo -e "  ${CYAN}•${NC} macOS defaults (Dock, Finder, keyboard, screenshots)"
echo -e "  ${CYAN}•${NC} Developer tools (rbenv, Ruby, Mint, Xcode)"
echo -e "  ${CYAN}•${NC} App configs (Terminal, Fork, BetterDisplay, Xcode themes)"
echo -e "  ${CYAN}•${NC} Clone your repositories to ~/Developer"
if [[ "$VAULTWARDEN_READY" == "true" ]]; then
    echo -e "  ${CYAN}•${NC} API keys and secrets from Vaultwarden"
fi
echo ""

# Build skip tags
SKIP_TAGS=""
if [[ "$VAULTWARDEN_READY" != "true" ]]; then
    SKIP_TAGS="--skip-tags secrets"
fi

print_warning "You will be prompted for your sudo password."
echo ""

if ask_yes_no "Ready to run the playbook?"; then
    print_step "Running Ansible playbook..."
    echo ""
    
    # Install Ansible requirements
    if [[ -f "requirements.yml" ]]; then
        ansible-galaxy collection install -r requirements.yml
    fi
    
    # Run playbook
    if [[ -n "$SKIP_TAGS" ]]; then
        ansible-playbook main.yml --ask-become-pass $SKIP_TAGS
    else
        ansible-playbook main.yml --ask-become-pass
    fi
    
    echo ""
    print_success "Playbook completed!"
else
    print_info "You can run the playbook later with:"
    echo ""
    echo -e "  ${CYAN}cd ~/Developer/dotfiles${NC}"
    echo -e "  ${CYAN}ansible-playbook main.yml --ask-become-pass${NC}"
fi

# =============================================================================
# Finish
# =============================================================================
print_header "🎉 Setup Complete!"

echo -e "${GREEN}Your Mac is configured!${NC}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} ${BOLD}Restart your Mac${NC} for all settings to take effect"
echo -e "  ${CYAN}2.${NC} Open a new terminal to load zsh plugins"
echo -e "  ${CYAN}3.${NC} Open Xcode once to complete setup"
echo ""
echo -e "${BOLD}Useful commands:${NC}"
echo ""
echo -e "  ${DIM}# Update everything (runs weekly automatically)${NC}"
echo -e "  ${CYAN}~/.local/bin/maintenance.sh${NC}"
echo ""
echo -e "  ${DIM}# Re-run full setup${NC}"
echo -e "  ${CYAN}cd ~/Developer/dotfiles && ansible-playbook main.yml --ask-become-pass${NC}"
echo ""
echo -e "  ${DIM}# Run specific parts${NC}"
echo -e "  ${CYAN}ansible-playbook main.yml --tags macos${NC}"
echo -e "  ${CYAN}ansible-playbook main.yml --tags homebrew${NC}"
echo ""
echo -e "${DIM}Dotfiles repo: github.com/ipedro/dotfiles${NC}"
echo ""
