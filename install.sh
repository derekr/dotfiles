#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing from $DOTFILES"

# --- Xcode CLI tools ---
if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode CLI tools..."
  xcode-select --install
  echo "    Waiting for Xcode CLI tools to finish. Re-run this script after."
  exit 0
fi

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- Brew packages ---
echo "==> Installing Brew packages..."
brew bundle --file="$DOTFILES/Brewfile" --no-lock

# --- SSH ---
echo "==> Setting up SSH..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ln -sf "$DOTFILES/ssh/config" ~/.ssh/config
chmod 600 ~/.ssh/config

if [ ! -f ~/.ssh/id_ed25519 ]; then
  echo "    Generating SSH key..."
  ssh-keygen -t ed25519 -C "derekr@users.noreply.github.com" -f ~/.ssh/id_ed25519
  echo ""
  echo "    Add this key to GitHub: https://github.com/settings/ssh/new"
  echo ""
  cat ~/.ssh/id_ed25519.pub
  echo ""
  read -p "    Press Enter after adding the key to GitHub..."
fi

# --- Symlinks ---
echo "==> Linking config files..."
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

# --- Fish plugins (fisher + fzf.fish) ---
echo "==> Installing fish plugins..."
fish -c "
  curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
  fisher install jorgebucaran/fisher PatrickF1/fzf.fish
" 2>/dev/null || echo "    Fisher install failed — run manually after restarting shell"

# --- Runtimes (mise) ---
echo "==> Installing runtimes via mise..."
eval "$(mise activate bash)"
mise install --yes

# --- Global packages ---
echo "==> Installing global pnpm packages..."
pnpm install -g @anthropic-ai/claude-code wt

# --- Fish as default shell ---
fish_path="$(which fish)"
if ! grep -q "$fish_path" /etc/shells 2>/dev/null; then
  echo "==> Adding fish to /etc/shells..."
  echo "$fish_path" | sudo tee -a /etc/shells
fi
if [ "$SHELL" != "$fish_path" ]; then
  echo "==> Setting fish as default shell..."
  chsh -s "$fish_path"
fi

# --- macOS defaults ---
echo "==> Applying macOS defaults..."
bash "$DOTFILES/macos/defaults.sh"

# --- Work bootstrap (optional) ---
WORK_DOTFILES="$HOME/dev/dotfiles-work"
if [ -f "$WORK_DOTFILES/install.sh" ]; then
  echo "==> Running work bootstrap..."
  bash "$WORK_DOTFILES/install.sh"
fi

# --- Manual steps ---
echo ""
echo "==> Done! Manual steps remaining:"
echo ""
echo "  1. Restart your terminal (fish + starship + atuin)"
echo "  2. atuin login"
echo "  3. Sign into Chrome / Chrome Canary"
echo ""
