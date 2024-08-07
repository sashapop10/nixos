{ config, lib, modulesPath, myEnv, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.kernelModules = [ ];
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1c5f93d0-b78c-4bd9-bf54-c869ba5e0e7a";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/CEEC-5381";
    fsType = "vfat";
  };

  swapDevices = [ ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault myEnv.platform;
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
