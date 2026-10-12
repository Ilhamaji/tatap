# Tatap

Pemutar anime mandiri multi-platform (Android, Windows, Linux, Web) yang ringan, bebas iklan, tanpa registrasi akun, dan menjaga privasi data di penyimpanan lokal.

[![Release](https://img.shields.io/github/v/release/asfaraguest/tatap?style=flat-square&color=00f0ff)](https://github.com/asfaraguest/tatap/releases)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg?style=flat-square)](LICENSE)
[![Trakteer](https://img.shields.io/badge/Trakteer-Dukung%20Saya-be1e2d?style=flat-square&logo=ko-fi&logoColor=white)](https://trakteer.id/bagus_azizul)
[![Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/L5J028GNTA)

---

## Fitur

- Bebas Iklan & Tanpa Akun: Akses streaming langsung tanpa pelacak atau registrasi.
- Antarmuka & Pemutar: Mendukung Ambient Stage Light, filter CRT scanline, dan penyesuaian rasio layar.
- Subtitle Bahasa Indonesia: Subtitle bawaan, terjemahan cepat AIGTX (500+ istilah anime), dan opsi integrasi AI (Gemini, Groq, OpenAI, Ollama).
- DPI-Bypass Terintegrasi: Modul TLS desync untuk membuka blokir akses stream tanpa VPN pihak ketiga.
- Privasi Lokal: Riwayat tontonan dan bookmark tersimpan di SQLite lokal (`anime.db`).

---

## Unduh dan Instalasi

### Android
Unduh berkas APK versi terbaru dari [GitHub Releases](https://github.com/asfaraguest/tatap/releases) dan pasang di perangkat (Android 7.0+).

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

<a href="https://trakteer.id/bagus_azizul" target="_blank"><img id="wse-buttons-preview" src="https://edge-cdn.trakteer.id/images/embed/trbtn-red.png" height="40" style="border:0px;height:40px;" alt="Trakteer Saya"></a>
<a href="https://ko-fi.com/L5J028GNTA" target="_blank"><img src="https://ko-fi.com/img/githubbutton_sm.svg" height="36" style="border:0px;height:36px;margin-left:8px;" alt="Support on Ko-fi"></a>

---

## Batasan Layanan

- Memerlukan koneksi internet aktif untuk mengambil metadata dan memutar stream.
- Aplikasi bertindak sebagai agregator konten publik dan tidak menyimpan video pada server tersendiri.
- Lisensi di bawah [GPL-3.0](LICENSE).
