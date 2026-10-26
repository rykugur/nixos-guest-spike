{ dotfiles, modulesPath, lib, pkgs, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/incus-virtual-machine.nix")
    dotfiles.modules.nixos.comin
  ];

  networking.hostName = "ashyn-nixos";
  networking.useNetworkd = true;
  networking.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 80 ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.max-jobs = 1;
  ryk.comin.url = "https://github.com/rykugur/nixos-guest-spike.git";

  services.openssh = {
    enable = true;
    startWhenNeeded = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
  users.users.root = {
    initialHashedPassword = lib.mkForce "!";
    openssh.authorizedKeys.keys = import (dotfiles.outPath + "/modules/misc/_dusty-ssh-keys.nix");
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts.default.locations."/".return = ''200 "guest-spike-v1\n"'';
  environment.systemPackages = [ pkgs.curl ];
  documentation.enable = lib.mkForce false;
  documentation.nixos.enable = lib.mkForce false;
  system.installer.channel.enable = false;
  system.stateVersion = "26.05";
}
