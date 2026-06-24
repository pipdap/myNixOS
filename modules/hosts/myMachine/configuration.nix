{ self, inputs, ... }: {
  flake.nixosModules.myMachineConfiguration = { config, pkgs, lib, ... }: {
    imports = [
      self.nixosModules.myMachineHardware
      self.nixosModules.niri
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
        # NVIDIA драйверы для Wayland (Niri)
    services.xserver.videoDrivers = [ "nvidia" ];
    
    hardware.nvidia = {
      modesetting.enable = true;        # КРИТИЧНО для Wayland
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;                     # Проприетарные модули (стабильнее)
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Параметры ядра для NVIDIA + Wayland
    boot.kernelParams = [ "nvidia-drm.modeset=1" ];
    
    # Переменные окружения для Wayland + NVIDIA
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
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
    services.displayManager.sddm.enable = true;
    services.xserver.desktopManager.xfce.enable = true;
    services.xserver.xkb = { layout = "us,ru"; options = "grp:alt_shift_toggle"; };

        # Wi-Fi драйверы для Intel
    boot.kernelModules = [ "iwlwifi" ];

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