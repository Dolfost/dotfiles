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

require('utils')
load_local_config()

require('hypr.autostart')
require('hypr.graphics')
require('hypr.input')
require('hypr.misc')
