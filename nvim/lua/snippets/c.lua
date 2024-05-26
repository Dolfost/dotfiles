return {
	s({
		trig = "main",
		name = "int main()",
		desc = "Begin main funciton",
	}, fmt([[
	int main(int argc, char** argv) {
		<body>

		return 0;
	}]], {
		body = i(1, "code")
	}, {delimiters = "<>"})),


	s({
		trig = "ifndef",
		name = "#ifndef",
		desc = "Include guard",
	}, fmt([[
	#ifndef <guard>
	#define <guard>

		<body>

	#endif // !<guard>
	]], {
		guard = i(1, "_GUARD_HPP_"),
		body = i(2, "// code"),
	}, {delimiters = "<>", repeat_duplicates = true})),


	s({
		trig = "for",
		name = "for loop",
		desc = "Begin new for loop",
	}, fmt([[ 
		for (<init>; <cond>; <inc>) {
			<body>
		}
		<e>]], {
			init = i(1, "int i = 0"),
			cond = i(2, "i < 10"),
			inc = i(3, "i += 1"),
			body = i(4, "// code"),
			e = i(0),
		}, {delimiters = "<>"})),
}
