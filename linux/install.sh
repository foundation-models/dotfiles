#!/usr/bin/env bash
# Ubuntu/Linux-specific setup (run from repo root or linux/)
# Install Stow and common dev tools.

set -e
if command -v apt-get &>/dev/null; then
  sudo apt-get update
  sudo apt-get install -y stow
  # Optional: sudo apt-get install -y git zsh tmux ...
fi
