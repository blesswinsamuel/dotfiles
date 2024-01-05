{ config, pkgs, lib, osConfig, systemConfig, ... }: {
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
