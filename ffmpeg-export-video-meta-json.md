# How to export video metadata as json

see [this](https://stackoverflow.com/questions/7708373/get-ffmpeg-information-in-friendly-way)

in short, use ffprobe like this
```bash
ffprobe -v quiet -print_format json -show_format -show_streams video.mp4
```
