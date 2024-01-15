{ config, pkgs, pkgsStable, lib, osConfig, systemConfig, ... }: {
  home.packages = [
    pkgs.aws-iam-authenticator
    # pkgs.code-server
    # pkgs.openvscode-server
  ];
}
