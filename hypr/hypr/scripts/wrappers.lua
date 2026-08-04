-- Usage:
--   notify-send [OPTION…] <SUMMARY> [BODY] - create a notification
--
-- Help Options:
--   -?, --help                        Show help options
--
-- Application Options:
--   -u, --urgency=LEVEL               Specifies the urgency level (low, normal, critical).
--   -t, --expire-time=TIME            Specifies the timeout in milliseconds at which to expire the notification.
--   -a, --app-name=APP_NAME           Specifies the app name for the notification
--   -i, --icon=ICON                   Specifies an icon filename or stock icon to display.
--   -n, --app-icon=ICON               Specifies an application icon filename or app icon name. The server may or may not display it.
--   -c, --category=TYPE[,TYPE...]     Specifies the notification category.
--   -e, --transient                   Create a transient notification
--   -h, --hint=TYPE:NAME:VALUE        Specifies basic extra data to pass. Valid types are boolean, int, double, string, byte and variant.
--   -p, --print-id                    Print the notification ID.
--   --id-fd                           File descriptor where to write the notification ID.
--   -r, --replace-id=REPLACE_ID       The ID of the notification to replace.
--   -w, --wait                        Wait for the notification to be closed before exiting.
--   -A, --action=[NAME=]Text...       Specifies the actions to display to the user. Implies --wait to wait for user input. May be set multiple times. The name of the action is output to stdout. If NAME is not specified, the numerical index of the option is used (starting with 0).
--   --selected-action-fd              File descriptor where to write the action chosen by the user.
--   --activation-token-fd             File descriptor where to write the action activation token. The daemon must support it.
--   -v, --version                     Version of the package.

function notify(opts)
	if not opts.urgency then opts.urgency = 'normal' end
	if not opts.expire_time then opts.expire_time = '2000' end
	if not opts.app_name then opts.app_name = 'lua' end
	if not opts.transient then opts.transient = false end
	if not opts.wait then opts.wait = false end
	local cmd = table.concat({'notify-send',
		'-u', opts.urgency,
		'-t', opts.expire_time,
		'-a' .. opts.app_name,
		opts.transient and ' -e ' or '',
		opts.wait and ' -w ' or '',
	}, ' ')
	os.execute(cmd);
end
