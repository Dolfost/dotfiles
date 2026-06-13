function exec_cmd_uwsm(cmd, opts)
	return hl.exec_cmd('uwsm app -p After=waybar.service -- ' .. cmd, opts)
end

hl.on("hyprland.start", function()
	hl.exec_cmd('hyprlock') --  WARN: IMPORTANT

	hl.exec_cmd('systemctl --user start waybar.service')

	hl.exec_cmd('systemctl --user start waybar.service')
	hl.exec_cmd('systemctl --user start hypridle')
	hl.exec_cmd('systemctl --user start hyprpaper')
	hl.exec_cmd('systemctl --user start hyprpolkitagent')
	hl.exec_cmd('systemctl --user start hyprsunset')
	hl.exec_cmd('systemctl --user start dunst')
	hl.exec_cmd('wl-paste --type text  --watch cliphist store')
	hl.exec_cmd('wl-paste --type image --watch cliphist store')

	exec_cmd_uwsm(TERMINAL..' start -- '..SHELL.." -lc 'tmux attach -t main'", { workspace = 1 })
	exec_cmd_uwsm(WEB_BROWSER, { workspace = '2 silent' })

	exec_cmd_uwsm('openrgb -p ~/.config/OpenRGB/OFF.orp')
	exec_cmd_uwsm('sleep 10s; easyeffects --hide-window --service-mode')
	exec_cmd_uwsm('signal-desktop')
	exec_cmd_uwsm('element-desktop --hidden')
	exec_cmd_uwsm('Telegram -startintray')
	exec_cmd_uwsm('discord --start-minimized')
	exec_cmd_uwsm('steam -silent')
	exec_cmd_uwsm('mullvad-vpn')

	-- hl.exec_cmd('hyprpm reload -n') -- load plugins
end)

load_local_config()
