# macOS Dotfiles & Ansible Playbook

[![CI](https://github.com/ipedro/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/ipedro/dotfiles/actions/workflows/ci.yml)

Automated setup for a new Mac using Ansible. Installs packages, configures dotfiles, and restores secrets from Vaultwarden.

## Quick Start (New Mac)

```zsh
# One-liner bootstrap
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
- **CLIs:** gh, ripgrep, cloc, hugo, iperf3

### Homebrew Casks

VS Code, Fork, Blender, FreeCAD, OpenSCAD, ChatGPT, Google Chrome, Sketch, and more.

### Mac App Store Apps

Xcode, 1Blocker, Bitwarden, Pixelmator Pro, RocketSim, Telegram, WhatsApp, and more.

### Dotfiles

- `.zshrc` / `.zprofile` — Shell configuration
- `.gitconfig` / `.gitignore_global` — Git configuration
- VS Code settings and extensions

### Secrets (via Vaultwarden)

- Environment variables (API keys)
- Sparkle EdDSA signing key
- SSH private keys

## Project Structure

```
dotfiles/
├── main.yml                 # Main playbook (imports roles)
├── config.yml               # All configuration variables
├── install.sh               # Bootstrap script
├── requirements.yml         # Ansible Galaxy dependencies
├── inventory                # Ansible inventory
├── ansible.cfg              # Ansible configuration
├── Brewfile                 # Homebrew bundle (reference)
├── files/                   # Dotfiles to symlink
│   ├── .zshrc
│   ├── .zprofile
│   ├── .gitconfig
│   ├── .gitignore_global
│   └── vscode/settings.json
└── roles/                   # Ansible roles
    ├── homebrew/            # Packages, casks, MAS apps
    ├── dotfiles/            # Shell & git configs
    ├── vscode/              # VS Code settings & extensions
    ├── macos/               # macOS system preferences
    └── secrets/             # Vaultwarden integration
```

## Usage

### Run Full Playbook

```zsh
ansible-playbook main.yml --ask-become-pass
```

### Run Specific Roles

```zsh
# Only Homebrew packages
ansible-playbook main.yml --tags homebrew

# Only dotfiles
ansible-playbook main.yml --tags dotfiles

# Only VS Code
ansible-playbook main.yml --tags vscode

# Only secrets (requires bw unlock)
ansible-playbook main.yml --tags secrets
```

### Restore Secrets from Vaultwarden

```zsh
# Configure and login
bw config server "https://vault.pedro.am"
bw login
export BW_SESSION=$(bw unlock --raw)

# Run secrets restoration
ansible-playbook main.yml --tags secrets
```

This will:

- Write API keys to `~/.zshrc.local`
- Add Sparkle signing key to Keychain
- Restore SSH private keys to `~/.ssh/`

## Configuration

Edit `config.yml` to customize:

- `homebrew_packages` — CLI tools
- `homebrew_casks` — GUI apps
- `mas_apps` — Mac App Store apps
- `vscode_extensions` — VS Code extensions
- `macos_defaults` — System preferences
- `vaultwarden_secrets` — Environment variables
- `sparkle_key` — Sparkle signing key
- `ssh_keys` — SSH keys to restore

## Vaultwarden Items Required

| Item Name | Type | Contents |
|-----------|------|----------|
| `OpenAI API Key` | Login | Password = API key |
| `GitHub Token` | Login | Password = PAT |
| `Sparkle EdDSA Key` | Login | Password = private key |
| `SSH Private Key (ed25519)` | Secure Note | Full key content |
| `SSH Private Key (RSA)` | Secure Note | Full key content |

## Development

### Linting

```zsh
# Install linters
pip install ansible-lint yamllint

# Run linters
yamllint .
ansible-lint
```

### Syntax Check

```zsh
ansible-playbook main.yml --syntax-check
```

### Dry Run

```zsh
ansible-playbook main.yml --check
```

## License

MIT
