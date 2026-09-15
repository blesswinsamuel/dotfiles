{ pkgsUnstable, ... }: {
  # Shared GUI / desktop packages for personal NixOS workstations.
  programs.firefox.enable = true;
  programs.firefox.package = pkgsUnstable.firefox;
  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;
  programs.chromium.enablePlasmaBrowserIntegration = true;
  programs._1password.enable = true;
  programs._1password.package = pkgsUnstable._1password-cli;
  programs._1password-gui.enable = true;
  programs._1password-gui.package = pkgsUnstable._1password-gui;
  security.polkit.enable = true;
}
