function load_local_config()
	local info = debug.getinfo(2, 'S')
	if not info or info.source:sub(1, 1) ~= '@' then return false end
	local local_path = info.source:sub(2):gsub('%.lua$', '.local.lua')
	local chunk = loadfile(local_path)
	if not chunk then return false end
	chunk()
	return true
end
