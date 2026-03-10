#!/usr/bin/env bash
# Generate SSH key and add to GitHub via gh CLI

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p ~/.ssh
chmod 700 ~/.ssh
ln -sf "$DOTFILES/ssh/config" ~/.ssh/config
chmod 600 ~/.ssh/config

if [ ! -f ~/.ssh/id_ed25519 ]; then
  echo "    Generating SSH key..."
  ssh-keygen -t ed25519 -C "derekr@users.noreply.github.com" -f ~/.ssh/id_ed25519
fi

if ! gh auth status &>/dev/null; then
  echo "    Authenticate with GitHub..."
  gh auth login -w -p ssh
fi

gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)" 2>/dev/null || echo "    SSH key already on GitHub"
