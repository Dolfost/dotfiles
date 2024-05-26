local line_end = require("luasnip.extras.conditions.show").line_end

-- luasnip
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet
local k = require("luasnip.nodes.key_indexer").new_key

local M = {}

-- snippet generators

-- make new environment with name <env> and context <context>
-- if no <context> passed, then <env> is used as context.trig
function M.environment(env, context)
	context = context or {}
	context.trig = context.trig or env
	context.name = context.name or ("\\begin{" .. env .. "}")
	context.desc = context.desc or ("Begin new " .. env .. " environment")
	context.docstring = context.docstring or string.format([[
	\begin{%s}
		
	\end{%s}
	]], env, env)


	return s(context , fmt(string.format([[ 
	\begin{%s}
		<con>
	\end{%s}
	<e>
	]], env, env) , {
		con = i(1, "contents"),
		e = i(0),
	}, { delimiters = "<>" }))
end

-- make snippet for bibliography entry type <type>
-- with required fileds <required_fields>
-- <required_fields> may be empty or nil
function M.bib_entry(type, required_fields)
	required_fields = required_fields or {}
	local format = "@" .. type .. "{<tag>,"
	local nodes = {tag = i(1, "tag")}
	local docstring =  "@" .. type .. "{ ,"
	local nodecount = 1;
	for idx, field in ipairs(required_fields) do
		format = format .. "\n\t" .. field .. " = {<" .. field .. ">},"
		docstring = docstring .. "\n\t" .. field .. " = {},"
		nodes[field] = i(idx+1, field .. " value")
		nodecount = nodecount + 1
	end
	if (nodecount == 1) then
		format = format .. "\n\t <nah>"
		docstring = docstring .. "\n\t"
		nodes["nah"] = i(2, "fields")
	end
	nodes.e = i(0)
	format = format .. "\n}\n<e>"
	docstring = docstring .. "\n}\n"

	return s({
		trig = type,
		show_condition = line_end,
		condition = line_end,
		filetype = "bib",
		docstring = docstring,
		name = "@" .. type,
		desc = "New bibliography " .. type .. " entry"
	}, fmt(format, nodes, {delimiters = "<>"}))
end


-- math / not math zones
function M.in_math()
    return vim.api.nvim_eval("vimtex#syntax#in_mathzone()") == 1
end

-- comment detection
function M.in_comment()
	return vim.fn["vimtex#syntax#in_comment"]() == 1
end

-- document class
function M.in_beamer()
	return vim.b.vimtex["documentclass"] == "beamer"
end

-- general env function
local function env(name)
	local is_inside = vim.fn["vimtex#env#is_inside"](name)
	return (is_inside[1] > 0 and is_inside[2] > 0)
end

function M.in_preamble()
	return not env("document")
end

function M.in_text()
	return env("document") and not M.in_math()
end

function M.in_tikz()
	return env("tikzpicture")
end

function M.in_bullets()
	return env("itemize") or env("enumerate")
end

function M.in_align()
	return env("align") or env("align*") or env("aligned")
end

return M
