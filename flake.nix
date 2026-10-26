{
  description = "Disposable NixOS guest bootstrap and comin deployment spike";

  inputs = {
    dotfiles.url = "github:rykugur/dotfiles/19ce095a4cd857f07e5cbdc347e43e6efca9eb75";
    nixpkgs.follows = "dotfiles/nixpkgs";
  };

  outputs = { dotfiles, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      guest = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit dotfiles; };
        modules = [ ./guest.nix ];
      };
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.ashyn-nixos = guest;
      packages.${system} = {
        metadata = guest.config.system.build.metadata;
        disk = guest.config.system.build.qemuImage;
        default = pkgs.linkFarm "incus-guest-image" [
          { name = "metadata"; path = guest.config.system.build.metadata; }
          { name = "disk"; path = guest.config.system.build.qemuImage; }
        ];
      };
    };
}
