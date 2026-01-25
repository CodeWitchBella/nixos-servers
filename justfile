# https://just.systems

deploy:
    deploy '.#hetzner'

deploy-remotebuild:
    deploy '.#hetzner' --remote-build

generate-hashes:
    nix run '.#generate-hashes'

inspect-hashes:
    nix run '.#inspect-hashes'
