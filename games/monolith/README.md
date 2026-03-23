# Monolith

Pterodactyl Docker image for Monolith that provides dependency tooling only.

## Included dependencies

- Git
- .NET SDK 9.0.101
- .NET SDK 10.0.100

## Runtime behavior

- Runs as the `container` user in `/home/container`
- Expects `STARTUP` to be provided by your Pterodactyl egg
- Install script is intended to run inside this Monolith yolk container
- Uses the container-provided `git` and `.NET` SDKs for clone/build
- Build is intended to happen on launch by default (`MONOLITH_BUILD_ON_LAUNCH=1`)

## Example startup command

```bash
bash ./install-monolith.sh
```

Put `install-monolith.sh` in your Pterodactyl server files (mounted at `/home/container`) and call it from `STARTUP`.

## Installer variables

- `ROOT_DIR` (default: `/home/container`)
- `MONOLITH_REPO_URL` (default: `https://github.com/Monolith-Station/Monolith.git`)
- `MONOLITH_REF` (default: `main`)
- `MONOLITH_DIR` (default: `${ROOT_DIR}/monolith`)
- `MONOLITH_UPDATE_SUBMODULES` (default: `1`)
- `MONOLITH_RUN_BUILD` (default: `0`, for install phase)
- `MONOLITH_BUILD_ON_LAUNCH` (default: `1`, runs update/build scripts before startup command)
- `MONOLITH_BUILD_CMD` (default: `dotnet build -c Debug`)
- `MONOLITH_BUILD_FALLBACK_CMD` (default: stricter low-memory `dotnet build` retry with debug symbols disabled)