#!/usr/bin/env bash

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAILURES=()
DRY=0
FILTER=""
WORK_REPO=""

export PATH="$HOME/.local/bin:$PATH"

while [[ $# -gt 0 ]]; do
  if [[ "$1" == "dry" ]]; then
    DRY=1
  elif [[ "$1" == "--work" ]]; then
    shift
    WORK_REPO="$1"
  else
    FILTER="$1"
  fi
  shift
done

export WORK_REPO

log() {
  if [[ $DRY -eq 1 ]]; then
    echo "  [dry run] $@"
  else
    echo "  $@"
  fi
}

execute() {
  log "$@"
  if [[ $DRY -eq 1 ]]; then
    return
  fi
  "$@"
}

echo "==> Installing from $DOTFILES"
echo ""

scripts=$(find "$DOTFILES/scripts" -mindepth 1 -maxdepth 1 -type f -perm +111 | sort)

for script in $scripts; do
  name="$(basename "$script")"

  if [[ -n "$FILTER" ]] && ! echo "$name" | grep -q "$FILTER"; then
    log "filtering $name"
    continue
  fi

  log "running $name"
  if [[ $DRY -eq 1 ]]; then
    continue
  fi

  if bash "$script"; then
    echo ""
  else
    echo "    FAILED: $name"
    echo ""
    FAILURES+=("$name")
  fi
done

# --- Summary ---
if [[ ${#FAILURES[@]} -gt 0 ]]; then
  echo "==> Finished with failures:"
  for f in "${FAILURES[@]}"; do
    echo "    - $f"
  done
  echo ""
  echo "  Re-run a single step: ./install.sh <filter>"
  echo ""
fi

echo "==> Manual steps:"
echo ""
echo "  1. Restart your terminal (fish + starship + atuin)"
echo "  2. atuin login"
echo "  3. Install Zed extensions: Alabaster theme"
echo "  4. Sign into Chrome / Chrome Canary"
echo ""
