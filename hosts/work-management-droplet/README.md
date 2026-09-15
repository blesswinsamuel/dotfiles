# work-management-droplet

Ubuntu work management droplet. **Not NixOS** — NixOS cannot be installed on this host.

## Bootstrap

1. Set the logical host id (once):

   ```bash
   mkdir -p ~/.config/dotfiles
   echo work-management-droplet > ~/.config/dotfiles/host-id
   ```

2. Install mise and the 1Password CLI (`op`). Sign in to the **work** 1Password account.

3. From a clone of this repo:

   ```bash
   task secrets:unlock   # once; caches decrypt under ~/.config/dotfiles/secrets.yaml
   task run-home
   ```

   Do **not** run `task switch` / `nixos-rebuild` here. Later `task run-home` uses the cache and does not need `op` until you refresh with `task secrets:unlock`.

## Layers applied by the home tool

`commons` → `commons-linux` → `work` → `work-linux` → `hosts.work-management-droplet`
