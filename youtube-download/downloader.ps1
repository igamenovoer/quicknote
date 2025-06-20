function Show-Help {
    Write-Host @"
Usage: download-youtube-high-quality.ps1 [options] <video_url>

Downloads a YouTube video with various options for quality, audio, subtitles, and time range.

Options:
  --help                Show this help message and exit.
  --no-sound            Download the video without audio.
  --start-time arg      The start time of the video segment to download (HH:MM:SS).
  --end-time arg        The end time of the video segment to download (HH:MM:SS).
  --subtitle            Download subtitles for the video.
  --sub-lang arg        The full language name for the subtitles (e.g., "english", "chinese-simplified").
                        Defaults to "english". Case-insensitive.
  --embed-subtitle      Embed the subtitles into the video file.
  --proxy arg           Use the specified HTTP/HTTPS/SOCKS proxy.

Examples:
  # Download a video with audio and default English subtitles
  .\download-youtube-high-quality.ps1 --subtitle "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

  # Download a specific time range and embed Simplified Chinese subtitles
  .\download-youtube-high-quality.ps1 --start-time 00:01:10 --end-time 00:01:45 --subtitle --sub-lang "chinese-simplified" --embed-subtitle "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

Notes:
  - Requires yt-dlp to be installed and in the system's PATH.
  - FFmpeg is required for merging formats, embedding subtitles, and downloading specific time ranges.
  - For private or members-only videos, you may need to provide a cookies.txt file.
    To get this file:
    1. Install a browser extension like "Get cookies.txt LOCALLY" for Chrome/Firefox.
    2. Navigate to the YouTube video page while logged in.
    3. Use the extension to export the cookies.
    4. Save the downloaded file as "cookies.txt" in the same directory as this script.
"@
}

function Get-AvailableSubtitles {
    param (
        [string]$video_url,
        [string]$proxy
    )

    Write-Host "Fetching available subtitle languages..."
    $listSubsArgs = @("--list-subs", $video_url)
    if ($proxy) {
        $listSubsArgs += "--proxy", $proxy
    }

    # Execute yt-dlp and capture output
    $subtitlesOutput = & yt-dlp $listSubsArgs 2>&1 | Out-String

    $langMap = [ordered]@{}
    $lines = $subtitlesOutput.Split([System.Environment]::NewLine)
    $captionsStarted = $false

    foreach ($line in $lines) {
        if (!$captionsStarted) {
            if ($line -match "Available (automatic captions|subtitles) for") {
                $captionsStarted = $true
            }
            continue
        }

        if ($line -match "Language\s+Name\s+Formats") {
            continue
        }
        if ([string]::IsNullOrWhiteSpace($line)) {
            break
        }

        $match = [regex]::Match($line.Trim(), "^([a-zA-Z0-9_-]+)\s+([\w\s\(\)-]+?)\s+vtt,")
        if ($match.Success) {
            $code = $match.Groups[1].Value.Trim()
            # Normalize name: "Chinese (Simplified)" -> "chinese-simplified"
            $name = $match.Groups[2].Value.Trim().ToLower() -replace '[\s\(\)]+', '-' -replace '-$', ''
            if (-not $langMap.Keys.Contains($name)) {
                $langMap.Add($name, $code)
            }
        }
    }
    return $langMap
}


# Initialize variables
$noSound = $false
$video_url = $null
$startTime = $null
$endTime = $null
$subtitle = $false
$userRequestedLang = "english" # Default language
$embedSubtitle = $false
$proxy = $null

# Parse command line arguments
if ($args.Contains("--help")) {
    Show-Help
    exit 0
}

if ($args.Count -eq 0) {
    Write-Host "Error: Video URL is required."
    Write-Host "Usage: .\download-youtube-high-quality.ps1 [options] <video_url>"
    exit 1
}

# The last argument is the video URL
$video_url = $args[-1]
$scriptArgs = if ($args.Count -gt 1) { $args[0..($args.Count - 2)] } else { @() }

# Parse remaining arguments
$i = 0
while ($i -lt $scriptArgs.Count) {
    switch ($scriptArgs[$i]) {
        "--no-sound" {
            $noSound = $true
            $i++
        }
        "--start-time" {
            if ($i + 1 -lt $scriptArgs.Count) {
                $startTime = $scriptArgs[$i+1]
                $i += 2
            } else {
                Write-Host "Error: --start-time requires a value."
                exit 1
            }
        }
        "--end-time" {
            if ($i + 1 -lt $scriptArgs.Count) {
                $endTime = $scriptArgs[$i+1]
                $i += 2
            } else {
                Write-Host "Error: --end-time requires a value."
                exit 1
            }
        }
        "--subtitle" {
            $subtitle = $true
            $i++
        }
        "--sub-lang" {
            if ($i + 1 -lt $scriptArgs.Count) {
                $userRequestedLang = $scriptArgs[$i+1]
                $i += 2
            } else {
                Write-Host "Error: --sub-lang requires a value."
                exit 1
            }
        }
        "--embed-subtitle" {
            $embedSubtitle = $true
            $i++
        }
        "--proxy" {
            if ($i + 1 -lt $scriptArgs.Count) {
                $proxy = $scriptArgs[$i+1]
                $i += 2
            } else {
                Write-Host "Error: --proxy requires a value."
                exit 1
            }
        }
        default {
            Write-Host "Error: Unknown argument $($scriptArgs[$i])"
            exit 1
        }
    }
}

# Validate video URL
if ([string]::IsNullOrWhiteSpace($video_url) -or $video_url.StartsWith("-")) {
    Write-Host "Error: Invalid or missing video URL."
    Write-Host "Usage: .\download-youtube-high-quality.ps1 [options] <video_url>"
    exit 1
}

# Check if yt-dlp is installed
if (!(Get-Command yt-dlp -ErrorAction SilentlyContinue)) {
    Write-Host "yt-dlp is not installed. Please install it first."
    Write-Host "You can install it using: pip install yt-dlp"
    exit 1
}

# Create output directory if it doesn't exist
$outputDir = "downloads"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Host "Created output directory: $outputDir"
}

# Set format based on whether sound is needed or not
$format = if ($noSound) {
    "bestvideo[ext=mp4]/best[ext=mp4]/best"
} else {
    "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
}

# Download the video in high quality mp4 format
Write-Host "Downloading video from: $video_url"
Write-Host "Audio: $(if ($noSound) { 'Disabled' } else { 'Enabled' })"

# Build yt-dlp command
$ytDlpArgs = @(
    $video_url,
    "--format", $format,
    "--merge-output-format", "mp4",
    "--output", "$outputDir/%(title)s.%(ext)s",
    "--no-playlist",
    "--parse-metadata", "webpage_url:%(meta_source_url)s",
    "--parse-metadata", "description:%(meta_description)s",
    "--add-metadata",
    "--embed-metadata",
    "--progress",
    "--referer", $video_url
)

# Optional: Use a cookies file for downloading private or members-only videos.
# To prepare the cookies.txt file:
# 1. Install a browser extension like "Get cookies.txt LOCALLY" for Chrome or Firefox.
# 2. Log in to your YouTube account in the browser.
# 3. Navigate to any YouTube video page.
# 4. Click the extension's icon and export the cookies.
# 5. Save the downloaded file as "cookies.txt" in the same directory as this script.
# The script will automatically detect and use this file if it exists.
if (Test-Path "cookies.txt") {
    $ytDlpArgs += "--cookies", "cookies.txt"
    Write-Host "Using cookies from cookies.txt"
}

if ($proxy) {
    $ytDlpArgs += "--proxy", $proxy
    Write-Host "Using proxy: $proxy"
}

if ($startTime -and $endTime) {
    $ytDlpArgs += "--download-sections", "*$startTime-$endTime"
    Write-Host "Downloading section from $startTime to $endTime"
}

# Handle subtitles dynamically
if ($subtitle) {
    $availableSubs = Get-AvailableSubtitles -video_url $video_url -proxy $proxy

    if ($availableSubs.Count -eq 0) {
        Write-Host "Warning: No subtitles found for this video."
    } else {
        $normalizedLang = $userRequestedLang.ToLower()
        if ($normalizedLang -eq "chinese") {
            $normalizedLang = "chinese-simplified"
        }

        $subLangCode = $null
        if ($availableSubs.Keys.Contains($normalizedLang)) {
            $subLangCode = $availableSubs[$normalizedLang]
        }

        if ($subLangCode) {
            Write-Host "Found requested subtitle language: '$userRequestedLang' (code: $subLangCode)"
            if ($embedSubtitle) {
                $ytDlpArgs += "--embed-subs"
                Write-Host "Subtitles: Enabled (embedding)"
            } else {
                $ytDlpArgs += "--write-subs"
                Write-Host "Subtitles: Enabled (writing to file)"
            }
            $ytDlpArgs += "--write-auto-subs"
            $ytDlpArgs += "--sub-langs", "$subLangCode,en" # Fallback to English if specific lang fails
        } else {
            Write-Host "Error: Subtitle language '$userRequestedLang' not found for this video."
            Write-Host "Available languages are:"
            $availableSubs.GetEnumerator() | ForEach-Object { Write-Host "- $($_.Name)" }
            Write-Host "Proceeding with download without subtitles."
        }
    }
}

yt-dlp $ytDlpArgs

Write-Host "Download completed. Video saved in $outputDir folder."
