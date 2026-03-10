#!/usr/bin/env bash
# Symlink all config files to their expected locations

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p ~/.config/fish
rm -rf ~/.config/ghostty
mkdir -p ~/.config/lazygit
mkdir -p ~/.config/mise
mkdir -p ~/.config/zed/themes
mkdir -p ~/.local/bin

ln -sf "$DOTFILES/fish/config.fish"           ~/.config/fish/config.fish
ln -sf "$DOTFILES/ghostty"                     ~/.config/ghostty
ln -sf "$DOTFILES/starship/starship.toml"     ~/.config/starship.toml
ln -sf "$DOTFILES/lazygit/config.yml"         ~/.config/lazygit/config.yml
ln -sf "$DOTFILES/git/gitconfig"              ~/.gitconfig
ln -sf "$DOTFILES/mise/config.toml"           ~/.config/mise/config.toml
ln -sf "$DOTFILES/zed/settings.json"          ~/.config/zed/settings.json
ln -sf "$DOTFILES/zed/keymap.json"            ~/.config/zed/keymap.json
ln -sf "$DOTFILES/zed/themes/blanche.json"    ~/.config/zed/themes/blanche.json
ln -sf "$DOTFILES/bin/tmux-sessionizer"       ~/.local/bin/tmux-sessionizer
