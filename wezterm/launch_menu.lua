local path = table.concat({
	os.getenv('PATH'),
	os.getenv('HOME') .. '/.local/bin',
	'/opt/homebrew/bin',
}, ':')

return {
	{
		label = 'Run zellij and attach to ' .. os.getenv('USER'),
		args = {'zj', os.getenv('USER')},
		set_environment_variables = {
			PATH =  path,
		}
	},
	{
		label = 'Run zellij and attach to docs',
		args = {'zj', 'docs'},
		set_environment_variables = {
			PATH =  path,
		}
	},
	{
		label = 'Run top',
		args = {'top'},
	}
}
