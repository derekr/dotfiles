#!/usr/bin/env bash
# Install Xcode CLI tools (required for git, compilers, etc.)

if xcode-select -p &>/dev/null; then
  echo "    Xcode CLI tools already installed"
  exit 0
fi

echo "    Installing Xcode CLI tools..."
xcode-select --install
echo "    Waiting for Xcode CLI tools to finish. Re-run install.sh after."
exit 1
