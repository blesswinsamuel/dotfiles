{ config, pkgs, lib, osConfig, systemConfig, ... }: {
  home.homeDirectory = "/Users/${systemConfig.username}";

  # # https://github.com/NixOS/nixpkgs/issues/240819
  # # Connects gpg-agent to the OSX keychain via the brew-installed
  # # pinentry program from GPGtools. This is the OSX 'magic sauce',
  # # allowing the gpg key's passphrase to be stored in the login
  # # keychain, enabling automatic key signing.
  # home.file.".gnupg/gpg-agent.conf".text = ''
  #   pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  # '';
}
