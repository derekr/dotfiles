#!/usr/bin/env bash
# Install Homebrew and all packages from Brewfile

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

if ! command -v brew &>/dev/null; then
  echo "    Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "    Installing packages..."
brew bundle install --file "$DOTFILES/Brewfile"
