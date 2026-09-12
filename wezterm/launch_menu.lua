local path = table.concat({
	os.getenv('PATH'),
	'/opt/homebrew/bin',
}, ':')

return {
	{
		label = 'Run zellij and attach to ' .. os.getenv('USER'),
		args = {'zellij', 'attach', '--create', os.getenv('USER')},
		set_environment_variables = {
			PATH =  path,
		}
	},
	{
		label = 'Run zellij and attach to docs',
		args = {'zellij', 'attach', '--create', 'docs'},
		set_environment_variables = {
			PATH =  path,
		}
	},
	{
		label = 'Run top',
		args = {'top'},
	}
}
