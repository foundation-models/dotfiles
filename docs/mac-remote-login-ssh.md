# macOS Remote Login (SSH server)

Enable SSH on your Mac so others can `ssh user@your-mac` and get a terminal session. You can keep using the desktop; their session is independent (no shared screen).

---

## 1. Enable Remote Login

1. **System Settings → General → Sharing**
2. Turn **Remote Login** **On**
3. Choose who can log in:
   - **All users** – any local user can SSH in
   - **Only these users** – pick specific local users

Remote Login starts the built-in `sshd` and listens on TCP port 22.

---

## 2. How others connect

- They need your Mac’s **IP or hostname** and a **user** that has Remote Login allowed.
- From their machine:
  ```bash
  ssh your_username@your-mac-ip-or-hostname
  ```
- They get a normal shell session (no GUI).

---

## 3. Security

### Prefer key-based auth

- In **Sharing → Remote Login → (i)** you can restrict to “Allow full disk access for remote users” or not; access is still per-user.
- Prefer **SSH keys** over passwords: add their public key to `~/.ssh/authorized_keys` on your Mac (for the user they log in as).
- To disable password auth (keys only), as root or with sudo:
  ```bash
  # Edit /etc/ssh/sshd_config (or create /etc/ssh/sshd_config.d/local.conf):
  PasswordAuthentication no
  ```
  Then restart: `sudo launchctl kickstart -k system/com.openssh.sshd` (or reboot).

### Firewall

- **System Settings → Network → Firewall**: If the firewall is on, ensure “Remote Login” is allowed (or allow incoming TCP 22).
- For exposure to the internet, prefer a tunnel (Tailscale, Cloudflare Tunnel, jump host) instead of opening port 22 on your router.

---

## 4. Reaching your Mac from the internet

If the other person is not on your LAN:

- **Option A – Port forward:** On your router, forward TCP 22 to your Mac’s LAN IP. They connect to your public IP. Consider a non-default port and key-only auth.
- **Option B – Tunnel / VPN:** Use Tailscale, ngrok, or an SSH reverse tunnel via a VPS so you don’t open port 22 on your home network. See **§5** when you have no router access.

---

## 5. No port forwarding: Tailscale, ngrok, or SSH reverse tunnel

When you’re behind a router you can’t configure, use one of these so a remote user can SSH in (e.g. to use **Cursor CLI** on your Mac while you work on the desktop).

### Option A – Tailscale (recommended)

- **Idea:** Your Mac and the remote user’s machine join a private mesh. They SSH to your Mac’s Tailscale IP. No VPS, no port forward, no tunnel to keep open.
- **Steps:**
  1. Install Tailscale on your Mac: from dotfiles repo run `make install-tailscale` (or `./mac/install.sh` to run full Mac setup). On the remote user’s machine use [Tailscale](https://tailscale.com/download). Sign in on both (same org or invite them).
  2. Enable **Remote Login** on your Mac (see §1).
  3. On your Mac, get the Tailscale IP: **Tailscale app → this device**, or `tailscale ip -4`.
  4. Remote user: `ssh your_username@100.x.x.x` (your Mac’s Tailscale IP).
- **Cursor CLI:** They get a normal SSH session, so they can run `cursor` CLI and work in your repo/workspace over that session. You keep using the desktop; same machine, separate sessions.

### Option B – ngrok (TCP tunnel)

- **Idea:** ngrok exposes your local port 22 via their cloud. Remote user gets a `tcp://X.tcp.ngrok.io:PORT` to connect to.
- **Steps:**
  1. Install ngrok: `brew install ngrok` (or [ngrok.com](https://ngrok.com)).
  2. Sign up and add your authtoken: `ngrok config add-authtoken YOUR_TOKEN`.
  3. Enable **Remote Login** on your Mac (§1).
  4. On your Mac, run: `ngrok tcp 22`.
  5. ngrok prints a line like `Forwarding  tcp://0.tcp.ngrok.io:12345 -> localhost:22`. Remote user: `ssh -p 12345 your_username@0.tcp.ngrok.io`.
- **Caveats:** Free tier may give a new URL/port each run; paid gives a stable address. Keep the `ngrok tcp 22` process running while they need access.

### Option C – SSH reverse tunnel via a VPS

- **Idea:** Your Mac connects out to a server you control (VPS). You create a reverse tunnel so that SSH to the VPS on a chosen port is forwarded to your Mac’s SSH. No port forward at your home; only outbound SSH from the Mac.
- **Requirements:** A VPS or any host with a public IP and SSH access.
- **Steps:**
  1. Enable **Remote Login** on your Mac (§1).
  2. On your Mac, open a reverse tunnel (and keep this running):
     ```bash
     ssh -R 2222:localhost:22 -o ServerAliveInterval=60 user@YOUR_VPS_IP
     ```
     So: connections to the VPS port 2222 are sent to your Mac’s localhost:22.
  3. On the VPS, allow TCP 2222 (e.g. firewall) and ensure `GatewayPorts` allows the bind (in `sshd_config`: `GatewayPorts yes` if they need to reach it from outside the VPS).
  4. Remote user connects to the VPS and is forwarded to your Mac:
     ```bash
     ssh -p 2222 -J user@YOUR_VPS_IP your_mac_username@localhost
     ```
     Or from the VPS: `ssh -p 2222 your_mac_username@localhost`.
- **Stability:** Use `autossh` or a systemd/launchd job to restart the tunnel if it drops.

### Summary for Cursor CLI

| Method       | You need              | Remote user gets        |
|-------------|-----------------------|-------------------------|
| **Tailscale** | Tailscale on both     | `ssh you@100.x.x.x`     |
| **ngrok**     | ngrok account, run `ngrok tcp 22` | `ssh -p PORT you@X.tcp.ngrok.io` |
| **Reverse SSH** | VPS + tunnel from Mac | `ssh -p 2222 -J vps you@localhost` |

All give the remote user a shell on your Mac so they can use Cursor CLI there while you use the desktop.

---

## 6. Troubleshooting: SSH "Operation timed out" over Tailscale

If the remote user gets `ssh: connect to host 100.x.x.x port 22: Operation timed out`:

- **Ping:** They must use `ping 100.x.x.x` (IP only). Do **not** use `ping user@100.x.x.x` — that's invalid and gives "cannot resolve".
- **If ping 100.x.x.x works but SSH times out:** the problem is on your Mac (SSH off or firewall blocking port 22).
- **If ping 100.x.x.x fails:** Tailscale connectivity (same tailnet, both connected, or IP changed).

**On your Mac (host):**

1. **Tailscale connected:** Menu bar Tailscale icon should show "Connected". In Terminal: `tailscale ip -4` — confirm the IP matches what they use (e.g. 100.112.238.94).
2. **Remote Login on:** **System Settings → General → Sharing → Remote Login** must be **On**.
3. **Firewall allows SSH:** **System Settings → Network → Firewall** — if firewall is On, open **Options** and ensure **Remote Login** is allowed (or add a rule for TCP port 22). If in doubt, temporarily turn the firewall Off to test.
4. **SSH listening:** In Terminal: `nc -z localhost 22` or `sudo lsof -i :22` — should show `sshd` listening.

**Remote user:**

- Run `ping 100.x.x.x` (your Tailscale IP, no `user@`). If that fails, fix Tailscale (same account/tailnet, both devices connected). If ping works, the host checks above will fix SSH.

---

---

## 7. Connection keeps dropping (short-lived sessions)

If SSH connects but disconnects again and again after a short time, the link is likely being closed by idle timeouts (NAT, firewall, or Tailscale). Fix with keepalives and (on the host) keeping the Mac awake.

**Remote user (Sajad) — send keepalives so the connection stays up**

- **One-off:** add options to the ssh command:
  ```bash
  ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=3 Hossein.Akhlaghpour@100.112.238.94
  ```
  That sends a keepalive every 60 seconds; after 3 missed replies SSH disconnects (so you notice quickly if the network is dead).

- **Permanent:** add this to **Sajad's** `~/.ssh/config`:
  ```
  Host 100.112.238.94
      ServerAliveInterval 60
      ServerAliveCountMax 3
  ```
  Or use a host alias (e.g. `Host hossein-mac`) and the same options, then `ssh hossein-mac`.

**On your Mac (host) — optional server-side keepalives**

- So the server also pings the client, create a small config override (requires sudo):
  ```bash
  echo "ClientAliveInterval 60" | sudo tee /etc/ssh/sshd_config.d/keepalive.conf
  echo "ClientAliveCountMax 3"   | sudo tee -a /etc/ssh/sshd_config.d/keepalive.conf
  sudo launchctl kickstart -k system/com.openssh.sshd
  ```
  Then SSH will send a keepalive to Sajad every 60 seconds.

**Keep your Mac from sleeping**

- While Sajad is using the session, the Mac (or its network) going to sleep can drop Tailscale and SSH. Either:
  - **System Settings → Lock Screen** (or **Energy Saver / Battery**) — set "Turn display off" and "Prevent automatic sleeping" so the Mac stays awake when plugged in, or
  - Run in a terminal on your Mac: `caffeinate -s` (keeps system awake while that terminal is open; `-s` = sleep disabled).

---

## 8. Check that it's running

- **Terminal:** `sudo launchctl list | grep ssh` — should show `com.openssh.sshd`.
- **Sharing:** Remote Login should show “On” and the address others use (e.g. `your-mac.local` or your IP).
