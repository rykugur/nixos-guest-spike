{
  description = "Disposable NixOS guest bootstrap and comin deployment spike";

  inputs = {
    dotfiles.url = "github:rykugur/dotfiles/1df88bb7";
    nixpkgs.follows = "dotfiles/nixpkgs";
  };

  outputs = { dotfiles, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      guest = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit dotfiles; username = "dusty"; };
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
