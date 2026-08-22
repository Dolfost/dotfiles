# User-space config (Home Manager). This is the declarative replacement for the
# ~/... entries in install.yaml. Build with:
#   home-manager switch --flake .#vladyslav@daorus
{ config, pkgs, ... }:
{
  home.username = "vladyslav";
  home.homeDirectory = "/home/vladyslav";   # (mac would be /Users/vladyslav)

  programs.home-manager.enable = true;

  # --- your existing plain-file configs, linked in place -------------------
  # Two ways to link, pick per config:

  # 1. Read-only copy into the Nix store — changing it needs a rebuild. Good for
  #    configs you don't hand-edit often. (Only git-TRACKED files get copied.)
  xdg.configFile."alacritty".source = ../alacritty;
  xdg.configFile."wezterm".source   = ../wezterm;
  home.file.".tmux.conf".source      = ../tmux/tmux.conf;

  # 2. Editable symlink straight to the live checkout — edits take effect with no
  #    rebuild, and the app can write back into the dir (e.g. nvim's lazy-lock.json).
  #    Use this for anything you tweak constantly or that writes to its own config.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";

  # Packages you currently install with pacman can move here over time:
  # home.packages = with pkgs; [ ripgrep fd fzf ];

  # Set once to the release you first activate; do NOT bump this casually — it
  # pins state/data-format compatibility, it is not "the version you run".
  home.stateVersion = "25.05";
}
