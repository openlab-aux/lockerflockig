# how to ...

## ... initial install

* boot from nixos-minimal usb image
* reset password for root user
* run command `nix run github:nix-community/nixos-anywhere -- --flake .#proxy root@172.16.0.181 --build-on-remote`

## ... full install

* deploy .#node1