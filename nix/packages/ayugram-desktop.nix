# AyuGram with one local patch, ayugram-paste-hints.patch, which honours two
# clipboard "paste hints" on a plain Ctrl+V (stickpile docs/clipboard.md,
# section 5): application/x-sticker preselects "send as file" when every
# pasted file is a sticker (so it goes out as one), and
# application/x-no-dialog sends the paste at once, without the send files
# box. stickpile offers both on its sticker-mode copies. Drops, "send as"
# choices and message edits ignore the hints. Not upstream. Built from
# source, so a nixpkgs bump that moves AyuGram rebuilds it (~25 min on
# loq), and a new AyuGram version may need the patch refreshed.
#
# The wrapper copies `unwrapped` from its own attribute (finalAttrs), so
# replacing that attribute is enough; ayugram-desktop.override would take
# the arguments of nixpkgs' package.nix instead.
{ ayugram-desktop }:

ayugram-desktop.overrideAttrs (old: {
	unwrapped = old.unwrapped.overrideAttrs (u: {
		patches = (u.patches or [ ]) ++ [ ./ayugram-paste-hints.patch ];
	});
})
