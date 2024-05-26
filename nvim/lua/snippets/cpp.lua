return {
	s({
		trig = "forauto",
		name = "C++11 for loop",
		desc = "Create C++ for loop",
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


	s({
		trig = "class",
		name = "Class",
		desc = "Create new class",
	}, fmt([[ 
	class <class> {
		public:
			<class>();
			<e>

		private: 
			~<class>();
	}]], {
			class = i(1, "SomeClass"),
			e = i(0),
		}, {delimiters = "<>", repeat_duplicates = true})),
}
