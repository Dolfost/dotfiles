-- Live preview for pandoc buffers with the REAL pandoc pipeline (pandoc-plot +
-- pandoc-crossref + KaTeX), unlike markdown-preview.nvim which renders generic
-- markdown-it.
--
--   :PandocPreview      start: build, open browser (auto-reloads on :w)
--   :PandocPreviewStop  stop server and rebuild autocmd
--
-- Needs: pandoc, pandoc-plot, pandoc-crossref, node (npx browser-sync). KaTeX
-- loads from CDN, so viewing needs network.

local state = { server = nil, group = nil }

local function build(src, out, on_done)
	-- pandoc writes to a temp file we then atomically rename into place; the
	-- live server must never see a half-written file (see the swap below)
	local tmp = out .. ".tmp"
	local cmd = { "pandoc", src, "-s", "--katex", "--embed-resources" }
	-- a pandoc-defaults.yaml next to the document is the project's shared option
	-- set (same file build scripts use); without one, fall back to the standard
	-- filter chain
	local defaults = vim.fs.joinpath(vim.fs.dirname(src), "pandoc-defaults.yaml")
	if vim.uv.fs_stat(defaults) then
		vim.list_extend(cmd, { "-d", defaults })
	else
		vim.list_extend(cmd, {
			"--filter", "pandoc-plot",
			"--filter", "pandoc-crossref",
		})
	end
	vim.list_extend(cmd, { "-o", tmp })
	vim.system(cmd, { cwd = vim.fs.dirname(src) }, function(res)
		vim.schedule(function()
			if res.code ~= 0 then
				vim.notify("PandocPreview build failed:\n" .. (res.stderr or ""),
					vim.log.levels.WARN)
				return
			end
			-- atomic swap: browser-sync only ever watches a complete file, so a
			-- mid-write reload can't serve truncated UTF-8 (the � you saw)
			local ok, err = vim.uv.fs_rename(tmp, out)
			if not ok then
				vim.notify("PandocPreview: rename failed: " .. tostring(err),
					vim.log.levels.WARN)
				return
			end
			if on_done then
				on_done()
			end
		end)
	end)
end

local function stop()
	if state.server then
		state.server:kill(15)
		state.server = nil
	end
	if state.group then
		pcall(vim.api.nvim_del_augroup_by_id, state.group)
		state.group = nil
	end
end

vim.api.nvim_create_user_command("PandocPreview", function()
	local src = vim.api.nvim_buf_get_name(0)
	if src == "" then
		vim.notify("PandocPreview: buffer has no file", vim.log.levels.WARN)
		return
	end
	local dir = vim.fn.stdpath("cache") .. "/pandoc-preview"
	vim.fn.mkdir(dir, "p")
	local out = dir .. "/preview.html"

	-- browser-sync reloads the page whenever the output file changes; started
	-- only after the first successful build so it never 404s
	local function start_server()
		if state.server then
			vim.notify("PandocPreview: rebuilt")
			return
		end
		vim.notify("PandocPreview: starting http://localhost:3000")
		state.server = vim.system({
			"npx", "--yes", "browser-sync", "start",
			"--server", dir,
			"--index", "preview.html",
			"--files", out,
			"--no-notify", "--no-ui",
		}, {}, function(res)
			state.server = nil
			if res.code ~= 0 and res.code ~= 15 then
				vim.schedule(function()
					vim.notify("PandocPreview server exited:\n" .. (res.stderr or ""),
						vim.log.levels.WARN)
				end)
			end
		end)
	end

	build(src, out, start_server)

	state.group = vim.api.nvim_create_augroup("PandocPreview", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = state.group,
		buffer = 0,
		callback = function()
			build(src, out)
		end,
	})
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = state.group,
		callback = stop,
	})
end, { desc = "Start live pandoc preview of current buffer" })

vim.api.nvim_create_user_command("PandocPreviewStop", stop,
	{ desc = "Stop live pandoc preview" })
