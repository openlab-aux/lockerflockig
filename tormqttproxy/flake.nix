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
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      deploy-rs,
      agenix,
      flake-utils,
    }:

    let
      system = "x86_64-linux";
      createSystem =
        {
          keys,
          hostname,
          mqttBridgeAddress,

        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              keys
              hostname
              mqttBridgeAddress
              ;
            pythonPackages = self.packages."${system}";
          };
          modules = [
            ./configuration.nix
            disko.nixosModules.disko
            ./proxy.nix
            agenix.nixosModules.default
          ];
        };

      pkgs = import nixpkgs { inherit system; };
      python3 = pkgs.python3.override {
        packageOverrides = final: prev: {
          meshcore = final.callPackage ./meshcore.nix { };
          mqttproxy = final.callPackage ./mqttproxy.nix {
            meshcore = final.meshcore;
          };
        };
      };
    in
    {
      packages."${system}" = {
        inherit python3;
        python3-meshcore = (python3.withPackages (ps: with ps; [ ps.meshcore ]));
        python3-mqttproxy = (python3.withPackages (ps: with ps; [ ps.mqttproxy ]));
      };
      nixosConfigurations.node1 = createSystem {
        keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEPATG9D1L1UtuZwhxWkhCFIDLwTfPxyMsB30JxT/5bV" ];
        hostname = "tormqttproxy1";
        mqttBridgeAddress = "rgpqo6a5pmmpvjl3nj6jbc4kd64eqijcx4m62sfexg7hsx6gmeaisbyd.onion";
      };

      nixosConfigurations.node2 = createSystem {
        keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmLNSzV9lFwdDUUPJqlQBYhyyem12zIO93xqD8sdXdW" ];
        hostname = "tormqttproxy2";
        mqttBridgeAddress = "tkzmr3x2ir2prx6hw7oigw2o73gdvjdvlmtoqqalttbg3gugn7ei35yd.onion";
      };

      deploy.nodes = {
        node1 = {
          hostname = "172.16.0.186";
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.node1;
            remoteBuild = false;
          };
        };
        node2 = {
          hostname = "172.16.0.144";
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.node2;
            remoteBuild = false;
          };
        };
      };
    };
}
