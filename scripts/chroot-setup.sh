#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export LC_ALL=C

echo "lnx-by-yas" > /etc/hostname

cat << 'EOF' > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu/ noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
EOF

apt-get update
apt-get install -y --no-install-recommends \
  linux-generic casper systemd-sysv os-prober \
  network-manager sudo locales curl wget git ca-certificates dbus-x11 \
  xorg xserver-xorg xserver-xorg-video-all \
  xfce4 xfce4-whiskermenu-plugin xfce4-notifyd xfce4-pulseaudio-plugin \
  xfce4-terminal thunar-archive-plugin file-roller \
  lightdm lightdm-gtk-greeter \
  pipewire pipewire-pulse wireplumber \
  fonts-noto-core fonts-inter \
  snapd flatpak gnome-software gnome-software-plugin-flatpak gnome-software-plugin-snap \
  gtk2-engines-murrine sassc

# Konfigurasi Locale
locale-gen en_US.UTF-8 id_ID.UTF-8

# Konfigurasi Flatpak (Flathub)
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Aktifkan service utama termasuk Snapd
systemctl enable NetworkManager || true
systemctl enable lightdm || true
systemctl enable snapd.socket || true
systemctl enable snapd.service || true

# Pasang Tema Windows 11 (Fluent GTK + Win11 Icon Theme)
git clone --depth=1 https://github.com/vinceliuice/Fluent-gtk-theme.git /tmp/Fluent-gtk-theme
/tmp/Fluent-gtk-theme/install.sh -d /usr/share/themes -t default -c dark -s compact --tweaks round
/tmp/Fluent-gtk-theme/install.sh -d /usr/share/themes -t default -c light -s compact --tweaks round

git clone --depth=1 https://github.com/yeyushengfan258/Win11-icon-theme.git /tmp/Win11-icon-theme
/tmp/Win11-icon-theme/install.sh -d /usr/share/icons

# Instalasi & Konfigurasi Installer Calamares
apt-get install -y \
  calamares grub2-common \
  grub-pc-bin grub-efi-amd64-bin grub-efi-amd64-signed shim-signed \
  efibootmgr dosfstools btrfs-progs ntfs-3g mtools

mkdir -p /etc/calamares/modules /etc/calamares/branding/lnx-by-yas
cp /tmp/calamares/settings.conf /etc/calamares/settings.conf
cp /tmp/calamares/modules/*.conf /etc/calamares/modules/
cp /tmp/calamares/branding/lnx-by-yas/* /etc/calamares/branding/lnx-by-yas/

LOGO_SRC="$(find /usr/share/icons/Win11* -name 'distributor-logo*.svg' -o -name 'computer.svg' | head -n 1 || true)"
if [ -n "${LOGO_SRC}" ]; then
  cp "${LOGO_SRC}" /etc/calamares/branding/lnx-by-yas/logo.svg
else
  cat << 'SVG' > /etc/calamares/branding/lnx-by-yas/logo.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">
  <rect width="128" height="128" rx="24" fill="#0078d4"/>
  <text x="64" y="78" font-size="42" font-family="sans-serif" font-weight="bold" fill="#ffffff" text-anchor="middle">LNX</text>
</svg>
SVG
fi

install -m 755 /tmp/calamares/install-lnx-by-yas.desktop /usr/share/applications/install-lnx-by-yas.desktop
mkdir -p /etc/skel/Desktop
install -m 755 /tmp/calamares/install-lnx-by-yas.desktop /etc/skel/Desktop/install-lnx-by-yas.desktop

# Izin sudo tanpa password khusus Live Mode (otomatis dihapus pasca-instalasi)
echo "yas ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-live-nopasswd
chmod 440 /etc/sudoers.d/99-live-nopasswd

# Pasang script tata letak desktop Windows 11 saat login pertama
install -m 755 /tmp/win11-layout.sh /usr/local/bin/lnx-win11-layout.sh
mkdir -p /etc/xdg/autostart
cat << 'EOF' > /etc/xdg/autostart/lnx-win11-layout.desktop
[Desktop Entry]
Type=Application
Name=LNX by YAS Win11 Layout
Exec=/usr/local/bin/lnx-win11-layout.sh
OnlyShowIn=XFCE;
X-GNOME-Autostart-enabled=true
EOF

# Branding LNX by YAS
cat << 'EOF' > /etc/os-release
PRETTY_NAME="LNX by YAS 1.0 (Win11 Minimal)"
NAME="LNX by YAS"
VERSION_ID="1.0"
VERSION="1.0"
ID=lnxbyyas
ID_LIKE=ubuntu
HOME_URL="https://github.com/yasz-yasz/lnx"
EOF

cat << 'EOF' > /etc/lsb-release
DISTRIB_ID="LNX by YAS"
DISTRIB_RELEASE=1.0
DISTRIB_CODENAME=noble
DISTRIB_DESCRIPTION="LNX by YAS 1.0"
EOF

# Konfigurasi User Live (Casper)
cat << 'EOF' > /etc/casper.conf
export USERNAME="yas"
export USERFULLNAME="LNX by YAS User"
export HOST="lnx-by-yas"
export BUILD_SYSTEM="Ubuntu"
EOF

# Konfigurasi LightDM Greeter & Auto-Login Live Mode
cat << 'EOF' > /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
theme-name=Fluent-Dark-compact
icon-theme-name=Win11-dark
font-name=Inter 10
EOF

mkdir -p /etc/lightdm/lightdm.conf.d
cat << 'EOF' > /etc/lightdm/lightdm.conf.d/50-autologin.conf
[Seat:*]
autologin-user=yas
autologin-user-timeout=0
user-session=xfce
EOF

update-initramfs -u

# Bersihkan sisa cache
rm -rf /tmp/Fluent-gtk-theme /tmp/Win11-icon-theme /tmp/calamares /tmp/chroot-setup.sh /tmp/win11-layout.sh
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
