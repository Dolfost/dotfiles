local w = require 'wezterm'

local c = w.config_builder()

c.colors = require'colors'
c.bold_brightens_ansi_colors = true

c.force_reverse_video_cursor = true
c.enable_tab_bar = false

c.window_padding = {
  left = 5,
  right = 5,
  top = 2,
  bottom = 2,
}
c.native_macos_fullscreen_mode = true

c.font = w.font("Iosevka Nerd Font", { weight = 'Light'})
c.font_size = 18
c.adjust_window_size_when_changing_font_size = false
c.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

c.scrollback_lines = 0

-- c.disable_default_key_bindings = true
c.keys = require'keys'
c.disable_default_mouse_bindings = true
c.mouse_bindings = require'mouse'

c.cursor_blink_rate = 0

c.launch_menu = require'launch_menu'

c.exit_behavior_messaging = 'Brief'

c.window_decorations = 'RESIZE'

require'events'

if os.getenv("HYPRLAND_INSTANCE_SIGNATURE") ~= nil then
	c.enable_wayland=false
end

return c
