# How to disable the inline last edit tooltip in editor?

see [this](https://stackoverflow.com/questions/72797748/how-to-hide-git-tooltip-in-vscode)

![image](https://github.com/user-attachments/assets/ea7b2ca7-9891-446f-8ab8-6b9dad8e3a45)

To solve this, edit the user setting json file:

```json
"gitlens.codeLens.authors.enabled": false,
"gitlens.codeLens.recentChange.enabled": false
"gitlens.currentLine.enabled": false
```
