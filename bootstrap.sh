#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/dev/github.com/derekr/dotfiles"
REPO="derekr/dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
  echo "==> $DOTFILES_DIR already exists, running install..."
  bash "$DOTFILES_DIR/install.sh"
  exit 0
fi

echo "==> Downloading dotfiles..."
mkdir -p "$(dirname "$DOTFILES_DIR")"
curl -fsSL --retry 3 --retry-delay 5 "https://github.com/$REPO/archive/main.tar.gz" | tar xz -C "$(dirname "$DOTFILES_DIR")"
mv "$(dirname "$DOTFILES_DIR")/dotfiles-main" "$DOTFILES_DIR"

echo "==> Running install..."
cd "$DOTFILES_DIR"
bash "$DOTFILES_DIR/install.sh"

# Convert to a proper git repo now that git is available
echo "==> Converting to git clone..."
git -C "$DOTFILES_DIR" init
git -C "$DOTFILES_DIR" remote add origin "git@github.com:$REPO.git"
git -C "$DOTFILES_DIR" fetch origin
git -C "$DOTFILES_DIR" reset origin/main
git -C "$DOTFILES_DIR" branch --set-upstream-to=origin/main main
