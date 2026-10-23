-- One pedal, two tones: each press moves the live chain to the next entry
-- of CYCLE and wraps around. Entries are positions among the tone tracks
-- (names starting with PREFIX, top to bottom), so { 1, 2 } alternates
-- between the first two. Same mechanics as amp_N.lua: the target is armed
-- with input monitoring, the other tone tracks are unarmed.
local PREFIX = "GT_"
local CYCLE = { 1, 2 }

local amps = {}
for i = 0, reaper.CountTracks(0) - 1 do
  local tr = reaper.GetTrack(0, i)
  local _, name = reaper.GetTrackName(tr)
  if name:sub(1, #PREFIX) == PREFIX then amps[#amps + 1] = tr end
end

-- Where in CYCLE the currently armed tone track sits (0 = none of them).
local cur = 0
for k, pos in ipairs(CYCLE) do
  local tr = amps[pos]
  if tr and reaper.GetMediaTrackInfo_Value(tr, "I_RECARM") == 1 then cur = k break end
end
local target = CYCLE[(cur % #CYCLE) + 1]
if not amps[target] then return end

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
for i, tr in ipairs(amps) do
  local on = (i == target) and 1 or 0
  reaper.SetMediaTrackInfo_Value(tr, "I_RECARM", on)
  reaper.SetMediaTrackInfo_Value(tr, "I_RECMON", on)
end
reaper.SetOnlyTrackSelected(amps[target])
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Cycle amp track", 1) -- 1 = track config only
