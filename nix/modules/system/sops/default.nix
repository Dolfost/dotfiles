# Secrets. Values live encrypted in nix/secrets.yaml (safe to publish) and are
# decrypted into /run/secrets at activation. Each host decrypts with its ssh
# host key, so a machine that can boot can read its secrets - nothing to
# distribute. Editing needs the admin key in ~/.config/sops/age/keys.txt (NOT
# in this repo - keep a copy somewhere safe, without it the secrets are
# uneditable once the hosts are gone).
#
#   edit:          sops nix/secrets.yaml
#   new machine:   ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
#                  -> add to .sops.yaml, run: sops updatekeys nix/secrets.yaml
{ ... }:

{
	sops.defaultSopsFile = ../../../secrets.yaml;
	sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
