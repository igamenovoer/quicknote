# How to Use the YouTube High-Quality Downloader Script

This document provides instructions on how to use the `download-youtube-high-quality.ps1` PowerShell script to download YouTube videos with various options.

## 1. Overview

The script is a wrapper around the powerful `yt-dlp` tool, designed to simplify the process of downloading high-quality videos, audio, and subtitles from YouTube. It offers a user-friendly command-line interface with several convenient features.

## 2. Requirements

Before using the script, ensure you have the following installed and accessible in your system's PATH:

-   **yt-dlp**: The core tool used for downloading videos. You can install it via pip: `pip install yt-dlp`.
-   **FFmpeg**: Required for merging video and audio files, embedding subtitles, and downloading specific time ranges.

## 3. Usage

The basic syntax for running the script is:

```powershell
.\download-youtube-high-quality.ps1 [options] <video_url>
```

### Options

The script supports the following command-line options:

-   `--help`: Displays the help message with all available options and examples.
-   `--no-sound`: Downloads the video without the audio track.
-   `--start-time <HH:MM:SS>`: Specifies the start time of the video segment to download.
-   `--end-time <HH:MM:SS>`: Specifies the end time of the video segment to download.
-   `--subtitle`: Enables subtitle download.
-   `--sub-lang <language>`: Specifies the full, case-insensitive name of the subtitle language (e.g., "english", "chinese-simplified"). Defaults to "english".
-   `--embed-subtitle`: Embeds the downloaded subtitles directly into the video file.
-   `--proxy <proxy_url>`: Uses the specified HTTP/HTTPS/SOCKS proxy for the download.

## 4. Examples

### Basic Download

To download a video with its audio and default English subtitles:

```powershell
.\download-youtube-high-quality.ps1 --subtitle "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

### Time-Range and Specific Language

To download a specific time segment of a video and embed "chinese-simplified" subtitles:

```powershell
.\download-youtube-high-quality.ps1 --start-time 00:01:10 --end-time 00:01:45 --subtitle --sub-lang "chinese-simplified" --embed-subtitle "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

## 5. Advanced Features

### Dynamic Subtitle Selection

The script intelligently handles subtitle downloads:

-   **User-Friendly Names**: You can use full language names like "english" or "chinese-simplified" instead of short codes.
-   **Dynamic Detection**: The script first checks the video for all available subtitle languages.
-   **Informative Feedback**: If your requested language is not available, the script will list all languages that are, and then proceed to download the video without subtitles.
-   **"Chinese" Alias**: For convenience, using `--sub-lang "chinese"` will automatically default to "chinese-simplified".

### Downloading Private or Members-Only Videos

To download videos that require a login (e.g., private videos, members-only content), you need to provide your browser's cookies to `yt-dlp`. The script makes this easy:

1.  **Install a Cookie Exporter Extension**: Install an extension like **"Get cookies.txt LOCALLY"** from the Chrome or Firefox web store.
2.  **Log In to YouTube**: Make sure you are logged into your YouTube account in the browser.
3.  **Export Cookies**: Navigate to any YouTube video page, click the extension's icon, and export the cookies.
4.  **Save the File**: Save the downloaded file as `cookies.txt` in the same directory as the `download-youtube-high-quality.ps1` script.

The script will automatically detect the `cookies.txt` file and use it for authentication. If the file is not present, the script will proceed with a normal, unauthenticated download.
