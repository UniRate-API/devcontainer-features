# UniRate Dev Container Features

[Dev Container Features](https://containers.dev/implementors/features/) maintained
by the [UniRate](https://unirateapi.com) team.

## Features

| Feature | Description |
|---|---|
| [`unirate-cli`](src/unirate-cli) | Installs the [`unirate` CLI](https://github.com/UniRate-API/unirate-cli) — currency exchange rates, conversion, and VAT lookups from the UniRate API. |

## Usage

Reference a feature in your `.devcontainer/devcontainer.json`:

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/unirate-api/devcontainer-features/unirate-cli:1": {}
    }
}
```

Pin a specific CLI version with the `version` option:

```jsonc
{
    "features": {
        "ghcr.io/unirate-api/devcontainer-features/unirate-cli:1": {
            "version": "0.1.0"
        }
    }
}
```

Then, inside the container:

```bash
export UNIRATE_API_KEY="your-api-key"   # free key at https://unirateapi.com
unirate convert 100 USD EUR
unirate rate USD JPY
unirate vat FR
```

## How it installs (supply-chain notes)

`unirate-cli` does **not** pull an npm/pip/other dependency tree. Its
`install.sh`:

1. Downloads the prebuilt, statically-linked release archive for the
   container's OS/arch from the official
   [`UniRate-API/unirate-cli` GitHub releases](https://github.com/UniRate-API/unirate-cli/releases).
2. Downloads that release's `checksums.txt` and **verifies the archive's
   SHA-256 before extracting anything**. A mismatch aborts the install.
3. Installs the single `unirate` binary to `/usr/local/bin`.

The only prerequisites installed (if absent) are `curl`, `tar`, `ca-certificates`,
and a SHA-256 tool, via the base image's own package manager.

## License

MIT — see [LICENSE](LICENSE).
