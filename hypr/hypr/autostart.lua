-- No-op on hosts where the binary is not installed (e.g. steam without
-- the gaming module) instead of a uwsm error notification.
function exec_cmd_uwsm(cmd, opts)
	local bin = cmd:match('^%S+')
	return hl.exec_cmd('command -v ' .. bin ..
		' >/dev/null && exec uwsm app -p After=waybar.service -- ' .. cmd, opts)
end

function start_systemd_service(service, opts)
	return hl.exec_cmd('systemctl --user ' .. (opts or '') .. ' start ' .. service)
end

hl.on("hyprland.start", function()
	hl.exec_cmd('hyprlock') --  WARN: IMPORTANT
	hl.exec_cmd('hyprctl monitors all | grep -q sunshine-headless || hyprctl output create headless sunshine-headless')

	start_systemd_service('waybar.service')
	start_systemd_service('hypridle')
	start_systemd_service('hyprpaper')
	start_systemd_service('hyprpolkitagent')
	start_systemd_service('hyprsunset')
	start_systemd_service('dunst')
	hl.exec_cmd('wl-paste --type text  --watch cliphist store')
	hl.exec_cmd('wl-paste --type image --watch cliphist store')

	exec_cmd_uwsm(TERMINAL..' start -- '..SHELL.." -lc 'tmux attach -t main'", { workspace = 1 })
	exec_cmd_uwsm(WEB_BROWSER, { workspace = '2 silent' })

	exec_cmd_uwsm('signal-desktop', { workspace = 'special:work silent' })
	exec_cmd_uwsm('element-desktop', { workspace = 'special:work silent' })
	exec_cmd_uwsm('Telegram', { workspace = 'special:chat silent' })
	exec_cmd_uwsm('discord', { workspace = 'special:chat silent' })
	exec_cmd_uwsm('obsidian', { workspace = 'special:notes silent' })
	exec_cmd_uwsm('feishin', { workspace = 'special:notes silent' })
	exec_cmd_uwsm('steam -silent', { workspace = '7 silent' })

	-- hl.exec_cmd('hyprpm reload -n') -- load plugins
end)

load_local_config()
