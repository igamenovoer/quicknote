# How to setup serena for python

## Installation

you need to install it with pyright

```powershell
uv tool install serena-agent --with pyright

# after that, you get this
uv tool list

serena-agent v0.1.4
- index-project.exe
- serena-mcp-server.exe
- serena.exe

```

## Project Configuration

in your project, do this to generate project config

```powershell
serena project generate-yml

# then you get .serena/project.yml
```

## `mcp.json` for vscode

use this in your vscode project-specific mcp configuration

```json
# .vscode/mcp.json
{
    "servers": {
        "serena-mcp": {
            "command": "serena-mcp-server",
            "args": [
                "--context",
                "ide-assistant",
                "--project",
                "${workspaceFolder}"
            ]
        }
    }
}
```

## claude code

add the mcp server first

```powershell
claude mcp add serena -- "serena-mcp-server --context ide-assistant --project $(pwd)"
```

then you check it

```powershell
claude mcp list
```

it WILL FAILED because it records the whole command instead of using proper mcp json format, now go to `C:\Users\(username)\.claude.json`,
find your `mcpServers` about the serena mcp, and modify it into

```json
"mcpServers": {
  "serena": {
    "type": "stdio",
    "command": "serena-mcp-server",
    "args": [
      "--context",
      "ide-assistant",
      "--project",
      "(your project path)"
    ],
    "env": {}
  }
},
```

then it is done

