#!/usr/bin/env bash
set -euo pipefail

DISTRO_NAME="LNX-by-YAS"
DISTRO_VERSION="${DISTRO_VERSION:-1.0}"
UBUNTU_RELEASE="noble"
ROOT_DIR="$(pwd)"
WORK_DIR="${ROOT_DIR}/work"
CHROOT_DIR="${WORK_DIR}/chroot"
ISO_DIR="${WORK_DIR}/iso"
ISO_OUTPUT="${ROOT_DIR}/${DISTRO_NAME}-${DISTRO_VERSION}-amd64.iso"

cleanup() {
  echo "[*] Membersihkan mount chroot..."
  for m in dev/pts dev proc sys run; do
    if mountpoint -q "${CHROOT_DIR}/${m}"; then
      umount -lf "${CHROOT_DIR}/${m}" || true
    fi
  done
}
trap cleanup EXIT

echo "[1/6] Menginstal dependensi build host..."
apt-get update
apt-get install -y \
  debootstrap squashfs-tools xorriso \
  grub-pc-bin grub-efi-amd64-bin mtools dosfstools

echo "[2/6] Membangun base system Ubuntu ${UBUNTU_RELEASE}..."
mkdir -p "${CHROOT_DIR}" "${ISO_DIR}/casper" "${ISO_DIR}/boot/grub" "${ISO_DIR}/.disk"
debootstrap --arch=amd64 "${UBUNTU_RELEASE}" "${CHROOT_DIR}" http://archive.ubuntu.com/ubuntu/

echo "[3/6] Menyiapkan lingkungan chroot..."
cp "${ROOT_DIR}/scripts/chroot-setup.sh" "${CHROOT_DIR}/tmp/chroot-setup.sh"
cp "${ROOT_DIR}/config/win11-layout.sh" "${CHROOT_DIR}/tmp/win11-layout.sh"
cp -r "${ROOT_DIR}/config/calamares" "${CHROOT_DIR}/tmp/calamares"

mount --bind /dev "${CHROOT_DIR}/dev"
mount --bind /dev/pts "${CHROOT_DIR}/dev/pts"
mount -t proc proc "${CHROOT_DIR}/proc"
mount -t sysfs sysfs "${CHROOT_DIR}/sys"
mount -t tmpfs tmpfs "${CHROOT_DIR}/run"

# Hapus symlink bawaan dan set DNS publik setelah /run dimount
rm -f "${CHROOT_DIR}/etc/resolv.conf"
cat << 'EOF' > "${CHROOT_DIR}/etc/resolv.conf"
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

echo "[4/6] Menjalankan konfigurasi distro di dalam chroot..."
chroot "${CHROOT_DIR}" /bin/bash /tmp/chroot-setup.sh

cleanup
trap - EXIT

echo "[5/6] Menyalin kernel, initrd, dan membuat SquashFS..."
VMLINUZ_FILE="$(ls -1 "${CHROOT_DIR}"/boot/vmlinuz-* | sort -V | tail -n 1)"
INITRD_FILE="$(ls -1 "${CHROOT_DIR}"/boot/initrd.img-* | sort -V | tail -n 1)"
cp "${VMLINUZ_FILE}" "${ISO_DIR}/casper/vmlinuz"
cp "${INITRD_FILE}" "${ISO_DIR}/casper/initrd"

chroot "${CHROOT_DIR}" dpkg-query -W --showformat='${Package} ${Version}\n' > "${ISO_DIR}/casper/filesystem.manifest"
printf "%s" "$(du -sx --block-size=1 "${CHROOT_DIR}" | cut -f1)" > "${ISO_DIR}/casper/filesystem.size"

mksquashfs "${CHROOT_DIR}" "${ISO_DIR}/casper/filesystem.squashfs" \
  -comp zstd -Xcompression-level 12

echo "[6/6] Membuat ISO Hybrid (BIOS + UEFI)..."
cp "${ROOT_DIR}/config/grub.cfg" "${ISO_DIR}/boot/grub/grub.cfg"
echo "LNX by YAS ${DISTRO_VERSION} (Ubuntu 24.04 Minimal - Puppy RAM Mode)" > "${ISO_DIR}/.disk/info"

grub-mkrescue -o "${ISO_OUTPUT}" "${ISO_DIR}" -- -volid "LNX_BY_YAS"
echo "[SELESAI] ISO berhasil dibuat: ${ISO_OUTPUT}"
