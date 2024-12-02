This shows how to retrieve youtube live stream using opencv.

Make sure you also set http proxy in the command prompt

```python
import numpy as np
import cv2
from yt_dlp import YoutubeDL
import os
import logging

os.environ['http_proxy'] = 'http://127.0.0.1:30080'
os.environ['https_proxy'] = 'http://127.0.0.1:30080'

video_url = 'https://youtu.be/1EiC9bvVGnk'

# Configure yt-dlp options
ydl_opts = {
    'format': 'best[ext=mp4]',  # Get best quality MP4
    'quiet': True,
}

# Get video URL using yt-dlp
with YoutubeDL(ydl_opts) as ydl:
    info = ydl.extract_info(video_url, download=False)
    stream_url = info['url']

# Start the video capture
cap = cv2.VideoCapture(stream_url)
while True:
    ret, frame = cap.read()
    if not ret:
        continue
        
    """
    your code here
    """
    cv2.imshow('frame', frame)
    if cv2.waitKey(int(1000/60)) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
```
