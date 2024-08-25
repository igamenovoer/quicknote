# How to print frame num and time code in video?

see [this](https://stackoverflow.com/questions/75268361/issues-with-adding-the-current-timestamp-of-a-video-when-using-ffplay) and [this](https://stackoverflow.com/questions/13494902/how-to-display-a-frame-number-on-each-frame-of-a-video-using-ffmpeg)

```bash
# linux
ffmpeg -i crowded_0820.mp4 -vf "drawtext=fontfile=Arial.ttf: text='frame=%{n} time=%{pts\:hms}':start_number=0:x=(w-tw)/2: y=h-(2*lh):fontcolor=black:fontsize=32:box=1:boxcolor=white:boxborderw=5" output.mp4

# windows
ffmpeg -i crowded_0820.mp4 -vf "drawtext=fontfile=Arial.ttf: text='frame=%%{n} time=%%{pts\:hms}':start_number=0:x=(w-tw)/2: y=h-(2*lh):fontcolor=black:fontsize=32:box=1:boxcolor=white:boxborderw=5" output.mp4
```
