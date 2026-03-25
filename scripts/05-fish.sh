#!/usr/bin/env bash
# Install fish plugins and set as default shell

eval "$(/opt/homebrew/bin/brew shellenv)"

echo "    Installing fish plugins..."
fish -c "
  curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
  fisher install jorgebucaran/fisher PatrickF1/fzf.fish
" 2>/dev/null || echo "    Fisher install failed — run manually after restarting shell"

fish_path="$(which fish)"
if ! grep -q "$fish_path" /etc/shells 2>/dev/null; then
  echo "    Adding fish to /etc/shells..."
  echo "$fish_path" | sudo tee -a /etc/shells
fi
if [ "$SHELL" != "$fish_path" ]; then
  echo "    Setting fish as default shell..."
  chsh -s "$fish_path"
fi
