#!/usr/bin/env bash
# Copy dotfiles to their expected locations

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

copy_file() {
  local from="$1"
  local to="$2"

  mkdir -p "$(dirname "$to")"
  cp "$from" "$to"
  echo "    $to"
}

echo "    Copying dotfiles..."

# ghostty
copy_file "$DOTFILES/ghostty/config"                              ~/.config/ghostty/config
copy_file "$DOTFILES/ghostty/themes/Alabaster Dark"               ~/.config/ghostty/themes/Alabaster\ Dark
for shader in "$DOTFILES"/ghostty/shaders/*.glsl; do
  copy_file "$shader" ~/.config/ghostty/shaders/"$(basename "$shader")"
done

# git (XDG: ~/.config/git/config)
copy_file "$DOTFILES/git/config"                                  ~/.config/git/config

# fish
copy_file "$DOTFILES/fish/config.fish"                            ~/.config/fish/config.fish

# zed
copy_file "$DOTFILES/zed/settings.json"                           ~/.config/zed/settings.json
copy_file "$DOTFILES/zed/keymap.json"                             ~/.config/zed/keymap.json
copy_file "$DOTFILES/zed/themes/blanche.json"                     ~/.config/zed/themes/blanche.json

# starship
copy_file "$DOTFILES/starship/starship.toml"                      ~/.config/starship.toml

# lazygit
copy_file "$DOTFILES/lazygit/config.yml"                          ~/.config/lazygit/config.yml

# mise
copy_file "$DOTFILES/mise/config.toml"                            ~/.config/mise/config.toml

# bin
copy_file "$DOTFILES/bin/tmux-sessionizer"                        ~/.local/bin/tmux-sessionizer
chmod +x ~/.local/bin/tmux-sessionizer
