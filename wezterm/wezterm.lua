local w = require 'wezterm'

local c = w.config_builder()

c.colors = {
  -- The default text color
  foreground = "#ffffff",
  -- The default background color
  background =  "#000000",

  -- Overrides the cell background color when the current cell is occupied by the
  -- cursor and the cursor style is set to Block
  cursor_bg = '#52ad70',
  -- Overrides the text color when the current cell is occupied by the cursor
  cursor_fg = 'black',
  -- Specifies the border color of the cursor when the cursor style is set to Block,
  -- or the color of the vertical or horizontal bar when the cursor style is set to
  -- Bar or Underline.
  cursor_border = '#52ad70',

  -- the foreground color of selected text
  selection_fg = 'black',
  -- the background color of selected text
  selection_bg = '#fffacd',

  -- The color of the scrollbar "thumb"; the portion that represents the current viewport
  scrollbar_thumb = '#222222',

  -- The color of the split lines between panes
  split = '#444444',

  ansi = {
		"#000000",
		"#e5120a",
		"#07ea01",
		"#fefc57",
		"#0060ff",
		"#d47bfe",
		"#27bdbe",
		"#e5e5e5",
  },
  brights = {
		"#666666",
		"#ff0000",
		"#1fff00",
		"#fefb67",
		"#04a1fe",
		"#d582eb",
		"#00ffff",
		"#ffffff",
  },

  -- When the IME, a dead key or a leader key are being processed and are effectively
  -- holding input pending the result of input composition, change the cursor
  -- to this color to give a visual cue about the compose state.
  compose_cursor = 'orange',

  -- Colors for copy_mode and quick_select
  -- In copy_mode, the color of the active text is:
  -- 1. copy_mode_active_highlight_* if additional text was selected using the mouse
  -- 2. selection_* otherwise
  copy_mode_active_highlight_bg = { Color = '#000000' },
  -- use `AnsiColor` to specify one of the ansi color palette values
  -- (index 0-15) using one of the names "Black", "Maroon", "Green",
  --  "Olive", "Navy", "Purple", "Teal", "Silver", "Grey", "Red", "Lime",
  -- "Yellow", "Blue", "Fuchsia", "Aqua" or "White".
  copy_mode_active_highlight_fg = { AnsiColor = 'Black' },
  copy_mode_inactive_highlight_bg = { Color = '#52ad70' },
  copy_mode_inactive_highlight_fg = { AnsiColor = 'White' },

  quick_select_label_bg = { Color = 'peru' },
  quick_select_label_fg = { Color = '#ffffff' },
  quick_select_match_bg = { AnsiColor = 'Navy' },
  quick_select_match_fg = { Color = '#ffffff' },
}

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
c.keys = require"keys"

return c
