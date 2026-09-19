#!/bin/sh
#
# Installs the unirate CLI from the official GitHub release, verifying the
# downloaded archive against the release's published SHA-256 checksums before
# installing. No third-party package trees are pulled — only the prebuilt,
# checksum-pinned goreleaser binary.
#
# The 'install.sh' entrypoint script is always executed as the root user.
set -e

CLI_VERSION="${VERSION:-latest}"
REPO="UniRate-API/unirate-cli"
BINARY="unirate"

echo "Activating feature 'unirate-cli' (requested version: ${CLI_VERSION})"

# ---------------------------------------------------------------------------
# Prerequisites: curl (fetch), tar (unpack), a SHA-256 tool (verify), and CA
# certs. Installed via the system package manager only if missing.
# ---------------------------------------------------------------------------
pkg_install() {
    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y
        apt-get install -y --no-install-recommends "$@"
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache "$@"
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y "$@"
    elif command -v microdnf >/dev/null 2>&1; then
        microdnf install -y "$@"
    elif command -v yum >/dev/null 2>&1; then
        yum install -y "$@"
    else
        echo "unirate-cli: no supported package manager found to install: $*" >&2
        return 1
    fi
}

have() { command -v "$1" >/dev/null 2>&1; }

MISSING=""
have curl || MISSING="${MISSING} curl"
have tar  || MISSING="${MISSING} tar"
if ! have sha256sum && ! have shasum; then
    MISSING="${MISSING} coreutils"
fi
if [ -n "${MISSING}" ]; then
    echo "unirate-cli: installing prerequisites:${MISSING}"
    # ca-certificates is needed for the HTTPS download; harmless if already present.
    # shellcheck disable=SC2086
    pkg_install ca-certificates ${MISSING} || pkg_install ${MISSING}
fi

sha256_of() {
    if have sha256sum; then
        sha256sum "$1" | awk '{print $1}'
    else
        shasum -a 256 "$1" | awk '{print $1}'
    fi
}

# ---------------------------------------------------------------------------
# Resolve architecture (dev containers are always Linux).
# ---------------------------------------------------------------------------
uname_arch="$(uname -m)"
case "${uname_arch}" in
    x86_64 | amd64)  ARCH="amd64" ;;
    aarch64 | arm64) ARCH="arm64" ;;
    *)
        echo "unirate-cli: unsupported architecture '${uname_arch}'" >&2
        exit 1
        ;;
esac
OS="linux"

# ---------------------------------------------------------------------------
# Resolve the release tag. For 'latest' we follow the release redirect so we
# can build the versioned archive filename (goreleaser embeds the version).
# ---------------------------------------------------------------------------
if [ "${CLI_VERSION}" = "latest" ]; then
    resolved_url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
        "https://github.com/${REPO}/releases/latest")"
    TAG="${resolved_url##*/}"       # e.g. v0.1.0
    if [ -z "${TAG}" ] || [ "${TAG}" = "latest" ]; then
        echo "unirate-cli: could not resolve the latest release tag" >&2
        exit 1
    fi
else
    # Tolerate a leading 'v' in a user-supplied version.
    TAG="v${CLI_VERSION#v}"
fi
VER_NO_V="${TAG#v}"

BASE="https://github.com/${REPO}/releases/download/${TAG}"
ARCHIVE="${BINARY}_${VER_NO_V}_${OS}_${ARCH}.tar.gz"
ARCHIVE_URL="${BASE}/${ARCHIVE}"
CHECKSUMS_URL="${BASE}/checksums.txt"

echo "unirate-cli: downloading ${ARCHIVE_URL}"

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

curl -fsSL -o "${tmp}/${ARCHIVE}"      "${ARCHIVE_URL}"
curl -fsSL -o "${tmp}/checksums.txt"   "${CHECKSUMS_URL}"

# ---------------------------------------------------------------------------
# Verify the archive against the release's published checksums.
# ---------------------------------------------------------------------------
expected="$(awk -v f="${ARCHIVE}" '$2 == f {print $1}' "${tmp}/checksums.txt")"
if [ -z "${expected}" ]; then
    echo "unirate-cli: no checksum for ${ARCHIVE} in checksums.txt" >&2
    exit 1
fi
actual="$(sha256_of "${tmp}/${ARCHIVE}")"
if [ "${expected}" != "${actual}" ]; then
    echo "unirate-cli: CHECKSUM MISMATCH for ${ARCHIVE}" >&2
    echo "  expected: ${expected}" >&2
    echo "  actual:   ${actual}"   >&2
    exit 1
fi
echo "unirate-cli: checksum verified (${actual})"

# ---------------------------------------------------------------------------
# Install.
# ---------------------------------------------------------------------------
tar -xzf "${tmp}/${ARCHIVE}" -C "${tmp}"
install -m 0755 "${tmp}/${BINARY}" "/usr/local/bin/${BINARY}"

echo "unirate-cli: installed $(/usr/local/bin/${BINARY} version) to /usr/local/bin/${BINARY}"
