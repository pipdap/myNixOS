{ self, inputs, ... }: {
  flake.nixosModules.myMachineHardware = { config, lib, pkgs, ... }: {
    imports = [ ];

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    boot.initrd.kernelModules = [ "iwlwifi" ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/9df5d26e-4e41-441d-a14c-e5f5f20acd65";
        fsType = "btrfs";
      };

    fileSystems."/home" =
      { device = "/dev/disk/by-uuid/9df5d26e-4e41-441d-a14c-e5f5f20acd65";
        fsType = "btrfs";
        options = [ "subvol=home" ];
      };

    fileSystems."/nix" =
      { device = "/dev/disk/by-uuid/9df5d26e-4e41-441d-a14c-e5f5f20acd65";
        fsType = "btrfs";
        options = [ "subvol=nix" ];
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/71DE-7AC5";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
    hardware.enableRedistributableFirmware = true;    
  };
}
