# Monolith

Pterodactyl Docker image for Monolith that provides dependency tooling only.

## Included dependencies

- Git
- .NET SDK 9.0.101

## Runtime behavior

- Runs as the `container` user in `/home/container`
- Expects `STARTUP` to be provided by your Pterodactyl egg
- Expects your install/start script to live in the server files volume
- Does not clone, build, or update the repository automatically unless your external script does it

## Example startup command

```bash
bash ./install-monolith.sh
```

Put `install-monolith.sh` in your Pterodactyl server files (mounted at `/home/container`) and call it from `STARTUP`.