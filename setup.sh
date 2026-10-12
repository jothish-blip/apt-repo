#!/usr/bin/env bash
# Felix Security Auditor - Automated APT Repository Setup Script
# Supported Platforms: Kali Linux, Debian 11/12/testing/unstable, Ubuntu 20.04/22.04/24.04
set -euo pipefail

echo "==========================================================="
echo " FELIX :: Kali Linux / Debian APT Setup"
echo "==========================================================="

if [ "$(id -u)" -ne 0 ]; then
    echo "[-] Error: This script must be run as root (or with sudo)." >&2
    exit 1
fi

# Ensure curl is available
if ! command -v curl >/dev/null 2>&1; then
    echo "[*] Installing curl..."
    apt-get update -qq && apt-get install -y -qq curl
fi

# Pre-flight: Remediate any legacy 0-byte or corrupt shadowing files in precedence paths
for shadow_bin in /usr/local/bin/felix /usr/local/sbin/felix; do
    if [ -L "${shadow_bin}" ] && [ ! -e "${shadow_bin}" ]; then
        echo "[i] Cleaning up broken symlink at ${shadow_bin}..."
        rm -f "${shadow_bin}"
    elif [ -f "${shadow_bin}" ] && [ ! -s "${shadow_bin}" ]; then
        echo "[i] Cleaning up legacy 0-byte file at ${shadow_bin}..."
        rm -f "${shadow_bin}"
    elif [ -f "${shadow_bin}" ] && grep -qi "<html>\|<head>\|404: Not Found" "${shadow_bin}" 2>/dev/null; then
        echo "[i] Cleaning up corrupt HTML download at ${shadow_bin}..."
        rm -f "${shadow_bin}"
    fi
done

KEYRING_DIR="/etc/apt/keyrings"
KEYRING_PATH="${KEYRING_DIR}/felix-archive-keyring.gpg"
SOURCES_PATH="/etc/apt/sources.list.d/felix.list"
REPO_URL="https://jothish-blip.github.io/apt-repo"

mkdir -p "${KEYRING_DIR}"
chmod 0755 "${KEYRING_DIR}"

echo "[*] Installing Felix repository signing key..."
curl -fsSL "${REPO_URL}/felix-archive-keyring.gpg" -o "${KEYRING_PATH}"
chmod 0644 "${KEYRING_PATH}"

ARCH="$(dpkg --print-architecture 2>/dev/null || echo amd64)"
echo "[*] Configuring APT source list (${SOURCES_PATH}) for ${ARCH}..."
cat <<EOF > "${SOURCES_PATH}"
deb [signed-by=${KEYRING_PATH} arch=${ARCH}] ${REPO_URL} stable main
EOF
chmod 0644 "${SOURCES_PATH}"

echo "[*] Updating APT package cache..."
apt-get update -o Dir::Etc::sourcelist="sources.list.d/felix.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" -qq || apt-get update -qq

echo ""
echo "==========================================================="
echo "[✓] Felix APT repository configured successfully!"
echo "==========================================================="
echo ""
echo "You can now install Felix by running:"
echo "  sudo apt update"
echo "  sudo apt install felix"
echo ""
echo "Then verify the installation:"
echo "  felix --version"
echo "  felix doctor"
echo ""
