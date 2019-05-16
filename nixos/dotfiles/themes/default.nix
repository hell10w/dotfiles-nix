{ config, pkgs, lib, ... }:
let cfg = (import <nixpkgs/nixos> {}).config.own.gui; in
with lib; with types;
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      lxappearance
    ];

    gtk = {
      enable = true;

      font = {
        name = "DejaVu Sans 10";
        package = pkgs.dejavu_fonts;
      };

      gtk3 = {
        extraCss = ''
          VteTerminal, vte-terminal {
              padding: 5px;
          }
        '';
      };

      theme = {
        name = "Arc-Dark";
        package = pkgs.arc-theme;
      };

      iconTheme = {
        name = "Flat-Remix-Blue-Dark";
        package = pkgs.flat-remix; 
      };

    };

  };

}
