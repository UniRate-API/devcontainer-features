
# UniRate CLI (unirate-cli)

Installs the unirate CLI — currency exchange rates, conversion, and VAT lookups from the UniRate API. A single zero-dependency static Go binary, downloaded from the official GitHub release and verified against the published SHA-256 checksums.

## Example Usage

```json
"features": {
    "ghcr.io/UniRate-API/devcontainer-features/unirate-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of the unirate CLI to install: a release tag such as '0.1.0', or 'latest'. | string | latest |

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/UniRate-API/devcontainer-features/blob/main/src/unirate-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
