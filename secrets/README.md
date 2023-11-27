# agenix stuff

I lost the host keys, reencrypt the secrets:

```sh
# on host
cat /etc/ssh/ssh_host_ed25519_key.pub
# set in secrets.nix
# reencrypt
agenix --rekey
```
