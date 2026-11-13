# The stickpile client (modules/user/stickpile) against the server on aorus,
# at its default tailnet address. loq is a user device, so `stickpile login`
# needs no password here: the serve proxy says who you are.
{ config, ... }: {
	home-manager.users.${config.dotfiles.user}.dotfiles.stickpile.enable = true;
}
