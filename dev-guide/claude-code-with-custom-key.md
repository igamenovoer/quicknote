# Using Kimi K2 api with claude code

Install claude code, and add this file to skip claude code sign-in requirement

```bash
echo '{"apiKeyHelper": "echo sk-WpZWqMAiK...(your true api key)"}' > ~/.claude/settings.json
```

Then add this to your .bashrc, use `claude-kimi` to start

```bash
alias claude-kimi='ANTHROPIC_BASE_URL="https://api.moonshot.cn/anthropic/" ANTHROPIC_API_KEY="sk-WpZWqMA..." claude'
```

# Create powershell alias

in powershell, you can create alias to quickly switch api provider

```powershell
# in $PROFILE, you can use `code $PROFILE` to open it in vscode

# END: RightArrow Key Handler Configuration
# BEGIN: Claude Skip All Function
# Creates a function to run claude with all skip permissions
function claude-skip-all {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )
    
    # Run claude with --dangerously-skip-permissions and pass all arguments
    & claude --dangerously-skip-permissions @Arguments
}
# END: Claude Skip All Function

# BEGIN: Claude Yunwu Function
# Runs claude pointed at yunwu.ai with placeholder API key, without persisting env changes.
function claude-yunwu {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    $oldBase = $env:ANTHROPIC_BASE_URL
    $oldKey  = $env:ANTHROPIC_API_KEY
    try {
        $env:ANTHROPIC_BASE_URL = "https://yunwu.ai"
        $env:ANTHROPIC_API_KEY  = "sk-your-key..."
        & claude --dangerously-skip-permissions @Arguments
    }
    finally {
        if ($null -ne $oldBase) { $env:ANTHROPIC_BASE_URL = $oldBase } else { Remove-Item Env:ANTHROPIC_BASE_URL -ErrorAction SilentlyContinue }
        if ($null -ne $oldKey)  { $env:ANTHROPIC_API_KEY  = $oldKey  } else { Remove-Item Env:ANTHROPIC_API_KEY  -ErrorAction SilentlyContinue }
    }
}
# END: Claude Yunwu Function
```
