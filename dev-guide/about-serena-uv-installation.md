# About Serena Installation and Usage via UV

This guide covers how to install and use Serena, a fully-featured Python coding agent that provides an MCP (Model Context Protocol) server, using UV package manager for optimal dependency isolation.

## What is Serena?

Serena is an open-source coding agent that provides semantic code analysis, editing capabilities, and project management through an MCP server. It offers 18+ tools for code manipulation, including symbol search, refactoring, memory management, and intelligent code editing.

Key features:
- **Semantic Code Analysis**: Advanced symbol search and reference finding
- **Intelligent Editing**: Symbol-based and regex-based code modifications  
- **Memory System**: Project-specific knowledge storage and retrieval
- **Language Server Integration**: Supports Python (via Pyright), TypeScript, and more
- **MCP Server**: Works with Claude Desktop, VS Code, and other MCP-compatible clients

## Why Use UV for Serena Installation?

UV provides several advantages for installing Serena:

1. **Dependency Isolation**: Serena and its dependencies (like pyright) are installed in isolated environments
2. **Performance**: 10-100x faster than pip for package operations
3. **Tool Management**: Dedicated `uv tool` interface for managing command-line tools
4. **No Conflicts**: Prevents conflicts with system Python packages
5. **Automatic PATH Management**: Tools are automatically available in your shell

## Installation

### Prerequisites

First, ensure UV is installed:

```bash
# Install UV if not already installed
curl -LsSf https://astral.sh/uv/install.sh | sh
# or via pip
pip install uv
```

### Install Serena with Dependencies

Install Serena as a tool with all required dependencies:

```bash
# Install Serena with pyright for Python language server support
uv tool install serena-agent --with pyright

# Alternative: Install without extra dependencies (if you have pyright globally)
uv tool install serena-agent
```

### Verify Installation

```bash
# Check Serena installation
serena --help

# Verify tools directory
uv tool dir

# List installed tools
uv tool list
```

## Project Setup

### Initialize Serena Project

1. **Navigate to your project directory**:
```bash
cd /path/to/your/project
```

2. **Initialize Serena project configuration**:
```bash
serena project init
```

3. **Configure project settings** in `.serena/project.yml`:
```yaml
project_name: "my-python-project"
language: python  # Required field
project_root: "."
```

### Register Project

```bash
# Register the current directory as a Serena project
serena project add .

# Or register with specific name
serena project add . --name my-project
```

## MCP Server Configuration

### For VS Code

Create or edit `.vscode/mcp.json`:

```json
{
  "mcpServers": {
    "serena": {
      "command": "serena",
      "args": ["start-mcp-server", "--context", "ide-assistant", "--project", "${workspaceFolder}"],
      "transport": {
        "type": "stdio"
      }
    }
  }
}
```

### For Claude Desktop

Add to Claude Desktop's MCP configuration (`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):

```json
{
  "mcpServers": {
    "serena": {
      "command": "serena",
      "args": ["start-mcp-server", "--context", "ide-assistant", "--project", "/absolute/path/to/your/project"]
    }
  }
}
```

## Usage Examples

### Basic Tool Operations

```bash
# Start MCP server manually for testing
serena start-mcp-server --context ide-assistant --project .

# List available Serena commands
serena --help

# Configure Serena settings
serena config edit
```

### Language Server Integration

With pyright installed via UV, Serena automatically gets:
- **Python semantic analysis**
- **Symbol navigation**
- **Type information**
- **Import resolution**
- **Error detection**

### Common MCP Tools Available

Once connected via MCP, Serena provides these tools:
- `list_dir` - Navigate project structure
- `find_file` - Locate files by pattern
- `get_symbols_overview` - Analyze file symbols
- `find_symbol` - Search for specific code symbols
- `find_referencing_symbols` - Find symbol usage
- `replace_symbol_body` - Intelligent code editing
- `write_memory` / `read_memory` - Project knowledge management

## Dependency Management

### Upgrade Serena

```bash
# Upgrade to latest version
uv tool upgrade serena-agent

# Upgrade with dependencies
uv tool upgrade serena-agent --reinstall
```

### Managing Dependencies

```bash
# Check tool environment details
uv tool dir

# Reinstall if dependencies are corrupted
uv tool uninstall serena-agent
uv tool install serena-agent --with pyright
```

### Python Version Management

```bash
# Install specific Python version for Serena
uv tool install --python 3.11 serena-agent --with pyright

# Upgrade with specific Python version
uv tool upgrade --python 3.11 serena-agent
```

## Troubleshooting

### Common Issues

1. **Language server not found**:
```bash
# Reinstall with pyright dependency
uv tool install serena-agent --with pyright --force
```

2. **Project not recognized**:
```bash
# Ensure project.yml has required fields
echo "language: python" >> .serena/project.yml
```

3. **PATH issues**:
```bash
# Update shell configuration
uv tool update-shell
```

### Verify Setup

```bash
# Check if Serena can find Python tools
serena start-mcp-server --context ide-assistant --project . --help

# Test language server initialization (should not show pyright errors)
# Check logs in ~/.serena/logs/
```

## Best Practices

1. **Always specify language** in `.serena/project.yml`
2. **Use UV tool isolation** rather than global pip installs
3. **Keep dependencies updated** with `uv tool upgrade --all`
4. **Use absolute paths** in MCP configurations
5. **Test MCP connection** before relying on it for development

## Reference Links

- [UV Documentation](https://docs.astral.sh/uv/)
- [UV Tool Management](https://docs.astral.sh/uv/concepts/tools/)
- [Serena MCP Server Guide](https://apidog.com/blog/serena-mcp-server-2/)
- [Model Context Protocol](https://modelcontextprotocol.io/)

## Environment Variables

Useful UV environment variables for Serena:

```bash
# Customize tool installation directory
export UV_TOOL_DIR=~/.uv/tools

# Customize tool binary directory  
export UV_TOOL_BIN_DIR=~/.local/bin

# Verify environment
echo $PATH | grep -o "[^:]*uv[^:]*"
```

This setup provides a robust, isolated environment for Serena development with proper dependency management and MCP integration.
