{ lib, ... }: {
  # Personal Linux shared settings (beyond commons-linux).
  services.tailscale.enable = true;

  # Tailscale uses UDP 41641 for direct connections when possible.
  networking.firewall.allowedUDPPorts = lib.mkDefault [ 41641 ];
}
