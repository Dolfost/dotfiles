hl.monitor({
	output   = 'eDP-1',
	mode     = '1920x1080@165',
	position = '0x0',
	scale = 1.0
})
hl.monitor({
	output   = 'HDMI-A-3',
	mode     = '1920x1080@60',
	position = '-1920x0',
	scale = 1.0
})
hl.monitor({
	output = "", mode = "preferred",
	position = "auto", scale = 1
})

TERMINAL = 'wezterm'
CALCULATOR = 'qalculate-gtk --new-instance'
WEB_BROWSER = 'firefox'
FILE_MANAGER = TERMINAL .. ' -e yazi'
MENU = 'fuzzel'
PDF_VIEWER = 'zathura'
SCRIPTS = '~/.config/hypr/hypr/scripts/'
SCREENSHOTS_DIR = '~/Pictures/Screenshots'
SHELL = os.getenv('SHELL')

require('hypr.autostart')
require('hypr.graphics')
require('hypr.input')
require('hypr.misc')
