# Design Doc

Alright, I've been doing this thing for a while now and it's a giant
mess which in turn makes it a bit of a pain in the backside... Let's
actually design how it should be, thinking it through.

## vpsfree server

This one is very stable, but not particularly powerful. So let's use
it for the things it's good at:

**Mail Server** - it runs, it works without extra fuzz. The IP has good
reputation and I never had problems with it.

**kanidm** - most things require SSO to work. Let's put it on the reliable
server so that I don't have to think too much about bootstrap. SSO just
exists and that's that.

**forgejo** - again, since most things will be dependent on git server,
let's just stick it here as well. Let's use forgejo which (as opposed
to gitlab), does not use too many resources.

**vaultwarden** - I have most password in here. I don't use SSO for this
to mitigate some bootstrap issues (I store kanidm's passkey in bitwarden)

**restic client** - since this is the most critical server, let's make sure
it's backed up properly.

**nginx** - to proxy the various things together. But it only acts as
reverse proxy to local stuff.

How it'll be hosted: nixos for the declarative base and mailserver and
docker (via podman) for everything else. No other service is planned to
be hosted on this server!

Also, this server will have a fully separate flake to avoid the need to
update all the servers in lockstep.

## Hetzner server

This will be more free-flowing server for various services which should
be accessible from the internet.

- planka
- minecraft
- postgres server
- songbook
- listmonk
- outline

## Samoska server

This runs at home, is very powerful and basically free. But it's on home
wifi... Let's run supplemental jobs (forgejo runner), Samoska duties (webui)
and things that can be down (jellyfin).

- samoska
- blocky
- isponsorblocktv
- transmission
- spoolman

## HomeAssistant RPi

If hass doesn't work, we freeze. It has to work. Let's use the most
standard setup for it.
