return {
	s({
		trig = "forauto",
		name = "C++11 for loop",
		desc = "Begin new C++ for loop",
	}, fmt([[ 
		for (auto <x> : <from>) {
			<body>
		}
		<e>]], {
			x = i(1, "const& x"),
			from = i(2, "vector"),
			body = i(3, "// code"),
			e = i(0),
		}, {delimiters = "<>"})),
}
