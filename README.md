# ISOs bauen
nix-build '<nixpkgs/nixos>' -A config.system.build.images.iso -I nixos-config=isos/taler.nix
