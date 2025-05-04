{
  nixUser = builtins.trace "NIX_USER: sam" "sam";
  nixUserEmail = builtins.trace "NIX_USER: sam@lemail.com" "sam@email.com";
  rootFlakePath = builtins.trace "ROOT_FLAKE_PATH: /home/sam/nixos-configuration" "/home/sam/nixos-configuration";
  tcpPorts = builtins.trace "TCP_PORTS: []" [];
  udpPorts = builtins.trace "UDP_PORTS: []" [];
  hostName = builtins.trace "HOST_NAME: NixOS" "NixOS";
  hosts = builtins.trace "HOSTS:"
      ''
      '';
}
