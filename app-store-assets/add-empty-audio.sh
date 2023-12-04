#!/bin/bash

if [ $# -eq 0 ]; then
    read -p "Enter video file name, without .mp4: " video
else
    video=$1
fi

# check existing
if [ ! -f "$video.mp4" ]; then
    echo "File $video.mp4 does not exist."
    exit 1
fi

DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$video.mp4")
# Check if the duration is within the required range by apple (15-30 seconds)
if (( $(echo "$DURATION >= 15 && $DURATION <= 30" | bc -l) )); then
    echo "The duration of the video is within the acceptable range."
else
    echo "Error: The video duration is not between 15 and 30 seconds."
    exit 1
fi

ffmpeg -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -i $video.mp4 -crf 28 -filter:v fps=30 -c:a aac -shortest $video-emptyaudio.mp4
