# How to use gemin-cli with custom api

set env variables:
- `GOOGLE_GEMINI_BASE_URL`=your-custom-gemini-base-url
- `GEMINI_API_KEY`=your-api-key

you can alias it in your .bashrc, like this

```bash
alias gemini-api='GOOGLE_GEMINI_BASE_URL="https://custom-base" GEMINI_API_KEY="the-key" gemini'
```
