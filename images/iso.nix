{ config, pkgs, lib, ... }:

let
  squashfs-compression = "xz -Xdict-size 100%";
  # squashfs-compression = "gzip -noD -noF -noX -noI";
in

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
    <nixpkgs/nixos/modules/profiles/all-hardware.nix>
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../modules/generic
    ../modules/nixos
  ] ++ lib.optional (builtins.pathExists ../local-iso.nix) ../local-iso.nix;

  networking.hostName = "iso";

  boot = {
    loader.grub.memtest86.enable = true;
    initrd.availableKernelModules = [
      "ehci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      # "r8125"
    ];
    kernelModules = [
      "kvm-intel"
      # "r8125"
    ];
    extraModulePackages = with config.boot.kernelPackages; [
      # r8125
    ];
  };

  own = {
    ssh = {
      enable = true;
    };
    gui = {
      enable = true;
      heavy = false;
    };
    # docker.enable = true;
    # virtualisation.enable = true;
  };

  services.spice-vdagentd.enable = true;

  # system.build.squashfsStore = pkgs.callPackage <nixpkgs/nixos/lib/make-squashfs.nix> {
  #   storeContents = config.isoImage.storeContents;
  #   comp = lib.mkForce squashfs-compression;
  # };

  services.xserver.displayManager.lightdm.greeters.mini = {
    enable = lib.mkForce false;
  };

  isoImage = {
    isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";

    makeEfiBootable = true;
    makeUsbBootable = true;

    squashfsCompression = "gzip -noD -noF -noX -noI";

    efiSplashImage = "${pkgs.wallpapers}/IMG_209880gs.jpg";
    splashImage = "${pkgs.wallpapers}/IMG_209880gs.jpg";

    appendToMenuLabel = "";
    # grubTheme = null;

  };

}
