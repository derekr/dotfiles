#!/usr/bin/env bash
# Install Xcode CLI tools (required for git, compilers, etc.)

if xcode-select -p &>/dev/null; then
  echo "    Xcode CLI tools already installed"
  exit 0
fi

echo "    Installing Xcode CLI tools..."
xcode-select --install

echo "    Waiting for Xcode CLI tools to finish (this can take a while)..."
until xcode-select -p &>/dev/null; do
  sleep 10
done
echo "    Xcode CLI tools installed"
