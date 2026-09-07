hl.config({
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = false,
		vrr = 1, -- 1=always on. Needed for gamescope (nested) VRR; vrr=2 (fullscreen-only) does NOT engage for gamescope windows.
		key_press_enables_dpms = true,
		mouse_move_enables_dpms = false,
		-- Apps activating themselves only flag the workspace urgent; clicking
		-- a notification jumps to the sender via a swaync action script
		-- (scripts/notification_focus.sh) that focuses its window directly.
		focus_on_activate = false,
		-- Let a fresh hyprlock take over if the running one dies mid-lock;
		-- otherwise the session stays locked with no way to enter a password.
		allow_session_lock_restore = true,
	}
})
