# Home half of the yazi portal file picker (system half:
# modules/system/file-picker): the termfilechooser wrapper config pointing
# it at yazi in wezterm.
{ config, lib, ... }:

{
	options.dotfiles.filePicker.enable = lib.mkOption {
		type = lib.types.bool;
		default = config.dotfiles.graphical;
		description = "Wrapper config for the yazi portal file picker.";
	};

	config = lib.mkIf config.dotfiles.filePicker.enable {
		xdg.configFile."xdg-desktop-portal-termfilechooser".source =
			config.lib.file.mkOutOfStoreSymlink
				"${config.dotfiles.dir}/xdg-desktop-portal-termfilechooser";
	};
}
