# Chrome Remote Desktop (macOS)

Notes from troubleshooting and configuring Chrome Remote Desktop on a Mac: starting the host, fixing authentication errors, and auto-start for all users.

---

## 1. Starting the Chrome Remote Desktop host

### App location

- **User app (PWA/shortcut):**  
  `~/Applications/Chrome Apps.localized/Chrome Remote Desktop.app`
- **Host service (system):**  
  `/Library/PrivilegedHelperTools/ChromeRemoteDesktopHost.app/Contents/MacOS/remoting_me2me_host_service`

### Opening the app

- **`open "…Chrome Remote Desktop.app"`** can fail with:  
  `kLSNoExecutableErr: The executable is missing`  
  (Launch Services / bundle issue; the executable is present but `open` may still fail.)
- **Workaround:** run the app’s loader directly (starts the Remote Desktop UI/host context):
  ```bash
  "$HOME/Applications/Chrome Apps.localized/Chrome Remote Desktop.app/Contents/MacOS/app_mode_loader" &
  ```
- Alternatively, open Chrome and go to **https://remotedesktop.google.com** to use or trigger the host.

### One-time host setup (per user)

Each user who wants to be reachable must complete setup once:

1. In Chrome, go to **https://remotedesktop.google.com/headless**.
2. Follow the steps: install host if prompted, set 6-digit PIN, grant **Screen Recording** (and **Accessibility** if asked) in **System Settings → Privacy & Security**.

---

## 2. “Unable to authenticate due to server error” (before session loads)

### Conclusion

This usually means the host or client cannot complete authentication with Google’s servers, or the host registration is broken/stale—not necessarily a local network block on the Mac we checked.

### What we checked

- **Connectivity from the Mac (host):** All three required endpoints responded OK:
  - `remotedesktop.google.com`
  - `remotedesktop-pa.googleapis.com`
  - `instantmessaging-pa.googleapis.com`

So the **host Mac** can reach Google; if the error persists, the problem is likely host registration, the **client’s** network, or account mismatch.

### Recommended fixes (in order)

1. **Re-register the host (most effective)**  
   On the host Mac: Chrome → **https://remotedesktop.google.com/headless** → remove this computer → add it again (install host, set PIN, grant permissions). Then restart the host or the Mac and try connecting again from the remote device.

2. **Same Google account**  
   The account used at **remotedesktop.google.com/headless** on the host must be the same one used at **remotedesktop.google.com** on the client.

3. **Client network**  
   If the **remote** device is on VPN or a restrictive firewall, try from another network (e.g. phone hotspot). The client must be able to reach the same Google URLs above.

4. **Clear site data (if still failing)**  
   In Chrome on the host: clear cookies (and optionally cache) for **remotedesktop.google.com**, then sign back in and re-add the computer at **remotedesktop.google.com/headless**.

5. **Google outage**  
   Check [Google Workspace Status](https://www.google.com/appsstatus) or similar; “server error” can be temporary.

### Quick connectivity check (run on the machine that fails)

```bash
for host in remotedesktop.google.com remotedesktop-pa.googleapis.com instantmessaging-pa.googleapis.com; do
  echo -n "$host: "
  curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "https://$host/" 2>/dev/null | grep -qE '^[0-9]+' && echo "OK" || echo "FAIL or timeout"
done
```

If any show FAIL or timeout, fix network/firewall/VPN for that machine first.

---

## 3. Auto-start for all users (other users at login)

### Conclusion

**Yes—Chrome Remote Desktop is already configured to start automatically when any user logs in.** No extra per-user LaunchAgent or script is required.

### How it’s configured

- **LaunchAgent (system-wide):**  
  **`/Library/LaunchAgents/org.chromium.chromoting.plist`**
  - **RunAtLoad:** `true` → host service starts when the agent is loaded (at graphical login).
  - **LimitLoadToSessionType:** `Aqua` (and `LoginWindow`) → runs for normal GUI logins.
  - **ProgramArguments:**  
    `/Library/PrivilegedHelperTools/ChromeRemoteDesktopHost.app/Contents/MacOS/remoting_me2me_host_service --run-from-launchd`

- Because the plist is in **`/Library/LaunchAgents`**, it is loaded for **every user** when they log in; each gets their own host process.

- **Host binary:**  
  `/Library/PrivilegedHelperTools/ChromeRemoteDesktopHost.app/Contents/MacOS/remoting_me2me_host_service`  
  (Present and used by the LaunchAgent.)

### What each user must do once

Each user who should be reachable via Chrome Remote Desktop must:

1. Log in as that user.
2. Open Chrome and go to **https://remotedesktop.google.com/headless**.
3. Complete the one-time setup (install host if prompted, set PIN, grant Screen Recording / Accessibility as requested).

After that, the service will start at login automatically for that user via the existing LaunchAgent.

### Verifying it’s running (as that user)

- **Terminal:**  
  `launchctl list | grep chromoting`  
  Should show **`org.chromium.chromoting`**.
- **Activity Monitor:** Search for **remoting** or **Chrome Remote Desktop**.

---

## 4. Reference: network requirements (Chrome Remote Desktop)

For locked-down networks, ensure outbound access to:

- **URLs:**  
  `remotedesktop.google.com`, `remotedesktop-pa.googleapis.com`, `instantmessaging-pa.googleapis.com`
- **Ports:** 443 (HTTPS); for relay/TURN, 3478 (TCP/UDP) and IP **74.125.247.128** may be required.

See [Network guide for Chrome Remote Desktop](https://support.google.com/chrome/a/answer/16364503) for full details.
