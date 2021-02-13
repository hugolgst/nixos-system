{ config, pkgs, ... }:

let 
  routeAllTraffic = false;
  allowedIP = (if routeAllTraffic then "0.0.0.0/0" else "10.42.0.0/16");
in {
  networking.wg-quick.interfaces = {
    visium_vpn = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      address = [ "own IP" ];
      dns = [ "10.42.0.0" ];
      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKey = "private key";
      peers = [
        # For a client configuration, one peer entry for the server will suffice.
        {
          # Public key of the server (not a file path).
          publicKey = "public key";
          # Forward all the traffic via VPN.
          allowedIPs = [ 
            allowedIP
          ];
          # Or forward only particular subnets
          # Set this to the server IP and port.
          endpoint = "IP";
          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
