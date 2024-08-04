# Remote ssh in vscode does not source /etc/profile.d/*, how to fix this?

Remote-ssh in vscode does not use login shell, so it only `source ~/.bashrc`, but not `/etc/profile.d/*`.

To fix this, force vscode to use login shell, see [issue](https://github.com/microsoft/vscode-remote-release/issues/1671)

Open user settings (json), and add the followings:

```json
"terminal.integrated.defaultProfile.linux": "bash",
"terminal.integrated.profiles.linux": {
    "bash": {
        "path": "bash",
        "icon": "terminal-bash",
        "args": ["--login"]
    }
}
```

Reboot, it should work.
