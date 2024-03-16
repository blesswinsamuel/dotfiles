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

  home.packages = with pkgs; [
    # Mac tools
    duti
    pngpaste # Paste image files from clipboard to file on MacOS
    mas
    dockutil
    # skhd # Simple hotkey daemon for macOS
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
