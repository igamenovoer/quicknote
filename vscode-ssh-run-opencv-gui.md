# How to use imshow() in ssh cmake projects

Create .vscode/tasks.json in your workspace, and use this task. 
Note that the `DISPLAY` is key to use `imshow()`, point it to any X-server you created. In this example, the program is run inside a docker container, and X-server is setup in host localhost:10.0

```json
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Run CMake Target",
            "type": "shell",
            "command": "${command:cmake.launchTargetPath}",
            "options": {
                "cwd": "${command:cmake.buildDirectory}",
                "env": {
                    "PATH": "${env:PATH}:${command:cmake.getLaunchTargetDirectory}",
                    "DISPLAY": "host.docker.internal:10.0"
                }
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared",
                "showReuseMessage": true,
                "clear": true
            },
            "problemMatcher": []
        }
    ]
}
```
