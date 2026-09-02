hl.monitor({
	output = "", mode = "preferred",
	position = "auto", scale = 1
})
hl.monitor({
	output = "sunshine-headless", disabled = true,
})

-- The cap_sys_nice wrapper strips TZDIR via glibc secure exec
-- (nixpkgs#526193); without it flatpaks and some apps fall back to UTC.
hl.env('TZDIR', '/etc/zoneinfo')

TERMINAL = 'wezterm'
CALCULATOR = 'qalculate-gtk --new-instance'
WEB_BROWSER = 'firefox'
FILE_MANAGER = TERMINAL .. ' -e yazi'
MENU = 'fuzzel'
PDF_VIEWER = 'zathura'
SCRIPTS = '~/.config/hypr/hypr/scripts/'
SCREENSHOTS_DIR = '~/Pictures/Screenshots'
SHELL = os.getenv('SHELL')

require('utils')
load_local_config()

require('hypr.autostart')
require('hypr.graphics')
require('hypr.input')
require('hypr.misc')

hl.on("config.reloaded", function()
	hl.exec_cmd('pgrep -x hyprlock >/dev/null || hyprlock')
end)
