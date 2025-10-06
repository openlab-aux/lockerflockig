{
  description = "A flake for managing thin clients with deploy-rs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs.url = "github:serokell/deploy-rs";
    agenix.url = "github:ryantm/agenix";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      deploy-rs,
      flake-utils,
      agenix,
      disko,
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        pakages = with pkgs; [
          deploy-rs
          nixos-anywhere
        ];
      };

      # nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [
      #     (
      #       {
      #         config,
      #         pkgs,
      #         modulesPath,
      #         ...
      #       }:
      #       {
      #         imports = [
      #           "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      #         ];
      #       }
      #     )

      #     ./installer/configuration.nix
      #   ];
      # };

      nixosConfigurations.audiovideo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          agenix.nixosModules.default
          ./base/configuration.nix
          (
            { ... }:
            {
              networking.hostName = "audiovideo";
            }
          )
          ./modules/audiovideo.nix
        ];
      };

      deploy.nodes.audiovideo = {
        hostname = "audiovideo.lab";
        profiles.system = {
          user = "root";
          sshUser = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.audiovideo;
          remoteBuild = false;
        };
      };
    };
}
