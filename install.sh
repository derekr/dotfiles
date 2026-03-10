#!/usr/bin/env bash

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
FAILURES=()

export PATH="$HOME/.local/bin:$PATH"

run_script() {
  local script="$1"
  local name
  name="$(basename "$script" .sh | sed 's/^[0-9]*-//')"
  echo "==> $name"
  if bash "$script"; then
    echo ""
  else
    echo "    FAILED: $name"
    echo ""
    FAILURES+=("$name")
  fi
}

echo "==> Installing from $DOTFILES"
echo ""

for script in "$DOTFILES"/scripts/[0-9]*.sh; do
  run_script "$script"
done

# --- Summary ---
if [ ${#FAILURES[@]} -gt 0 ]; then
  echo "==> Finished with failures:"
  for f in "${FAILURES[@]}"; do
    echo "    - $f"
  done
  echo ""
  echo "  Re-run individual scripts with: bash scripts/<script>.sh"
  echo ""
fi

echo "==> Manual steps:"
echo ""
echo "  1. Restart your terminal (fish + starship + atuin)"
echo "  2. atuin login"
echo "  3. Install Zed extensions: Alabaster theme"
echo "  4. Sign into Chrome / Chrome Canary"
echo ""
