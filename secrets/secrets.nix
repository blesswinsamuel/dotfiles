let
  # ssh-keygen -t ed25519
  # cat ~/.ssh/id_ed25519.pub
  blesswinsamuel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5qmX429IPSo2TsFywtCr9w7kprutEYCBS1c291jZv";
  blesswinsamuel-work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9lSrVQh4xEX8s/gmBps9Zg3UpGeQZ84uLdGzANPXaa";
  users = [ blesswinsamuel blesswinsamuel-work ];

  # cat /etc/ssh/ssh_host_ed25519_key.pub
  mac-studio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDiltQTf88+ROU/nWjsIaSe4pyumcV0hRykF0ds/vL5V";
  mbp-work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICihRKcpKUKVmhPtwIvjP6TodfszpM+IMQ1MSE5oMkB9";
  systems = [ mac-studio mbp-work ];
in
{
  "config.json.age".publicKeys = users ++ systems;
  "personalEmail.age".publicKeys = [ blesswinsamuel mac-studio ];
  "workEmail.age".publicKeys = [ blesswinsamuel-work mbp-work ];
}

# nix run github:ryantm/agenix -- -e personalEmail.age
