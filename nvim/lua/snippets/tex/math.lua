local line_end = require("luasnip.extras.conditions.show").line_end

local tex = require"utils.texsnip"

return {
	tex.environment("gather", {
		show_condition = line_end * tex.in_text,
		condition = line_end * tex.in_text,
	}),

	tex.environment("align", {
		show_condition = line_end * tex.in_text,
		condition = line_end * tex.in_text,
	}),

	tex.environment("multline", {
		show_condition = line_end * tex.in_text,
		condition = line_end * tex.in_text,
	}),

	tex.environment("cases", {
		show_condition = tex.in_math,
		condition = tex.in_math,
	}),

	tex.environment("bmatrix", {
		show_condition = tex.in_math,
		condition = tex.in_math,
	}),

	s({
		trig = "mm",
		show_condition = tex.in_text,
		condition = tex.in_text,
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
		show_condition = tex.in_text,
		condition = tex.in_text,
		name = "Display math",
		desc = "Begin display math",
		docstring = "\\[ \\]"
	}, fmt([[\[<math>\] <e>]], {
		math = i(1, "x^2"),
		e = i(0),
	}, {
		delimiters = "<>" })),

}
