# use yt-dlp to download youtube videos in high quality

# Initialize variables
$noSound = $false
$video_url = $null

# Parse command line arguments
if ($args.Count -eq 0) {
    Write-Host "Error: Video URL is required."
    Write-Host "Usage: .\download-youtube-high-quality.ps1 <video_url> [--no-sound]"
    exit 1
}

# First argument is the video URL
$video_url = $args[0]

# Check for --no-sound flag in remaining arguments
foreach ($arg in $args[1..($args.Count-1)]) {
    if ($arg -eq "--no-sound") {
        $noSound = $true
    }
}

# Validate video URL
if ([string]::IsNullOrWhiteSpace($video_url)) {
    Write-Host "Error: Invalid video URL."
    Write-Host "Usage: .\download-youtube-high-quality.ps1 <video_url> [--no-sound]"
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

yt-dlp $video_url `
    --format $format `
    --merge-output-format mp4 `
    --output "$outputDir/%(title)s.%(ext)s" `
    --no-playlist `
    --parse-metadata "webpage_url:%(meta_source_url)s" `
    --add-metadata `
    --embed-metadata `
    --progress

Write-Host "Download completed. Video saved in $outputDir folder."
