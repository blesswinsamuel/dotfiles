{ config, pkgs, pkgsStable, pkgsMaster, lib, osConfig, systemConfig, ... }: {
  home.packages = [
    pkgsMaster.go
    pkgsMaster.nodejs

    # pkgsMaster.terraform
    pkgsMaster.stern
    pkgsMaster.kubectl
    pkgsMaster.direnv
    pkgsMaster.kcat
    pkgsMaster.redis
    pkgsMaster.gnumake

    # 3rd party cloud service tools
    pkgsMaster.awscli2
    pkgsMaster.s3cmd
    pkgsMaster.gh
    pkgsMaster.doctl

    # pkgs.aws-iam-authenticator
    # pkgs.code-server
    # pkgs.openvscode-server
  ];

  # programs.fish = {
  #   enable = true;
  #   functions = {
  #     fish_greeting = "";
  #   };
  #   interactiveShellInit = (builtins.readFile ./fish/env_vars.fish) + "\n" + (builtins.readFile ./fish/aliases.fish) + "\n" + (builtins.readFile ./fish/config.fish);
  # };
}
