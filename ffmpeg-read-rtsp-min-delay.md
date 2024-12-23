### How to read rtsp stream with minimum delay?

```bash
ffplay -fflags nobuffer -flags low_delay -framedrop -probesize 32 -analyzeduration 0 -sync ext -vf setpts=0 -rtsp_transport udp rtsp://username@ip:port/stream
```

Here's what each option does:

1. `-fflags nobuffer`: Reduces buffering during stream analysis
2. `-flags low_delay`: Forces low delay mode
3. `-framedrop`: Drops frames if video gets out of sync
4. `-probesize 32`: Minimizes initial analysis size (default is 5MB)
5. `-analyzeduration 0`: Minimizes stream analysis time
6. `-sync ext`: Uses external clock source for sync
7. `-vf setpts=0`: Displays frames immediately without framerate delay
8. `-rtsp_transport udp`: Uses UDP for RTSP transport (lower latency than TCP but less reliable)

### Alternative Options

If you still experience latency issues, you can try these additional options:

1. Add `-avioflags direct` to reduce buffering:
```bash
ffplay -fflags nobuffer -flags low_delay -framedrop -avioflags direct -rtsp_transport udp rtsp://username@ip:port/stream
```

2. For MPEG-TS streams, add `-omit_video_pes_length 1`:
```bash
ffplay -fflags nobuffer -flags low_delay -omit_video_pes_length 1 -rtsp_transport udp rtsp://username@ip:port/stream
```

[Source 1](https://stackoverflow.com/questions/16658873/how-to-minimize-the-delay-in-a-live-streaming-with-ffmpeg)
[Source 2](https://superuser.com/questions/1776901/streaming-video-over-udp-with-ffmpeg-h264-low-latency)

Note: While UDP offers lower latency, it may result in frame drops or artifacts due to its unreliable nature. If you experience too many artifacts, consider switching to TCP with `-rtsp_transport tcp`.
