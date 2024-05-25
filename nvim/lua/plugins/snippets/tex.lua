return {
	s("itemize", {
		t{"\\begin{itemize}", "\t\\item "}, i(1),
		t{"", "\\end{itemize}"}
	}),

	s("enumerate", {
		t{"\\begin{itemize}", "\t\\item "}, i(1),
		t{"", "\\end{enumerate}"}
	}),

	s("description", {
		t{"\\begin{itemize}", "\t\\item["}, i(1), t"] ", i(2),
		t{"", "\\end{description}"}
	}),

	s({trig = "figure", trigEngine = 'pattern'}, {
		t{"\\begin{figure}", "\t\\begin{center}", "\t\t\\includegraphics[width="}, 
		i(1), t"textwidth]{\\subfix{images/", i(2), t{"}}", "\t\\end{center}", 
		"\t\\caption{"}, i(3), t"}\\label{fig:", i(4), t"}",
		t{"", "\\end{figure}", ""}, i(0)
	}),
}
