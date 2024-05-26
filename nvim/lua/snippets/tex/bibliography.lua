local tex = require"utils.texsnip"

return {
	tex.bib_entry("article", {
		"author", "title", "journal", "year"
	}),

	tex.bib_entry("book", {
		"author", "year", "title", "publisher", "address",
	}),

	tex.bib_entry("booklet", {
		"title", "author", "howpublished", "address", "year",
	}),

	tex.bib_entry("conference", {
		"author", "title", "year", "booktitle"
	}),

	tex.bib_entry("conference", {
		"author", "title", "booktitle", "year"
	}),

	tex.bib_entry("inbook", {
		"author", "title", "booktitle", "publisher", "year"
	}),

	tex.bib_entry("incollection", {
		"author", "title", "booktitle", "publisher", "year"
	}),

	tex.bib_entry("inproceedings", {
		"author", "title", "booktitle", "year"
	}),

	tex.bib_entry("manual", {
		"title", "year"
	}),

	tex.bib_entry("masterthesis", {
		"author", "title", "school", "year"
	}),

	tex.bib_entry("misc"),

	tex.bib_entry("phdthesis", {
		"author", "title", "school", "year"
	}),

	tex.bib_entry("proceedings", {
		"title", "year"
	}),

	tex.bib_entry("techreport", {
		"author", "title", "institution", "year", "number"
	}),

	tex.bib_entry("unpublished", {
		"author", "title", "institution", "year"
	}),
}
