# Tatap

Pemutar anime mandiri multi-platform (Android, Windows, Linux, Web) yang ringan, bebas iklan, tanpa registrasi akun, dan menjaga privasi data di penyimpanan lokal.

[![Release](https://img.shields.io/github/v/release/asfaraguest/tatap?style=flat-square&color=00f0ff)](https://github.com/asfaraguest/tatap/releases)
[![Stars](https://img.shields.io/github/stars/asfaraguest/tatap?style=flat-square&logo=github&color=e3b341)](https://github.com/asfaraguest/tatap/stargazers)
[![Forks](https://img.shields.io/github/forks/asfaraguest/tatap?style=flat-square&logo=github&color=58a6ff)](https://github.com/asfaraguest/tatap/network/members)
[![Downloads](https://img.shields.io/github/downloads/asfaraguest/tatap/total?style=flat-square&logo=github&color=3fb950)](https://github.com/asfaraguest/tatap/releases)
[![Views](https://hits.sh/github.com/asfaraguest/tatap.svg?style=flat-square&label=views&color=00f0ff)](https://hits.sh/github.com/asfaraguest/tatap/)
[![Issues](https://img.shields.io/github/issues/asfaraguest/tatap?style=flat-square&logo=github&color=f85149)](https://github.com/asfaraguest/tatap/issues)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg?style=flat-square)](LICENSE)

[![Trakteer](https://img.shields.io/badge/Trakteer-Dukung%20Saya-be1e2d?style=flat-square&logo=ko-fi&logoColor=white)](https://trakteer.id/bagus_azizul)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support%20Me-FF5E5B?style=flat-square&logo=ko-fi&logoColor=white)](https://ko-fi.com/L5J028GNTA)

---

## Fitur

- Bebas Iklan & Tanpa Akun: Akses streaming langsung tanpa pelacak atau registrasi.
- Antarmuka & Pemutar: Mendukung Ambient Stage Light, filter CRT scanline, dan penyesuaian rasio layar.
- Subtitle Bahasa Indonesia: Subtitle bawaan, terjemahan cepat AIGTX (500+ istilah anime), dan opsi integrasi AI (Gemini, Groq, OpenAI, Ollama).
- DPI-Bypass Terintegrasi: Modul TLS desync untuk membuka blokir akses stream tanpa VPN pihak ketiga.
- Privasi Lokal: Riwayat tontonan dan bookmark tersimpan di SQLite lokal (`anime.db`).

---

## Unduh dan Instalasi

### Android & Android TV

Unduh berkas APK versi terbaru dari [GitHub Releases](https://github.com/asfaraguest/tatap/releases) dan pasang di perangkat (Android 7.0+):
- **Android TV:** `tatap-tv-release-v*.apk` (dioptimalkan untuk navigasi remote D-pad dan antarmuka Leanback).
- **Android Ponsel / Tablet:** `tatap-release-v*.apk` (dioptimalkan untuk layar sentuh dan orientasi mobile).

### Windows
1. Unduh arsip zip portable dari [GitHub Releases](https://github.com/asfaraguest/tatap/releases).
2. Ekstrak arsip dan jalankan `Tatap.exe` (berbasis WebView2 bawaan Windows).

### Linux

**AppImage:**
```bash
chmod +x Tatap-x86_64.AppImage
./Tatap-x86_64.AppImage
```

**Dari Source Code:**
```bash
git clone https://github.com/asfaraguest/tatap.git
cd tatap
./install.sh
./manage.sh start
```
Buka peramban di `http://127.0.0.1:8767`. Untuk menghentikan: `./manage.sh stop`.

---

## Pintasan Keyboard (Desktop)

| Tombol | Fungsi |
| :--- | :--- |
| `Spasi` / `K` | Putar / Jeda |
| `F` | Layar penuh |
| `←` / `→` | Mundur / Maju 5 detik |
| `J` / `L` | Mundur / Maju 10 detik |
| `↑` / `↓` | Atur volume |
| `M` | Matikan suara (Mute) |
| `C` | Aktifkan filter CRT |
| `Esc` | Keluar layar penuh |

---

## Navigasi Remote (Android TV)

Tatap TV dirancang khusus agar dapat dioperasikan penuh menggunakan remote kontrol D-pad:

| Tombol Remote | Fungsi di Layar Utama & Daftar Anime | Fungsi Saat Pemutaran Video (Player) |
| :--- | :--- | :--- |
| `D-Pad Kiri / Kanan` | Berpindah antar item / kartu episode | Mundur / Maju 5 detik (Seek) |
| `D-Pad Atas` | Berpindah ke baris atas / bar pencarian | Memunculkan menu atas (Resolusi, Subtitle, Info) |
| `D-Pad Bawah` | Berpindah ke baris bawah / konten | Menyembunyikan menu atas / toggle kontrol player |
| `D-Pad Tengah` / `OK` | Membuka detail / mulai memutar | Putar / Jeda (Play / Pause) |
| `Menu` / `Info` / `Settings` | Buka menu navigasi drawer | Buka dialog pengaturan resolusi, subtitle, dan rasio |
| `Play / Pause` | – | Putar / Jeda video secara langsung |
| `Rewind` / `Fast Forward` | – | Mundur / Maju 5 detik |
| `Next` / `Previous` | – | Pindah ke episode berikutnya / sebelumnya |
| `Kembali` / `Back` | Kembali ke halaman sebelumnya / tutup dialog | Sembunyikan kontrol player / kembali ke daftar episode |

---

## Konfigurasi AI Subtitle (Opsional)

Dukungan model bahasa kustom (BYOK) via kolom pencarian pemutar:

| Perintah | Layanan |
| :--- | :--- |
| `:gemini <api_key>` | Google AI Studio |
| `:groq <api_key>` | Groq Cloud |
| `:openai <api_key>` | OpenAI |
| `:ollama <api_key>` | Ollama |

Perintah utilitas:
- Cek kunci: `:apikey`
- Hapus kunci: `:apikey clear`
- Ganti model: `:model <nama_model>`

---

## Dukungan / Donasi

Jika Anda merasa aplikasi ini bermanfaat, dukung pengembangan Tatap agar tetap aktif, bebas iklan, dan terus diperbarui:

<p align="left">
  <a href="https://trakteer.id/bagus_azizul" target="_blank">
    <img src="https://img.shields.io/badge/Trakteer-Dukung%20Saya-be1e2d?style=for-the-badge&logo=ko-fi&logoColor=white" height="38" alt="Dukung di Trakteer">
  </a>
  &nbsp;
  <a href="https://ko-fi.com/L5J028GNTA" target="_blank">
    <img src="https://img.shields.io/badge/Ko--fi-Beli%20Kopi-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white" height="38" alt="Support di Ko-fi">
  </a>
</p>

---

## Riwayat Versi & Changelog

Proyek ini sepenuhnya mematuhi kaidah [Semantic Versioning 2.0.0](https://semver.org/lang/id/). Catatan riwayat perubahan terperinci dan alasan kenaikan tiap nomor versi didokumentasikan di [CHANGELOG.md](CHANGELOG.md).

---

## Batasan Layanan

- Memerlukan koneksi internet aktif untuk mengambil metadata dan memutar stream.
- Aplikasi bertindak sebagai agregator konten publik dan tidak menyimpan video pada server tersendiri.
- Lisensi di bawah [GPL-3.0](LICENSE).
