# How to extract all frames?

In windows, `.bat` file

```bat
REM convert video to frames using ffmpeg, given a video file as input
set video_file=%1
set start_time=%2
set duration=%3
set output_dir=%4

REM create output directory
mkdir %output_dir%

REM convert video to frames
ffmpeg -i %video_file% -ss %start_time% -t %duration% "%output_dir%\frame_%%07d.jpg"
```
