{
  nixUser = builtins.trace "NIX_USER: sam" "sam";
  nixUserEmail = builtins.trace "NIX_USER_EMAIL: sam@lemail.com" "sam@email.com";
  nixWorkUser = builtins.trace "NIX_WORK_USER: sam_work" "sam_work";
  nixWorkUserEmail = builtins.trace "NIX_WORK_USER_EMAIL: sam@lworkemail.com" "sam@eworkmail.com";
  rootFlakePath = builtins.trace "ROOT_FLAKE_PATH: /home/sam/nixos-configuration" "/home/sam/nixos-configuration";
  tcpPorts = builtins.trace "TCP_PORTS: []" [];
  udpPorts = builtins.trace "UDP_PORTS: []" [];
  hostName = builtins.trace "HOST_NAME: NixOS" "NixOS";
  hosts = builtins.trace "HOSTS:"
      ''
      '';
  ovpn_switzerland_path = builtins.trace "OVN_SWITZERLAND_PATH: not set" "";
}
