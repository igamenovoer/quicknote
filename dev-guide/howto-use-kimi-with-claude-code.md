# Using Kimi K2 api with claude code

Install claude code, and add this file to skip claude code sign-in requirement

```bash
echo '{"apiKeyHelper": "echo sk-WpZWqMAiK..."}' > ~/.claude/settings.json
```

Then add this to your .bashrc, use `claude-kimi` to start

```bash
alias claude-kimi='ANTHROPIC_BASE_URL="https://api.moonshot.cn/anthropic/" ANTHROPIC_API_KEY="sk-WpZWqMA..." claude'
```
