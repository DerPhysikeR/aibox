{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  # The generated image has an ext4 root filesystem.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  # BIOS/GRUB bootable image. This works nicely with ordinary libvirt/QEMU.
  boot.loader.grub.device = lib.mkDefault "/dev/sda";

  # Build target for a standalone qcow2 disk image.
  system.build.qcow2 =
    import "${modulesPath}/../lib/make-disk-image.nix" {
      inherit lib config pkgs;

      format = "qcow2";

      # Size is in MiB here. Pick whatever makes sense for the agent VM.
      diskSize = 20 * 1024;

      partitionTableType = "hybrid";
    };
}
