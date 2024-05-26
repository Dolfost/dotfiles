local function type_return(t)
	local type_value = {
		int = '0',
		short = '0',
		long = '0',
		double = '0.0',
		float = '0.0',
		char = "'a'",
		string = '"Hello, World!"',
		vector = "{}",
		list = "{}"
	}

	local val = nil
	for k, v in pairs(type_value) do
		if (string.find(t, k) ~= nil) then
			val = v
			break
		end
	end

	return val and "return " .. val .. ";" or ""
end


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
		body = i(1, "// code")
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
		trig = "if",
		name = "If statement",
		desc = "Create new if statement",
	}, fmt([[ 
	if (<cond>) {
		<body>
	} <e>]], {
			cond = i(1, "i < 10"),
			body = i(2, "// code"),
			e = i(0),
		}, {delimiters = "<>"})),


	s({
		trig = "else",
		name = "Else statement",
		desc = "Create else statement",
	}, fmt([[ 
	else  {
		<body>
	} <e>]], {
			body = i(1, "// code"),
			e = i(0),
		}, {delimiters = "<>"})),

		s({
			trig = "switch",
			name = "Switch case",
			dscr = "Create new switch case" },
		fmt([[
		switch (<cond>) {
			case <val>:
				<body>
				break;

			default:
				break;
		}]], {
			cond = i(1, "/* var */"),
			val = i(2, "/* val */"),
			body = i(3, "// code"),
		}, {delimiters = "<>"})),


	s({
		trig = "for",
		name = "For loop",
		desc = "Create C for loop",
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

		
	s({
		trig = "while",
		name = "While loop",
		desc = "Create while loop",
	}, fmt([[ 
		while (<cond>) {
			<body>
		}
		<e>]], {
			cond = i(1, "i < 10"),
			body = i(2, "// code"),
			e = i(0),
		}, {delimiters = "<>"})),


	s({
		trig = "func",
		name = "Funciton definition",
		desc = "Define new fuction",
	}, fmt([[ 
	<rtype> <fname>(<fparams>) {
		<body>

		<ret>
	}
	]], {
			rtype = i(1, "int"),
			fname = i(2, "someFunction"),
			fparams = i(3, "int a"),
			body = i(4, "// code"),
			ret = d(5, function(args)
				return sn(nil, {
					t(type_return(args[1][1]))
				})
			end,
			{1})
		}, {delimiters = "<>"})),


	s({
		trig = "struct",
		name = "Structure",
		desc = "Create new structure",
	}, fmt([[ 
	struct <struct> {
		<e>
	}]], {
			struct = i(1, "SomeStruct"),
			e = i(0),
		}, {delimiters = "<>"})),


	s({
		trig = "ternary",
		name = "Ternary operator",
		desc = "Create new ternary operator",
	}, fmt([[<cond> ? <exp1> : <exp2>;]], {
			cond = i(1, "/*cond*/"),
			exp1 = i(2, "/*exp1*/"),
			exp2 = i(3, "/*exp2*/"),
		}, {delimiters = "<>"})),
}
