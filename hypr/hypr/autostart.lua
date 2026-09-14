-- No-op on hosts where the binary is not installed (e.g. steam without
-- the gaming module) instead of a uwsm error notification.
function exec_cmd_uwsm(cmd, opts)
	local bin = cmd:match('^%S+')
	return hl.exec_cmd('command -v ' .. bin ..
		' >/dev/null && exec uwsm app -- ' .. cmd, opts)
end

function start_systemd_service(service, opts)
	return hl.exec_cmd('systemctl --user ' .. (opts or '') .. ' start ' .. service)
end

-- One waybar instance per monitor (waybar@.service, hyprland nix module) so
-- SUPER+Y can hide the bar on just the focused output. Registered at top level
-- so instances follow hotplug; start/stop is idempotent, which matters because
-- monitor.removed can fire several times per removal.
hl.on('monitor.added', function(mon)
	start_systemd_service('waybar@' .. mon.name .. '.service')
end)
hl.on('monitor.removed', function(mon)
	hl.exec_cmd('systemctl --user stop waybar@' .. mon.name .. '.service')
end)

hl.on("hyprland.start", function()
	hl.exec_cmd('hyprlock') --  WARN: IMPORTANT
	hl.exec_cmd('hyprctl monitors all | grep -q sunshine-headless || hyprctl output create headless sunshine-headless')

	-- monitors already present fired no monitor.added while the config loaded
	hl.exec_cmd("hyprctl monitors -j | jq -r '.[].name' | " ..
		"xargs -I{} systemctl --user start 'waybar@{}.service'")
	start_systemd_service('hypridle')
	start_systemd_service('hyprpaper')
	start_systemd_service('hyprpolkitagent')
	start_systemd_service('hyprsunset')
	start_systemd_service('swaync')

	exec_cmd_uwsm(TERMINAL..' start -- '..SHELL.." -lc 'zellij attach --create main'", { workspace = 1 })
	exec_cmd_uwsm(WEB_BROWSER, { workspace = '2 silent' })

	exec_cmd_uwsm('signal-desktop', { workspace = 'special:work silent' })
	exec_cmd_uwsm('element-desktop', { workspace = 'special:work silent' })
	exec_cmd_uwsm('AyuGram', { workspace = 'special:chat silent' })
	exec_cmd_uwsm('vesktop', { workspace = 'special:chat silent' })
	exec_cmd_uwsm('obsidian', { workspace = 'special:notes silent' })
	exec_cmd_uwsm('feishin', { workspace = 'special:music silent' })
	exec_cmd_uwsm('steam -silent', { workspace = '7 silent' })

	-- hl.exec_cmd('hyprpm reload -n') -- load plugins
end)

load_local_config()
