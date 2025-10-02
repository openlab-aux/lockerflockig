# how to ...

## ... initial install

* boot from nixos-minimal usb image
* reset password for root user
* run command `nix run github:nix-community/nixos-anywhere -- --flake .#node2 root@172.16.0.144 --build-on-remote --extra-files extrafiles`

## ... full install

* deploy .#node1
