hl.config({
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = false,
		vrr = 1, -- 1=always on. Needed for gamescope (nested) VRR; vrr=2 (fullscreen-only) does NOT engage for gamescope windows.
		-- Wake dpms in-compositor on input. hypridle's on-resume also does this,
		-- but its dpms handlers are gated on "pidof hyprlock", so if the screen is
		-- ever dpms-off without hyprlock alive nothing would turn it back on.
		key_press_enables_dpms = true,
		mouse_move_enables_dpms = true,
		-- Let a fresh hyprlock take over if the running one dies mid-lock;
		-- otherwise the session stays locked with no way to enter a password.
		allow_session_lock_restore = true,
	}
})
