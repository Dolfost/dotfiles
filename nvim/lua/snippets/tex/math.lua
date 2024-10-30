local line_end = require("luasnip.extras.conditions.show").line_end

local tex = require"utils.texsnip"

return {
	tex.environment("gather", {
		show_condition = line_end,
		condition = line_end,
	}),

	tex.environment("align", {
		show_condition = line_end,
		condition = line_end,
	}),

	tex.environment("multline", {
		show_condition = line_end,
		condition = line_end,
	}),

	tex.environment("cases"),

	tex.environment("bmatrix"),

	s({
		trig = "ff",
		name = "Fraction",
		desc = "Open new fraction",
		docstring = [[\frac{}{}]]
	}, fmt([[\frac{<num>}{<den>}<e>]], {
		num = i(1, "1"),
		den = i(2, "2"),
		e = i(0),
	}, {
		delimiters = "<>" })),

	s({
		trig = "mm",
		name = "Inline math",
		desc = "Begin inline math",
		docstring = [[\( \)]]
	}, fmt([[\(<math>\) <e>]], {
		math = i(1, "x^2"),
		e = i(0),
	}, {
		delimiters = "<>" })),

	s({
		trig = "MM",
		name = "Display math",
		desc = "Begin display math",
		docstring = "\\[ \\]"
	}, fmt([[\[<math>\] <e>]], {
		math = i(1, "x^2"),
		e = i(0),
	}, {
		delimiters = "<>" })),
}
