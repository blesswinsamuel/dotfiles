# work-management-droplet

Ubuntu work management droplet. **Not NixOS** — NixOS cannot be installed on this host.

## Bootstrap

1. Set the logical host id (once):

   ```bash
   mkdir -p ~/.config/dotfiles
   echo work-management-droplet > ~/.config/dotfiles/host-id
   ```

2. Install mise (and optionally the Determinate Nix installer for ad-hoc `nix run` only — no flake rebuild on this host).

3. From a clone of this repo:

   ```bash
   task run-home
   ```

   Do **not** run `task switch` / `nixos-rebuild` here.

## Layers applied by the home tool

`commons` → `commons-linux` → `work` → `work-linux` → `hosts.work-management-droplet`
