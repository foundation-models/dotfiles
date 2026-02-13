#!/usr/bin/env bash
# Install all desktop packages from docs/setup-new-desktop.md Step 3.
# Run from dotfiles repo root. Requires: Ubuntu/Debian, sudo (passwordless recommended).
# Tailscale will prompt for browser login; log out and back in after Docker install for docker group.

set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES_DIR"

echo "=== 1. Chrome (and set default browser) ==="
if ! command -v google-chrome-stable &>/dev/null; then
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-linux-signing-key.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-key.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
  sudo apt update && sudo apt install -y google-chrome-stable
fi
xdg-settings set default-web-browser google-chrome.desktop 2>/dev/null || true

echo "=== 2. Pritunl (VPN client) ==="
if ! command -v pritunl-client-electron &>/dev/null; then
  sudo apt install -y gnupg curl
  curl -fsSL https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc | sudo gpg --dearmor -o /usr/share/keyrings/pritunl.gpg
  echo "deb [signed-by=/usr/share/keyrings/pritunl.gpg] https://repo.pritunl.com/stable/apt $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/pritunl.list
  sudo apt update && sudo apt install -y pritunl-client-electron
fi

echo "=== 3. Docker ==="
if ! command -v docker &>/dev/null; then
  sudo apt update && sudo apt install -y docker.io
  sudo usermod -aG docker "${USER:-$(whoami)}"
  echo "Docker installed. Log out and back in (or run: newgrp docker) so docker runs without sudo."
fi

echo "=== 4. Slack ==="
if ! snap list slack 2>/dev/null; then
  sudo snap install slack --classic
fi

echo "=== 5. Telegram ==="
if ! snap list telegram-desktop 2>/dev/null; then
  sudo snap install telegram-desktop
fi

echo "=== 6. Espanso (text expander) ==="
if ! command -v espanso &>/dev/null; then
  curl -fsSL -o /tmp/espanso.deb "https://github.com/espanso/espanso/releases/latest/download/espanso-debian-x11-amd64.deb"
  sudo apt install -y /tmp/espanso.deb
  rm -f /tmp/espanso.deb
fi
if command -v espanso &>/dev/null; then
  espanso service register 2>/dev/null || true
  espanso service start 2>/dev/null || true
  echo "Espanso registered as service and started. Run './install.sh config' from dotfiles to stow Espanso config (match folder)."
fi

echo "=== 7. Tailscale ==="
if ! command -v tailscale &>/dev/null; then
  curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).noarmor.gpg" | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
  curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).tailscale-keyring.list" | sudo tee /etc/apt/sources.list.d/tailscale.list
  sudo apt update && sudo apt install -y tailscale
  echo "Run 'sudo tailscale up' to authenticate in browser when prompted."
fi

echo "=== 8. Solaar (Logitech keyboard and mouse) ==="
if ! command -v solaar &>/dev/null; then
  sudo apt update && sudo apt install -y solaar
fi

echo "=== 9. ngrok ==="
if ! command -v ngrok &>/dev/null; then
  curl -fsSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
  echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
  sudo apt update && sudo apt install -y ngrok
  echo "Run 'ngrok config add-authtoken <YOUR_TOKEN>' with your token from https://dashboard.ngrok.com/get-started/your-authtoken"
fi

echo "=== 10. Howdy (face recognition login) ==="
if ! command -v howdy &>/dev/null; then
  sudo add-apt-repository -y ppa:ubuntuhandbook1/howdy
  sudo apt update && sudo apt install -y howdy v4l-utils
  echo "After install: set device_path in /etc/howdy/config.ini if needed, then run 'sudo howdy add' to enroll your face."
fi

echo "=== Desktop packages done. ==="
echo "Reminder: log out and back in (or newgrp docker) for Docker group; run './install.sh config' for Espanso config; run 'sudo tailscale up' for Tailscale if needed."
