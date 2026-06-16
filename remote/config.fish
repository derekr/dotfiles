# Lean fish config for remote Linux dev boxes.
# Deliberately omits the Mac-only bits from fish/config.fish: OrbStack,
# VS Code shell integration, /opt/homebrew paths, and the todo/calendar helpers.

# --- Paths first (brew provides starship/atuin/zoxide/mise/etc.) -----------
if test -d /home/linuxbrew/.linuxbrew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

fish_add_path ~/.local/bin

set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx EDITOR nvim

# --- Tool init -------------------------------------------------------------
if status is-interactive
    atuin init fish | source
end

starship init fish | source
zoxide init fish | source
mise activate fish | source

# Tmux sessionizer (same Ctrl-F binding as the Mac setup)
bind \cf tmux-sessionizer

# --- Git abbreviations (mirror the Mac config) -----------------------------
abbr --add am 'git amend'
abbr --add gbr 'git br'
abbr --add gco 'git co'
abbr --add gd 'git diff -w'
abbr --add gds 'git diff -w --staged'
abbr --add glogo 'git logo'
abbr --add gp 'git push origin'
abbr --add gs 'git status'

# --- Agents ----------------------------------------------------------------
# Plain by default (Claude Code runs on your subscription, on-box auth).
# To broker an agent through Claw Patrol, comment the plain line and use the
# clawpatrol one below it.
abbr --add cc 'claude'
abbr --add oc 'opencode'
# abbr --add cc 'clawpatrol run -- claude'
# abbr --add oc 'clawpatrol run -- opencode'
