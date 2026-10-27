# NixOS guest spike

Disposable Incus VM proving an image bootstrap followed by guest-owned comin deployments. Guest OS configuration lives here; the Incus instance definition lives in [Ashyn](https://github.com/rykugur/ashyn), and reusable modules live in [dotfiles](https://github.com/rykugur/dotfiles).

## Build

```nu
nix build .#packages.x86_64-linux.default --no-link --print-out-paths
nix build .#nixosConfigurations.ashyn-nixos.config.system.build.toplevel --no-link
```

The image output contains `metadata/tarball/nixos.tar.xz` and `disk/nixos.qcow2`, built with Nixpkgs' Incus VM module. It includes DHCP, the Incus agent, public SSH authorization, comin, and a small HTTP demonstration service. It contains no private SSH keys or repository credentials; the guest generates its own identity at boot. SSH password authentication is disabled.

`dotfiles.modules.nixos.guest-access` creates the normal `dusty` user with
shared public SSH keys and passwordless sudo. SSH passwords and keyboard-interactive
authentication are disabled; root SSH is disabled. This imports no Home Manager
client configuration or SOPS module, and grants no ability to decrypt dotfiles secrets.

Ashyn alone decrypts its `guest_user_password_hash` and supplies the guest-local
`/var/lib/guest-access/password-hash` through the Incus agent. It is not baked
into the image or stored in this repo. The account has no usable console password
until that file is supplied; SSH keys still work. The console password does not
enable SSH password authentication. Persist the file when adding guest impermanence.

## Deployment ownership

Ashyn pins this flake as `guestSpike`. Its local Incus module consumes this image package through the instance's `imagePackage` option, imports the pinned artifacts, then creates and starts the missing `ashyn-nixos` VM. No per-guest import service, manual image import, VM launch, installer, or guest setup command is part of provisioning.

Once running, the guest polls this repository's `master` with comin. Edit `guest.nix`, build the toplevel, then commit and push here to update the existing guest. No host change or image rebuild is needed for an ordinary guest deployment. Do not run a competing manual switch.

To select a newer bootstrap image for future creation, update Ashyn's `guestSpike` input and build/deploy the host. This does not reinstall an existing guest or replace its disk. The bootstrap pin and the guest's tracking branch deliberately have different roles.

This guest uses a persistent ext4 root, not guest-level impermanence. Ashyn's host root rollback must preserve the entire Incus database and guest disks. Private workload repos would require a separate per-guest credential bootstrap; this public spike does not test that.

The controlled comin recovery test uses an intentional failing derivation,
then removes it and changes the HTTP response to `guest-spike-v3-recovered`.
The failed build must leave the previous system and service running; the
corrective push must deploy without a reboot or lost guest data. Historical
test commits include the deliberate failure; do not select that revision as
a bootstrap pin. Detailed observed results are recorded in Arcanum.

Durable decisions and observed acceptance results live in Arcanum: `wiki/Projects/Ashyn/Ashyn.md` and `log/2026-10.md`.
