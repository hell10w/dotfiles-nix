{ config, pkgs, lib, ... }:
let cfg = config.own.steam; in
with lib; with types;
{
  options.own.steam = {
    enable = mkEnableOption "steam";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # steam
      (steam.override {
        extraPkgs = pkgs: with pkgs; [ pango harfbuzz libthai ];
      })
      # steam-run-native
      protontricks
      drivers.x52pro
    ];
    services.udev.packages = with pkgs; [
      drivers.x52pro
    ];

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      setLdLibraryPath = true;
      extraPackages32 = [ ];
    };
    hardware.pulseaudio.support32Bit = true;
    hardware.steam-hardware.enable = true;

    services.udev.extraRules = ''
      # This rule is needed for basic functionality of the controller in
      # Steam and keyboard/mouse emulation
      SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
      # This rule is necessary for gamepad emulation; make sure you
      # replace 'pgriffais' with a group that the user that runs Steam
      # belongs to
      KERNEL=="uinput", MODE="0660", GROUP="users", OPTIONS+="static_node=uinput"
      # Valve HID devices over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"
      # Valve HID devices over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"
      # DualShock 4 over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0666"
      # DualShock 4 wireless adapter over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0666"
      # DualShock 4 Slim over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0666"
      # DualShock 4 over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*054C:05C4*", MODE="0666"
      # DualShock 4 Slim over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*054C:09CC*", MODE="0666"
  '';

  };

}
