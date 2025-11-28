# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Ruby version manager
eval "$(rbenv init - --no-rehash zsh)"

# Python
export PATH="/opt/homebrew/opt/python@3.14/libexec/bin:$PATH"
