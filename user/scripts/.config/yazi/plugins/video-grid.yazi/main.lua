local M = {}

-- ─────────────────────────────────────────────────────────────
--  CONFIGURATION
--  Adjust these values as needed
-- ─────────────────────────────────────────────────────────────

-- Maximum video file size (in bytes)
-- Files above this limit will be skipped without spawning ffmpeg
-- Default: 500MB = 500 * 1024 * 1024
local MAX_FILE_SIZE = 500 * 1024 * 1024

-- Maximum concurrent ffmpeg processes (layer 2 safety net)
-- Layer 1 is already handled by macro_workers in yazi.toml
-- This value should be equal to or less than macro_workers
local MAX_CONCURRENT = 3

-- ffprobe timeout in seconds
-- If ffprobe doesn't complete within this time, it's considered failed
local FFPROBE_TIMEOUT = 5

-- Grid thumbnail: tile layout and scale
-- "2x2" = 4 frames, scale 400px width
local TILE_LAYOUT   = "2x2"
local SCALE_WIDTH   = 400
local FRAME_COUNT   = 4

-- ─────────────────────────────────────────────────────────────
--  STATE: Semaphore to throttle concurrent ffmpeg processes
--  This is shared at plugin level (per yazi session)
-- ─────────────────────────────────────────────────────────────
local active_jobs = 0

-- ─────────────────────────────────────────────────────────────
--  PEEK: Display cached thumbnail
-- ─────────────────────────────────────────────────────────────
function M:peek(job)
    local cache = ya.file_cache(job)

    -- No cache path, or preload not complete
    if not cache or self:preload(job) ~= 1 then
        return
    end

    ya.image_show(cache, job.area)
    ya.preview_widgets(job, {})
end

function M:seek(job) end

-- ─────────────────────────────────────────────────────────────
--  PRELOAD: Generate thumbnail with layered throttling
-- ─────────────────────────────────────────────────────────────
function M:preload(job)

    -- ── Layer 3: Skip if this job is a re-trigger ──────────
    -- job.skip > 0 means yazi has already triggered this preload
    -- and the result is still pending. No need to spawn again.
    if job.skip > 0 then
        return 1
    end

    -- ── Layer 4: Skip files above size limit ───────────────
    -- job.file.cha.len is the file size in bytes
    -- This is zero-cost, no additional syscalls needed
    local file_size = job.file.cha and job.file.cha.len or 0
    if file_size > MAX_FILE_SIZE then
        ya.err(string.format(
            "[video-grid] SKIP (size): %s — %.0f MB exceeds limit %.0f MB",
            tostring(job.file.url),
            file_size / 1024 / 1024,
            MAX_FILE_SIZE / 1024 / 1024
        ))
        return 0
    end

    -- ── Layer 5: Skip if cache exists ────────────────────
    -- fs.cha(cache) returns truthy if cache file exists
    -- No need to regenerate existing thumbnails
    local cache = ya.file_cache(job)
    if not cache then
        return 0
    end
    if fs.cha(cache) then
        return 1  -- cache hit, immediate success return
    end

    -- ── Layer 2: Semaphore — throttle at plugin level ─────────
    -- If MAX_CONCURRENT ffmpeg processes are running, return 2
    -- Return 2 = "not ready, try again later" (yazi will retry)
    if active_jobs >= MAX_CONCURRENT then
        return 2
    end

    -- ── Start thumbnail generation process ─────────────────────
    active_jobs = active_jobs + 1

    -- Probe video duration to calculate grid fps
    -- Timeout to avoid hangs on corrupt or unreadable files
    local probe = Command("ffprobe")
        :arg("-i"):arg(tostring(job.file.url))
        :arg("-show_entries"):arg("format=duration")
        :arg("-v"):arg("quiet")
        :arg("-of"):arg("csv=p=0")
        :arg("-timeout"):arg(tostring(FFPROBE_TIMEOUT * 1000000))  -- in microseconds
        :stdout(Command.PIPED)
        :output()

    local duration = probe and probe.stdout and tonumber(probe.stdout)

    if not duration or duration <= 0 then
        ya.err(string.format(
            "[video-grid] ERROR ffprobe: %s — output: %s",
            tostring(job.file.url),
            tostring(probe and probe.stdout)
        ))
        active_jobs = active_jobs - 1
        return 0
    end

    -- Calculate fps to produce exactly FRAME_COUNT frames
    -- evenly distributed across video duration
    local fps_val = FRAME_COUNT / duration
    local filter_string = string.format(
        "fps=%f,scale=%d:-1,tile=%s",
        fps_val, SCALE_WIDTH, TILE_LAYOUT
    )

    -- Spawn ffmpeg to generate thumbnail grid
    local child, err_code = Command("ffmpeg")
        :arg("-v"):arg("quiet")
        :arg("-y")                                      -- overwrite cache if exists
        :arg("-nostdin")                                -- non-interactive
        :arg("-i"):arg(tostring(job.file.url))
        :arg("-vf"):arg(filter_string)
        :arg("-frames:v"):arg("1")                     -- only 1 frame output (grid)
        :arg("-q:v"):arg("3")                           -- JPG quality (1=best, 31=worst)
        :arg("-f"):arg("image2")
        :arg("-c:v"):arg("mjpeg")
        :arg(tostring(cache))
        :spawn()

    if not child then
        ya.err(string.format(
            "[video-grid] ERROR spawn ffmpeg: %s — code: %s",
            tostring(job.file.url),
            tostring(err_code)
        ))
        active_jobs = active_jobs - 1
        return 0
    end

    -- Wait for ffmpeg to complete
    local status = child:wait()
    active_jobs = active_jobs - 1

    if status and status.success then
        return 1  -- success, cache ready to display
    else
        ya.err(string.format(
            "[video-grid] ERROR ffmpeg exit: %s — status: %s",
            tostring(job.file.url),
            tostring(status and status.code)
        ))
        return 2  -- failed, yazi will retry according to bizarre_retry
    end
end

return M
