Upscales a video using [the waifu2x superscaler][waifu2x] *super fast*.

The frames of the video are clustered before superscaling and only one frame per cluster is superscaled to reduce the time of conversion.
This works well for still image videos, such as lecture slides, where only a few distinct video frames exist.

## Requirements

- [GNU Bash][],
- [GNU Make][],
- [FFmpeg][],
- [Python 3][], and
- [Waifu2x][].

## Installation

First, install the required Python packages:

``` sh
$ pip install -r requirements.txt
```

Then, update the configuration file `configuration.mk`:

- `FFMPEG`: The location of the `ffmpeg` binary in your [FFmpeg][] installation.
- `FFMPEG_OPTIONS`: The [FFmpeg][] output file options, specifying the properties of the output video.
- `FFPROBE`: The location of the `ffprobe` binary in your [FFmpeg][] installation.
- `PYTHON`: The location of the `python` binary in your [Python 3][] installation.
- `WAIFU2X`: The location of the `waifu2x.lua` script in your [Waifu2x][] installation.
- `WAIFU2X_OPTIONS`: The [Waifu2x][] options, specifying the properties of the superscaling.
- `LARGE_STORAGE`: The location of a large storage device, where superscaled video frames will be temporarily stored.

## Usage

Download a sample video:

``` sh
$ wget https://nlp.fi.muni.cz/trac/research/chrome/site/seminar2020/scm-at-arqmath.mp4 -O sample.mp4
sample.mp4   100%[========================================================================>]  70.87M
```

The naive approach that superscales all video frames takes a lot of time:

``` sh
$ time make sample2x-naive.mp4
49 days 13 hours 39 minutes 48.669 seconds
```

Our fast approach that superscales one frame per cluster is a lot faster:

``` sh
$ time make NUMBER_OF_CLUSTERS=21 sample2x.mp4
6 hours 38 minutes 0.670 seconds
```

## Caveats

The video filename may not contain whitespace characters.

 [gnu bash]: https://www.gnu.org/software/bash/
 [gnu make]: https://www.gnu.org/software/make/
 [ffmpeg]: https://www.ffmpeg.org/
 [python 3]: https://www.python.org/
 [waifu2x]: https://github.com/nagadomi/waifu2x
