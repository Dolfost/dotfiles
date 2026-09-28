-- Re-encode the current A-B loop into its own file.
--
-- Ctrl+l (../input.conf) opens the console asking for a name, prefilled with
-- the last name used; that name is kept in ~/.local/state/mpv so it survives
-- restarts. When <name>.<ext> already exists the clip goes to <name>_1.<ext>,
-- then _2, ... so naming once and pressing Ctrl+l on each loop numbers a
-- series of fragments. The encode runs in the background through ffmpeg and
-- reports on the OSD when it is done.
--
-- `script-message ab-loop-export-as <name>` exports without the prompt.
-- Tunables: ../script-opts/ab-loop-export.conf.

local mp = require "mp"
local utils = require "mp.utils"
local msg = require "mp.msg"
local options = require "mp.options"

local o = {
	dir = "",
	ext = "mp4",
	vcodec = "libx264",
	acodec = "aac",
	crf = 18,
	preset = "medium",
	audio_bitrate = "192k",
	pix_fmt = "yuv420p",
	extra_args = "",
	state_file = "~~state/ab-loop-export.name",
}
options.read_options(o, "ab-loop-export")

local function expand(path)
	return mp.command_native({ "expand-path", path })
end

local function mkdirp(dir)
	local res = mp.command_native({
		name = "subprocess",
		args = { "mkdir", "-p", dir },
		playback_only = false,
	})
	return res and res.status == 0
end

local function read_file(path)
	local f = io.open(path, "r")
	if not f then return nil end
	local data = f:read("*a")
	f:close()
	return data
end

local function write_file(path, data)
	mkdirp((utils.split_path(path)))
	local f = io.open(path, "w")
	if not f then return false end
	f:write(data)
	f:close()
	return true
end

-- The name typed last time, remembered across mpv sessions.
local last_name = nil

local function state_path()
	return expand(o.state_file)
end

local function load_last_name()
	if last_name then return last_name end
	local data = read_file(state_path())
	if data then
		last_name = data:gsub("%s+$", "")
		if last_name == "" then last_name = nil end
	end
	return last_name
end

local function save_last_name(name)
	last_name = name
	if not write_file(state_path(), name .. "\n") then
		msg.warn("could not remember the clip name in " .. state_path())
	end
end

local function loop_range()
	local a = mp.get_property_number("ab-loop-a")
	local b = mp.get_property_number("ab-loop-b")
	if not a or not b then return nil end
	if a > b then a, b = b, a end
	if b - a <= 0 then return nil end
	return a, b
end

local function is_url(path)
	return path:find("^%a[%w+.-]*://") ~= nil
end

-- What ffmpeg should read: local files as given (made absolute so the OSD
-- and the output dir make sense), ytdl streams through the resolved media
-- URL that mpv itself opens.
local function source()
	local path = mp.get_property("path")
	if not path then return nil end
	if is_url(path) then
		return mp.get_property("stream-open-filename") or path
	end
	if path:sub(1, 1) ~= "/" then
		path = utils.join_path(mp.get_property("working-directory"), path)
	end
	return path:gsub("/%./", "/")
end

local function default_dir(src)
	if o.dir ~= "" then return expand(o.dir) end
	if is_url(src) then return expand("~/Videos") end
	return (utils.split_path(src))
end

local function source_stem()
	local name = mp.get_property("filename/no-ext") or "clip"
	return name
end

local function free_path(dir, base, ext)
	local candidate = utils.join_path(dir, base .. "." .. ext)
	local n = 0
	while utils.file_info(candidate) do
		n = n + 1
		candidate = utils.join_path(dir, string.format("%s_%d.%s", base, n, ext))
	end
	return candidate
end

local function split_args(s)
	local args = {}
	for word in s:gmatch("%S+") do args[#args + 1] = word end
	return args
end

local function selected_track(kind)
	for _, t in ipairs(mp.get_property_native("track-list") or {}) do
		if t.type == kind and t.selected then return t end
	end
	return nil
end

-- Builds the ffmpeg command line. Input-side -ss plus -t re-encodes from the
-- exact A point (ffmpeg decodes from the previous keyframe and drops what is
-- before A), which is what makes the clip frame-accurate.
local function ffmpeg_args(src, a, b, out)
	local args = { "ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "error", "-y" }
	local function input(path)
		args[#args + 1] = "-ss"
		args[#args + 1] = string.format("%.3f", a)
		args[#args + 1] = "-i"
		args[#args + 1] = path
	end
	input(src)

	local maps = {}
	local video = selected_track("video")
	if video and not video.external and video["ff-index"] then
		maps[#maps + 1] = "0:" .. video["ff-index"]
	else
		maps[#maps + 1] = "0:v:0?"
	end

	local audio = selected_track("audio")
	if audio and audio.external and audio["external-filename"] then
		input(audio["external-filename"])
		maps[#maps + 1] = "1:" .. (audio["ff-index"] or "a:0")
	elseif audio and audio["ff-index"] then
		maps[#maps + 1] = "0:" .. audio["ff-index"]
	end

	for _, m in ipairs(maps) do
		args[#args + 1] = "-map"
		args[#args + 1] = m
	end
	if not audio then args[#args + 1] = "-an" end
	args[#args + 1] = "-sn"
	args[#args + 1] = "-dn"

	args[#args + 1] = "-t"
	args[#args + 1] = string.format("%.3f", b - a)
	args[#args + 1] = "-c:v"
	args[#args + 1] = o.vcodec
	args[#args + 1] = "-crf"
	args[#args + 1] = tostring(o.crf)
	args[#args + 1] = "-preset"
	args[#args + 1] = o.preset
	if o.pix_fmt ~= "" then
		args[#args + 1] = "-pix_fmt"
		args[#args + 1] = o.pix_fmt
	end
	args[#args + 1] = "-c:a"
	args[#args + 1] = o.acodec
	args[#args + 1] = "-b:a"
	args[#args + 1] = o.audio_bitrate
	if o.ext == "mp4" or o.ext == "mov" or o.ext == "m4a" then
		args[#args + 1] = "-movflags"
		args[#args + 1] = "+faststart"
	end
	for _, extra in ipairs(split_args(o.extra_args)) do
		args[#args + 1] = extra
	end
	args[#args + 1] = out
	return args
end

local function export(name)
	name = (name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" then
		mp.osd_message("No name given, clip not saved")
		return
	end
	local a, b = loop_range()
	if not a then
		mp.osd_message("Set an A-B loop first (l)")
		return
	end
	local src = source()
	if not src then
		mp.osd_message("Nothing is playing")
		return
	end
	if src:find("^edl://") or src:find("^memory://") then
		mp.osd_message("This stream has no single file for ffmpeg to read")
		return
	end

	save_last_name(name)

	local suffix = "%." .. o.ext:gsub("%W", "%%%0") .. "$"
	local dir, base = utils.split_path(name)
	base = base:gsub(suffix, "")
	if name:sub(1, 1) == "/" then
		-- absolute: dir came from the name
	elseif dir ~= "" and dir ~= "." then
		dir = utils.join_path(default_dir(src), dir)
	else
		dir = default_dir(src)
	end
	if base == "" or base == "." or base == ".." then
		mp.osd_message("Bad clip name: " .. name)
		return
	end
	if not mkdirp(dir) then
		mp.osd_message("Cannot create " .. dir)
		return
	end

	local out = free_path(dir, base, o.ext)
	local _, out_name = utils.split_path(out)
	local args = ffmpeg_args(src, a, b, out)
	msg.info("exporting " .. out .. ": " .. table.concat(args, " "))
	mp.osd_message(string.format("Exporting %s (%.1fs)…", out_name, b - a), 3600)

	mp.command_native_async({
		name = "subprocess",
		args = args,
		playback_only = false,
		capture_stdout = true,
		capture_stderr = true,
	}, function(ok, res, err)
		if ok and res and res.status == 0 and utils.file_info(out) then
			mp.osd_message("Saved " .. out, 4)
			msg.info("saved " .. out)
			return
		end
		local detail = (res and res.stderr or err or ""):gsub("%s+$", "")
		msg.error("ffmpeg failed: " .. detail)
		local last = detail:match("([^\n]*)$") or ""
		mp.osd_message("Export failed: " .. last, 6)
	end)
end

local function prompt()
	if not loop_range() then
		mp.osd_message("Set an A-B loop first (l)")
		return
	end
	local ok, input = pcall(require, "mp.input")
	if not ok then
		mp.osd_message("mp.input unavailable, use: script-message ab-loop-export-as <name>")
		return
	end
	local default = load_last_name() or source_stem()
	input.get({
		prompt = "Save clip as:",
		default_text = default,
		cursor_position = #default + 1,
		submit = function(text)
			input.terminate()
			export(text)
		end,
	})
end

mp.add_key_binding(nil, "ab-loop-export", prompt)
mp.register_script_message("ab-loop-export-as", export)
