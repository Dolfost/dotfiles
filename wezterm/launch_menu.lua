local path = table.concat({
	os.getenv('PATH'),
	'/opt/homebrew/bin',
}, ':')

return {
	{
		label = 'Run tmux and attach to ' .. os.getenv('USER'),
		args = {'tmux', 'attach', '-t', os.getenv('USER')},
		set_environment_variables = {
			PATH =  path,
		}
	},
	{
		label = 'Run tmux and attach to docs',
		args = {'tmux', 'attach', '-t', 'docs'},
		set_environment_variables = {
			PATH =  path,
		}
	},
	{
		label = 'Run top',
		args = {'top'},
	}
}
