#!/usr/bin/env bash
# Install language runtimes via mise and global pnpm packages

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

export PATH="$HOME/.local/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(mise activate bash)"

echo "    Installing runtimes..."
mise trust "$DOTFILES/mise/config.toml"
mise install --yes

echo "    Installing global pnpm packages..."
pnpm config set global-bin-dir "$HOME/.local/bin"
pnpm install -g @anthropic-ai/claude-code wt
