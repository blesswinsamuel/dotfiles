{
  self,
  pkgsUnstable,
  pkgsStable,
  pkgsMaster,
  lib,
  config,
  secrets,
  systemConfig,
  ...
}:
{
  ids.gids.nixbld = 30000;
  users.users.${systemConfig.username}.packages = [
    # pkgsMaster.terraform
    # pkgsMaster.docker-client
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
    pkgsMaster.tilt

    pkgsMaster.graphviz

    # 3rd party cloud service tools
    pkgsMaster.awscli2
    pkgsMaster.s3cmd
    pkgsMaster.doctl

    pkgsMaster.libllvm
    pkgsMaster.rsync

    # pkgs.aws-iam-authenticator
    # pkgs.code-server
    # pkgs.openvscode-server

    # pkgsUnstable.darwin.apple_sdk.frameworks.Security
  ]; # ++ (builtins.attrValues pkgsUnstable.darwin.apple_sdk.frameworks);

  environment.variables = {
    CTHULHU_DIR = "$HOME/dev/digitalocean/cthulhu";
    DEV_TARGET_ARCH = "arm64";
    OP_SSH_KEY_REF = "op://Private/Work SSH Key/private key";
  };
}
