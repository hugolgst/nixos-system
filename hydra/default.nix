{ pkgs, ... }: {
  services.hydra = {
    enable = true;
    package = pkgs.hydra-unstable.overrideAttrs (_oldAttrs: {
      patches = [
        # Fix for https://github.com/NixOS/nix/issues/1888
        ./no-restrict.patch
      ];
    });
    hydraURL = "http://localhost:3000";
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [ ];
    useSubstitutes = true;
  };
}
