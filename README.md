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

The install script will:

1. Install Xcode CLI tools (if needed)
2. Install Homebrew and all packages from `Brewfile`
3. Generate an SSH key and prompt you to add it to GitHub
4. Symlink all config files to their expected locations
5. Install fish plugins (fisher + fzf.fish)
6. Install runtimes via mise (node, go, python)
7. Install global npm packages (claude-code, wt)
8. Set fish as default shell
9. Apply macOS system defaults

## Structure

```
Brewfile              # Homebrew packages and casks
install.sh            # Bootstrap script
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
3. Sign into Chrome / Chrome Canary
