# https://serverfault.com/questions/973654/using-ssh-keys-with-multiple-computers
let
  # ssh-keygen -t ed25519
  # cat ~/.ssh/id_ed25519.pub
  blesswinsamuel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5qmX429IPSo2TsFywtCr9w7kprutEYCBS1c291jZv";
  blesswinsamuel-work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9lSrVQh4xEX8s/gmBps9Zg3UpGeQZ84uLdGzANPXaa";
  blesswinsamuel-hp-chromebox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILmlOAdQKZyJX+UG2BnysMK/oCEWqjGVd4Gu7ZY3pH9r";
  users = [ blesswinsamuel blesswinsamuel-work blesswinsamuel-hp-chromebox ];

  # cat /etc/ssh/ssh_host_ed25519_key.pub
  mac-studio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDiltQTf88+ROU/nWjsIaSe4pyumcV0hRykF0ds/vL5V";
  mbp-work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICihRKcpKUKVmhPtwIvjP6TodfszpM+IMQ1MSE5oMkB9";
  hp-chromebox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKE78dcvVrNedROJbOjEaMDBhkr4Gaa+Uo6Z/48zK7QR";
  systems = [ mac-studio mbp-work hp-chromebox ];
in
{
  "config.json.age".publicKeys = users ++ systems;
  "personalEmail.age".publicKeys = [ blesswinsamuel mac-studio ];
  "workEmail.age".publicKeys = [ blesswinsamuel-work mbp-work ];
}

# nix run github:ryantm/agenix -- -e personalEmail.age
