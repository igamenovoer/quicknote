see https://github.com/cline/cline/issues/3135

# How to Install the context7 MCP Server on Windows

This guide provides the steps to install the context7 MCP server on a Windows machine.

**Prerequisites:**

*   Node.js and npm
*   Git
*   PowerShell

---

### 1. Navigate to the MCP Servers Directory

Open PowerShell and change to the directory where your Cline MCP servers are stored. Replace `<YourUsername>` with your actual Windows username.

```powershell
cd C:\Users\<YourUsername>\Documents\Cline\MCP
```

### 2. Clean and Clone the Repository

To ensure a fresh installation, remove any existing `context7-mcp` directory and then clone the repository from GitHub.

```powershell
Remove-Item -Recurse -Force context7-mcp; git clone https://github.com/upstash/context7-mcp
```

### 3. Enter the Project Directory

Navigate into the newly cloned `context7-mcp` folder.

```powershell
cd context7-mcp
```

### 4. Install Dependencies

Use `npm` to install the necessary packages as defined in `package.json`.

```powershell
npm install
```

### 5. Build the Project

Compile the TypeScript source code into JavaScript.

```powershell
npm run build
```
*(Note: You may see an error regarding a `chmod` command. This is expected on Windows and can be safely ignored as it does not affect the outcome.)*

### 6. Configure MCP Settings

Update your MCP settings file to correctly point to the newly built server. The file is located at: `C:\Users\<YourUsername>\AppData\Roaming\Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json`

Add or modify the entry for `context7-mcp` as follows, ensuring the path in `args` is correct for your system:

```json
{
  "github.com/upstash/context7-mcp": {
    "autoApprove": [],
    "disabled": false,
    "timeout": 60,
    "command": "node",
    "args": [
      "C:\\Users\\<YourUsername>\\Documents\\Cline\\MCP\\context7-mcp\\dist\\index.js"
    ],
    "transportType": "stdio"
  }
}
```

### 7. Verification

After completing these steps, restart your environment and check the "Connected MCP Servers" section in Cline to confirm that `github.com/upstash/context7-mcp` is listed and running.
