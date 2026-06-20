function exec_cmd_uwsm(cmd, opts)
	return hl.exec_cmd('uwsm app -p After=waybar.service -- ' .. cmd, opts)
end

function start_systemd_service(service, opts)
	return hl.exec_cmd('systemctl --user ' .. (opts or '') .. ' start ' .. service)
end

hl.on("hyprland.start", function()
	hl.exec_cmd('hyprlock') --  WARN: IMPORTANT

	hl.exec_cmd('systemctl --user start waybar.service')

	start_systemd_service('waybar.service')
	start_systemd_service('hypridle')
	start_systemd_service('hyprpaper')
	start_systemd_service('hyprpolkitagent')
	-- start_systemd_service('hyprsunset')
	start_systemd_service('dunst')
	hl.exec_cmd('wl-paste --type text  --watch cliphist store')
	hl.exec_cmd('wl-paste --type image --watch cliphist store')

	exec_cmd_uwsm(TERMINAL..' start -- '..SHELL.." -lc 'tmux attach -t main'", { workspace = 1 })
	exec_cmd_uwsm(WEB_BROWSER, { workspace = '2 silent' })

	exec_cmd_uwsm('openrgb -p ~/.config/OpenRGB/OFF.orp')
	exec_cmd_uwsm('easyeffects --hide-window --service-mode')
	exec_cmd_uwsm('signal-desktop')
	exec_cmd_uwsm('element-desktop --hidden')
	exec_cmd_uwsm('Telegram -startintray')
	exec_cmd_uwsm('discord --start-minimized')
	exec_cmd_uwsm('steam -silent')

	-- hl.exec_cmd('hyprpm reload -n') -- load plugins
end)

load_local_config()
