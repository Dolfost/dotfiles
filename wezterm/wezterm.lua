local w = require 'wezterm'
local m = w.mux
local on = w.on

local c = w.config_builder()

c.colors = require'colors'

c.force_reverse_video_cursor = true
c.enable_tab_bar = false
c.bold_brightens_ansi_colors = true

c.window_padding = {
  left = 5,
  right = 5,
  top = 2,
  bottom = 2,
}

c.font = w.font("Iosevka Nerd Font", { weight = 'Light'})
c.font_size = 18
c.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

c.disable_default_key_bindings = true
c.keys = require'keys'
c.disable_default_mouse_bindings = true
c.mouse_bindings = require'mouse'

c.cursor_blink_rate = 0

c.launch_menu = require'launch_menu'

c.exit_behavior_messaging = 'Brief'

require'events'

return c
