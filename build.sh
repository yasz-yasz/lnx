#!/bin/bash
set -ex

OS_NAME="${OS_NAME:-CustomLinuxOS}"
DEBIAN_RELEASE="${DEBIAN_RELEASE:-bookworm}"
ARCH="amd64"
MIRROR="http://deb.debian.org/debian/"
SECURITY_MIRROR="http://security.debian.org/debian-security/"

echo "=========================================="
echo " Building $OS_NAME ($DEBIAN_RELEASE - $ARCH)"
echo "=========================================="

# Clean previous build artifacts if any
lb clean --purge || true

# Configure live-build explicitly for Debian on Ubuntu runner
lb config noauto \
  --mode debian \
  --architecture "$ARCH" \
  --distribution "$DEBIAN_RELEASE" \
  --parent-distribution "$DEBIAN_RELEASE" \
  --parent-debian-installer-distribution "$DEBIAN_RELEASE" \
  --mirror-bootstrap "$MIRROR" \
  --mirror-chroot "$MIRROR" \
  --mirror-chroot-security "$SECURITY_MIRROR" \
  --mirror-binary "$MIRROR" \
  --mirror-binary-security "$SECURITY_MIRROR" \
  --keyring-packages debian-archive-keyring \
  --binary-images iso-hybrid \
  --archive-areas "main contrib non-free non-free-firmware" \
  --bootappend-live "boot=live components quiet splash locales=id_ID.UTF-8,en_US.UTF-8" \
  --iso-application "$OS_NAME" \
  --iso-publisher "$OS_NAME Builder" \
  --iso-volume "$OS_NAME Live" \
  --memtest none \
  --debian-installer live \
  --updates true \
  --security true

# Build the ISO
lb build

# Rename output ISO cleanly
if [ -f "live-image-${ARCH}.hybrid.iso" ]; then
    mv "live-image-${ARCH}.hybrid.iso" "${OS_NAME}-${DEBIAN_RELEASE}-${ARCH}.iso"
    echo "SUCCESS: ${OS_NAME}-${DEBIAN_RELEASE}-${ARCH}.iso created!"
else
    echo "ERROR: ISO file was not generated."
    exit 1
fi
