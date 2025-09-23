Yes—VS Code lets you *force* where an extension runs.

By default, Copilot Chat “prefers” the UI (local) host, but you can override that so it runs in the **workspace** (the SSH remote) instead.

### Do this once in your VS Code settings (JSON)

1. Open **Command Palette → Preferences: Open Settings (JSON)**.
2. Add/merge the following block (identifiers are lowercase):

```json
"remote.extensionKind": {
  "github.copilot": ["workspace"],
  "github.copilot-chat": ["workspace"]
}
```

> `["workspace"]` = run only on the remote host.
> (If you ever want it to be allowed in both places, use `["ui","workspace"]`.)

3. **Reload Window** (or reconnect to the SSH target).

### Also make sure

* In the Extensions view:

  * **On Local**: you can **Disable (This Machine)** for GitHub Copilot and GitHub Copilot Chat.
  * **On SSH: <your host>**: ensure both are **Installed & Enabled**.
* Sign in to GitHub **in the remote window** (the remote has its own auth context).
* Verify where it runs: **Command Palette → Developer: Print Extension Host Diagnostics** (you should see Copilot / Copilot Chat under the *workspace*/remote host).

After this, Copilot Chat (and its file/FS operations) will execute on the SSH remote instead of your Mac.
