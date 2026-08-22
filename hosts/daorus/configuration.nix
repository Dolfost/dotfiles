# System config for the "daorus" host (NixOS). Only used once the box is NixOS:
#   sudo nixos-rebuild switch --flake .#daorus
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "daorus";
  time.timeZone = "Europe/Kyiv";

  # Bootloader — set to match the real machine before the first rebuild:
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  users.users.vladyslav = {
    isNormalUser = true;
    extraGroups = [ "wheel" "render" "video" ];
    linger = true;                 # so rootless quadlets start at boot
    # shell = pkgs.zsh;
  };

  # ---- how your current dotfiles buckets map onto NixOS -------------------
  # etc/  ->  environment.etc (paths are relative to THIS file: ../../ = repo root)
  #   environment.etc."coolercontrol/config.toml".source =
  #     ../../etc/coolercontrol/config.toml;
  #
  # services  ->  native modules (drop the container, or keep it — your call):
  #   services.jellyfin.enable = true;
  #   programs.coolercontrol.enable = true;
  #
  # containers/  ->  quadlets, once you add the quadlet-nix input to the flake.
  #   Your existing .container/.pod files translate almost 1:1.

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set to the release you install; do NOT change later (see note in home config).
  system.stateVersion = "25.05";
}
