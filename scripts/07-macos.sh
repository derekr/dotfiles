#!/usr/bin/env bash
# Apply macOS system preferences

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
bash "$DOTFILES/macos/defaults.sh"
