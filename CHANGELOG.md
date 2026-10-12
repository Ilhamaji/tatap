# Changelog

Semua perubahan penting pada proyek **Tatap** didokumentasikan di berkas ini.

Format dokumen ini mengacu pada [Keep a Changelog](https://keepachangelog.com/id/1.1.0/), dan proyek ini sepenuhnya mematuhi [Semantic Versioning 2.0.0](https://semver.org/lang/id/).

---

## Prinsip Penomoran Versi (SemVer 2.0.0)

Format versi menggunakan skema `MAJOR.MINOR.PATCH`:
- **MAJOR (X.0.0):** Perubahan arsitektur mendasar atau modifikasi yang tidak kompatibel ke belakang (*breaking changes*).
- **MINOR (x.Y.0):** Penambahan fitur atau kapabilitas baru yang tetap kompatibel ke belakang (*backward-compatible new features*). Digit PATCH direset ke 0.
- **PATCH (x.y.Z):** Perbaikan bug, peningkatan stabilitas, atau perbaikan internal tanpa penambahan fitur baru (*backward-compatible bug fixes*).

## [2.4.2] - 2026-10-13

### Ditingkatkan
- **Kamus Idiom & Ungkapan Fansub Anime Universal:** Mengintegrasikan kamus referensi penerjemahan fansub anime yang komprehensif ke dalam mesin penerjemah `translate.py` (prompt sistem `_FANSUB_PROMPT_ID`, aturan normalisasi universal `_UNIVERSAL_FANSUB_RULES`, percakapan kasual `_CASUAL_FANSUB_RULES`, dan penghalus `_AIGTX_SMOOTH_RULES`). Mengeliminasi puluhan calque dan blunder penerjemahan mesin yang kaku:
  - *"It can't be helped / shouganai"* -> *"Mau gimana lagi"* (bukan *"Itu tidak bisa ditolong"*).
  - *"Give me a break"* -> *"Yang benar saja! / Ampun deh!"* (bukan *"Beri aku istirahat"*).
  - *"Serves you right"* -> *"Rasakan itu! / Syukurin!"* (bukan *"Melayanimu dengan benar"*).
  - *"I'll take care of this"* -> *"Biar aku yang urus ini"* (bukan *"Aku akan merawat ini"*).
  - *"Don't let your guard down"* -> *"Jangan lengah!"* (bukan *"Jangan biarkan penjagamu turun"*).
  - *"Stand back / Back down"* -> *"Mundur! / Menjauhlah!"* (bukan *"Berdiri kembali / Kembali ke bawah"*).
  - *"Watch your back"* -> *"Waspadalah di belakangmu!"* (bukan *"Perhatikan punggungmu"*).
  - *"Make up your mind"* -> *"Tentukan pilihanmu!"* (bukan *"Bentuk pikiranmu"*).
  - *"Change of heart"* -> *"Berubah pikiran"* (bukan *"Perubahan hati"*).
  - *"Over my dead body"* -> *"Langkahi dulu mayatku!"* (bukan *"Di atas tubuh matiku"*).
  - *"Who is in charge?"* -> *"Siapa penanggung jawabnya?"* (bukan *"Siapa yang mengisi daya?"*).
  - *"Piece of cake"* -> *"Gampang banget"* (bukan *"Sepotong kue"*).
  - *"Under the weather"* -> *"Kurang enak badan"* (bukan *"Di bawah cuaca"*).
  - *"Not on my watch"* -> *"Tidak akan kubiarkan!"* (bukan *"Bukan di jam tanganku"*).
  - *"Take your time"* -> *"Santai saja, jangan terburu-buru"* (bukan *"Ambil waktumu"*).
  - Serta ungkapan dan respons kultural khas anime lainnya (*mendokusai*, *sasuga*, *tsundere*, *greeting*, dan umpatan shonen).
- **Sinkronisasi Penuh Antar-Platform:** Menyelaraskan seluruh berkas kamus dan versi di `backend/` dengan `android/app/src/main/python/backend/` guna menjamin paritas 100% pada platform Windows Portable, Linux Desktop, Android Mobile, dan Android TV.

---

## [2.4.1] - 2026-10-13

### Diperbaiki
- **Pembersihan dan Pemulihan Engine Penerjemah Subtitle:** Mengatasi masalah fallback tidak diinginkan ke MyMemory yang menghasilkan terjemahan kaku. Menghapus penyimpanan cache MyMemory ke entri database `sub2|gtx`, memvalidasi dan membuang otomatis cache yang berisi pesan peringatan kuota MyMemory, serta memulihkan kualitas terjemahan luwes Google AIGTX dan AI Fansub.
- **Perbaikan Rute Endpoint Google Translate:** Menghapus parameter `client=gtx` yang diblokir/dibatasi laju (HTTP 429) oleh Google dan menggantinya dengan pool endpoint tanpa kuota berbasis `clients5.google.com` (`dict-chrome-ex` dan `tw-ob`) serta `translate.google.com` dengan konkurensi optimal 3 pekerja, memangkas durasi proses translasi satu episode penuh menjadi sangat cepat (< 5 detik).
- **Perbaikan Pemilihan Mode dan Model AI Fansub:** Memperbaiki identifikasi `job_key` inflight (`base_hash|lang|mode`) agar permintaan mode `ai` atau `aigtx` tidak dibajak oleh tugas prefetch `gtx`. Memperbarui model default Google AI Studio dari penamaan tidak valid `gemini-3.1-flash-lite` menjadi model aktif `gemini-2.0-flash` (dengan rantai failover `gemini-1.5-flash`), serta memperbaiki prioritas eksekusi mode AI agar langsung memanggil LLM fansub saat diminta.
- **Penanganan Aksi Refresh Subtitle di Pemutar:** Mengatasi bug pada dialog pemilih subtitle Android di mana eksekusi `[Refresh] Terjemahkan Ulang Subtitle` tertimpa oleh pemanggilan `applySubtitleSelection()` non-refresh.
- **Pencegahan Cache Poisoning Subtitle:** Memperbaiki bug kritis di mana kegagalan terjemahan sementara menyebabkan subtitle teks asli (bahasa Inggris) tersimpan ke database `subtitle_cache` lokal selama 7 hari, sehingga episode tersebut terkunci permanen dalam bahasa Inggris.
- **Validasi dan Pembersihan Cache Otomatis:** Sistem kini memvalidasi struktur kosakata bahasa Indonesia saat membaca cache subtitle. Entri cache lama yang terindikasi berisi teks mentah bahasa Inggris otomatis dihapus dan diterjemahkan ulang secara transparan.
- **Navigasi Next dan Previous Episode di ExoPlayer:** Mengatasi kendala tombol kontrol Next (`exo_next`) dan Previous (`exo_prev`) di `PlayerControlView` ExoPlayer (Media3) yang terkunci nonaktif secara internal akibat timeline MediaItem tunggal. Mengonfigurasi atribut layout XML `app:show_next_button="true"` dan `app:show_previous_button="true"`, memanggil `setShowNextButton(true)` dan `setShowPreviousButton(true)`, mengoreksi urutan inisialisasi agar `initExoPlayer` berjalan sebelum `setupExoNativeControls`, serta menerapkan logika batas navigasi optimistik sehingga tombol tetap responsif saat daftar episode sedang dimuat.
- **Pemuatan Metadata URL Episode dan Eliminasi Race Condition:** Memperbaiki penanganan respons endpoint resolver stream di mana master URL stream m3u8 tetap dipilih secara andal, membaca stream error secara tepat pada status non-200 tanpa melemparkan eksepsi prematur, mengisolasi setiap permintaan pemuatan stream dengan token identifikasi (`currentResolveLoadId`) agar pergantian episode beruntun tidak saling menimpa, serta menambahkan metadata judul serial dan nomor episode lengkap ke dalam `MediaMetadata` MediaItem Media3.
- **Pembersihan State saat Pergantian Episode:** Membersihkan referensi subtitle (`currentCues`, `currentSubLoadId`, teks overlay), stream URL, dan memanggil `player.clearMediaItems()` saat berpindah episode untuk mencegah tumpang tindih audio/video atau kebocoran subtitle episode sebelumnya.
- **Fallback Otakudesu pada Daftar Episode:** Memperbaiki endpoint `/api/anime/{slug}/episodes` agar secara otomatis beralih ke parser Otakudesu jika scraper HiAnime gagal atau anime berasal dari domain Otakudesu.

### Ditingkatkan
- **Sinkronisasi Penuh Aturan Translate Antar-Platform (Windows & Android):** Menyelaraskan seluruh modul dan berkas kamus penerjemah di `android/app/src/main/python/backend/` dengan repositori induk `backend/`. Memastikan runtime tersemat Chaquopy pada platform Android Mobile maupun Android TV memiliki 100% paritas aturan translasi, kamus kosakata atelier, dan penanganan fallback yang persis sama dengan platform Windows Portable dan Linux Desktop.
- **Kamus Referensi Fansub Fantasi & Atelier Sihir (Sampling Witch Hat Atelier):** Mengintegrasikan hasil audit dan sampling subtitle 13 episode *Witch Hat Atelier* ke dalam mesin penerjemah. Menambahkan kamus kosakata dunia sihir dan perapal mantra (*cast magic*, *conjuring ink*, *casting seal*, *magic stationer*, *witch apprentice*, *diadem herb*, *consent of the crown*) pada `_FANSUB_PROMPT_ID`, serta memperkaya filter penormalisasi `_UNIVERSAL_FANSUB_RULES`, `_CASUAL_FANSUB_RULES`, dan `_AIGTX_SMOOTH_RULES` guna mengeliminasi terjemahan kaku atau rancu (misal: "melakukan casting" menjadi "merapal sihir", "tinta sulap" menjadi "tinta sihir", "celah di tongkat" menjadi "retakan di tongkat", "toko alat tulis ajaib" menjadi "toko alat sihir", "memilih ramuan" menjadi "memetik herba", "sangat baik andal" menjadi "sangat mantap", "tiketnya terjual habis" menjadi "langsung ludes dalam sekejap", dan merapikan campuran kata ganti formal-santai). Perbaikan ini meningkatkan keluwesan tata bahasa untuk anime fantasi, atelier, petualangan, dan percakapan anime lainnya secara menyeluruh.
- **Menu Refresh / Terjemahkan Ulang Subtitle:** Menambahkan opsi aksi `[Refresh] Terjemahkan Ulang Subtitle (Hapus Cache)` pada dialog pemilih subtitle Android untuk membersihkan cache episode secara instan dan mengulang translasi dari awal.
- **Pacing dan Pembagian Mini-Batch Adaptif:** Mengurangi konkurensi pekerja menjadi 2 thread dengan jeda mikro antar batch dan mekanisme pembagian otomatis batch 20 baris menjadi 10 baris jika terjadi penolakan paket.
- **Pemuatan Asinkron Cadangan Daftar Episode di Pemutar:** Menambahkan `ensureEpisodeListLoaded()` di `PlayerActivity` untuk mengambil daftar episode secara otomatis jika pemutar dibuka langsung dari tautan riwayat atau intent eksternal tanpa membawa daftar episode lengkap.
- **Dukungan Tombol Fisik dan Keyboard Navigasi Episode:** Menambahkan pintasan `KEYCODE_N` (Next Episode) dan `KEYCODE_P` (Previous Episode) selain tombol media bawaan untuk kenyamanan pengendali remote TV dan keyboard fisik.

---

## [2.4.0] - 2026-10-12

### Ditambahkan
- **Fitur Jadwal Rilis 3 Hari:** Endpoint backend `/api/schedule` yang membatasi dan mengelompokkan jadwal tayang menjadi Kemarin, Hari Ini, dan Besok dengan zona waktu Indonesia Barat (WIB, UTC+7).
- **Filter Ketat Ketersediaan Judul:** Judul anime yang tidak tersedia pada scraper lokal otomatis dihapus dari jadwal sehingga setiap judul yang tampil dijamin dapat diputar.
- **Tab Jadwal Android Mobile:** Tab segmented `[Jadwal]` dan chip selector 3 hari khusus pada antarmuka Android Mobile (`!TvFocusHelper.isTv`).
- **Selector Chip Jadwal Web & Desktop:** Tombol filter interaktif 3 hari pada antarmuka Web, Windows Portable, dan Linux AppImage.
- **Fitur Navigasi Relasi Season Anime:** Endpoint `/api/anime/{slug}/relations` beserta tombol navigasi relasi (Prekuel, Season 1, Sekuel, Movie) di halaman detail anime.
- **Algoritma Origin Discovery:** Penelusuran rantai prekuel ke belakang (*backward-tracing*) untuk mendeteksi anime awal (Season 1) secara otomatis.
- **Counter Statistik Repositori di README:** Menambahkan badge counter real-time (GitHub Stars, Forks, Total Downloads, Repository Views/Hits, dan Open Issues) pada berkas `README.md`.

### Ditingkatkan
- **Optimasi Loading Episode Panjang:** Sistem caching dua lapis (SQLite backend dan memory cache) untuk serial dengan ratusan hingga ribuan episode, memangkas latensi pemuatan dari hitungan detik menjadi instan (< 50ms).
- **Format Jam Rilis pada Kartu:** Menampilkan label jam tayang WIB pada kartu anime di daftar jadwal.

### Diperbaiki
- **Isolasi Antarmuka Android TV:** Menjaga antarmuka Android TV tetap bersih dengan 3 tab standar tanpa merusak fokus navigasi D-pad.

---

## [2.3.16] - 2026-10-11

### Diperbaiki
- Reset sesi decoder saat perpindahan resolusi untuk mencegah distorsi zoom berlebih dan penyusutan layar (*shrink*) pada Android TV.

---

## [2.3.15] - 2026-10-11

### Diperbaiki
- Eliminasi masalah zoom dan pemulihan SurfaceView native dengan penskalaan rasio fit pada pemutar Android TV.

---

## [2.3.14] - 2026-10-11

### Diperbaiki
- Penghapusan loop resolusi melalui track override dan perbaikan penyusutan layar menggunakan TextureView fallback.

---

## [2.3.13] - 2026-10-11

### Diperbaiki
- Perbaikan garis hitam asimetris pada rasio aspek resolusi TV dan penambahan auto-focus pada hasil pencarian Android TV.

---

## [2.3.12] - 2026-10-11

### Diperbaiki
- Mengatasi java `EOFException` pada segmen video proxy HLS (`drama1.cfd`) dan peningkatan penanganan kegagalan socket.

---

## [2.3.11] - 2026-10-10

### Diperbaiki
- Eliminasi *double-probe* pada video proxy lokal, perpanjangan batas waktu koneksi (*connect timeout*), dan penambahan mekanisme stream retry.

---

## [2.3.10] - 2026-10-10

### Diperbaiki
- Mengatasi error sumber stream pada HLS anime yang sedang tayang (*ongoing*) dan penambahan fallback otomatis ke engine desync.

---

## [2.3.8] - 2026-10-10

### Diperbaiki
- Mengatasi masalah audio hening pada multi-rendition stream HiAnime saat beralih resolusi kualitas video.

---

## [2.3.7] - 2026-10-10

### Diperbaiki
- Perbaikan audio yang hilang pada stream puterin dan penyelarasan ukuran subtitle pada mode layar penuh.

---

## [2.3.6] - 2026-10-10

### Ditambahkan
- Desain ulang tata letak antarmuka Web, Windows, dan Linux dengan gaya modern bernuansa terminal.

---

## [2.3.4] - 2026-10-10

### Ditambahkan
- Integrasi pengaturan subtitle, pilihan kualitas video, dan rasio aspek langsung ke dalam kontroler bawaan ExoPlayer.

---

## [2.3.3] - 2026-10-10

### Ditambahkan
- Tombol navigasi episode berikutnya/sebelumnya (Next/Prev) pada kontroler native ExoPlayer serta mekanisme *background pre-resolving* stream episode lanjutan.

---

## [2.3.0] - 2026-10-10

### Ditambahkan
- **Inisiasi Arsitektur Android TV:** Penambahan target *product flavor* khusus TV (`tatap-tv-release-v*.apk`) terpisah dari Mobile.
- **Navigasi D-Pad TV:** Sistem penanganan fokus D-pad komprehensif (`TvFocusHelper`), penskalaan kartu (*card focus highlight*), dan dukungan remote televisi.
- **Standardisasi SemVer 2.0.0:** Penerapan aturan penomoran SemVer atomik di seluruh berkas proyek (`VERSION`, Android Gradle, dan script otomasi `tools/bump_version.py`).

---

## [2.2.0] - 2026-10-09

### Ditambahkan
- **Ekspansi Platform Android Mobile:** Peluncuran rilis perdana APK Android native menggunakan runtime Chaquopy Python lokal dan pemutar native ExoPlayer.
- **Rilis Multiplatform:** Standarisasi build rilis untuk Windows Portable, Linux AppImage, dan Android Mobile.

### Diperbaiki
- Penanganan rendering subtitle agar tetap aktif dan konsisten saat berpindah ke mode layar penuh.

---

## [2.1.0] - 2026-10-08

### Ditambahkan
- **Mesin Penerjemah AI Subtitle (BYOK):** Fitur auto-translate subtitle berbasis model bahasa besar (*Bring Your Own Key*) dengan dukungan Google Gemini, Groq Cloud, Ollama, dan OpenAI.
- Perintah terminal pemutar (`:gemini`, `:groq`, `:openai`, `:ollama`, `:model`, `:apikey`).

---

## [2.0.0] - 2026-10-05

### Diubah (Perombakan Arsitektur / Breaking Change)
- **Peluncur Native Desktop Standalone:** Beralih dari penggunaan tab browser peramban eksternal menjadi aplikasi native desktop mandiri (*standalone window*) berbasis Go launcher dan Microsoft Edge WebView2.
- **Integrasi Siklus Hidup Aplikasi:** Menutup jendela aplikasi secara otomatis mematikan backend lokal, dilengkapi proteksi instans tunggal (*single instance lock*).
- **Penyimpanan Terpusat:** Struktur penyimpanan lokal terisolasi di `webview2-data` dan database SQLite lokal.

---

## [1.1.0] - 2026-10-03

### Ditambahkan
- Dukungan multi-track subtitle dan pemilih dropdown subtitle di pemutar video.
- Migrasi skema database lokal untuk pencatatan preferensi subtitle pengguna.

---

## [1.0.0] - 2026-10-01

### Ditambahkan
- Inisiasi rilis perdana Tatap: Pemutar dan agregator anime mandiri tanpa server publik.
- Backend FastAPI lokal dengan scraping multi-sumber (HiAnime dan Otakudesu).
- Pemutar Web HLS dengan fitur Ambient Stage Light, penyesuaian rasio layar, dan proteksi bypass DPI via TLS desync.
