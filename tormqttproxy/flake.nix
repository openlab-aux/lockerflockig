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
    {
      nixosConfigurations.proxy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGnZ9eV387NUKXIs+TSxRjL5bH/bCp2qI7imzTuhjsdh"
          ];
        };
        modules = [
          ./configuration.nix
          disko.nixosModules.disko
          ./proxy.nix
        ];
      };

      deploy.nodes = {
        node1 = {
          hostname = "172.16.0.181";
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.proxy;
            remoteBuild = false;
          };
        };
      };
    };
}
