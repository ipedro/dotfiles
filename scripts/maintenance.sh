#!/bin/zsh
#
# Automated maintenance script - runs via LaunchAgent
# Updates Homebrew, MAS apps, and other package managers
#

LOG_FILE="$HOME/.local/log/maintenance.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Starting maintenance ==="

# Homebrew
if command -v brew &>/dev/null; then
    log "Updating Homebrew..."
    brew update >> "$LOG_FILE" 2>&1
    
    log "Upgrading packages..."
    brew upgrade >> "$LOG_FILE" 2>&1
    
    log "Upgrading casks..."
    brew upgrade --cask >> "$LOG_FILE" 2>&1
    
    log "Cleaning up..."
    brew cleanup --prune=30 >> "$LOG_FILE" 2>&1
fi

# Mac App Store
if command -v mas &>/dev/null; then
    log "Upgrading Mac App Store apps..."
    mas upgrade >> "$LOG_FILE" 2>&1
fi

# Mint (Swift CLI tools)
if command -v mint &>/dev/null; then
    log "Updating Mint packages..."
    mint bootstrap >> "$LOG_FILE" 2>&1
fi

# rbenv (check for new Ruby versions, don't auto-install)
if command -v rbenv &>/dev/null; then
    log "Checking rbenv plugins..."
    cd ~/.rbenv && git pull >> "$LOG_FILE" 2>&1 || true
fi

# Cleanup old logs (keep 30 days)
find "$HOME/.local/log" -name "*.log" -mtime +30 -delete 2>/dev/null

log "=== Maintenance complete ==="
