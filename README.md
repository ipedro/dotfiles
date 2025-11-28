# macOS Dotfiles & Ansible Playbook

Automated setup for a new Mac using Ansible.

## Quick Start (New Mac)

```zsh
# One-liner (after Xcode CLI tools)
curl -fsSL https://raw.githubusercontent.com/ipedro/dotfiles/main/install.sh | zsh
```

Or clone and run manually:

```zsh
git clone https://github.com/ipedro/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
./install.sh
```

## What's Included

### Homebrew Packages
- **Languages:** Go, Node.js, Python 3.14, Ruby (via rbenv)
- **Swift Tools:** swiftlint, swiftformat, swift-format, mint, xclogparser
- **Utils:** ripgrep, cloc, hugo, iperf3

### Homebrew Casks
- xcodes-app, ollama-app, android-platform-tools, font-fira-code

### Dotfiles
- `.zshrc` / `.zprofile` — Shell configuration
- `.gitconfig` / `.gitignore_global` — Git configuration
- VS Code settings and extensions

### macOS Preferences (Optional)
Set `configure_macos_defaults: true` in `config.yml` to enable:
- Show hidden files & extensions
- Fast key repeat
- Dock auto-hide

## File Structure

```
dotfiles/
├── install.sh          # Bootstrap script
├── main.yml            # Ansible playbook
├── config.yml          # Configuration (packages, extensions, etc.)
├── requirements.yml    # Ansible Galaxy dependencies
├── inventory           # Ansible inventory
├── ansible.cfg         # Ansible configuration
├── Brewfile            # Homebrew bundle (reference)
└── files/
    ├── .zshrc
    ├── .zprofile
    ├── .zshrc.local.example
    ├── .gitconfig
    ├── .gitignore_global
    ├── vscode-extensions.txt
    └── vscode/
        └── settings.json
```

## Running Specific Tasks

```zsh
# Only Homebrew packages
ansible-playbook main.yml --tags homebrew

# Only dotfiles
ansible-playbook main.yml --tags dotfiles

# Only VS Code
ansible-playbook main.yml --tags vscode
```

## Secrets Management

Secrets are NOT stored in this repo. After setup:

1. Edit `~/.zshrc.local` with your API keys
2. Consider using [Vaultwarden](https://github.com/dani-garcia/vaultwarden) for centralized secrets

## Manual Steps

After running the playbook:

1. **SSH Keys** — Import from secure backup or generate new ones
2. **Mac App Store** — Sign in and install apps manually
3. **Sparkle Key** — Import EdDSA signing key from backup
4. **Code Signing** — Regenerate via Xcode / Apple Developer portal
