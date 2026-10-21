# Tatap for iOS (IPA)

Versi resmi Tatap untuk ekosistem Apple iOS (iPhone & iPad).

---

## 1. Arsitektur Teknis iOS

Aplikasi Tatap untuk iOS dirancang menggunakan pendekatan **SwiftUI + Native Embedded HTTP Runtime + WKWebView Engine**:

- **Embedded Local Server (`TatapHTTPServer.swift`):** Berjalan di `127.0.0.1:8767` menggunakan Apple Network.framework (`NWListener`). Melayani UI web statis serta merespon rute `/api/ping`, `/api/seasonal`, `/api/schedule`, `/api/search`, `/api/stream/resolve`, `/api/player/video`, `/api/history`, dan `/api/bookmarks`.
- **Swift GraphQL & Scraping Engine (`AniListService.swift`, `HiAnimeService.swift`):** Menjalankan kueri metadata AniList dan resolusi stream HiAnime/MegaCloud dengan dekripsi AES-CBC via Apple `CommonCrypto`.
- **Stream Proxy & M3U8 Rewriter (`StreamProxy.swift`):** Menulis ulang playlist master `.m3u8` dan memproksi segmen video dengan header `Referer` dan `Origin` yang valid.
- **Local Storage (`LocalDatabase.swift`):** Persistensi riwayat tontonan (*history*), *bookmarks*, dan pengaturan menggunakan native iOS `libsqlite3` dalam mode WAL.
- **Audio & PiP Resilience (`AppDelegate.swift`):** Kategori `AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)` diaktifkan bersama `UIBackgroundModes: [audio]` untuk pemutaran audio di latar belakang dan Picture-in-Picture (PiP).

---

## 2. Struktur Berkas iOS

```
ios/
├── Tatap/
│   ├── App/
│   │   ├── TatapApp.swift             # Entry point SwiftUI
│   │   ├── AppDelegate.swift          # Audio session & rotasi layar
│   │   └── TatapConfig.swift          # Konfigurasi port, host, user-agent
│   ├── Server/
│   │   ├── TatapHTTPServer.swift      # Embedded HTTP Server (port 8767)
│   │   ├── LocalDatabase.swift        # SQLite persisten (history, bookmarks)
│   │   ├── AniListService.swift       # Client GraphQL AniList
│   │   ├── HiAnimeService.swift       # HiAnime scraper & AES-CBC decryptor
│   │   └── StreamProxy.swift          # Rewriter M3U8 & video segment proxy
│   ├── Views/
│   │   ├── MainWebView.swift          # WKWebView container dengan inline media & haptic
│   │   └── LoadingView.swift          # Cyberpunk splash / loading screen
│   └── Resources/
│       └── Info.plist                 # ATS exceptions, orientations, background modes
└── Tatap.xcodeproj/                   # Xcode Project Bundle
```

---

## 3. Kompilasi & Build Paket IPA

### A. Otomatis via Builder Script (Multiplatform)
Jalankan perintah berikut di root repositori:
```bash
node tools/build_ios_ipa.js
# atau
python3 tools/build_ios_ipa.py
```
Output berkas akan otomatis tersimpan di:
```
dist/ios/tatap-release-v<VERSION>.ipa
```

### B. Kompilasi Manual dengan Xcode (macOS)
1. Buka `ios/Tatap.xcodeproj` menggunakan Xcode.
2. Pilih target perangkat: **Any iOS Device (arm64)**.
3. Atur *Signing & Capabilities* dengan Apple ID pengembang Anda.
4. Pilih menu **Product > Archive**.
5. Pilih **Distribute App > Ad Hoc / Development > Export** untuk menghasilkan file `.ipa`.

---

## 4. Panduan Pemasangan (Sideloading ke iPhone/iPad)

Paket `.ipa` dapat dipasang ke perangkat iOS tanpa jailbreak menggunakan alat sideloading berikut:

1. **TrollStore (iOS 14.0 - 17.0):**
   - Kirim `tatap-release-v<VERSION>.ipa` ke perangkat via AirDrop.
   - Buka file dan pilih **Open in TrollStore > Install**. Aplikasi akan langsung terpasang secara permanen tanpa kedaluwarsa sertifikat 7 hari.

2. **AltStore / SideStore:**
   - Buka aplikasi AltStore di iPhone.
   - Masuk ke tab **My Apps**, tekan tombol `+` di pojok kiri atas.
   - Pilih `tatap-release-v<VERSION>.ipa`.

3. **Sideloadly (Windows & macOS):**
   - Hubungkan iPhone via kabel USB ke PC.
   - Buka **Sideloadly**, seret file `.ipa` ke jendela Sideloadly.
   - Masukkan Apple ID dan klik **Start**.

4. **Scarlet:**
   - Buka aplikasi Scarlet di iPhone.
   - Tekan ikon impor di sudut kanan atas dan pilih `tatap-release-v<VERSION>.ipa`.
