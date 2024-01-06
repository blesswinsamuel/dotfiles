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

    # "bin/code".source = config.lib.file.mkOutOfStoreSymlink "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code";
    # "bin/code-tunnel".source = config.lib.file.mkOutOfStoreSymlink "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code-tunnel";
    # "bin/subl".source = config.lib.file.mkOutOfStoreSymlink "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl";
    # "bin/idea".source = config.lib.file.mkOutOfStoreSymlink "/Applications/IntelliJ IDEA.app/Contents/MacOS/idea";
    # "bin/fork".source = config.lib.file.mkOutOfStoreSymlink "/Applications/Fork.app/Contents/Resources/fork_cli";
    # "bin/github".source = config.lib.file.mkOutOfStoreSymlink "/Applications/GitHub Desktop.app/Contents/Resources/app/static/github.sh";
    # "bin/hexf".source = config.lib.file.mkOutOfStoreSymlink "/Applications/Hex Fiend.app/Contents/Resources/hexf";
    # "bin/iina".source = config.lib.file.mkOutOfStoreSymlink "/Applications/IINA.app/Contents/MacOS/iina-cli";
    # "bin/inkscape".source = config.lib.file.mkOutOfStoreSymlink "/opt/homebrew/Caskroom/inkscape/1.2.2/inkscape.wrapper.sh";
  };
}
