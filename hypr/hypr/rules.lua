hl.layer_rule { -- disable outline around screenshots
	name = 'no-anim-for-selection',
	match = { namespace = 'selection' },
	no_anim = true,
}
hl.window_rule {
	name = 'telegram-to-chat',
	match = { class = '^org\\.ayugram\\.desktop$' },
	workspace = 'special:chat silent',
}
-- Without this, toggling the drawer on another monitor slides its windows
-- across the screen (windowsMove animates the reposition). The workspace-level
-- fade from the specialWorkspace animation still applies.
hl.window_rule {
	name = 'special-no-window-anim',
	match = { workspace = 's[true]' },
	no_anim = true,
}
hl.window_rule {
	name = 'special-transparent',
	match = { workspace = 's[true]' },
	-- keep this high: drawer windows blend with the dimmed background
	-- behind them, so low opacity reads as "dimmed text" in the drawer
	opacity = '1',
	-- xray would make the blur sample the wallpaper and hide the
	-- background workspace entirely; keep it off so the drawer is
	-- actually see-through to the workspace below.
	xray = false,
	rounding = 6,
}
hl.window_rule { -- but keep fullscreened drawer windows (videos) fully opaque
	name = 'special-fullscreen-opaque',
	match = { workspace = 's[true]', fullscreen = true },
	opacity = '1 override 1 override',
	rounding = 0,
}

-- The portal file picker (yazi in a wezterm window) floats centered.
hl.window_rule {
	name = 'termfilechooser-float',
	match = { class = '^termfilechooser$' },
	float = true,
	size = '60% 60%',
	center = true,
}

hl.workspace_rule { workspace = 'special:chat', layout = 'master' }

-- Inset the scratchpad drawers so the workspace behind stays visible around
-- them.
hl.workspace_rule { workspace = 's[true]', gaps_out = 12, gaps_in = 4 }

-- The keyring unlock prompt delays Element's window past the exec-time
-- workspace assignment in autostart, so pin it by class instead.
hl.window_rule {
	name = 'element-to-work',
	match = { class = '^element$' },
	workspace = 'special:work silent',
}

-- Pin Discord windows to the chat drawer by class, like Telegram above.
hl.window_rule {
	name = 'discord-to-chat',
	match = { class = '^(discord|vesktop)$' },
	workspace = 'special:chat silent',
}

-- Popped-out Discord calls get their own full-screen drawer: no gaps, no
-- rounding, fully opaque. Must come after the generic special-workspace rules
-- so its overrides win.
hl.window_rule {
	name = 'discord-popout-to-call',
	match = { class = '^(discord|vesktop)$', title = '^Discord Popout$' },
	workspace = 'special:call',
	opacity = '1 override 1 override',
	rounding = 0,
}
hl.workspace_rule { workspace = 'special:call', gaps_out = 0, gaps_in = 0 }
