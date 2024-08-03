# how to debug opencv with highgui in remote ssh
First, make sure you have x-server started somewhere (like localhost), and ssh -X to the remote.
Then, in vscode, create launch.json, and use this

```json
"configurations": [
    {
        "name": "debug cmake target",
        "type": "cppdbg",
        "request": "launch",
        "program": "${command:cmake.launchTargetPath}",
        "args": [],
        "stopAtEntry": false,
        "cwd": "${fileDirname}",
        "environment": [
            {
                "name": "PATH",
                "value": "${env:PATH}:${command:cmake.getLaunchTargetDirectory}"
            },
            {
                "name": "DISPLAY",
                "value": "host.docker.internal:10.0"
            }
        ],
        "externalConsole": false,
        "MIMode": "gdb",
        "setupCommands": [
            {
                "description": "Enable pretty-printing for gdb",
                "text": "-enable-pretty-printing",
                "ignoreFailures": true
            }
        ]
    }

]
```
