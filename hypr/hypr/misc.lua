hl.config({
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = false,
		vrr = 1, -- 1=always on. Needed for gamescope (nested) VRR; vrr=2 (fullscreen-only) does NOT engage for gamescope windows.
	}
})

hl.layer_rule { -- disable outline around screenshots
    name = 'no-anim-for-selection',
    match = { namespace = 'selection' },
    no_anim = true,
}

hl.window_rule { -- keep the steam self-updater popup off the current workspace
    name = 'steam-updater-silent',
    match = { title = '^(Updating Steam|Steam - Self Updater)$' },
    workspace = '7 silent',
    no_initial_focus = true,
}
