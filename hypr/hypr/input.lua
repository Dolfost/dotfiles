hl.config({
	input = {
		kb_layout = "us,ua",
		kb_options = 'grp:alt_shift_toggle',
		repeat_rate = 50,
		repeat_delay = 150,
		numlock_by_default = true,

		follow_mouse = 1,

		sensitivity = 0.2,
		accel_profile = 'flat',
		scroll_factor = 1,

		touchpad = {
			disable_while_typing = true,
			natural_scroll = false,
			tap_to_click = true,
			scroll_factor = 1,
		},
	},

	gestures = {
		workspace_swipe_distance = 200,
		workspace_swipe_invert = true,
		workspace_swipe_touch = false,
		workspace_swipe_touch_invert = false,
		workspace_swipe_min_speed_to_force = false,
		workspace_swipe_cancel_ratio = 0.5,
		workspace_swipe_create_new = true,
		workspace_swipe_direction_lock = true,
		workspace_swipe_direction_lock_threshold = 10,
		workspace_swipe_forever = false,
		workspace_swipe_use_r = false,
		close_max_timeout = 1000,
	}
})

hl.gesture({ fingers = 3, direction = "horizontal", scale = 1.5,   action = "workspace" })
hl.gesture({ fingers = 3, direction = "down",       mods  = "ALT", action = "close"     })

local l = 'SUPER + '

-- window management
hl.bind(l..'W', hl.dsp.window.close())
hl.bind(l..'Q', hl.dsp.window.kill())
hl.bind(l..'M', hl.dsp.exit())
hl.bind(l..'E', hl.dsp.exec_cmd(FILE_MANAGER))
hl.bind(l..'V', hl.dsp.window.float({ action = 'toggle' }))
hl.bind(l..'P', hl.dsp.window.pseudo())
hl.bind(l..'F', hl.dsp.window.fullscreen_state({ internal = 1, client = 2 }))
hl.bind(l..'R', hl.dsp.exec_raw(SCRIPTS..'resize_active.sh'))
hl.bind(l..'B', hl.dsp.exec_raw(SCRIPTS..'hyprsunset.sh'))
hl.bind(l..'A', hl.dsp.exec_raw(SCRIPTS..'swap_headphones_and_lineout.sh'))
hl.bind(l..'D', hl.dsp.exec_raw(SCRIPTS..'toggle_secondary_display.sh horizontal'))
hl.bind(l..'C', hl.dsp.exec_raw(SCRIPTS..'toggle_secondary_display.sh vertical'))
hl.bind(l..'G', hl.dsp.exec_raw(SCRIPTS..'toggle_secondary_display.sh mirror'))
hl.bind(l..'Z', hl.dsp.exec_raw(SCRIPTS..'toggle_phone_camera.sh'))
hl.bind(l..'Y', hl.dsp.exec_raw('killall -SIGUSR1 waybar'))
hl.bind('ALT + SPACE', hl.dsp.exec_cmd(MENU))

-- notifications
hl.bind(l..'N', hl.dsp.exec_raw('dunstctl close-all'))
hl.bind(l..'O', hl.dsp.exec_raw('dunstctl history-pop'))
hl.bind(l..'X', hl.dsp.exec_raw(SCRIPTS..'dunstctl_toggle.sh'))

-- apps
hl.bind(l..'CTRL + L', hl.dsp.exec_raw('hyprlock'))
hl.bind(l..'CTRL + T', hl.dsp.exec_cmd(TERMINAL))
hl.bind(l..'CTRL + A', hl.dsp.exec_raw(TERMINAL..' -e pulsemixer'))
hl.bind(l..'CTRL + B', hl.dsp.exec_raw(TERMINAL..' -e bluetui'))
hl.bind(l..'CTRL + W', hl.dsp.exec_raw(TERMINAL..' -e sudo impala'))
hl.bind(l..'CTRL + S', hl.dsp.exec_raw(TERMINAL..' -e btop'))
hl.bind(l..'CTRL + R', hl.dsp.exec_raw(TERMINAL..' -e rmpc'))
hl.bind(l..'CTRL + P', hl.dsp.exec_raw('hyprpicker -a'))
hl.bind(l..'CTRL + Z', hl.dsp.exec_raw(PDF_VIEWER))
hl.bind(l..'CTRL + C', hl.dsp.exec_cmd('[float; center; size 1200 100] '.. CALCULATOR))
hl.bind(l..'CTRL + H', hl.dsp.exec_raw('cliphist list | '..MENU..' --dmenu --with-nth 2 | cliphist decode | wl-copy'))

-- screenshots
hl.bind(l..'SHIFT + D', hl.dsp.exec_raw('hyprshot -m output -m active -o '.. SCREENSHOTS_DIR))
hl.bind(l..'SHIFT + W', hl.dsp.exec_raw(SCRIPTS..'screenshot_window.sh '.. SCREENSHOTS_DIR))
hl.bind(l..'SHIFT + R', hl.dsp.exec_raw('hyprshot -m region -o '.. SCREENSHOTS_DIR))

-- move focus
hl.bind(l..'H', hl.dsp.focus({ direction = 'l' }))
hl.bind(l..'L', hl.dsp.focus({ direction = 'r' }))
hl.bind(l..'K', hl.dsp.focus({ direction = 'u' }))
hl.bind(l..'J', hl.dsp.focus({ direction = 'd' }))

-- workspace navigation
hl.bind(l..'SHIFT + H', hl.dsp.focus({ workspace = 'e-1' }))
hl.bind(l..'SHIFT + L', hl.dsp.focus({ workspace = 'e+1' }))
for i = 1, 9 do
	hl.bind(l..i,             hl.dsp.focus({ workspace = i }))
	hl.bind(l..'SHIFT + '..i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(l..'0',         hl.dsp.focus({ workspace = 10 }))
hl.bind(l..'SHIFT + 0', hl.dsp.window.move({ workspace = 10 }))

-- monitor focus
hl.bind(l..'CTRL + SHIFT + H', hl.dsp.focus({ monitor = '-1' }))
hl.bind(l..'CTRL + SHIFT + L', hl.dsp.focus({ monitor = '+1' }))

-- special workspace (scratchpad)
hl.bind(l..'S',         hl.dsp.workspace.toggle_special('magic'))
hl.bind(l..'SHIFT + S', hl.dsp.window.move({ workspace = 'special:magic' }))

-- workspace scroll with mouse
hl.bind(l..'mouse_down', hl.dsp.focus({ workspace = 'e+1' }))
hl.bind(l..'mouse_up',   hl.dsp.focus({ workspace = 'e-1' }))

-- Move/resize windows with mouse drag
hl.bind(l..'mouse:272', hl.dsp.window.drag(),   { mouse = true })
hl.bind(l..'mouse:273', hl.dsp.window.resize(), { mouse = true })

-- volume and screen brightness (repeating + locked)
hl.bind('XF86AudioRaiseVolume',          hl.dsp.exec_raw('wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+'), { locked = true, repeating = true })
hl.bind('XF86AudioLowerVolume',          hl.dsp.exec_raw('wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-'),      { locked = true, repeating = true })
hl.bind('XF86AudioMute',                 hl.dsp.exec_raw('wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'),     { locked = true, repeating = true })
hl.bind('XF86AudioMicMute',              hl.dsp.exec_raw('wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'),   { locked = true, repeating = true })
hl.bind('XF86MonBrightnessUp',           hl.dsp.exec_raw('brightnessctl s 10%+'),  { locked = true, repeating = true })
hl.bind('XF86MonBrightnessDown',         hl.dsp.exec_raw('brightnessctl s 10%-'),  { locked = true, repeating = true })
hl.bind('SHIFT + XF86MonBrightnessUp',   hl.dsp.exec_raw('brightnessctl s 100%'),  { locked = true, repeating = true })
hl.bind('SHIFT + XF86MonBrightnessDown', hl.dsp.exec_raw('brightnessctl s 0%'),    { locked = true, repeating = true })

-- media controls (locked)
hl.bind('XF86AudioNext',  hl.dsp.exec_raw('playerctl next'),       { locked = true })
hl.bind('XF86AudioPause', hl.dsp.exec_raw('playerctl play-pause'), { locked = true })
hl.bind('XF86AudioPlay',  hl.dsp.exec_raw('playerctl play-pause'), { locked = true })
hl.bind('XF86AudioPrev',  hl.dsp.exec_raw('playerctl previous'),   { locked = true })

-- DDC screen brightness (locked)
hl.bind(l..'CTRL + comma',   hl.dsp.exec_raw(SCRIPTS..'brightness.sh small-dec'),  { locked = true })
hl.bind(l..'CTRL + period',  hl.dsp.exec_raw(SCRIPTS..'brightness.sh small-inc'),  { locked = true })
hl.bind(l..'comma',          hl.dsp.exec_raw(SCRIPTS..'brightness.sh dec'),        { locked = true })
hl.bind(l..'period',         hl.dsp.exec_raw(SCRIPTS..'brightness.sh inc'),        { locked = true })
hl.bind(l..'SHIFT + comma',  hl.dsp.exec_raw(SCRIPTS..'brightness.sh min'),        { locked = true })
hl.bind(l..'SHIFT + period', hl.dsp.exec_raw(SCRIPTS..'brightness.sh max'),        { locked = true })
hl.bind(l..'ALT + comma',    hl.dsp.exec_raw(SCRIPTS..'brightness.sh large-dec'),  { locked = true })
hl.bind(l..'ALT + period',   hl.dsp.exec_raw(SCRIPTS..'brightness.sh large-inc'),  { locked = true })
