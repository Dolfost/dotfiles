hl.on("hyprland.start", function()
	hl.exec_cmd('hyprlock') --  WARN: IMPORTANT

	hl.exec_cmd('uwsm app -- '..TERMINAL..' start -- '..SHELL.." -lc 'tmux new -As main'", { workspace = 2 })
	hl.exec_cmd('uwsm app -- '..WEB_BROWSER, { workspace = '3 silent' })

	hl.exec_cmd('systemctl --user start waybar.service')
	hl.exec_cmd('systemctl --user start hypridle')
	hl.exec_cmd('systemctl --user start hyprpaper')
	hl.exec_cmd('systemctl --user start hyprpolkitagent')
	hl.exec_cmd('systemctl --user start hyprsunset')
	hl.exec_cmd('systemctl --user start dunst')
	hl.exec_cmd('wl-paste --type text  --watch cliphist store')
	hl.exec_cmd('wl-paste --type image --watch cliphist store')

	hl.exec_cmd('uwsm app -p After=waybar.service -- openrgb -p ~/.config/OpenRGB/OFF.orp')
	hl.exec_cmd('sleep 5s; uwsm app -p After=waybar.service -- easyeffects --hide-window --service-mode')
	hl.exec_cmd('uwsm app -p After=waybar.service -- signal-desktop')
	hl.exec_cmd('uwsm app -p After=waybar.service -- element-desktop --hidden')
	hl.exec_cmd('uwsm app -p After=waybar.service -- Telegram -startintray')
	hl.exec_cmd('uwsm app -p After=waybar.service -- discord --start-minimized')
	hl.exec_cmd('uwsm app -p After=waybar.service -- steam -silent')
	hl.exec_cmd('uwsm app -p After=waybar.service -- mullvad-vpn')
	hl.exec_cmd('uwsm app -p After=waybar.service -- jellyfin-mpv-shim')

	-- hl.exec_cmd('hyprpm reload -n') -- load plugins
end)
