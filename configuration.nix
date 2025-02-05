# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:


{

services.xserver.videoDrivers = ["nvidia"];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


# Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nixpkgs.config.allowUnfree = true;

  nix = {
  settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };
  gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
};


  fileSystems."/" = {
    device = "zroot/root/nixos";
    fsType = "zfs";
    options = [ "noatime" "nodiratime" ];
  };

  fileSystems."/home" = {
    device = "zroot/home";
    fsType = "zfs";
    options = [ "noatime" "nodiratime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F2DA-D468";
    fsType = "vfat";
  };


boot.initrd = {
  supportedFilesystems = [ "ext4" "btrfs" "xfs" "vfat" ];
  kernelModules = [ "raid0" "raid1" "raid10" "raid456" ];
};

systemd.services.mdmonitor = {
  enable = true;
  wantedBy = [ "multi-user.target" ];
};

# Enable LVM
services.lvm.enable = true;

# Add the mount point for your LVM volume
fileSystems."/home/stephey/shared" = {  # Adjust path as needed
  device = "/dev/vg_main/home";
  fsType = "ext4";  # Adjust if using a different filesystem
  options = [
    "defaults"
    "x-systemd.automount"
    "noatime"
    "nodiratime"
  ];
};

  networking.hostName = "br0th3r"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.hostId="ab8023a9";

  # Set your time zone.
  time.timeZone = "America/New_York";


  # Configure network proxy if necessary
  # networking.proxy.

#default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };


  #Enable Wayland

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
    };
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    forceFullCompositionPipeline = true;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };



  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    NIXPKGS_ALLOW_UNFREE = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    GDK_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    GTK_THEME = "Adwaita:dark";
    QT_STYLE_OVERRIDE = "adwaita-dark";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    WLR_RENDERER = "vulkan";
    CLUTTER_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
    GTK_DATA_PREFIX = "${pkgs.gtk3}";
  };

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "adwaita-dark";
  };

  # GTK Theme settings

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
 };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/Hyprland";
      };
    };
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
   services.pipewire = {
     enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
     wireplumber.enable = true;
     pulse.enable = true;
   };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
users.users.stephey = {
  isNormalUser = true;
  description = "stephey";
  extraGroups = [ "nixconf" "networkmanager" "wheel" "video" "input" "render" "docker" "disk" "lvm" ];
  packages = with pkgs; [
    tree
  ];
  shell = pkgs.zsh;
};

users.users.greeter = {
  group = "greeter";
  isSystemUser = true;
  extraGroups = [ "video" "input" "render" ];
};


users.groups.greeter = {};
security.sudo = {
  enable = true;
  extraRules = [{
    groups = [ "wheel" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" "SETENV" ];
    }];
  }];
  # Remove the problematic line about systemd_run_no_new_privs
};

  # Create a group for NixOS config access
  users.groups.nixconf = {};

  system.autoUpgrade = {
  enable = true;
  allowReboot = false;  # Set to true if you want automatic reboots
  dates = "02:00";
  flags = [
    "--no-build-output"
    "--delete-older-than 30d"
  ];
};

  # Set permissions for /etc/nixos
  system.activationScripts.nixos-config-perms = ''
    mkdir -p /etc/nixos
    chown -R root:nixconf /etc/nixos
    chmod -R 775 /etc/nixos
    '';

xdg.mime.defaultApplications = {
  "text/html" = "librewolf.desktop";
  "x-scheme-handler/http" = "librewolf.desktop";
  "x-scheme-handler/https" = "librewolf.desktop";
  "x-scheme-handler/about" = "librewolf.desktop";
  "x-scheme-handler/unknown" = "librewolf.desktop";
};
  programs = {
    firefox = {
      enable = true;
      preferences = {
        "privacy.resistFingerprinting" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.firstparty.isolate" = true;
        "browser.send_pings" = false;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "dom.event.clipboardevents.enabled" = false;
        "media.navigator.enabled" = false;
        "network.cookie.cookieBehavior" = 1;
        "network.http.referer.XOriginPolicy" = 2;
        "webgl.disabled" = true;
        "javascript.options.asmjs" = false;
      };
    };
    };



  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
      xdg-utils
      sudo
        dbus

	  cairo
	  pango
	  gdk-pixbuf
	  atk
      mdadm
  lvm2
    # Development
    rustup
    rust-analyzer
    nodejs_20
    nodePackages.npm
    nodePackages.pnpm
    greetd.regreet
    # System utilities
    btop
    neofetch
    ripgrep
    fd
    eza # modern replacement for ls
    bat # better cat
    zoxide # smart cd command
    fzf # fuzzy finder

    # Hardware & Power Management
    acpi # Battery and power info
    brightnessctl # Screen brightness control
    powertop # Power consumption analyzer
    tlp # Power management
    libsForQt5.kwalletmanager
        libsForQt5.kwalletmanager
    ktailctl
    # Current packages remain...
    _1password-gui
    _1password-cli
    grim
    slurp
    wf-recorder
    wlogout
    swaylock-effects
    waybar
    wget
    swww
    wl-clipboard
    wezterm
    git
    uwsm
    vulkan-tools
    vulkan-validation-layers
    libva
    libva-utils
    glxinfo
    wayland-utils
    xdg-utils
    xdg-desktop-portal-hyprland
    qt6.qtwayland
    libsForQt5.qt5.qtwayland
    hyprpolkitagent
    wev
    waypipe
    wl-mirror
    hyprpicker
    code-cursor
    hyprls
    swaynotificationcenter
    libnotify
	discord
	swaynotificationcenter
	nextcloud-client
    # File management
    yazi
    file
    unzip
    zip
    # Application launcher
    rofi-wayland
    # Media
    pavucontrol
    playerctl
    # System info and theming
    nwg-look # GTK theme configuration
    libsForQt5.qt5ct
    # Development
    docker
    docker-compose
    yazi  # Modern file manager
    starship  # Better prompt
    helix  # Modern editor
    zellij  # Terminal multiplexer
    eww  # For future custom
    # Development additions
    nil  # Nix LSP
    alejandra  # Nix formatter
    direnv  # Per-project environments
    nix-direnv
       tailscale
       parted
       ddrescue
       ubootTools
       gcc-arm-embedded-8
       python3
       flashrom
       dtc

    # ASUS-specific
    asusctl # ASUS control utilities
    supergfxctl # Graphics switching utility
    librewolf  # Primary hardened browser
    brave  # Privacy-focused Chromium browser
    tor-browser-bundle-bin  # For when maximum privacy is needed
    rocmPackages_5.clr
    microcode-amd
    amdvlk
    wl-clipboard  # Wayland clipboard utilities
  	cliphist      # Clipboard history
  	qt6.qtwayland
    adwaita-icon-theme  # Changed from gnome.adwaita-icon-theme
  	adwaita-qt
  	qt6Packages.qt6ct
  	papirus-icon-theme
  	tuba
  	zed-editor
      gtk3  # Required for GTK apps
  gtk4  # Required for modern GTK apps
  glib
  hicolor-icon-theme
  gsettings-desktop-schemas
  ];

fonts = {
  enableDefaultPackages = true;  # Changed from enableDefaultFonts

  fontDir.enable = true;
  enableGhostscriptFonts = true;

  fontconfig = {
    enable = true;
    antialias = true;
    hinting = {
      enable = true;
      style = "full";
    };
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
    defaultFonts = {
      serif = [ "DejaVu Serif" ];
      sansSerif = [ "DejaVu Sans" ];
      monospace = [ "DejaVu Sans Mono" ];
    };
  };

  packages = with pkgs; [  # Changed from fonts
  noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    dejavu_fonts
    ubuntu_font_family
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];
};

    services.tailscale = {
       enable = true;
     };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
   programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

   programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
};

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
   system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

  boot = {

    kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_RegistryDwords=EnableBrightnessControl=1"
    "mem_sleep_default=deep"
    "amd_pstate=active"  # Better AMD CPU frequency management
        "mitigations=auto"  # Better security/performance balance
    "quiet"  # Cleaner boot
    "systemd.show_status=1"
  ];
  tmp.cleanOnBoot = true;  # Clean /tmp on boot

  };



  # Add these hardware configurations
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Needed for Steam and some games
  };
  # We don't need Xserver enabled since we're using Wayland/Hyprland
  # The NVIDIA drivers are already configured properly above in hardware.nvidia

  # Add vulkan support
  security.polkit.enable = true;
  systemd.user.services.hyprpolkit = {
    description = "Hyprland Polkit Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Add zsh with better defaults
programs.zsh = {
  enable = true;
  autosuggestions.enable = true;  # Changed from enableAutosuggestions
  enableCompletion = true;
  syntaxHighlighting.enable = true;
};

  # Enable Docker
  virtualisation.docker.enable = true;

  # Better GTK/Qt theming
  programs.dconf.enable = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;  # Higher swappiness for ZRAM
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  # If you have >16GB RAM, consider adding zram
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;  # Use 50% of RAM for ZRAM
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # AMD CPU specific settings
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # PCIe power management
      PCIE_ASPM_ON_BAT = "powersupersave";
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # GPU power management
      RADEON_DPM_STATE_ON_AC = "performance";
      RADEON_DPM_STATE_ON_BAT = "battery";
    };
  };

  security.rtkit.enable = true;  # Better real-time scheduling
  security.pam.services.swaylock = {};  # For swaylock to work properly

  # Optional but recommended security features
  security.audit.enable = true;
  security.audit.rules = [
    "-w /etc/nixos/ -p wa -k nixos_conf"
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.makeBinPath [pkgs.greetd.tuigreet]}/tuigreet --time --cmd ${pkgs.uwsm}/bin/uwsm";
        user = "greeter";
      };
    };
  };



# Configure regreet
environment.etc."greetd/regreet.toml".text = ''
  [terminal]
  vt = 1

  [default_session]
  command = "${pkgs.uwsm}/bin/uwsm start Hyprland"
  user = "stephey"

  [background]
  path = ""
  fit = "Fill"

  [GTK]
  application_prefer_dark_theme = true
  cursor_theme_name = "Adwaita"
  font_name = "FiraCode Nerd Font 12"
  icon_theme_name = "Papirus-Dark"

  [theme]
  background_color = "rgba(22, 22, 22, 0.8)"
  font_family = "FiraCode Nerd Font"
  font_size = 12
  border_width = 3
  border_radius = 8
  border_color = "#B026FF"
  text_color = "#FFFFFF"
'';

# Configure uwsm
environment.etc."uwsm/config.toml".text = ''
  [[sessions]]
  name = "Hyprland"
  command = "Hyprland"
  environment = [
    "LIBVA_DRIVER_NAME=nvidia"
    "GBM_BACKEND=nvidia-drm"
    "__GLX_VENDOR_LIBRARY_NAME=nvidia"
    "WLR_NO_HARDWARE_CURSORS=1"
    "WLR_RENDERER=vulkan"
    "XDG_SESSION_TYPE=wayland"
    "XDG_CURRENT_DESKTOP=Hyprland"
    "XDG_SESSION_DESKTOP=Hyprland"
    "QT_QPA_PLATFORM=wayland"
    "GDK_BACKEND=wayland"
    "CLUTTER_BACKEND=wayland"
    "SDL_VIDEODRIVER=wayland"
    "_JAVA_AWT_WM_NONREPARENTING=1"
    "MOZ_ENABLE_WAYLAND=1"
  ]
'';

# Ensure proper permissions for the log directory
systemd.tmpfiles.rules = [
  "d /var/log/regreet 0755 greeter greeter -"
  "d /var/lib/regreet 0755 greeter greeter -"
  "d /tmp/regreet 0755 greeter greeter -"
];

  networking = {
    useDHCP = false;  # Deprecated
    useNetworkd = true;  # More modern networking
    firewall = {
      enable = true;
      allowPing = false;
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";  # Better for modern AMD CPUs
  };

  # Add specific AMD microcode updates
  hardware.cpu.amd.updateMicrocode = true;

  # Add AMD-specific graphics support

  services.asusd = {
    enable = true;
    enableUserService = true;  # For user-level control
  };

  # Fan control and power profiles
  services.supergfxd.enable = true;

}
