# RULES.md — Tatap Mandatory Engineering Rules & Standards

Dokumen ini mematenkan aturan mutlak yang **WAJIB DIPATUHI** oleh setiap kontributor dan agen AI (Antigravity, Gemini, Copilot, Cursor, Claude) saat bekerja pada repositori **Tatap**.

---

## 1. Kaidah Mutlak Semantic Versioning (SemVer 2.0.0)
Semua penomoran versi Tatap wajib mengikuti spesifikasi resmi **Semantic Versioning 2.0.0** dengan format `v<MAJOR>.<MINOR>.<PATCH>`:

1. **MAJOR (`X.0.0`):**
   - **Kapan:** Terjadi perubahan arsitektur besar yang merusak kompatibilitas ke belakang (*breaking changes*), perombakan skema database SQLite tanpa backward-compatibility otomatis, atau pemutusan kontrak API runtime inti.
   - **Contoh:** Migrasi arsitektur dari monolithic localhost ke microservice terdistribusi, perombakan menyeluruh format database.

2. **MINOR (`x.Y.0`):**
   - **Kapan:** Penambahan fitur fungsional atau antarmuka baru yang backward-compatible tanpa merusak fungsionalitas yang ada sebelumnya.
   - **Contoh:** Penambahan Drawer Navigation Panel, In-Player Resolution Selector, On-Demand Update Checker, integrasi provider anime/fansub baru, atau perombakan desain header/katalog.
   - **Aturan:** Setiap kali MINOR dinaikkan, digit PATCH wajib direset kembali ke `0`.

3. **PATCH (`x.y.Z`):**
   - **Kapan:** Perbaikan bug (*bug fixes*), perbaikan kompatibilitas platform/perangkat tertentu (seperti fullscreen iOS Safari / Android Chrome, display cutout notch, immersive mode), penyesuaian styling minor, optimasi performa, atau pembaruan dependensi keamanan.
   - **Contoh:** v2.2.2 -> v2.2.3.

### 📋 Checklist Wajib Saat Bump Versi (Atomic Synchronization):
Saat agent menaikkan versi, agent **WAJIB SECARA ATOMIK MENYELARASKAN** seluruh berkas berikut tanpa ada yang tertinggal:
- [ ] `backend/main.py` -> `CURRENT_VERSION = "<VERSION>"` & User-Agent header
- [ ] `android/app/src/main/python/backend/main.py` -> `CURRENT_VERSION = "<VERSION>"` & User-Agent header
- [ ] `android/app/build.gradle` -> `versionName "<VERSION>"` dan increment `versionCode`
- [ ] Rebuild dan verifikasi ketiga berkas rilis resmi di folder `dist/`
- [ ] Buat git tag `v<VERSION>` dan terbitkan rilis publik GitHub

---

## 2. Aturan Mutlak Rilis GitHub (Strict 3 Official Assets / Zero Raw APK)
> [!CAUTION]
> Halaman rilis publik GitHub **HANYA BOLEH MENYEDIAKAN TEPAT 3 BERKAS RESMI BERIKUT**:
> 1. 📱 **`tatap-release-v<VERSION>.apk`** (Official Signed APK via Keystore produksi `android/keystore/release.jks`, v2/v3 signature verified)
> 2. 🪟 **`tatap-windows-x64-portable.zip`** (Official Windows x64 Portable)
> 3. 🐧 **`Tatap-x86_64.AppImage`** (Official Linux x86_64 AppImage)

- **DILARANG KERAS** mengunggah atau membiarkan berkas APK mentah hasil build CI (`app-release.apk`, `app-debug.apk`, dsb.) berada di rilis publik GitHub.
- **TIDAK PERNAH** meng-commit file binary APK ke dalam repositori git.
- **Pembersihan Wajib:** Jika proses CI atau rilis sempat mengunggah berkas selain 3 aset resmi di atas, agent **WAJIB SEGERA** menghapusnya dengan:
  ```bash
  gh release delete-asset v<VERSION> app-release.apk -y
  gh release delete-asset v<VERSION> app-debug.apk -y
  ```
- **Verifikasi Wajib:** Selalu jalankan `gh release view v<VERSION>` untuk memastikan HANYA 3 file resmi yang tersisa sebelum menyelesaikan tugas.

---

## 3. Blacklist Total Genre Hentai (Zero-Tolerance)
- Seluruh konten bergenre Hentai telah diblokir secara permanen di seluruh level:
  - Backend FastAPI (`/api/browse`, `/api/search`, `/api/stream/resolve`, `/api/anime/{slug}/episodes`).
  - Scraper HiAnime & Otakudesu.
  - TUI terminal `:genre hentai` dan kata kunci terkait.
- **Dilarang** membypass atau menghapus filter blacklist hentai. Jangan pernah mengizinkan fallback video ke anime lain untuk query/genre terlarang.

---

## 4. Pencegahan Regresi Stream & Metadata
- **Otakudesu Fallback:** Dilarang melakukan fallback buta ke `res[0]` atau mengambil kata pertama judul (`words[0]`).
- Selalu gunakan `_is_title_match` dan `_extract_season_num` sebelum menautkan stream Otakudesu ke judul HiAnime/AniList agar tidak tertukar dengan anime fansub lain yang tidak berkaitan.

---

## 5. Android Packaging & 16KB Page Alignment
- Pertahankan `packaging.jniLibs.useLegacyPackaging = true` di `android/app/build.gradle` dan `android:extractNativeLibs="true"` di `AndroidManifest.xml` untuk kompatibilitas penuh Android 15/16 (16KB page alignment) dan perangkat modern.

---

## 6. Referensi SOP Lengkap
Untuk arsitektur sistem, player controls, subtitle styling, dan build pipeline, baca dokumentasi lengkap di:
👉 **[agent.md](file:///home/b-ict/tatap/agent.md)**
