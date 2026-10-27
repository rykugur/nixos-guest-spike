{ dotfiles, modulesPath, lib, pkgs, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/incus-virtual-machine.nix")
    dotfiles.modules.nixos.comin
    dotfiles.modules.nixos.guest-access
  ];

  networking.hostName = "ashyn-nixos";
  networking.useNetworkd = true;
  networking.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 80 ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.max-jobs = 1;
  ryk.comin.url = "https://github.com/rykugur/nixos-guest-spike.git";

  services.openssh.startWhenNeeded = false;
  users.users.root.initialHashedPassword = lib.mkForce "!";
  # Ashyn supplies this guest-local hash; the guest has no decryption keys.
  ryk.guestAccess.passwordFile = "/var/lib/guest-access/password-hash";

  services.nginx.enable = true;
  services.nginx.virtualHosts.default.locations."/".return = ''200 "guest-spike-v2\n"'';
  environment.systemPackages = [ pkgs.curl ];
  system.extraDependencies = [
    (pkgs.runCommand "intentional-comin-recovery-failure" { } ''
      echo "INTENTIONAL_COMIN_RECOVERY_FAILURE" >&2
      exit 1
    '')
  ];
  documentation.enable = lib.mkForce false;
  documentation.nixos.enable = lib.mkForce false;
  system.installer.channel.enable = false;
  system.stateVersion = "26.05";
}
