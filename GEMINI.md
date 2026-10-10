# GEMINI.md / AGENTS.md — Mandatory Workspace Directives for Tatap

> [!CAUTION]
> **MANDATORY INSTRUCTION FOR ALL AI CODING AGENTS (ANTIGRAVITY / GEMINI / COPILOT / CLAUDE / CURSOR):**
> Anda berada di repositori **Tatap**. Anda **WAJIB MEMBACA DAN MEMATUHI SECARA MUTLAK** seluruh aturan yang tertuang di file `agent.md`. Pelanggaran terhadap poin-poin berikut tidak dapat ditoleransi:

---

## 1. ATURAN MUTLAK RILIS GITHUB (ZERO RAW APK / STRICT 3 OFFICIAL ASSETS)
- **Halaman rilis GitHub HANYA BOLEH MENYEDIAKAN 3 BERKAS RESMI BERIKUT:**
  1. `tatap-release-v<VERSION>.apk` (Official Signed APK yang ditandatangani keystore produksi `android/keystore/release.jks` dengan skema v2 & v3 verified).
  2. `tatap-windows-x64-portable.zip` (Official Windows x64 Portable build).
  3. `Tatap-x86_64.AppImage` (Official Linux x86_64 AppImage build).
- **DILARANG KERAS** mengunggah atau membiarkan berkas APK mentah hasil build (`app-release.apk`, `app-debug.apk`, dsb.) berada di rilis publik GitHub.
- **TIDAK PERNAH** meng-commit file binary APK ke dalam repositori git.
- **Pembersihan Wajib:** Jika proses CI atau rilis sempat mengunggah berkas selain 3 aset resmi di atas, agent **WAJIB SEGERA** menghapusnya dengan:
  ```bash
  gh release delete-asset v<VERSION> app-release.apk -y
  gh release delete-asset v<VERSION> app-debug.apk -y
  ```
- **Verifikasi Wajib:** Selalu jalankan `gh release view v<VERSION>` untuk memastikan HANYA 3 file resmi yang tersisa sebelum menyelesaikan tugas.

---

## 2. BLACKLIST TOTAL GENRE HENTAI (ZERO-TOLERANCE)
- Konten bergenre Hentai telah diblacklist 100% di semua level:
  - Backend FastAPI (`/api/browse`, `/api/search`, `/api/stream/resolve`, `/api/stream/episode`).
  - Scraper HiAnime & Otakudesu.
  - TUI terminal `:genre hentai` dan pencarian kata kunci terkait.
- Dilarang membypass atau menghapus filter blacklist hentai. Jangan pernah mengizinkan fallback video ke anime lain untuk query/genre terlarang.

---

## 3. PENCEGAHAN REGRESI STREAM & METADATA (OTAKUDESU FALLBACK)
- Dilarang melakukan fallback buta ke `res[0]` atau mengambil kata pertama `words[0]`.
- Selalu gunakan `_is_title_match` dan `_extract_season_num` sebelum menautkan stream Otakudesu ke judul HiAnime/AniList agar tidak tertukar dengan anime fansub lain yang tidak berkaitan.

---

## 4. ANDROID PACKAGING & 16KB PAGE ALIGNMENT
- Pertahankan `packaging.jniLibs.useLegacyPackaging = true` di `android/app/build.gradle` dan `android:extractNativeLibs="true"` di `AndroidManifest.xml` untuk kompatibilitas penuh Android 15/16 dan perangkat seperti Infinix Note 40.

---

## 5. DOKUMENTASI DAN SOP LENGKAP
Untuk panduan detail mengenai arsitektur, player controls, subtitle styling, dan build pipeline, baca dokumentasi lengkap di:
👉 **[agent.md](file:///home/b-ict/tatap/agent.md)**
