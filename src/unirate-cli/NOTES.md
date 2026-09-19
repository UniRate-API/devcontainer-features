## OS support

Works on Debian/Ubuntu (`apt`), Alpine (`apk`), and Fedora/RHEL family
(`dnf`/`microdnf`/`yum`) base images, on `linux/amd64` and `linux/arm64`.

## Authentication

The CLI reads its API key from `UNIRATE_API_KEY` (or the `--api-key` flag). Get
a free key at [unirateapi.com](https://unirateapi.com). Add it to your dev
container, for example:

```jsonc
{
    "features": {
        "ghcr.io/unirate-api/devcontainer-features/unirate-cli:1": {}
    },
    "containerEnv": {
        "UNIRATE_API_KEY": "${localEnv:UNIRATE_API_KEY}"
    }
}
```

## Integrity

The binary is downloaded from the official GitHub release and verified against
the release's published SHA-256 `checksums.txt` before installation.
