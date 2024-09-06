{ modulesPath, lib, myLib, ... }: {
  imports = myLib.pfxPaths ../../core/options [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel.nix"
    "systemd-boot.nix"
    "netmanager.nix"
  ];

  isoImage.squashfsCompression = "zstd -Xcompression-level 10";
  nix.settings.auto-optimise-store = false; # Speedup write
  boot.binfmt.emulatedSystems = [ "aarch64-linux" "i686-linux" ];
  networking.wireless.enable = false;
  networking.wireless.iwd.enable = true;
  boot.supportedFilesystems =
    lib.mkForce [ "btrfs" "vfat" "f2fs" "xfs" "ntfs" ];
}
