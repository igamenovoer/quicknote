# how to configure aider with project specific setting

set api key via `OPENAI_API_KEY` in your system env

in your project, add these files:

## `.aider.conf.yml`

```yaml
# Project-specific configuration for aider
# Docs: https://aider.chat/docs/config/aider_conf.html
# This file lives at the git repo root so aider auto-detects it.
# NOTE: Do NOT put API keys or secrets here; define them as environment variables.
# You said you'll set env vars later, so they are just commented placeholders below.

# ---------------------------------------------------------------------------
# Environment variables (define in shell; NEVER put real keys in this file):
# PowerShell (current session only):
#   $Env:OPENAI_API_KEY = "<your_openai_key>"
# Persist for new terminals (run once, then open a new window):
#   setx OPENAI_API_KEY "<your_openai_key>"
# Anthropic (if you use Anthropic models):
#   setx ANTHROPIC_API_KEY "<your_anthropic_key>"
# Optional: aider also recognizes the AIDER_* variants (AIDER_OPENAI_API_KEY, AIDER_ANTHROPIC_API_KEY)
# but the standard variable names above are what the warnings reference.
# ---------------------------------------------------------------------------

# Core model configuration
# Replace with models you actually have access to. If a model isn't available,
# aider will complain at startup; just edit these names.
openai-api-base: https://yunwu.ai/v1  # Custom OpenAI-compatible base URL for this project
model: gpt-5-2025-08-07              # Primary reasoning/coding model (custom endpoint)
weak-model: gpt-4o                   # Updated per request
editor-model: gpt-5-2025-08-07       # Match main model per request
cache-prompts: true                  # Enable provider prompt caching (caches repo map & read-only file prompts)
# cache-keepalive-pings: 5           # Keep prompt cache warm; send a keepalive ping every 5 minutes (uncomment to enable)
# You can comment any of the above out if you prefer aider defaults.

# Limit how much prior conversation gets re-sent (controls cost & context size)
max-chat-history-tokens: 400000

# Automatic commit behavior
auto-commits: false                # Disabled per user request (no automatic commits after edits)
attribute-commit-message-author: false # If later enabling auto/manual commits, adds 'aider:' authored-by marker in commit message
# attribute-commit-message-committer: true  # Enable if you also want committer attribution
# commit: true                     # Force a commit even if aider thinks it's unnecessary
# git-commit-verify: true          # Enforce pre-commit hooks (disabled by default)

# File watching (allows inline ai: comments in code to trigger context captures)
watch-files: true

# Language settings
chat-language: en
commit-language: en

# History & artifact file locations (add these patterns to .gitignore so they are not committed)
input-history-file: .aider.input.history
chat-history-file: .aider.chat.history.md
# llm-history-file: .aider.llm.history.json    # Uncomment if you want raw LLM exchange logs

## File ignore controls
# aiderignore: path to ignore file for context building (defaults to .aiderignore in repo root)
aiderignore: .aiderignore          # Explicitly specify (optional; here for clarity)
add-gitignore-files: true          # Treat .gitignore patterns as ignored when suggesting files

# Note: The openai-api-base line is shown only in verbose (-v) output as `openai_api_base:`. Use `aider -v --dry-run` to verify.

# Safety / UX tweaks (uncomment if desired)
yes-always: true           # Skip y/n confirmations (user requested)
# multiline: true           # Enable multiline input mode by default
# dark-mode: true           # Force dark mode output styling

# Advanced / niche options (left commented; add as needed)
# commit-prompt: "<custom prompt template>"
# restore-chat-history: true              # Try to restore previous session context
# map-multiplier-no-files: 1.5            # Tuning for summarization scaling
# show-model-warnings: false              # Silence model mismatch warnings
# set-env: ["VAR1=value1", "VAR2=value2"]  # Set extra env vars when running aider

# ---------------------------------------------------------------------------
# Project notes:
# This repository contains large generated documentation directories (casey-docs/, docs/, tmp/).
# They are excluded via .aiderignore to avoid bloating context & token usage.
# Add only the specific source/test files you want aider to consider, e.g.:
#   /add src/ tests/test_client.py
# Avoid adding large HTML dumps unless working directly on them.
# ---------------------------------------------------------------------------
```

## `.aider.model.settings.yml`

this is for model specific settings (reasoning efforts, temperature, etc.)

```yaml
# Aider advanced model settings
# Docs: https://aider.chat/docs/config/adv-model-settings.html
# IMPORTANT: This file must be a YAML LIST (each item begins with a dash).
# Each list item is a dict of settings for a single model.

# Set temperature 1.0 for the main model.
- name: gpt-5-2025-08-07
  extra_params:
    temperature: 1.0
  # You can add more per-model overrides here if needed, eg:
  # edit_format: diff
  # use_repo_map: true

# (Optional) Global extra params applied to all models (uncomment to use):
# - name: aider/extra_params
#   extra_params:
#     temperature: 1.0
#     # Any other litellm completion params go here.

```
