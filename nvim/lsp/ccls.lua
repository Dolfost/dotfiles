return {
	init_options = {
		compilationDatabaseDirectory = "build";
		index = {
			threads = 0;
		};
		clang = {
			excludeArgs = { "-frounding-math"} ;
		};
	},
	cmd = { "ccls" },
	filetypes = { "c", "cpp", "h", "hpp", "inl", "objc", "objcpp", "cuda", "proto" },
	root_markers = { '.git', '.clangd', 'compile_commands.json' }
}
