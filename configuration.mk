FFMPEG=ffmpeg -loglevel error -stats
FFMPEG_OPTIONS=-c:v libx264 -crf 17 -pixel_format yuv420p -preset veryslow -tune stillimage -movflags +faststart -c:a copy -y

FFPROBE=ffprobe -v 0

PYTHON=python3

WAIFU2X=th /opt/waifu2x/waifu2x.lua
WAIFU2X_OPTIONS=-force_cudnn 1 -model_dir /opt/waifu2x/models/anime_style_art -tta 1 -tta_level 8 -m noise_scale -noise_level 1 -scale 2 -resume 1

LARGE_STORAGE=/var/tmp

NUMBER_OF_CLUSTERS=100
