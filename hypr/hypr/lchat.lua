-- LAN chat overlay (SUPER + T): `lchat` (nix/modules/system/ssh-chat) in a
-- small pinned float tucked into the top-right corner, dressed to pass for a
-- piece of the terminal underneath rather than a chat app: no shadow, no
-- border, translucent, the terminal font a size down, instant show/hide.
--
-- One key cycles: absent -> spawn, hidden -> show on the focused monitor and
-- focus, visible but unfocused -> focus, focused -> hide. Hidden means parked
-- on a special workspace that nothing ever opens, so the session (and the
-- scrollback, which the main wezterm config turns off) survives.
local CLASS = 'lchat'
local PARK = 'special:lchat'
local W, H = 520, 320
local MARGIN_X, MARGIN_Y = 16, 44 -- y clears the bar

hl.window_rule {
	name = 'lchat-overlay',
	match = { class = '^' .. CLASS .. '$' },
	float = true,
	pin = true,
	size = W .. ' ' .. H,
	opacity = '0.6 0.45',
	no_shadow = true,
	no_dim = true,
	no_anim = true,
	rounding = 4,
}

local function target(win) return 'address:' .. win.address end

local function place(win, mon)
	hl.dispatch(hl.dsp.window.move({
		x = mon.x + mon.width - W - MARGIN_X,
		y = mon.y + MARGIN_Y,
		window = target(win),
	}))
end

hl.on('window.open', function(win)
	if win.class ~= CLASS then return end
	place(win, win.monitor or hl.get_active_monitor())
end)

local function spawn()
	hl.exec_cmd("sh -c 'command -v lchat >/dev/null"
		.. " && exec wezterm --config scrollback_lines=5000 --config font_size=9"
		-- [[ ]] not quotes: sh strips them before wezterm sees the Lua.
		.. " --config window_decorations=[[NONE]]" -- the main config's RESIZE frame draws a 1px border
		.. " start --class " .. CLASS .. " -- lchat"
		.. " || notify-send lchat \"not installed on this host\"'")
end

function lchat_toggle()
	local win = hl.get_windows({ class = CLASS })[1]
	if not win then return spawn() end
	local t = target(win)
	local mon = hl.get_active_monitor()
	-- An open drawer counts as "here": the chat joins it as a plain float, so
	-- focusing it does not collapse the drawer, and hiding returns focus to a
	-- drawer window. Pinned only on regular workspaces.
	local drawer = hl.get_active_special_workspace()
	if drawer and drawer.name == PARK then -- the lot itself got opened (e.g. an urgent focus): fold it
		hl.dispatch(hl.dsp.workspace.toggle_special(PARK:sub(#"special:" + 1)))
		drawer = nil
	end
	local here = drawer or hl.get_active_workspace()
	local shown = win.workspace ~= nil and win.monitor ~= nil and win.monitor.id == mon.id
		and (win.workspace.id == here.id
			or (not drawer and win.pinned and not win.workspace.special))
	if not shown then
		if win.pinned then hl.dispatch(hl.dsp.window.pin({ window = t })) end -- pinned refuses to move
		hl.dispatch(hl.dsp.window.move({ workspace = here.name, window = t }))
		if not drawer then hl.dispatch(hl.dsp.window.pin({ window = t })) end
		place(win, mon)
		hl.dispatch(hl.dsp.focus({ window = t }))
	elseif win.active then
		if win.pinned then hl.dispatch(hl.dsp.window.pin({ window = t })) end
		hl.dispatch(hl.dsp.window.move({ workspace = PARK, window = t, silent = true }))
		-- silent keeps focus on the parked window; give it back
		local back = here.last_window
		if back and back.address ~= win.address then
			hl.dispatch(hl.dsp.focus({ window = target(back) }))
		end
	else
		hl.dispatch(hl.dsp.focus({ window = t }))
	end
end

hl.bind('SUPER + T', lchat_toggle)
