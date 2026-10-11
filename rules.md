# RULES.md — Tatap Mandatory Engineering Rules & Standards

Dokumen ini mematenkan aturan mutlak yang **WAJIB DIPATUHI** oleh setiap kontributor dan agen AI (Antigravity, Gemini, Copilot, Cursor, Claude) saat bekerja pada repositori **Tatap**.

---

## 1. Kaidah Mutlak Semantic Versioning (SemVer 2.0.0)
> [!IMPORTANT]
> **PRINSIP PATEN: SETIAP PATCH DAN RILIS WAJIB TUNDUK PADA KAIDAH SEMVER 2.0.0**
> Semua penomoran versi, hotfix, rilis patch, dan pembaruan fitur di Tatap **WAJIB 100% MENGIKUTI SPESIFIKASI RESMI SEMANTIC VERSIONING 2.0.0** (`v<MAJOR>.<MINOR>.<PATCH>`).
> - **DILARANG KERAS** menggunakan penomoran versi bebas, format arbitrer (seperti `v2.3`, `v2.3-patch1`, build timestamp), atau melompati kaidah SemVer.
> - **DILARANG KERAS** merilis perbaikan (*patch / hotfix*) tanpa menaikkan digit PATCH (`X.Y.Z` -> `X.Y.Z+1`).
> - **DILARANG KERAS** merilis fitur baru (*feature*) tanpa menaikkan digit MINOR dan mereset digit PATCH ke `0` (`X.Y.0`).
> - **DILARANG KERAS** melakukan perubahan breaking/inkompatibel tanpa menaikkan digit MAJOR dan mereset MINOR & PATCH ke `0` (`X.0.0`).
> - **DILARANG KERAS** mengedit nomor versi secara manual/parsial di satu file saja. Berkas `VERSION` adalah Single Source of Truth (SSOT), dan seluruh sinkronisasi wajib dilakukan secara atomik.

### Taksonomi Kenaikan Versi:
1. **MAJOR (`X.0.0`):**
   - **Kapan:** Terjadi perubahan arsitektur besar yang merusak kompatibilitas ke belakang (*breaking changes*), perombakan skema database SQLite tanpa backward-compatibility otomatis, atau pemutusan kontrak API runtime inti.
   - **Contoh:** Migrasi arsitektur dari monolithic localhost ke microservice terdistribusi, perombakan menyeluruh format database.

2. **MINOR (`x.Y.0`):**
   - **Kapan:** Penambahan fitur fungsional atau antarmuka baru yang backward-compatible tanpa merusak fungsionalitas yang ada sebelumnya.
   - **Contoh:** Penambahan Drawer Navigation Panel, In-Player Resolution Selector, On-Demand Update Checker, dukungan Android TV 10-Foot UI, integrasi provider anime baru, atau perombakan desain header/katalog.
   - **Aturan:** Setiap kali MINOR dinaikkan, digit PATCH wajib direset kembali ke `0`.

3. **PATCH (`x.y.Z`):**
   - **Kapan:** Perbaikan bug (*bug fixes*), perbaikan kompatibilitas platform/perangkat tertentu (seperti fullscreen iOS Safari / Android Chrome, display cutout notch, immersive mode), penyesuaian styling minor, optimasi performa memori/jaringan, atau pembaruan dependensi keamanan.
   - **Contoh:** v2.3.0 -> v2.3.1.
   - **Aturan:** Tidak boleh ada penambahan antarmuka/fitur baru besar pada patch release; fokus murni pada stabilitas, perbaikan bug, dan keandalan.

### 📋 Prosedur Standar Wajib Saat Patch & Rilis (Automated Atomic Synchronization):
Setiap kali agent merilis perbaikan bug atau rilis fitur baru, agent **WAJIB MENJALANKAN PROSEDUR ATOMIK** berikut:
```bash
# 1. Eksekusi bump versi sesuai kategori perubahan:
python3 tools/bump_version.py patch   # untuk bugfix/perbaikan patch
python3 tools/bump_version.py minor   # untuk penambahan fitur baru
python3 tools/bump_version.py major   # untuk breaking changes

# 2. Audit konsistensi seluruh modul:
python3 tools/bump_version.py --check

# 3. Jalankan automated test suite SemVer:
pytest tests/test_semver.py
```
Tool ini secara atomik menyinkronkan:
- [x] `VERSION` (Root SSOT)
- [x] `backend/version.py` & `android/app/src/main/python/backend/version.py` (`__version__` & dynamic User-Agent & `/api/version`)
- [x] `android/app/build.gradle` (deterministik `versionCode` dan `versionName`)
- [x] `launcher/winres/winres.json` & `tatap.manifest` (4-digit format Windows PE)
- [x] `frontend/index.html` badge versi

> [!CAUTION]
> **GERBANG MUTLAK RILIS:** Dilarang membuat tag rilis git atau mempublikasikan rilis GitHub jika `python3 tools/bump_version.py --check` atau `pytest tests/test_semver.py` belum lolos 100%!

---

## 2. Aturan Mutlak Rilis GitHub (Strict 4 Official Assets / Zero Raw APK)
> [!CAUTION]
> Halaman rilis publik GitHub **HANYA BOLEH MENYEDIAKAN TEPAT 4 BERKAS RESMI BERIKUT**:
> 1. 📱 **`tatap-release-v<VERSION>.apk`** (Official Signed Mobile APK via Keystore produksi `android/keystore/release.jks`, v2/v3 signature verified)
> 2. 📺 **`tatap-tv-release-v<VERSION>.apk`** (Official Signed Android TV / Google TV APK 10-Foot UI)
> 3. 🪟 **`tatap-windows-x64-portable.zip`** (Official Windows x64 Portable)
> 4. 🐧 **`Tatap-x86_64.AppImage`** (Official Linux x86_64 AppImage)

- **DILARANG KERAS** mengunggah atau membiarkan berkas APK mentah hasil build CI (`app-release.apk`, `app-debug.apk`, dsb.) berada di rilis publik GitHub.
- **TIDAK PERNAH** meng-commit file binary APK ke dalam repositori git.
- **Pembersihan Wajib:** Jika proses CI atau rilis sempat mengunggah berkas selain 4 aset resmi di atas, agent **WAJIB SEGERA** menghapusnya dengan:
  ```bash
  gh release delete-asset v<VERSION> app-release.apk -y
  gh release delete-asset v<VERSION> app-debug.apk -y
  ```
- **Verifikasi Wajib:** Selalu jalankan `gh release view v<VERSION>` untuk memastikan HANYA 4 file resmi yang tersisa sebelum menyelesaikan tugas.

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
