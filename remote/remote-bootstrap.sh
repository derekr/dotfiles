#!/usr/bin/env bash
# Remote dev bootstrap — turn a fresh Ubuntu/Debian droplet into a terminal-first
# dev box that mirrors the Mac dotfiles' CLI layer (fish + tmux + nvim + mise +
# tools), minus every GUI/macOS piece. Work-specific config is layered via
# --work and is never baked into this public repo.
#
# Usage (from a clone):
#   bash remote/remote-bootstrap.sh [--work <org/repo|path>] [--clawpatrol] [dry]
#
# Or curl-able on a bare droplet (downloads the repo tarball first):
#   curl -fsSL https://raw.githubusercontent.com/derekr/dotfiles/main/remote/remote-bootstrap.sh | bash
#
# Flags:
#   --work <org/repo|path>  Run a private work-overlay repo's install.sh afterward
#                           (reuses scripts/08-work.sh — clone over SSH, run install).
#   --clawpatrol            Also install the Claw Patrol agent firewall (opt-in).
#   dry                     Print what would run without doing it.

set -euo pipefail

REPO="derekr/dotfiles"
DOTFILES_DIR="$HOME/dev/github.com/derekr/dotfiles"
WORK_REPO=""
WITH_CLAWPATROL=0
DRY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --work)       shift; WORK_REPO="${1:-}" ;;
    --clawpatrol) WITH_CLAWPATROL=1 ;;
    dry|--dry)    DRY=1 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
  shift
done

log()  { echo ""; echo "==> $*"; }
note() { echo "    $*"; }
run()  { if [[ $DRY -eq 1 ]]; then echo "    [dry] $*"; else "$@"; fi; }

# --- 0. Guards -------------------------------------------------------------
if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This is the remote (Linux) bootstrap. On macOS use ./install.sh instead." >&2
  exit 1
fi

# Homebrew refuses to run as root, and you should not dev as root anyway.
if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  cat <<'EOF'

This bootstrap installs Homebrew, which refuses to run as root.
Create a non-root sudo user first, then re-run as that user:

  adduser dev && usermod -aG sudo dev
  rsync --archive --chown=dev:dev ~/.ssh /home/dev   # carry over SSH access
  su - dev
  # then re-run this script as 'dev'

EOF
  exit 1
fi

SUDO=""; [[ ${EUID:-$(id -u)} -ne 0 ]] && SUDO="sudo"

# --- 1. Base apt packages --------------------------------------------------
log "Installing base apt packages"
run $SUDO apt-get update -y
run $SUDO apt-get install -y \
  build-essential procps file curl git ufw mosh unzip ca-certificates

# --- 2. Homebrew on Linux --------------------------------------------------
log "Installing Homebrew (Linux)"
if ! command -v brew >/dev/null 2>&1; then
  run bash -c 'env NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# --- 3. CLI tools (the portable subset of the Mac Brewfile) ----------------
log "Installing CLI tools via brew"
run brew install \
  git git-delta git-lfs gh lazygit jj neovim fish atuin starship tmux \
  ripgrep fd fzf sk zoxide ast-grep bat eza tree yazi fastfetch btop \
  mise jq coreutils libpq pgcli todo-txt
run brew install anomalyco/tap/opencode || note "opencode tap failed — install later"

# --- 4. Ensure the dotfiles repo is present (for config files) -------------
if [[ ! -d "$DOTFILES_DIR" ]]; then
  log "Downloading dotfiles repo"
  run mkdir -p "$(dirname "$DOTFILES_DIR")"
  if [[ $DRY -eq 0 ]]; then
    curl -fsSL --retry 3 "https://github.com/$REPO/archive/main.tar.gz" \
      | tar xz -C "$(dirname "$DOTFILES_DIR")"
    mv "$(dirname "$DOTFILES_DIR")/dotfiles-main" "$DOTFILES_DIR"
  fi
fi

# --- 5. Copy the portable configs ------------------------------------------
log "Copying configs"
copy() { run mkdir -p "$(dirname "$2")"; run cp "$1" "$2"; note "$2"; }
if [[ $DRY -eq 0 ]]; then
  copy "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
  copy "$DOTFILES_DIR/git/config"             "$HOME/.config/git/config"
  copy "$DOTFILES_DIR/lazygit/config.yml"     "$HOME/.config/lazygit/config.yml"
  copy "$DOTFILES_DIR/nvim/init.lua"          "$HOME/.config/nvim/init.lua"
  copy "$DOTFILES_DIR/mise/config.toml"       "$HOME/.config/mise/config.toml"
  # Mac uses Zed; on the remote box nvim is the editor.
  sed -i 's/zed-preview/nvim/' "$HOME/.config/mise/config.toml"
  copy "$DOTFILES_DIR/remote/config.fish"     "$HOME/.config/fish/config.fish"
  copy "$DOTFILES_DIR/remote/tmux.conf"       "$HOME/.config/tmux/tmux.conf"
  copy "$DOTFILES_DIR/bin/tmux-sessionizer"   "$HOME/.local/bin/tmux-sessionizer"
  chmod +x "$HOME/.local/bin/tmux-sessionizer"
fi

# --- 6. mise runtimes + LSPs -----------------------------------------------
log "Installing mise runtimes (node, go, python + LSPs)"
run mise trust "$HOME/.config/mise/config.toml" || true
run mise install || note "mise install had failures — re-run 'mise install' later"

# --- 6b. Browser automation: Chromium + Playwright -------------------------
# Installs a Chromium build plus every headless system library, used by BOTH
# the chrome-devtools MCP and Playwright. The browser lands in the user's
# ~/.cache/ms-playwright; --with-deps installs the shared libs via apt (sudo).
log "Installing Playwright + Chromium (+ headless system deps)"
export PATH="$HOME/.local/share/mise/shims:$PATH"   # node/npx from mise
run npx --yes playwright@latest install --with-deps chromium
# Optional: a system Chrome at a predictable /usr/bin path, for tools that
# can't be pointed at the Playwright Chromium. Uncomment if your chrome-devtools
# MCP doesn't auto-find a browser:
#   curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
#   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
#   sudo apt-get update && sudo apt-get install -y google-chrome-stable

# --- 7. Default shell ------------------------------------------------------
log "Setting fish as the default shell"
FISH_BIN="$(command -v fish)"
if [[ $DRY -eq 0 ]]; then
  grep -qx "$FISH_BIN" /etc/shells 2>/dev/null || echo "$FISH_BIN" | $SUDO tee -a /etc/shells >/dev/null
  $SUDO chsh -s "$FISH_BIN" "$USER" || chsh -s "$FISH_BIN" || note "chsh failed — set fish manually"
fi

# --- 8. Claude Code (native installer, no Node needed) ---------------------
log "Installing Claude Code"
run bash -c 'curl -fsSL https://claude.ai/install.sh | bash'

# --- 9. Tailscale (install only; you bring it up interactively) ------------
log "Installing Tailscale"
run bash -c 'curl -fsSL https://tailscale.com/install.sh | sh'

# --- 10. Claw Patrol (opt-in) ----------------------------------------------
if [[ $WITH_CLAWPATROL -eq 1 ]]; then
  log "Installing Claw Patrol (agent firewall)"
  run bash -c 'curl -fsSL https://clawpatrol.dev/install.sh | sh'
else
  note "Claw Patrol skipped (pass --clawpatrol to install)"
fi

# --- 11. Work overlay (optional, private repo) -----------------------------
if [[ -n "$WORK_REPO" ]]; then
  log "Running work overlay: $WORK_REPO"
  run env WORK_REPO="$WORK_REPO" bash "$DOTFILES_DIR/scripts/08-work.sh"
fi

# --- 12. Convert tarball to a git clone so you can pull updates -------------
if [[ $DRY -eq 0 && ! -d "$DOTFILES_DIR/.git" ]]; then
  log "Converting dotfiles to a git clone"
  git -C "$DOTFILES_DIR" init -q
  git -C "$DOTFILES_DIR" remote add origin "https://github.com/$REPO.git"
  git -C "$DOTFILES_DIR" fetch -q origin && git -C "$DOTFILES_DIR" reset -q origin/main
  git -C "$DOTFILES_DIR" branch --set-upstream-to=origin/main main 2>/dev/null || true
fi

# --- Done ------------------------------------------------------------------
cat <<'EOF'

==> Base install complete. Manual steps (out-of-band by design):

  1. Restart your shell:            exec fish
  2. Bring up Tailscale + SSH:      sudo tailscale up --ssh
  3. Lock the firewall to tailnet:  sudo ufw allow in on tailscale0   # also lets mosh UDP (60000-61000) through
                                     sudo ufw allow 41641/udp      # tailscale
                                     sudo ufw --force enable        # (keep an SSH session open!)
  4. Shell history sync:            atuin login
  5. Auth Claude Code:              claude            # then /login (subscription)
  6. GitHub auth (manual):          gh auth login     # or forward your 1Password SSH agent
  7. Fix Ghostty terminfo — run this ONCE FROM YOUR MAC:
       infocmp -x xterm-ghostty | ssh <droplet> -- tic -x -
  8. Mosh from a phone/tablet (Blink, Moshi, etc.)? Mosh CANNOT bootstrap through
     Tailscale SSH, so give the OS sshd a tailnet-only port 2222 and use key auth.
     (ssh is socket-activated on Ubuntu 24.04, so the port lives in the socket, not
     sshd_config.) Run as root:
       sudo bash -c 'install -d /etc/systemd/system/ssh.socket.d; printf "[Socket]\nListenStream=\nListenStream=22\nListenStream=%s:2222\n" "$(tailscale ip -4)" > /etc/systemd/system/ssh.socket.d/port2222.conf; systemctl daemon-reload; systemctl restart ssh.socket'
     Then add the client's PUBLIC key to ~/.ssh/authorized_keys (password auth is
     off), and point the app at port 2222 with mosh-server /usr/bin/mosh-server.

  Work box? Do work auth/VPN/registries here by hand, and keep work config in a
  private overlay repo run via:  bash remote/remote-bootstrap.sh --work <org/repo>

EOF
