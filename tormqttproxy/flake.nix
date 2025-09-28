{
  description = "tormqttproxy flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    deploy-rs.url = "github:serokell/deploy-rs";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      deploy-rs,
      agenix,
    }:

    let
      createSystem =
        { keys, hostname, mqttBridgeAddress}:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit keys hostname mqttBridgeAddress;
          };
          modules = [
            ./configuration.nix
            disko.nixosModules.disko
            ./proxy.nix
          ];
        };
    in

    {
      nixosConfigurations.proxy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmLNSzV9lFwdDUUPJqlQBYhyyem12zIO93xqD8sdXdW"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/RI14+mEaF3qrQNmwR+8glDijrIPr2Zun/Evs2qnum"
          ];
          hostname = "tormqttproxy";
          mqttBridgeAddress = "";
        };
        modules = [
          ./configuration.nix
          disko.nixosModules.disko
          ./proxy.nix
        ];
      };

      deploy.nodes = {
        node1 = {
          hostname = "172.16.0.144";
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos (createSystem {
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmLNSzV9lFwdDUUPJqlQBYhyyem12zIO93xqD8sdXdW"
              ];
              hostname = "tormqttproxy1";
              mqttBridgeAddress = "dp7oq6xvy44ytpcy5wi2dkpyslwzphcgiv743g5iofwlz6boiygvx2id.onion";
            });
            remoteBuild = false;
          };
        };
        node2 = {
          hostname = "172.16.0.186";
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos (createSystem {
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/RI14+mEaF3qrQNmwR+8glDijrIPr2Zun/Evs2qnum"
              ];
              hostname = "tormqttproxy2";
              mqttBridgeAddress = "mrgrft3vcbcq27lp7cmxhdw2pbu2h4imypijkchgmi2fefk353kd2yqd.onion";
            });
            remoteBuild = false;
          };
        };
      };
    };
}
