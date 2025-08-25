# How to setup aider in powershell profile

```powershell
function aider-gpt5 {
    [CmdletBinding()]
    param(
        [string]$Model = "gpt-5-2025-08-07",
        [string]$BaseUrl = "https://yunwu.ai/v1",
        # Prefer pulling the API key from environment instead of storing plaintext in the profile
        [string]$ApiKey = "sk-...",
        [string]$WeakModel = "gpt-4o",
        # Optional one-shot message to send via --message
        [string]$Message,
        [string]$ReasoningEffort = "medium",
        # Capture any remaining raw aider CLI arguments (e.g. --file foo.py)
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Extra
    )
    # Gracefully handle accidental use of double-dash style: aider-gpt5 --message "hi"
    # PowerShell treats '--message' as a positional argument. Detect this and repair.
    if ($Model -eq '--message') {
        if (-not $Message -and $BaseUrl -and $BaseUrl -notmatch '^https?://') {
            $Message = $BaseUrl
            # Restore defaults for displaced params
            $BaseUrl = 'https://yunwu.ai/v1'
        }
        $Model = 'gpt-5-2025-08-07'
    }
    # Also parse any stray '--message' in Extra
    if (-not $Message -and $Extra) {
        for ($i=0; $i -lt $Extra.Length; $i++) {
            if ($Extra[$i] -eq '--message' -and ($i + 1) -lt $Extra.Length) {
                $Message = $Extra[$i+1]
                $Extra = @($Extra[0..($i-1)] + $Extra[($i+2)..($Extra.Length-1)])
                break
            }
        }
    }

    $argsList = @(
        '--model', $Model
        '--openai-api-base', $BaseUrl
        '--weak-model', $WeakModel,
        '--yes-always',
        '--no-auto-commits',
        '--cache-prompts'
    )

    # Only include API key flag if we actually have a value
    if ($ApiKey) {
        $argsList += @('--openai-api-key', $ApiKey)
    }

    # Include reasoning-effort only for o* models, not gpt-5*
    if ($ReasoningEffort -and ($Model -match '(^o1|^o2|^o3)') ) {
        $argsList += @('--reasoning-effort', $ReasoningEffort)
    }

    if ($Message) {
        $argsList += @('--message', $Message)
    }

    if ($Extra) { $argsList += $Extra }

    aider @argsList
}

```

