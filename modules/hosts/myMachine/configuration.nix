{ self, inputs, ... }: {
  flake.nixosModules.myMachineConfiguration = { config, pkgs, lib, ... }: {
    imports = [
      self.nixosModules.myMachineHardware
      self.nixosModules.niri
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_15;
    
    # NVIDIA для Wayland
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      forceFullCompositionPipeline = true;
    };

    boot.initrd.kernelModules = [ 
      "nvidia" 
      "nvidia_modeset" 
      "nvidia_uvm" 
      "nvidia_drm" 
    ];

    boot.kernelParams = [ 
      "nvidia-drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.extraModulePackages = with config.boot.kernelPackages; [ amneziawg ];

    networking.hostName = "nixos";
    networking.networkmanager.enable = true;
    networking.firewall.allowedTCPPorts = [ 53317 ];
    networking.firewall.allowedUDPPorts = [ 53317 ];

    time.timeZone = "Europe/Moscow";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "ru_RU.UTF-8"; LC_IDENTIFICATION = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8"; LC_MONETARY = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8"; LC_NUMERIC = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8"; LC_TELEPHONE = "ru_RU.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };

    services.xserver.enable = true;
    
    # Greetd для Wayland (вместо SDDM)
    programs.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "niri-session";
          user = "pincet";
        };
      };
    };
    
    services.xserver.desktopManager.xfce.enable = true;
    services.xserver.xkb = { layout = "us,ru"; options = "grp:alt_shift_toggle"; };

    services.printing.enable = true;

    services.pipewire = {
      enable = true; alsa.enable = true; alsa.support32Bit = true; pulse.enable = true;
    };

    users.users.pincet = {
      isNormalUser = true; description = "pincet";
      extraGroups = [ "networkmanager" "wheel" "video" "input" ];
      shell = pkgs.zsh;
    };
    programs.zsh.enable = true;
    programs.firefox.enable = true;

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      amneziawg-go amneziawg-tools localsend
    ];

    programs.amnezia-vpn.enable = true;

    system.stateVersion = "24.05";
  };
}