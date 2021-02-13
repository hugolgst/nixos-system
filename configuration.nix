# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix ./vpn-configuration.nix ./hydra ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    # For airpods
    extraConfig = ''
      ControllerMode=bredr
    '';
  };

  # Networking 
  networking.nat.enable = true;
  networking.nat.externalInterface = "wlp1s0";
  networking.nat.internalInterfaces = [ "wg0" ];
  # networking.firewall = { allowedUDPPorts = [ 51820 ]; };

  virtualisation.docker.enable = true;

  networking.hostName =
    (import ./user-configuration.nix).serialNumber; # Define your hostname.
  networking.networkmanager.enable = true;

  # Enable captive-browser
  programs.captive-browser.enable = true;
  programs.captive-browser.interface = "wlp1s0";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp3s0f0.useDHCP = false;
  networking.interfaces.wlp1s0.useDHCP = false;

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager
    git
    wget
    unzip
    zip
    vpn-traffic
    signal-desktop
  ];

  programs.gnupg.agent.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.pulseaudio = true;

  # To enable Swaylock to check the password
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # Import the overlay
  nixpkgs.overlays = [ (import ./overlay/default.nix) ];

  # Setup fonts
  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
    fonts = with pkgs; [ nerdfonts ];
  };

  # For the Yubikey
  services.udev.packages = [ pkgs.yubikey-personalization ];
  programs.light.enable = true;

  # Open UDP/TCP ports
  networking.firewall = {
    allowedUDPPortRanges = [{
      from = 32768;
      to = 60999;
    }];
    allowedTCPPorts = [ 3000 ];
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    package = pkgs.pulseaudioFull;
    daemon.config = {
      default-sample-rate = 48000;
      default-fragments = 8;
      default-fragment-size-msec = 10;
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "intl";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    hl = {
      shell = pkgs.fish;
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    };
  };

  nix.useSandbox = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}

