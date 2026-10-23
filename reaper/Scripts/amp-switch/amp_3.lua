-- Arm exactly one guitar tone track and unarm the other tone tracks.
-- Tone tracks are the ones whose name starts with PREFIX.
-- Which one is taken from this file's name: amp_3.lua -> third tone track.
-- Bind each copy to a pedal key (F1 -> amp_1.lua, F2 -> amp_2.lua, ...).
local PREFIX = "GT_"

local _, path = reaper.get_action_context()
local n = tonumber(path:match("(%d+)%.lua$"))
if not n then return end

local amps = {}
for i = 0, reaper.CountTracks(0) - 1 do
  local tr = reaper.GetTrack(0, i)
  local _, name = reaper.GetTrackName(tr)
  if name:sub(1, #PREFIX) == PREFIX then amps[#amps + 1] = tr end
end
if n > #amps then return end

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
for i, tr in ipairs(amps) do
  local on = (i == n) and 1 or 0
  reaper.SetMediaTrackInfo_Value(tr, "I_RECARM", on)
  reaper.SetMediaTrackInfo_Value(tr, "I_RECMON", on)
end
reaper.SetOnlyTrackSelected(amps[n])
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Switch to amp track " .. n, -1)
