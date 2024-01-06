{ config, pkgs, lib, osConfig, systemConfig, ... }: {
  home.homeDirectory = "/Users/${systemConfig.username}";

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

  home.packages = with pkgs; [
    # Mac tools
    duti
    pngpaste # Paste image files from clipboard to file on MacOS
    mas
  ];

  programs.fish = {
    # fix path variable order - https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
    # https://d12frosted.io/posts/2021-05-21-path-in-fish-with-nix-darwin.html
    loginShellInit =
      let
        # This naive quoting is good enough in this case. There shouldn't be any
        # double quotes in the input string, and it needs to be double quoted in case
        # it contains a space (which is unlikely!)
        dquote = str: "\"" + str + "\"";

        makeBinPathList = map (path: path + "/bin");
      in
      ''
        fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList osConfig.environment.profiles)}
        set fish_user_paths $fish_user_paths
      '';
  };
}
