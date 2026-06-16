# remote — terminal-first dev on a Linux droplet

Bootstrap a fresh Ubuntu/Debian droplet (DigitalOcean, etc.) into a remote dev
box that mirrors the Mac CLI layer — **fish + tmux + nvim + mise + the same
tools** — minus every GUI/macOS piece. Designed for agentic work in tmux that
survives disconnects.

This is intentionally **separate and lean** from the Mac `install.sh`. It reuses
the repo's portable configs (`starship`, `git`, `lazygit`, `nvim`, `mise`,
`tmux-sessionizer`) and adds the two remote-only files here.

## Quick start

On the droplet, as a **non-root sudo user** (Homebrew refuses to run as root):

```bash
curl -fsSL https://raw.githubusercontent.com/derekr/dotfiles/main/remote/remote-bootstrap.sh | bash
```

Then follow the printed manual steps (Tailscale up, ufw, `claude` login, etc.).

## Flags

| Flag | Effect |
|---|---|
| `--work <org/repo\|path>` | After the base install, run a private work-overlay repo's `install.sh` (via `scripts/08-work.sh`). |
| `--clawpatrol` | Also install the [Claw Patrol](https://clawpatrol.dev) agent firewall. Off by default. |
| `dry` | Print steps without executing. |

## Architecture

- **Mac** stays the thin client (Ghostty + your SSH key in 1Password). You SSH in
  over **Tailscale**; no public SSH port.
- **Droplet** runs tmux (persistent agent sessions), fish, nvim, and Claude
  Code on your subscription auth (first-party, allowed on-box).
- **Work** is a private overlay repo + manual auth/VPN — never in this repo.

## What's deliberately NOT here

- macOS system prefs, Xcode, GUI casks (Ghostty/Zed/Raycast/1Password/OrbStack).
- Secrets of any kind. Interactive auth (GitHub, Tailscale, work SSO) is done by
  hand on the box; credentials with real blast radius can later be brokered
  through Claw Patrol rather than written to disk.

## Files

- `remote-bootstrap.sh` — the orchestrator (idempotent, re-runnable).
- `tmux.conf` — truecolor, mouse, vi copy-mode, sessionizer popup. Copied to
  `~/.config/tmux/tmux.conf`.
- `config.fish` — lean fish config (Linux brew paths, `EDITOR=nvim`, git abbrs,
  agent abbrs). Copied to `~/.config/fish/config.fish`.
