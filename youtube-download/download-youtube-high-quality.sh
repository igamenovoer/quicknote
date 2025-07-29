#!/bin/bash

show_help() {
    cat << 'EOF'
Usage: download-youtube-high-quality.sh [options] <video_url>

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
  ./download-youtube-high-quality.sh --subtitle "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

  # Download a specific time range and embed Simplified Chinese subtitles
  ./download-youtube-high-quality.sh --start-time 00:01:10 --end-time 00:01:45 --subtitle --sub-lang "chinese-simplified" --embed-subtitle "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

Notes:
  - Requires yt-dlp to be installed and in the system's PATH.
  - FFmpeg is required for merging formats, embedding subtitles, and downloading specific time ranges.
  - For private or members-only videos, you may need to provide a cookies.txt file.
    To get this file:
    1. Install a browser extension like "Get cookies.txt LOCALLY" for Chrome/Firefox.
    2. Navigate to the YouTube video page while logged in.
    3. Use the extension to export the cookies.
    4. Save the downloaded file as "cookies.txt" in the same directory as this script.
EOF
}

get_available_subtitles() {
    local video_url="$1"
    local proxy="$2"
    
    echo "Fetching available subtitle languages..."
    
    local list_subs_args=("--list-subs" "$video_url")
    if [[ -n "$proxy" ]]; then
        list_subs_args+=("--proxy" "$proxy")
    fi
    
    # Execute yt-dlp and capture output
    local subtitles_output
    subtitles_output=$(yt-dlp "${list_subs_args[@]}" 2>&1)
    
    # Declare associative array for language mapping
    declare -gA lang_map
    lang_map=()
    
    local captions_started=false
    
    while IFS= read -r line; do
        if [[ "$captions_started" == false ]]; then
            if [[ "$line" =~ Available\ (automatic\ captions|subtitles)\ for ]]; then
                captions_started=true
            fi
            continue
        fi
        
        if [[ "$line" =~ Language[[:space:]]+Name[[:space:]]+Formats ]]; then
            continue
        fi
        
        if [[ -z "${line// }" ]]; then
            break
        fi
        
        # Match pattern: language_code  Language Name  vtt,
        if [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_-]+)[[:space:]]+([[:alpha:][:space:]()_-]+)[[:space:]]+vtt, ]]; then
            local code="${BASH_REMATCH[1]}"
            local name="${BASH_REMATCH[2]}"
            
            # Normalize name: "Chinese (Simplified)" -> "chinese-simplified"
            name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[[:space:]()]+/-/g' | sed 's/-$//')
            
            if [[ -z "${lang_map[$name]:-}" ]]; then
                lang_map["$name"]="$code"
            fi
        fi
    done <<< "$subtitles_output"
}

# Initialize variables
no_sound=false
video_url=""
start_time=""
end_time=""
subtitle=false
user_requested_lang="english"  # Default language
embed_subtitle=false
proxy=""

# Parse command line arguments
if [[ "$*" == *"--help"* ]]; then
    show_help
    exit 0
fi

if [[ $# -eq 0 ]]; then
    echo "Error: Video URL is required."
    echo "Usage: ./download-youtube-high-quality.sh [options] <video_url>"
    exit 1
fi

# The last argument is the video URL
video_url="${!#}"
# All arguments except the last one
script_args=("${@:1:$#-1}")

# Parse remaining arguments
i=0
while [[ $i -lt ${#script_args[@]} ]]; do
    case "${script_args[$i]}" in
        "--no-sound")
            no_sound=true
            ((i++))
            ;;
        "--start-time")
            if [[ $((i + 1)) -lt ${#script_args[@]} ]]; then
                start_time="${script_args[$((i+1))]}"
                ((i += 2))
            else
                echo "Error: --start-time requires a value."
                exit 1
            fi
            ;;
        "--end-time")
            if [[ $((i + 1)) -lt ${#script_args[@]} ]]; then
                end_time="${script_args[$((i+1))]}"
                ((i += 2))
            else
                echo "Error: --end-time requires a value."
                exit 1
            fi
            ;;
        "--subtitle")
            subtitle=true
            ((i++))
            ;;
        "--sub-lang")
            if [[ $((i + 1)) -lt ${#script_args[@]} ]]; then
                user_requested_lang="${script_args[$((i+1))]}"
                ((i += 2))
            else
                echo "Error: --sub-lang requires a value."
                exit 1
            fi
            ;;
        "--embed-subtitle")
            embed_subtitle=true
            ((i++))
            ;;
        "--proxy")
            if [[ $((i + 1)) -lt ${#script_args[@]} ]]; then
                proxy="${script_args[$((i+1))]}"
                ((i += 2))
            else
                echo "Error: --proxy requires a value."
                exit 1
            fi
            ;;
        *)
            echo "Error: Unknown argument ${script_args[$i]}"
            exit 1
            ;;
    esac
done

# Validate video URL
if [[ -z "$video_url" || "$video_url" == -* ]]; then
    echo "Error: Invalid or missing video URL."
    echo "Usage: ./download-youtube-high-quality.sh [options] <video_url>"
    exit 1
fi

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp is not installed. Please install it first."
    echo "You can install it using: pip install yt-dlp"
    exit 1
fi

# Create output directory if it doesn't exist
output_dir="downloads"
if [[ ! -d "$output_dir" ]]; then
    mkdir -p "$output_dir"
    echo "Created output directory: $output_dir"
fi

# Set format based on whether sound is needed or not
if [[ "$no_sound" == true ]]; then
    format="bestvideo[ext=mp4]/best[ext=mp4]/best"
else
    format="bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
fi

# Download the video in high quality mp4 format
echo "Downloading video from: $video_url"
echo "Audio: $(if [[ "$no_sound" == true ]]; then echo 'Disabled'; else echo 'Enabled'; fi)"

# Build yt-dlp command
yt_dlp_args=(
    "$video_url"
    "--format" "$format"
    "--merge-output-format" "mp4"
    "--output" "$output_dir/%(title)s.%(ext)s"
    "--no-playlist"
    "--parse-metadata" "webpage_url:%(meta_source_url)s"
    "--parse-metadata" "description:%(meta_description)s"
    "--add-metadata"
    "--embed-metadata"
    "--progress"
    "--referer" "$video_url"
)

# Optional: Use a cookies file for downloading private or members-only videos.
# To prepare the cookies.txt file:
# 1. Install a browser extension like "Get cookies.txt LOCALLY" for Chrome or Firefox.
# 2. Log in to your YouTube account in the browser.
# 3. Navigate to any YouTube video page.
# 4. Click the extension's icon and export the cookies.
# 5. Save the downloaded file as "cookies.txt" in the same directory as this script.
# The script will automatically detect and use this file if it exists.
if [[ -f "cookies.txt" ]]; then
    yt_dlp_args+=("--cookies" "cookies.txt")
    echo "Using cookies from cookies.txt"
fi

if [[ -n "$proxy" ]]; then
    yt_dlp_args+=("--proxy" "$proxy")
    echo "Using proxy: $proxy"
fi

if [[ -n "$start_time" && -n "$end_time" ]]; then
    yt_dlp_args+=("--download-sections" "*$start_time-$end_time")
    echo "Downloading section from $start_time to $end_time"
fi

# Handle subtitles dynamically
if [[ "$subtitle" == true ]]; then
    # Declare the associative array before calling the function
    declare -A lang_map
    get_available_subtitles "$video_url" "$proxy"
    
    if [[ ${#lang_map[@]} -eq 0 ]]; then
        echo "Warning: No subtitles found for this video."
    else
        normalized_lang=$(echo "$user_requested_lang" | tr '[:upper:]' '[:lower:]')
        if [[ "$normalized_lang" == "chinese" ]]; then
            normalized_lang="chinese-simplified"
        fi
        
        sub_lang_code=""
        if [[ -n "${lang_map[$normalized_lang]:-}" ]]; then
            sub_lang_code="${lang_map[$normalized_lang]}"
        fi
        
        if [[ -n "$sub_lang_code" ]]; then
            echo "Found requested subtitle language: '$user_requested_lang' (code: $sub_lang_code)"
            if [[ "$embed_subtitle" == true ]]; then
                yt_dlp_args+=("--embed-subs")
                echo "Subtitles: Enabled (embedding)"
            else
                yt_dlp_args+=("--write-subs")
                echo "Subtitles: Enabled (writing to file)"
            fi
            yt_dlp_args+=("--write-auto-subs")
            yt_dlp_args+=("--sub-langs" "$sub_lang_code,en")  # Fallback to English if specific lang fails
        else
            echo "Error: Subtitle language '$user_requested_lang' not found for this video."
            echo "Available languages are:"
            for lang in "${!lang_map[@]}"; do
                echo "- $lang"
            done
            echo "Proceeding with download without subtitles."
        fi
    fi
fi

yt-dlp "${yt_dlp_args[@]}"

echo "Download completed. Video saved in $output_dir folder."
