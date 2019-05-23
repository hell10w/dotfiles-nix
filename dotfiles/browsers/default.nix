{ config, pkgs, lib, ... }:
let cfg = config.nixos-config.own.gui; in
with lib; with types;
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      google-chrome
      vivaldi
      vivaldi-ffmpeg-codecs
    ];

    programs = {
      firefox = {
        enable = true;
        enableAdobeFlash = false;
        enableGoogleTalk = false;
        extensions = [ ];
      };

      chromium = {
        enable = true;
        extensions = [
          "dbepggeogbaibhgnhhndojpepiihcmeb"  # vimium
          "gcbommkclmclpchllfjekcdonpmejbdp"  # https everywhere
          "padekgcemlokbadohgkifijomclgjgif"  # proxy switchyomega
          "gighmmpiobklfepjocnamgkkbiglidom"  # adblock
          "cfhdojbkjhnklbpkdaibdccddilifddb"  # adblock plus
          "cmedhionkhpnakcndndgjdbohmhepckk"  # adblock youtube
          "aapbdbdomjkkjkaonfhkkikfgjllcleb"  # google translate
          "gjjpophepkbhejnglcmkdnncmaanojkf"  # plus for trello
        ];
      };

    };

  };

}
