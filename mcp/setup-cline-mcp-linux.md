# How to setup mcp for linux

## Outcome

```json
{
  "mcpServers": {
    "tavily-mcp": {
      "command": "npx",
      "args": ["-y", "tavily-mcp@latest"],
      "env": {
        "TAVILY_API_KEY": "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"
      },
      "disabled": false,
      "autoApprove": []
    },
    "fetch": {
      "command": "/home/igamenovoer/.local/bin/uvx",
      "args": ["mcp-server-fetch"]
    },
    "blender": {
      "command": "python3",
      "args": [
          "-m", "blender_mcp.server"
      ]
    }
  }
}
```

## Tavily MCP
- simple. just follow official tutorial

## Fetch MCP
- there is multiple versions, use this [fetch-mcp](https://pypi.org/project/mcp-server-fetch/)
- install uv

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

- then most importantly, in your mcp config, use **full path** to `uvx`.

## Blender MCP
- install blender mcp via pip, see [this](https://pypi.org/project/blender-mcp/)
- now, in container it will try to access `localhost:9876`, which is hard-coded and will not connect (unless you are using host network mode).
So, go to your path `site-packages/blender_mcp` (probably in ~/.local, like this `~/.local/lib/python3.12/site-packages/blender_mcp`), find the `server.py`,
and change the `localhost` to `host.docker.internal`
- in mcp config, **DO NOT** use uvx, just use python3 to start it, like this:

```json
{
  "mcpServers": {
    "blender": {
      "command": "python3",
      "args": [
          "-m", "blender_mcp.server"
      ]
    }
  }
}
```
