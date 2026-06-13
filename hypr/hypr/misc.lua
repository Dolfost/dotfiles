hl.config({
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = false,
	}
})

hl.layer_rule { -- disable outline around screenshots
    name = 'no-anim-for-selection',
    match = { namespace = 'selection' },
    no_anim = true,
}
