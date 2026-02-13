# Setup a New Desktop from Scratch

Step-by-step guide. Add new steps and instructions below as you go. Most steps are Makefile tasks, so you need **make** (and **sops** for encrypted config). Do **Step 0 first** so your user is a sudoer; then installs won’t prompt for a password.

---

## Step 0: Allow passwordless sudo for your user (optional but recommended)

So `sudo` doesn’t ask for a password every time, and so Cursor (or scripts) can run `sudo` commands non-interactively, add your user as a passwordless sudoer. **Run these once in a terminal** (you’ll be prompted for your password once):

```bash
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/99-"$USER"-nopasswd
sudo chmod 440 /etc/sudoers.d/99-"$USER"-nopasswd
```

After that, `sudo` won’t ask for a password for your user. Cursor and Makefile tasks that use `sudo` (e.g. `apt install`) can then run without interaction.

---

## Step 1: Install Git, make, sops, and clone this dotfiles repo

- **Install Git, make, and sops** (if not already installed). Do this **after Step 0** so sudo doesn’t prompt:
  ```bash
  sudo apt install git make sops age-encryption   # Ubuntu/Debian
  # or: brew install git sops age                 # macOS (make is usually preinstalled via Xcode tools)
  ```
  On Ubuntu, `make` and `sops` are not always present; you need both for the Makefile tasks and for restoring config from the encrypted repo. `age-encryption` is required for SOPS decryption.

- **Clone the dotfiles repo** (e.g. into `~/workspace` or `~`):
  ```bash
  git clone https://github.com/foundation-models/dotfiles.git
  cd dotfiles
  ```
  The repo is public, so no credentials are required for clone.

- **Optional – use GitHub CLI for browser-based auth** on other repos later:
  ```bash
  sudo apt install gh   # Ubuntu/Debian
  gh auth login         # choose web login for browser popup
  ```

---

## Step 2: Reconstruct all TOML files in ~/.config from the encrypted repo

Restore every `~/.config/**/*.toml` from the SOPS+age–encrypted `confidential.tar.enc` in this repo. The Makefile task will prompt for the SOPS age passphrase (and for the age secret key file path if `SOPS_AGE_KEY_FILE` is not set).

- **Prerequisites:** `sops` and `age` (installed in Step 1).

- **Run from the dotfiles repo root:**
  ```bash
  make restore-config-toml
  ```
  You will be prompted for:
  1. Path to your age secret key file (default: `~/.config/sops/age/keys.txt`) if `SOPS_AGE_KEY_FILE` is not set.
  2. SOPS age passphrase.

  The task decrypts `confidential.tar.enc` into `confidential/`, then copies all `confidential/.config/**/*.toml` into `~/.config` (preserving directory structure). The decrypted `confidential/` directory is left in the repo (it is in `.gitignore`). To deploy all confidential files (not just TOMLs), run `./install-confidential.sh` afterward.

- **After this step:** All credentials are in `~/.config`. You can start installing other repos, tools, and the rest of the setup using the dotfiles repo (e.g. `./install.sh`, `make clone REPO=...`, and any further steps below).

---

## Step 3: Install desktop packages

Install these packages (Ubuntu/Debian). Order is flexible; run from a terminal. After Step 2, credentials are in `~/.config`, so you can use the dotfiles repo for the rest of the setup.

**One command (from dotfiles repo root):**
```bash
make install-desktop-packages
```
This runs all of the installs below; already-installed items are skipped. Or install each package manually using the blocks below.

### 1. Chrome (and set as default browser)

```bash
# Add Google Chrome repo and install
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-linux-signing-key.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-key.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update && sudo apt install -y google-chrome-stable

# Set Chrome as default browser
xdg-settings set default-web-browser google-chrome.desktop
```

### 2. Pritunl (VPN client)

```bash
# Add Pritunl repo and install desktop client
sudo apt install -y gnupg curl
curl -fsSL https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc | sudo gpg --dearmor -o /usr/share/keyrings/pritunl.gpg
echo "deb [signed-by=/usr/share/keyrings/pritunl.gpg] https://repo.pritunl.com/stable/apt $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/pritunl.list
sudo apt update && sudo apt install -y pritunl-client-electron
```

### 3. Docker

```bash
# Docker from Ubuntu repos (simple)
sudo apt update && sudo apt install -y docker.io
sudo usermod -aG docker "$USER"
# Log out and back in (or newgrp docker) so docker runs without sudo
```

### 4. Slack

```bash
sudo snap install slack --classic
# Or: download .deb from https://slack.com/downloads/linux and: sudo dpkg -i slack-desktop-*.deb
```

### 5. Telegram

```bash
sudo snap install telegram-desktop
# Or: sudo apt install telegram-desktop   # if in your Ubuntu repos
```

### 6. Espanso (text expander)

This repo has Espanso config in `config/espanso/`. Install the app, then run `./install.sh config` from the dotfiles root to stow it.

```bash
# X11 (most Ubuntu sessions)
wget -q "https://github.com/espanso/espanso/releases/latest/download/espanso-debian-x11-amd64.deb" -O /tmp/espanso.deb
sudo apt install -y /tmp/espanso.deb

# Register as service and start (runs at login)
espanso service register
espanso service start
```

On macOS the dotfiles `mac/install.sh` symlinks Espanso match config to `~/Library/Application Support/espanso/`. On Linux, `./install.sh config` stows into `~/.config/espanso/`. The desktop-packages script registers espanso as a system service so it starts automatically when you log in.

### 7. Tailscale

```bash
# Add Tailscale repo and install (use noarmor.gpg so apt can verify signatures)
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt update && sudo apt install -y tailscale
sudo tailscale up   # authenticate in browser when prompted
```

### 8. Solaar (Logitech keyboard and mouse)

Manages Logitech Unifying/Bolt receivers and paired devices (pair/unpair, battery, settings).

```bash
sudo apt update && sudo apt install -y solaar
```

For a newer version: `sudo add-apt-repository ppa:solaar-unifying/stable` then `sudo apt update && sudo apt install -y solaar`.

**If Solaar doesn’t appear in the application menu:** Some setups only install an autostart `.desktop` (for the tray), not a menu launcher. You can:

- **Run from terminal:** `solaar` or `solaar --window=show` to open the GUI.
- **Add a menu launcher:** Create `~/.local/share/applications/solaar.desktop` with:
  ```ini
  [Desktop Entry]
  Name=Solaar
  Comment=Logitech Unifying receiver manager
  Exec=solaar --window=show
  Icon=solaar
  Terminal=false
  Type=Application
  Categories=Settings;Utility;
  ```
  Then run `update-desktop-database ~/.local/share/applications` (if available) or log out and back in; “Solaar” should appear in your applications list.

### 9. ngrok

Expose local servers via secure tunnels. Add your authtoken after install from https://dashboard.ngrok.com/get-started/your-authtoken.

```bash
# Add ngrok repo and install (Debian/Ubuntu; repo uses buster distro name)
curl -fsSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install -y ngrok

# Then add your token (one-time)
ngrok config add-authtoken <YOUR_TOKEN>
```

Alternative: `sudo snap install ngrok`.

### 10. Howdy (face recognition login)

Windows Hello–style face auth for login, sudo, and screen unlock (convenience only; keep your password as fallback). On Ubuntu 24.04+ use the unofficial PPA that bundles dlib.

```bash
# Ubuntu 24.04 / 24.10 / 25.04 (official PPA fails on noble+)
sudo add-apt-repository -y ppa:ubuntuhandbook1/howdy
sudo apt update && sudo apt install -y howdy v4l-utils
```

After install:

1. **Ensure you can access the camera:** add your user to the `video` group so Howdy can open the device: `sudo usermod -aG video $USER` (then log out and back in, or reboot).
2. **Internal webcam (Intel Tiger Lake / similar):** Ubuntu does not ship the IPU6 (MIPI) camera driver by default. Install the matching kernel modules so `/dev/video0` appears:
   ```bash
   # For current kernel (example: 6.17.0-14-generic); use your actual uname -r
   sudo apt install -y linux-modules-ipu6-$(uname -r)
   # Or meta-package for future kernels: linux-modules-ipu6-generic-hwe-24.04
   ```
   Reboot, then run `v4l2-ctl --list-devices`. If still no devices, check **BIOS**: enable "Camera", "Integrated Camera", or "Onboard Camera" (and disable any "Camera Privacy" or "Privacy Shutter" that turns the camera off).
3. **Set camera device** (if not auto-detected): list devices with `v4l2-ctl --list-devices`. Edit `/etc/howdy/config.ini` and set `device_path` under `[video]` to your camera, e.g. `device_path = /dev/video0` or a stable path under `/dev/v4l/by-id/`.
4. **Enroll your face:** `sudo howdy add` (follow prompts).
5. **Test:** `sudo howdy test` or use sudo in a terminal; you should get a face scan option.

PAM is configured in `/etc/pam.d/common-auth` by the package (so sudo and login use face). For **face login at the GDM graphical login screen**, the `gdm` user must be able to access the camera: `sudo usermod -aG video gdm`. Restart GDM or reboot for it to take effect; then at the login screen you can use face recognition (Howdy runs first, then password if needed). To disable Howdy: `sudo howdy disable`; to re-enable: `sudo howdy enable`.

---

## Housekeeping: Cursor terminal keybindings and shell aliases

### Terminal copy/paste: Super+C and Super+V

By default, Ctrl+Shift+Insert may open the terminal instead of copying. To use **Super (Windows key) + C** for copy and **Super + V** for paste in the Cursor integrated terminal:

1. In Cursor, open the Command Palette (`Ctrl+Shift+P`) and run **“Open Keyboard Shortcuts (JSON)”** (or **Preferences: Open Keyboard Shortcuts (JSON)**).
2. Add these entries to your `keybindings.json` (merge with any existing `[]` array):

```json
[
  {
    "key": "meta+c",
    "command": "workbench.action.terminal.copySelection",
    "when": "terminalFocus"
  },
  {
    "key": "meta+v",
    "command": "workbench.action.terminal.paste",
    "when": "terminalFocus"
  }
]
```

On Linux, `meta` is the Super/Windows key, so this gives **Super+C** = copy selection, **Super+V** = paste in the terminal. Copy only runs when there is a selection; paste works whenever the terminal is focused.

### Use dotfiles aliases in the Cursor terminal

The dotfiles define aliases (and exports/functions) in **zsh**: `zsh/.zsh_aliases`, `zsh/.zsh_exports`, `zsh/.zsh_functions`, all sourced from `zsh/.zshrc`. The Cursor integrated terminal uses your **default login shell** (`$SHELL`). If that is **bash**, it reads `~/.bashrc` and does **not** load the dotfiles zsh aliases. To get the dotfiles aliases in the terminal:

**Option A – Default shell to zsh (recommended), full steps:**

1. Install zsh and GNU Stow (if not already installed):
   ```bash
   sudo apt install -y zsh stow   # Ubuntu/Debian
   ```

2. Copy the dotfiles zsh config (including `.zshrc`) into your home directory by stowing the zsh package:
   ```bash
   cd /path/to/dotfiles
   ./install.sh zsh
   ```
   This creates `~/.zshrc`, `~/.zsh_aliases`, etc. (as symlinks into the repo). Or run `./install.sh` to stow everything (zsh, git, config) and run OS-specific install.

3. Set your default login shell to zsh:
   ```bash
   chsh -s "$(which zsh)"
   ```
   Enter your password when prompted.

4. Log out and back in (or open a new Cursor window). New terminals will use zsh and load the dotfiles aliases.

**Option B – Cursor only:** Keep your system default as bash, but make Cursor’s integrated terminal use zsh. Do steps 1 and 2 above, then add to Cursor **Settings (JSON)** (Ctrl+Shift+P → “Open User Settings (JSON)”):
   ```json
   "terminal.integrated.defaultProfile.linux": "zsh",
   "terminal.integrated.profiles.linux": {
     "zsh": {
       "path": "zsh"
     }
   }
   ```
   Then new terminals in Cursor will be zsh and load `~/.zshrc` (and thus the dotfiles aliases).

After this, the Cursor terminal will use the same aliases as in the dotfiles (e.g. `..`, `l`, `la`, `g`, `reload`, etc.). The dotfiles zsh config is in the repo under `zsh/` (`.zshrc`, `.zsh_aliases`, `.zsh_exports`, `.zsh_functions`).

---

## Step 4: _(add next steps below as you give instructions)_

_(Instructions will be added here.)_
