hl.monitor({
	output = "", mode = "preferred",
	position = "auto", scale = 1
})
-- This one must ALWAYS be registered: without it a reload re-enables the
-- sunshine-headless output. Targets only the headless output, so it cannot
-- modeset the real panel.
hl.monitor({
	output = "sunshine-headless", disabled = true,
})

-- The cap_sys_nice wrapper strips TZDIR via glibc secure exec
-- (nixpkgs#526193); without it flatpaks and some apps fall back to UTC.
hl.env('TZDIR', '/etc/zoneinfo')

TERMINAL = 'wezterm'
WEB_BROWSER = 'firefox'
FILE_MANAGER = TERMINAL .. ' -e yazi'
MENU = 'walker'
PDF_VIEWER = 'zathura'
SCRIPTS = '~/.config/hypr/hypr/scripts/'
SCREENSHOTS_DIR = '~/Pictures/Screenshots'
SHELL = os.getenv('SHELL')

require('utils')
load_local_config()

require('hypr.autostart')
require('hypr.graphics')
require('hypr.input')
require('hypr.rules')
require('hypr.misc')
