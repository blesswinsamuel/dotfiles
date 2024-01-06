{ config, pkgs, lib, osConfig, systemConfig, ... }: { 
  home.homeDirectory = "/home/${systemConfig.username}";
}
