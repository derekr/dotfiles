# dotfiles

Personal dev environment for macOS. One script to go from a fresh machine to a working setup.

## What's included

- **Shell** — fish + starship prompt + atuin history sync
- **Terminal** — Ghostty with custom shaders and split keybinds
- **Editor** — Zed (preview) with vim mode, Alabaster Dark + gruvbox overrides
- **Git** — delta diffs, lazygit, sensible defaults
- **Runtimes** — mise for node, go, python version management
- **Tools** — ripgrep, fd, fzf, bat, eza, zoxide, yazi, tmux, and more
- **macOS** — fast key repeat, autohide dock, tap to click, screenshots to ~/Screenshots

## Install

One-liner for a fresh machine (no git required):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/derekr/dotfiles/main/bootstrap.sh)
```

Or if you already have git:

```bash
git clone git@github.com:derekr/dotfiles.git ~/dev/github.com/derekr/dotfiles
~/dev/github.com/derekr/dotfiles/install.sh
```

## Scripts

The install runs numbered scripts in order. Each can also be run individually:

```
scripts/01-xcode.sh     # Xcode CLI tools
scripts/02-brew.sh      # Homebrew and Brewfile packages
scripts/03-ssh.sh       # SSH key generation + GitHub auth via gh
scripts/04-symlinks.sh  # Symlink all config files
scripts/05-fish.sh      # Fish plugins and default shell
scripts/06-runtimes.sh  # mise runtimes (node, go, python) + global pnpm packages
scripts/07-macos.sh     # macOS system preferences
scripts/08-work.sh      # Optional work bootstrap (if ~/dev/dotfiles-work exists)
```

Re-run a single step:

```bash
bash scripts/06-runtimes.sh
```

## Structure

```
Brewfile              # Homebrew packages and casks
install.sh            # Orchestrator — runs scripts/ in order
bootstrap.sh          # One-liner entry point for fresh machines
scripts/              # Individual install steps (re-runnable)
fish/config.fish      # Fish shell config, aliases, functions
ghostty/              # Ghostty terminal config, shaders, themes
git/gitconfig         # Git config with delta and aliases
lazygit/config.yml    # Lazygit config
macos/defaults.sh     # macOS system preferences
mise/config.toml      # Runtime versions (node, go, python)
ssh/config            # SSH config
starship/starship.toml # Starship prompt theme (gruvbox)
zed/                  # Zed editor settings, keymap, themes
bin/tmux-sessionizer  # Tmux project switcher (ctrl-f)
```

## Post-install

1. Restart your terminal
2. `atuin login`
3. Install Zed extensions: Alabaster theme
4. Sign into Chrome / Chrome Canary
