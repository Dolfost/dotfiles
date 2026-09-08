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
		dim_special = 0.4,
		dim_around = 0.4,
		border_part_of_window = true,

		blur = {
			enabled = true,
			size = 6,
			passes = 2,
			ignore_opacity = true,
			xray = true,
			-- neutral, so translucent drawer windows don't inherit extra
			-- darkness from the dimmed background they blur
			brightness = 1.0,
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
			enabled = false,
			range = 10,
			render_power = 4,
			color = 0xee1a1a1a,
		}
	},

	animations = {
		enabled = true,
	}

})
