{
  description = "Thinclient Audio configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      deploy-rs,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.deploy-rs
          ];
        };
      }
    )
    // {
      nixosConfigurations = {
        hauptraum = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            ./hosts/hauptraum/configuration.nix
            ./modules/essentials.nix
            ./modules/pipewire.nix
            ./modules/spotifyd.nix
            ./modules/shairport.nix
            ./modules/sendspin-client.nix
          ];

          extraArgs = {
            # set the room name for this machine
            roomName = "central-hack-haven";
          };
        };
      };

      deploy.nodes = {
        hauptraum = {
          hostname = "central-hack-haven-audio.lab";
          sshUser = "root";
          remoteBuild = true;

          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.hauptraum;
          };
        };
      };
    };
}
