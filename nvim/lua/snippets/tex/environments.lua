local line_end = require("luasnip.extras.conditions.show").line_end

local tex = require"utils.texsnip"

return {
	s({
		trig = "itemize",
		show_condition = line_end,
		condition = line_end,
		name = [[\begin{itemize}]],
		desc = "Begin new itemize environment",
		docstring = [[
		\begin{itemize}
			\item 
		\end{itemize}]],
	}, fmt([[
	\begin{itemize}
		\item <item>
	\end{itemize}
	<e>
	]], {
		item = i(1),
		e = i(0),
	}, { delimiters = "<>" })),

	s({
		trig = "enumerate",
		show_condition = line_end,
		condition = line_end,
		name = [[\begin{enumerate}]],
		desc = "Begin new enumerate environment",
		docstring = [[
		\begin{enumerate}
			\item 
		\end{enumerate}]],
	}, fmt([[
	\begin{enumerate}
		\item <item>
	\end{enumerate}
	<e>
	]], {
		item = i(1),
		e = i(0),
	}, { delimiters = "<>" })),


	s({
		trig = "description",
		show_condition = line_end,
		condition = line_end,
		name = [[\begin{description}]],
		desc = "Begin new description environment",
		docstring = [[
		\begin{description}
			\item[]
		\end{description}]],
	}, fmt([[
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
		condition = line_end,
		name = [[\begin{figure}]],
		desc = "Make a figure",
		docstring = [[ 
		\begin{figure}
			\begin{center}
				\includegraphics[width=\textwidth]{}
			\end{center}
			\caption{}\label{fig:}
		\end{figure}
		]]
	}, fmt([[ 
		\begin{figure}
			\begin{center}
				\includegraphics[width=<width>\textwidth]{<path>}
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
		condition = line_end,
		name = [[\begin{longlisting}]],
		desc = "Begin new code listing",
		docstring = [[
		\begin{longlisting}
			\begin{minted}{}

			\end{minted}
			\caption{}\label{lst:}
		\end{longlisting}
		]]}, fmt([[ 
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
		condition = line_end,
		name = [[\begin{minted}]],
		desc = "Begin new minted environment",
		docstring = [[ 
		\begin{minted}{}
			
		\end{minted}
	]]
	}, fmt([[ 
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


	s({
		trig = "begin",
		name = [[\begin{}]],
		desc = "Begin new environment",
		docstring = [[
		\begin{}[]{}
			
		\end{}
		]]},fmt([[ 
		\begin{<env>}<opts>
			<con>
		\end{<env>}
		]], {
		env = i(1, "environment"),
		opts = i(2),
		con = i(3, "contents"),
	}, {
		delimiters = "<>",
		repeat_duplicates = true,
	})),


	tex.environment("center", {
		show_condition = line_end,
		condition = line_end,
	}),

	tex.environment("tikzpicture", {
		show_condition = line_end,
		condition = line_end,
	}),
}
