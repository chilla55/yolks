# Monolith

Pterodactyl Docker image for Monolith that provides dependency tooling only.

## Included dependencies

- Git
- .NET SDK 9.0.101

## Runtime behavior

- Runs as the `container` user in `/home/container`
- Expects `STARTUP` to be provided by your Pterodactyl egg
- Does not clone, build, or update the repository automatically

## Example startup command

```bash
bash ./start-monolith.sh
```

Put your custom clone/build/run logic in `start-monolith.sh` (or any script/command you set in `STARTUP`).