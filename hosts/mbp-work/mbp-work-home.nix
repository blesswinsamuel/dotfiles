{ config, pkgs, pkgsStable, pkgsMaster, lib, osConfig, systemConfig, ... }: {
  home.packages = [
    # pkgsMaster.go
    pkgsMaster.nodejs

    # pkgsMaster.terraform
    pkgsMaster.docker-client
    pkgsMaster.stern
    pkgsMaster.kubectl
    pkgsMaster.kubectx
    pkgsMaster.kubetail
    pkgsMaster.kubernetes-helm
    pkgsMaster.direnv
    pkgsMaster.kcat
    pkgsMaster.redis
    pkgsMaster.gnumake
    pkgsMaster.kapp
    pkgsMaster.k9s

    # 3rd party cloud service tools
    pkgsMaster.awscli2
    pkgsMaster.s3cmd
    pkgsMaster.gh
    pkgsMaster.doctl

    # Network tools
    pkgs.nmap
    pkgs.inetutils
    pkgs.iperf

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
