# Custom Linux OS Builder (Debian Live-Build + GitHub Actions)

Repository siap pakai untuk merakit distribusi Linux kustom berbasis **Debian** lengkap dengan desktop **XFCE** dan installer **Calamares**, yang otomatis dikompilasi menjadi file `.iso` melalui **GitHub Actions**.

## Struktur Repository
- `.github/workflows/build-iso.yml` — Workflow otomatis untuk membangun file `.iso` di server GitHub.
- `build.sh` — Skrip utama konfigurasi `live-build`.
- `config/package-lists/custom.list.chroot` — Daftar aplikasi & paket sistem yang akan di-install ke dalam OS.
- `config/hooks/live/01-customize.hook.chroot` — Skrip kustomisasi branding (`/etc/os-release`) dan konfigurasi layanan sistem.
- `config/includes.chroot/` — File tambahan yang disalin langsung ke sistem file root (`/`) OS hasil build.

## Cara Menggunakan
1. Buat repository baru di GitHub.
2. Ekstrak file ZIP ini dan upload seluruh isinya ke repository GitHub tersebut.
3. Buka tab **Actions** pada repository GitHub kamu, pilih **Build Custom Linux ISO**, lalu klik **Run workflow** (atau otomatis berjalan saat `git push`).
4. Setelah proses build selesai (~15–25 menit), unduh file `.iso` dari bagian **Artifacts** atau **Releases**.
5. Uji file `.iso` menggunakan VirtualBox, QEMU, atau buat bootable USB dengan Rufus / Ventoy.

## Kustomisasi
- **Menambah/Menghapus Aplikasi:** Edit `config/package-lists/custom.list.chroot`.
- **Menambah Wallpaper/File Bawaan:** Masukkan file ke dalam `config/includes.chroot/etc/skel/` agar otomatis muncul di folder home pengguna.
