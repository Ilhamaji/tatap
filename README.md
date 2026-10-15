<div align="center">
  <img src="assets/tatap_icon_512.png" width="112" height="112" alt="Tatap Logo">
  <h1>Tatap</h1>
  <p>Pemutar dan agregator anime mandiri multiplatform (Android Mobile, Android TV, Windows, Linux, Web) yang ringan, bebas iklan, tanpa registrasi akun, dan menjaga privasi data di penyimpanan lokal.</p>

  <p>
    <a href="https://github.com/asfaraguest/tatap/releases/latest"><img src="https://img.shields.io/github/v/release/asfaraguest/tatap?style=flat-square&color=00dbeb&label=Rilis" alt="Release"></a>
    <a href="https://github.com/asfaraguest/tatap/releases"><img src="https://img.shields.io/github/downloads/asfaraguest/tatap/total?style=flat-square&color=3fb950&label=Unduhan" alt="Downloads"></a>
    <a href="https://github.com/asfaraguest/tatap/stargazers"><img src="https://img.shields.io/github/stars/asfaraguest/tatap?style=flat-square&logo=github&color=e3b341&label=Stars" alt="Stars"></a>
    <a href="https://github.com/asfaraguest/tatap/network/members"><img src="https://img.shields.io/github/forks/asfaraguest/tatap?style=flat-square&logo=github&color=58a6ff&label=Forks" alt="Forks"></a>
    <a href="https://hits.sh/github.com/asfaraguest/tatap/"><img src="https://hits.sh/github.com/asfaraguest/tatap.svg?style=flat-square&label=Kunjungan&color=00dbeb" alt="Views"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/Lisensi-GPL--3.0-blue.svg?style=flat-square" alt="License"></a>
  </p>

  <p>
    <a href="https://trakteer.id/bagus_azizul" target="_blank"><img src="https://img.shields.io/badge/Trakteer-Dukung%20Karya-be1e2d?style=flat-square" alt="Trakteer"></a>
    <a href="https://ko-fi.com/L5J028GNTA" target="_blank"><img src="https://img.shields.io/badge/Ko--fi-Beli%20Kopi-FF5E5B?style=flat-square&logo=ko-fi&logoColor=white" alt="Ko-fi"></a>
  </p>
</div>

---

## Fitur

- **Bebas Iklan & Tanpa Akun:** Akses streaming langsung tanpa pelacak analitik, iklan banner, maupun keharusan registrasi akun.
- **Runtime Mandiri Multiplatform:** Berjalan mandiri di Android Mobile, Android TV, Windows Portable, dan Linux AppImage menggunakan server backend localhost terisolasi (`127.0.0.1:8767`).
- **Resume Watch Multiplatform:** Menyimpan progres menit dan detik terakhir penayangan per episode secara persisten pada basis data SQLite lokal (`watch_progress`), dilengkapi dialog interaktif (*Lanjutkan* atau *Mulai dari Awal*) dengan navigasi keyboard dan remote TV.
- **Pemutar Video & Kontrol Pemutaran:** Mendukung pemilih kecepatan putar (0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 1.75x, 2.0x) dengan reset otomatis ke 1.0x pada judul baru, pemilih resolusi adaptif HLS (360p s/d 1080p), Ambient Stage Light, penyesuaian rasio layar, dan filter CRT scanline.
- **Deteksi Opening & Ending (AniSkip):** Mendeteksi durasi opening dan ending secara otomatis, menyediakan tombol lewati intro/outro satu klik untuk keyboard desktop (`S`) maupun remote Android TV (`OK` / `>>`), serta opsi lewati otomatis pada dialog pengaturan.
- **Subtitle Multi-Tier:** Mendukung subtitle bawaan (softsub WEBVTT/ASS), terjemahan cepat AIGTX dengan leksikon 500+ istilah anime, kustomisasi tipografi (ukuran, posisi margin, transparansi latar), dan integrasi model bahasa AI opsional (BYOK: Gemini, Groq, OpenAI, Ollama).
- **Agregasi Ganda & Anti-DPI Terintegrasi:** Mendukung sumber stream ganda (HiAnime dan Otakudesu sub Indo) dengan verifikasi konsistensi nomor musim, dilengkapi mitigasi DPI bawaan via desinkronisasi TLS ClientHello dan DNS-over-HTTPS (DoH) tanpa memerlukan VPN tambahan.
- **Katalog, Indikator Ongoing & Jadwal:** Penjelajahan katalog berdasarkan musim tayang, anime populer, filter genre terintegrasi, indikator rasio episode rilis aktif (`Ep X/Y`), penanda status tamat, dan jadwal rilis harian (Senin s/d Minggu).
- **Privasi Penyimpanan Lokal:** Riwayat tontonan, bookmark anime, preferensi pemutar, dan riwayat posisi tersimpan penuh di penyimpanan lokal (`anime.db`).

---

## Unduh dan Instalasi

### Unduhan Langsung Versi Terbaru

Pilih paket instalasi resmi sesuai dengan sistem operasi dan perangkat Anda:

| Platform Perangkat | Tombol Unduh Langsung | Format Berkas | Keterangan & Kompatibilitas |
| :--- | :---: | :---: | :--- |
| **Android Ponsel / Tablet** | [![Unduh Android APK](https://img.shields.io/badge/Download-Android%20APK-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://github.com/asfaraguest/tatap/releases/latest/download/tatap-release-v2.7.0.apk) | `.apk` (~35 MB) | Signed Production APK (Android 7.0 s/d 16, 16KB-page aligned, Adaptive Icons & Material You) |
| **Android TV / Google TV** | [![Unduh Android TV APK](https://img.shields.io/badge/Download-Android%20TV%20APK-0081C9?style=for-the-badge&logo=android&logoColor=white)](https://github.com/asfaraguest/tatap/releases/latest/download/tatap-tv-release-v2.7.0.apk) | `.apk` (~35 MB) | Signed Production APK khusus TV (antarmuka Leanback 10-foot UI, D-pad remote, Card Center Layout) |
| **Windows (x64)** | [![Unduh Windows Portable](https://img.shields.io/badge/Download-Windows%20Portable-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/asfaraguest/tatap/releases/latest/download/tatap-windows-x64-portable.zip) | `.zip` (~26 MB) | Standalone Portable (Python 3.11 embed + Go launcher Tatap.exe, WebView2 terintegrasi) |
| **Linux (x86_64)** | [![Unduh Linux AppImage](https://img.shields.io/badge/Download-Linux%20AppImage-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://github.com/asfaraguest/tatap/releases/latest/download/Tatap-x86_64.AppImage) | `.AppImage` (~58 MB) | Standalone AppImage (CPython 3.11 standalone runtime, berikan izin `chmod +x` dan jalankan) |

Seluruh arsip versi rilis sebelumnya tersedia di [Halaman Rilis GitHub](https://github.com/asfaraguest/tatap/releases).

### Panduan Tambahan

#### Android Ponsel & Android TV
Unduh berkas APK bertanda tangan resmi dari tabel di atas atau [GitHub Releases](https://github.com/asfaraguest/tatap/releases), kemudian pasang pada perangkat (mendukung Android 7.0 hingga Android 16):
- **Android TV / Google TV:** Pasang `tatap-tv-release-v*.apk` untuk navigasi remote D-pad, tata letak dialog terpusat 700dp, dan banner Leanback standar TV.
- **Android Ponsel / Tablet:** Pasang `tatap-release-v*.apk` untuk tata letak layar sentuh, gesture swipe volume dan kecerahan, serta ikon adaptif Material You.

#### Windows (x64)
1. Unduh paket zip portable melalui tombol unduh di atas.
2. Ekstrak arsip ke folder yang diinginkan, kemudian jalankan `Tatap.exe`.
3. Aplikasi berjalan mandiri tanpa instalasi Python terpisah dan memanfaatkan runtime Edge WebView2 bawaan Windows.

#### Linux (x86_64)

**Paket AppImage Mandiri:**
```bash
chmod +x Tatap-x86_64.AppImage
./Tatap-x86_64.AppImage
```

**Menjalankan dari Source Code:**
```bash
git clone https://github.com/asfaraguest/tatap.git
cd tatap
./install.sh
./manage.sh start
```
Buka peramban di `http://127.0.0.1:8767`. Untuk menghentikan server: `./manage.sh stop`.

---

## Pintasan Keyboard (Desktop)

### Pemutar Video (Player Modal)

| Tombol | Fungsi |
| :--- | :--- |
| `Spasi` | Putar / Jeda video |
| `F` | Masuk / Keluar mode layar penuh |
| `←` / `→` | Mundur / Maju 5 detik (Seek) |
| `[` / `]` | Perlambat / Percepat kecepatan putar (0.5x s/d 2.0x) |
| `S` | Lewati opening/ending (saat intro/outro aktif) atau beralih sumber stream |
| `N` / `P` | Pindah ke episode berikutnya / episode sebelumnya |
| `M` | Matikan / Nyalakan suara (Mute toggle) |
| `Esc` | Keluar dari mode layar penuh atau menutup pemutar video |

### Antarmuka Utama & Dialog

| Tombol | Fungsi |
| :--- | :--- |
| `/` | Fokus ke kolom input perintah / pencarian |
| `Tab` | Berpindah antar tab beranda (Cari, Musim, Jadwal, Lanjutan, Katalog) |
| `↑` / `↓` | Navigasi riwayat perintah terminal atau pemilihan kartu anime |
| `[` / `]` | Halaman sebelumnya / berikutnya pada katalog, atau pindah hari jadwal |
| `Enter` | Eksekusi pencarian atau konfirmasi dialog modal yang aktif |
| `Esc` | Membatalkan dialog riwayat tontonan atau menutup modal informasi |

---

## Navigasi Remote (Android TV)

Tatap TV dirancang khusus untuk pengoperasian penuh menggunakan remote D-pad tanpa memerlukan mouse pointer:

| Tombol Remote | Fungsi di Layar Utama & Daftar Anime | Fungsi Saat Pemutaran Video (Player) |
| :--- | :--- | :--- |
| `D-Pad Kiri / Kanan` | Berpindah antar kartu anime / episode | Mundur / Maju 5 detik (Seek) |
| `D-Pad Atas` | Berpindah ke baris navigasi tab / pencarian | Menampilkan panel kontrol atas (Resolusi, Subtitle, Kecepatan, Info) |
| `D-Pad Bawah` | Berpindah ke konten baris bawah | Memfokuskan tombol lewati opening/ending jika aktif, atau menyembunyikan kontrol |
| `D-Pad Tengah / OK` | Membuka detail anime / konfirmasi pilihan | Putar/Jeda; Lewati opening/ending saat tombol skip terfokus; Konfirmasi resume |
| `Rewind / Fast Forward` | – | Mundur / Maju 5 detik; Tombol `>>` melompati opening/ending secara langsung |
| `Next / Previous` | – | Pindah ke episode berikutnya / sebelumnya |
| `Menu / Info / Settings` | Buka menu drawer navigasi | Buka dialog pengaturan pemutar (resolusi, subtitle, kecepatan, rasio, auto-skip) |
| `Kembali / Back` | Kembali ke halaman sebelumnya / tutup dialog | Menyembunyikan kontrol pemutar / kembali ke detail anime |

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

## Dukungan dan Donasi

Jika Anda merasa aplikasi ini bermanfaat, dukung pengembangan Tatap agar tetap aktif, bebas iklan, dan terus diperbarui:

<p align="left">
  <a href="https://trakteer.id/bagus_azizul" target="_blank">
    <img src="https://img.shields.io/badge/Trakteer-Dukung%20Karya-be1e2d?style=for-the-badge" height="38" alt="Dukung di Trakteer">
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

- Memerlukan koneksi internet aktif untuk mengambil metadata anime dan memutar stream video.
- Aplikasi bertindak sebagai agregator konten publik dan tidak menyimpan berkas video pada server privat.
- Seluruh kode sumber dirilis di bawah lisensi [GPL-3.0](LICENSE).
