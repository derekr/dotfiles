#!/usr/bin/env bash
# Optional work bootstrap — only runs if dotfiles-work repo exists

WORK_DOTFILES="$HOME/dev/dotfiles-work"

if [ ! -f "$WORK_DOTFILES/install.sh" ]; then
  echo "    No work dotfiles found, skipping"
  exit 0
fi

echo "    Running work bootstrap..."
bash "$WORK_DOTFILES/install.sh"
