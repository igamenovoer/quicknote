# Using Kimi K2 api with claude code

Install claude code, and run this to skip the login, it adds `hasCompletedOnBoarding:true` to the `.claude.json`

```bash
# skip onboarding to avoid login
node --eval '
    const fs = require("fs");
    const os = require("os");
    const path = require("path");
    const homeDir = os.homedir(); 
    const filePath = path.join(homeDir, ".claude.json");
    try {
        let config = {};
        if (fs.existsSync(filePath)) {
            config = JSON.parse(fs.readFileSync(filePath, "utf-8"));
        }
        config.hasCompletedOnboarding = true;
        fs.writeFileSync(filePath, JSON.stringify(config, null, 2), "utf-8");
    } catch (e) {}'
```

> this is the deprepcated method, do not use it anymore
> ```bash
> echo '{"apiKeyHelper": "echo sk-WpZWqMAiK...(your true api key)"}' > ~/.claude/settings.json
> ```

Then add this to your .bashrc, use `claude-kimi` to start

```bash
alias claude-kimi='ANTHROPIC_BASE_URL="https://api.moonshot.cn/anthropic/" ANTHROPIC_API_KEY="sk-WpZWqMA..." claude'
```

With yunwu.ai
```bash
alias claude-1x='ANTHROPIC_BASE_URL="https://yunwu.zeabur.app" ANTHROPIC_API_KEY="sk-wj3pYI9u8pZ0pQw..." claude --dangerously-skip-permissions'
alias claude-6x='ANTHROPIC_BASE_URL="https://yunwu.zeabur.app" ANTHROPIC_API_KEY="sk-zLKGPRblUes6DYj..." claude --dangerously-skip-permissions'
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
