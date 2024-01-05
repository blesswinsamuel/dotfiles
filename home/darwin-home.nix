{ config, pkgs, lib, osConfig, systemConfig, ... }: {
  # https://github.com/NixOS/nixpkgs/issues/240819
  # Connects gpg-agent to the OSX keychain via the brew-installed
  # pinentry program from GPGtools. This is the OSX 'magic sauce',
  # allowing the gpg key's passphrase to be stored in the login
  # keychain, enabling automatic key signing.
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '';

  home.file = {
    "Library/Application Support/Sublime Text 3/Packages/User/Package Control.sublime-settings" = {
      enable = true;
      source = ./Sublime-Text/${"Package Control.sublime-settings"};
    };
    "Library/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings" = {
      enable = true;
      source = ./sublime-text/Preferences.sublime-settings;
    };
  };
}
