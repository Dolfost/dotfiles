local line_end = require("luasnip.extras.conditions.show").line_end

local tex = require"utils.texsnip"

return {
	s("itemize", fmt([[
	\begin{itemize}
		\item <item>
	\end{itemize}
	<e>
	]], {
		item = i(1),
		e = i(0),
	}, { delimiters = "<>" })),

	s("enumerate", fmt([[
	\begin{enumerate}
		\item <item>
	\end{enumerate}
	<e>
	]], {
		item = i(1),
		e = i(0),
	}, { delimiters = "<>" })),


	s("description", fmt([[
	\begin{description}
		\item[<desc>] <item>
	\end{description}
	<e>
	]], {
		item = i(1),
		desc = i(1),
		e = i(0),
	}, { delimiters = "<>" })),


	s({
		trig = "figure",
		show_condition = line_end,
		condition = line_end}, fmt([[ 
		\begin{figure}
			\begin{center}
				\includegraphics[width=<width>\textwidth]{\subfix{images/<path>}}
			\end{center}
			\caption{<caption>}\label{fig:<label>}
		\end{figure}
		<e>
		]], {
			width = i(1, "1.0"),
			path = i(2, "fig"),
			caption = i(3, "caption"),
			label = d(4, function (args)
				return sn(nil, {
					i(1, args[1])
				})
			end,
			{2}),
			e = i(0),
		}, {
			delimiters = "<>" })),


	s({
		trig = "listing",
		show_condition = line_end,
		condition = line_end}, fmt([[ 
		\begin{longlisting}
			\begin{minted}{<lang>}
				<code>
			\end{minted}
			\caption{<caption>}\label{lst:<label>}
		\end{longlisting}
		<e>
		]], {
			lang = i(1, "c++"),
			code = i(2, "code"),
			caption = i(3, "caption"),
			label = i(4, "code"),
			e = i(0),
		}, {
			delimiters = "<>" })),


	s({
		trig = "minted",
		show_condition = line_end,
		condition = line_end}, fmt([[ 
		\begin{minted}{<lang>}
			<con>
		\end{minted}
		<e>
		]], {
			lang = i(1, "c++"),
			con = i(2, "code"),
			e = i(0),
		}, {
			delimiters = "<>" })),


	s("begin", fmt([[ 
	\begin{<env>}
		<con>
	\end{<env>}
	]], {
		env = i(1, "environment"),
		con = i(2, "contents"),
	}, {
		delimiters = "<>",
		repeat_duplicates = true,
	})),


	tex.environment("center", {
		show_condition = line_end,
		condition = line_end
	}),
}
