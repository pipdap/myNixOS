{ self, inputs, ... }: {
  flake.nixosModules.myMachineConfiguration = { config, pkgs, lib, ... }: {
    imports = [
      self.nixosModules.myMachineHardware
      self.nixosModules.niri
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
    
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

    hardware.firmware = [ pkgs.linux-firmware ];

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

    #boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 3;
    };
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
    
    services.greetd = {
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

    services.ollama = {
  enable = true;
  package = pkgs.ollama-cuda;
};

    users.users.pincet = {
      isNormalUser = true; description = "pincet";
      extraGroups = [ "networkmanager" "wheel" "video" "input" ];
      shell = pkgs.zsh;
    };
    #programs.zsh.enable = true;
    programs.firefox.enable = true;

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      # --- Твои старые программы ---
      amneziawg-go 
      amneziawg-tools 
      localsend
      firefox
      obsidian
      zapret
      gh  # GitHub CLI

      # --- GUI и Система (КРИТИЧНО ВАЖНО) ---
      xarchiver               # Архиватор
      blueman                 # GUI для Bluetooth (спасение после твоих мучений!)
      
      # --- Терминал и Разработка ---
      neovim                  # Продвинутый редактор (или используй nano)
      btop                    # Красивый мониторинг системы (вместо htop)
      yazi


  starship
  tmux
  fzf
  zoxide
  ripgrep
  fd
  eza
  bat
  kitty

  pi-coding-agent
opencode

      # --- Wayland и Niri ---
      #awww                    # Установка обоев в Wayland
      grim        # Скриншоты
  slurp       # Выбор области для скриншота
  swaybg      # Обои
  alsa-utils  # Управление звуком
      wl-clipboard            # Буфер обмена для Wayland (копировать/вставить в терминале)


      # --- Шрифты (ОБЯЗАТЕЛЬНО для терминалов и Noctalia) ---
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];

    programs.zsh = {
      enable = true;
      autosuggestions.enable = true;  # <-- Исправлено: добавлена 's'
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        theme = "agnoster";
        plugins = [ "git" "z" "fzf" ];
      };
    };

# Настройка Starship (если не используете Oh My Zsh тему)
# programs.starship.enable = true; 

    programs.amnezia-vpn.enable = true;

    system.stateVersion = "24.05";
  };
}
