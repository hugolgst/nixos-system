{ pkgs }:

let path = "/etc/nixos/vpn-configuration.nix";
in pkgs.writeShellScriptBin "vpn-traffic" ''
  if [ $# -eq 0 ]; then
      echo "No arguments supplied."
      echo "Arguments available:"
      echo "  - status: Checks the status of the routing."
      echo "  - switch: Switch the routing of the VPN."
      exit 0
  fi

  # Get status of current routing
  # true: routing all the traffic into the VPN
  # false: only VPN traffic
  STATUS="$(cat ${path} | grep "routeAllTraffic = " | grep -o "true\|false")"

  if [ $1 == "status" ]; then
    if [ $STATUS == "true" ]; then 
      echo -e "\e[32mAll\e[39m traffic is routed through the VPN."
    else
      echo -e "\e[31mNot all\e[39m traffic is routed through the VPN."
    fi
    exit 0
  fi

  if [ $1 != "switch" ]; then
    exit 0
  fi

  if [[ $EUID -ne 0 ]]; then
    echo -e "This script \e[31mmust be run as root.\e[39m" 
    exit 1
  fi

  if [ $STATUS == "true" ]; then
    NEW_STATUS="false"
  else
    NEW_STATUS="true"
  fi

  # Replace the old status by the new one in the configuration
  sed -i "/routeAllTraffic =/s/$STATUS/$NEW_STATUS/g" ${path}
  # Rebuild and switch the configuration
  nixos-rebuild switch

  if [ $NEW_STATUS == "true" ]; then 
    echo -e "All traffic is now \e[32mrouted\e[39m through the VPN."
  else
    echo -e "All traffic is now \e[31mnot routed\e[39m through the VPN."
  fi
''
