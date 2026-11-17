# video-grid.yazi

A [yazi](https://github.com/sxyazi/yazi) plugin that generates **thumbnail grid previews** for video files — directly inside your terminal.

Instead of showing a single frame, `video-grid` extracts multiple frames across the video timeline and stitches them into a 2×2 grid, giving you a quick visual overview of the content at a glance.

> 📸 **Screenshot**
> ![screenshot](./screenshot.png)

---

## Features

- 🎬 **2×2 grid preview** — 4 frames sampled evenly across the video duration
- ⚡ **Throttled processing** — built-in concurrency limiter prevents CPU overload in large directories
- 💾 **Smart caching** — already-generated thumbnails are never re-processed
- 🚫 **Large file skip** — files above a configurable size threshold (default 500MB) are skipped instantly
- 🔁 **Graceful retry** — failed jobs are handled cleanly and retried by yazi's task queue
- 📦 **Supports common formats** — mp4, mkv, mov, avi, webm, and any format supported by ffmpeg

---

## Requirements

- [yazi](https://github.com/sxyazi/yazi) `>= 26.x`
- [ffmpeg](https://ffmpeg.org/) — for frame extraction and grid generation
- [ffprobe](https://ffmpeg.org/) — bundled with ffmpeg, used for duration probing

Install ffmpeg via Homebrew:

```bash
brew install ffmpeg
```

---

## Installation

**Via yazi package manager (recommended):**

```bash
ya pkg add ryanda/video-grid.yazi
```

**Manual:**

```bash
git clone https://github.com/ryanda/video-grid.yazi.git \
  ~/.config/yazi/plugins/video-grid.yazi
```

---

## Setup

**1. Register the plugin in `~/.config/yazi/yazi.toml`:**

```toml
[plugin]
prepend_preloaders = [
  { mime = "video/*", run = "video-grid" },
]
prepend_previewers = [
  { mime = "video/*", run = "video-grid" },
]
```

**2. Tune concurrency in `~/.config/yazi/yazi.toml`:**

```toml
[tasks]
macro_workers = 3  # recommended: keep low to avoid spawning too many ffmpeg processes
micro_workers = 10
bizarre_retry = 3
```

> **Why `macro_workers = 3`?**
> Preloaders run as macro tasks. With the default value of 10, yazi can spawn up to 10 ffmpeg processes simultaneously in a video-heavy directory. Setting it to 3 keeps CPU usage sane while still generating thumbnails quickly.

---

## Configuration

You can tweak the plugin behavior by editing the constants at the top of `main.lua`:

```lua
-- Maximum file size to process (in bytes). Files above this are skipped.
-- Default: 500MB
local MAX_FILE_SIZE = 500 * 1024 * 1024

-- Maximum concurrent ffmpeg processes (plugin-level safety net)
-- Keep this equal to or lower than macro_workers in yazi.toml
local MAX_CONCURRENT = 3

-- ffprobe timeout in seconds
local FFPROBE_TIMEOUT = 5

-- Thumbnail grid layout
local TILE_LAYOUT  = "2x2"   -- 2 columns × 2 rows = 4 frames
local SCALE_WIDTH  = 400     -- output image width in pixels
local FRAME_COUNT  = 4       -- must match tile grid (2x2 = 4)
```

---

## How It Works

1. When yazi previews a video file, it calls `preload` to generate a thumbnail cache
2. The plugin first checks if a cache already exists — if so, it returns immediately
3. Files exceeding `MAX_FILE_SIZE` are skipped without spawning any process
4. `ffprobe` measures the video duration to calculate even frame sampling intervals
5. `ffmpeg` extracts frames and tiles them into a single grid image, saved to yazi's cache directory
6. On subsequent visits, the cached thumbnail is displayed instantly

---

## Tested On

| OS | Arch | yazi | ffmpeg |
|---|---|---|---|
| macOS Sequoia 15.x | Apple M1 | 26.1.22 | via Homebrew |

> Contributions with test results on Linux or other platforms are welcome.

---

## Troubleshooting

**Thumbnails not showing up**

- Make sure `ffmpeg` and `ffprobe` are installed and accessible in your `$PATH`
- Run `yazi` with logging enabled to see plugin errors: `YAZI_LOG=debug yazi`
- Check logs for `[video-grid]` prefixed messages

**High CPU usage in large directories**

- Lower `macro_workers` in `yazi.toml` (recommended: `3`)
- Lower `MAX_CONCURRENT` in `main.lua`

**Large video files are skipped**

- This is intentional. Adjust `MAX_FILE_SIZE` in `main.lua` to fit your needs.

---

## License

MIT © [ryanda](https://github.com/ryanda)