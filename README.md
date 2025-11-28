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

1Blocker, Bitwarden, Pixelmator Pro, RocketSim, Telegram, WhatsApp, TestFlight, and more.

### Xcode

Installed via [xcodes](https://github.com/xcodeReleases/xcodes) CLI for better version control. Requires Apple ID credentials in Vaultwarden for automation.

### Dotfiles

- `.zshrc` / `.zprofile` — Shell configuration
- `.gitconfig` — Git config with **SSH commit signing** enabled
- `.gitignore_global` — Global gitignore
- VS Code settings and extensions

> **Note:** Existing dotfiles are automatically backed up before being replaced (e.g., `.zshrc.backup.1732789200`)

### macOS Configuration

- **System Preferences** — Finder, Dock, Keyboard, Safari developer settings
- **Touch ID for sudo** — Use fingerprint for terminal authentication
- **Dock apps** — Configured in order with your preferred apps
- **Automated maintenance** — Weekly updates via LaunchAgent (Sundays 10 AM)

### Secrets (via Vaultwarden)

- Environment variables (API keys)
- Sparkle EdDSA signing key
- SSH private keys

## Project Structure

```text
dotfiles/
├── main.yml                 # Main playbook (imports roles)
├── config.yml               # All configuration variables
├── install.sh               # Bootstrap script
├── requirements.yml         # Ansible Galaxy dependencies
├── inventory                # Ansible inventory
├── ansible.cfg              # Ansible configuration
├── files/                   # Dotfiles to symlink
│   ├── .zshrc
│   ├── .zprofile
│   ├── .gitconfig           # Git config with SSH signing
│   ├── .gitignore_global
│   ├── ssh_config           # SSH config (optional)
│   └── vscode/settings.json
├── Brewfile                 # Homebrew bundle (reference)
└── roles/                   # Ansible roles
    ├── workspace/           # ~/Developer folder & repo cloning
    ├── homebrew/            # Packages, casks, MAS apps
    ├── dotfiles/            # Shell & git configs (with backup)
    ├── vscode/              # VS Code settings & extensions
    ├── macos/               # System prefs, Dock, Touch ID
    ├── devtools/            # rbenv, Mint, Xcode setup
    └── secrets/             # Vaultwarden integration
```

## Usage

### Run Full Playbook

```zsh
ansible-playbook main.yml --ask-become-pass
```

### Update Existing Setup

```zsh
./update.sh                     # Pull latest and re-run
./update.sh --tags homebrew     # Update specific roles only
```

### Restore Secrets Only

```zsh
./restore-secrets.sh            # Requires bw login first
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
- `dock_apps` — Dock apps (in order)
- `enable_touchid_sudo` — Touch ID for terminal sudo
- `enable_maintenance_schedule` — Weekly auto-updates
- `timemachine_exclusions` — Paths to exclude from backups
- `developer_repos` — Git repos to clone into ~/Developer
- `ruby_version` — Ruby version for rbenv
- `mint_packages` — Swift CLI tools
- `xcode_version` — Xcode version for xcodes
- `vaultwarden_secrets` — Environment variables
- `sparkle_key` — Sparkle signing key
- `ssh_keys` — SSH keys to restore

## Automated Maintenance

A LaunchAgent runs weekly (Sundays at 10 AM) to keep your system updated:

- `brew update && brew upgrade` — Homebrew packages and casks
- `mas upgrade` — Mac App Store apps
- `mint bootstrap` — Swift CLI tools
- Cleanup old cached files

**Logs:** `~/.local/log/maintenance.log`

**Manual run:** `~/Developer/dotfiles/scripts/maintenance.sh`

**Disable:** Set `enable_maintenance_schedule: false` in `config.yml`

## Vaultwarden Items Required

| Item Name | Type | Contents |
|-----------|------|----------|
| `OpenAI API Key` | Login | Password = API key |
| `GitHub Token` | Login | Password = PAT |
| `Apple ID Credentials` | Login | Username + Password for xcodes |
| `Sparkle EdDSA Key` | Login | Password = private key |
| `SSH Private Key (ed25519)` | Secure Note | Full key content |
| `SSH Private Key (RSA)` | Secure Note | Full key content |

## Post-Install: Enable Git SSH Signing on GitHub

After setup, add your SSH signing key to GitHub:

1. Copy your public key: `cat ~/.ssh/id_ed25519.pub | pbcopy`
2. Go to [GitHub SSH Keys](https://github.com/settings/keys)
3. Click "New SSH key" → Key type: **Signing Key**
4. Paste and save

Your commits will now show as "Verified" ✓

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
