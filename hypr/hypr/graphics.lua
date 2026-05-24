hl.config({

	general = {
		border_size = 0,
		gaps_in = 0,
		gaps_out = 0,
		float_gaps = 0,

		layout = 'dwindle',
		no_focus_fallback = false,
		resize_on_border = true,
		extend_border_grab_area = 15,
		hover_icon_on_border = true,
		allow_tearing = false,
		resize_corner = 0,
		modal_parent_blocking = true,
		locale = '', -- empty for system locale

		snap = {
			enabled = false,
			window_gap = 10,
			monitor_gap = 10,
			border_overlap = false,
			respect_gaps = false,
		}
	},

	decoration = {
		rounding = 0,
		rounding_power = 3.0,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		dim_inactive = false,
		dim_modal = true,
		dim_strength = 0.1,
		dim_special = 0.2,
		dim_around = 0.4,
		border_part_of_window = true,

		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			ignore_opacity = true,
			xray = true,
			vibrancy = 0.1696,
		},

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			sharp = false,
			color = 0xee1a1a1a,
			offset = {0, 0},
			scale = 1.0
		},

		glow = {
			enabled = true,
			range = 10,
			render_power = 4,
			color = 0xee1a1a1a,
		}
	},

	animations = {
		enabled = true,
	}

})

hl.curve("easeOutQuint",   { type = "bezier", points = {{ 0.23, 1    }, { 0.32, 1 }}})
hl.curve("easeInOutCubic", { type = "bezier", points = {{ 0.65, 0.05 }, { 0.36, 1 }}})
hl.curve("linear",         { type = "bezier", points = {{ 0, 0       }, { 1, 1    }}})
hl.curve("almostLinear",   { type = "bezier", points = {{ 0.5, 0.5   }, { 0.75, 1 }}})
hl.curve("quick",          { type = "bezier", points = {{ 0.15, 0    }, { 0.1, 1  }}})

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default"       })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint"  })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint"  })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear"  })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear"  })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick"         })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint"  })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear"  })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear"  })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick"         })
