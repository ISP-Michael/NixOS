{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
      ];

      kernelModules = [

      ];
    };

    kernelModules = [
      "kvm-amd"
    ];

    extraModulePackages = [

    ];
  };


  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/e4d3f4ad-1139-4f49-a60a-a4c2fbf67e1b";
      fsType = "ext4";
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/8FC0-5952";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  swapDevices = [

  ];

  networking = {
    useDHCP = lib.mkDefault true;
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
  };

  hardware = {
    cpu = {
      amd = {
        updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
  };
}
