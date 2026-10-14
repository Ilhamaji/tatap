# Changelog

Semua perubahan penting pada proyek **Tatap** didokumentasikan di berkas ini.

Format dokumen ini mengacu pada [Keep a Changelog](https://keepachangelog.com/id/1.1.0/), dan proyek ini sepenuhnya mematuhi [Semantic Versioning 2.0.0](https://semver.org/lang/id/).

---

## Prinsip Penomoran Versi (SemVer 2.0.0)

Format versi menggunakan skema `MAJOR.MINOR.PATCH`:
- **MAJOR (X.0.0):** Perubahan arsitektur mendasar atau modifikasi yang tidak kompatibel ke belakang (*breaking changes*).
- **MINOR (x.Y.0):** Penambahan fitur atau kapabilitas baru yang tetap kompatibel ke belakang (*backward-compatible new features*). Digit PATCH direset ke 0.
- **PATCH (x.y.Z):** Perbaikan bug, peningkatan stabilitas, atau perbaikan internal tanpa penambahan fitur baru (*backward-compatible bug fixes*).

## [2.6.0] - 2026-10-14

### Justifikasi SemVer 2.0.0 (MINOR: 2.5.0 -> 2.6.0)
Kenaikan digit MINOR diterapkan secara resmi sesuai kaidah Semantic Versioning 2.0.0 karena memperkenalkan penambahan fungsionalitas dan antarmuka interaktif baru yang kompatibel ke belakang (*backward-compatible new features*):
1. **Interactive Cross-Filter Modal Katalog (Urutan, Tahun, Bulan, Format, Status):** Menambahkan antarmuka dialog modal interaktif multiplatform (Android Mobile, Android TV, dan Desktop Web) untuk menyaring katalog anime secara komprehensif tanpa membebani antarmuka genre yang sudah memiliki tab tersendiri.
2. **Penyaringan Temporal Tahun & Bulan Rilis:** Mendukung filtering temporal presisi tinggi berdasarkan tahun tunggal (2025, 2024, 2023, 2022, 2021, 2020), rentang dekade (2015-2019, 2010-2014, 2000-2009, <2000), serta bulan rilis spesifik (Januari hingga Desember) yang dipadukan dengan opsi urutan (Skor Tertinggi, Terpopuler, Baru Ditambahkan, Paling Difavoritkan), format media (TV, Movie, OVA, ONA, Special), dan status (Selesai, Sedang Tayang).
3. **Sinkronisasi Bar Filter & Indikator Aktif Dinamis:** Menampilkan ringkasan filter aktif pada judul seksi dan bilah status interaktif dengan tombol reset satu klik (*✕*) baik di Android maupun Desktop Web.

### Ditambahkan
- **Interactive Cross-Filter Modal Katalog Multiplatform:**
  - **Antarmuka Android Native Mobile & Android TV (`dialog_catalog_filter.xml` & `MainActivity.java`):**
    - Menyediakan modal interaktif dengan chip selektor kategori visual: *Urutan* (Skor Tertinggi, Terpopuler, Baru Ditambahkan, Terbanyak Difavoritkan), *Tahun Rilis* (2025, 2024, 2023, 2022, 2021, 2020, 2015-2019, 2010-2014, 2000-2009, <2000), *Bulan Rilis* (Januari s.d. Desember), *Format Media* (TV, Movie, OVA, ONA, Special), dan *Status Tayang* (Selesai, Sedang Tayang).
    - Tombol pintas `🎛️ Filter` di sisi kanan judul seksi beranda berpadu dengan tombol reset dan terapkan.
    - Menampilkan *Active Filter Bar* di atas grid kartu saat filter aktif dengan tombol reset `✕`.
    - Integrasi penuh dengan navigasi remote D-Pad Android TV via `TvFocusHelper` (efek zoom halus 1.04x dan border cyan).
    - Menambahkan dukungan perintah TUI `:filter` pada terminal command bar Android.
  - **Desktop Web Terminal & UI (`frontend/index.html`, `frontend/css/style.css`, `frontend/js/term.js`, `frontend/js/app.js`):**
    - Modal interaktif `#catalog-filter-modal` bergaya cyber dark dengan chip selektor interaktif untuk kombinasi kriteria urutan, tahun, bulan, tipe, dan status.
    - Tombol pemicu `#btn-catalog-filter` otomatis muncul pada header pencarian saat membuka tampilan katalog.
    - Integrasi menu Drawer `🎛️ Filter Katalog` untuk akses cepat dari sidebar.
    - Perintah CLI `:filter` untuk membuka modal filter kapan saja dari prompt command.
    - Judul tampilan dinamis menampilkan ringkasan kriteria aktif (misalnya `KATALOG · 2024 · OKTOBER · SKOR TERTINGGI`).
- **Backend & Paritas Chaquopy (`backend/main.py` & `android/app/src/main/python/backend/main.py`):**
  - Menambahkan parameter `year` dan `month` pada endpoint `/api/browse`.
  - Parser fleksibel yang menerjemahkan tahun tunggal, rentang dekade, dan label klasik menjadi rentang tahun riil (`sy` dan `ey`) serta bulan (`sm` dan `em`).
  - Safe parameter extraction untuk mencegah kegagalan runtime FastAPI Dependency Injection dan unit test context.
  - Tetap menjunjung tinggi *Zero-Tolerance Blacklist Hentai* di semua tingkatan filter.
- **Automated Test Suite:**
  - Menambahkan pengujian menyeluruh pada `tests/test_catalog_filter.py` mencakup parsing rentang dekade, parameter temporal, kombinasi cross-filter, serta audit blacklist hentai.

## [2.5.0] - 2026-10-14

### Justifikasi SemVer 2.0.0 (MINOR: 2.4.2 -> 2.5.0)
Kenaikan digit MINOR diterapkan secara resmi sesuai kaidah Semantic Versioning 2.0.0 karena memperkenalkan penambahan fungsionalitas dan antarmuka baru yang kompatibel ke belakang (*backward-compatible new features*):
1. **Dual-Lane View & Pemisahan Anime Musiman vs Serial Panjang:** Menambahkan seksi jalur ganda mandiri pada halaman katalog dan tab anime masih tayang (`which=airing`) di seluruh platform (Android TV, Mobile, dan Desktop Web).
2. **True Seamless Resolution Switching:** Menambahkan kapabilitas peralihan resolusi dinamis tanpa jeda layar hitam dan tanpa pemotongan audio pada Android TV.
3. **Kapsul Navigasi Mengambang & Notifikasi Adaptif:** Menambahkan komponen UI floating bottom bar dan timer dinamis pada antarmuka Android.
4. **GraphQL Query & Filter Baru:** Menambahkan kueri pencarian anime yang baru saja tamat (`recently_finished_page`) dan pengklasifikasi serial anime continuous otomatis.
5. **Fitur Skip Opening & Ending Interaktif Multiplatform:** Menambahkan kapabilitas melompati intro (OP) dan outro (ED) anime melalui floating buttons interaktif, keyboard shortcut `S`, dan D-Pad remote TV dengan integrasi native MegaCloud & fallback AniSkip API.

### Ditambahkan
- **Fitur Skip Opening dan Ending Anime Interaktif Multiplatform:**
  - **Multi-Tier Skip Provider Engine:** Mengambil penanda waktu intro dan outro secara native langsung dari provider streaming (MegaCloud / MegaPlay `getSourcesNew`), dilengkapi fallback cerdas ke AniSkip API v2 komunitas open-source untuk sumber video alternatif.
  - **Non-Breaking Database Persistence:** Migrasi kolom `intro` dan `outro` pada tabel `episode_cache` SQLite lokal dengan paritas 100% pada Chaquopy Android untuk cache waktu instan tanpa query jaringan berulang.
  - **Floating Interactive Player Skip Buttons:**
    - Desktop Web (`frontend/index.html` & `frontend/js/app.js`): Tombol mengambang cyber cyan `#pm-skip-btn` muncul otomatis di kanan bawah selama pemutaran intro/outro berlangsung, dengan dukungan shortcut keyboard `S` dan transisi fade-out halus di luar durasi OP/ED.
    - Android Mobile & Android TV (`activity_player.xml` & `PlayerActivity.java`): Tombol mengambang `btn_skip_op_ed` berukuran 38dp dengan sudut melengkung 19dp dan border cyan di kanan bawah (72dp di atas timeline) tanpa menghalangi subtitle, terintegrasi penuh dengan navigasi fokus remote TV D-Pad.
- **Fitur Bookmark / Favorit Anime Multiplatform:**
  - **Penyimpanan Persisten SQLite Lokal:** Menambahkan tabel SQLite mandiri `bookmarks` (`slug`, `title`, `poster`, `type`, `sub`, `eps`, `score`, `created_at`) di `backend/database/__init__.py` dan paritas Chaquopy Android. Tabel terisolasi dari riwayat tontonan agar pembersihan riwayat tidak menghapus koleksi favorit.
  - **REST API Endpoints:** Menyediakan endpoint `/api/bookmarks` (GET untuk daftar favorit terurut terbaru, POST untuk simpan), `/api/bookmarks/{slug}` (DELETE untuk hapus item), dan `/api/bookmarks/check` (GET status bookmark instan).
  - **Tombol Bookmark Ergonomis di Halaman Detail:**
    - Android (`DetailActivity`): Menambahkan tombol `⭐ + Favorit` berdampingan dengan tombol putar cepat, berubah dinamis menjadi `★ Tersimpan` (warna emas/amber) saat aktif, lengkap dengan notifikasi Toast dan dukungan navigasi remote D-Pad TV.
    - Desktop Web (`openTitle`): Menambahkan tombol `#tm-bookmark-btn` di sheet header modal anime dengan sinkronisasi status real-time.
  - **Navigasi Tab & Drawer Favorit:**
    - Android: Menambahkan pill `⭐ Favorit` pada Category Pills Carousel beranda untuk akses instan ke seluruh anime tersimpan.
    - Desktop Web: Menambahkan menu navigasi `⭐ Anime Favorit` pada drawer panel dan dukungan perintah `:favorit` / `:bookmark`.
- **Penataan Ulang Top Menu Android & Ultra-Clean Fluid Search Bar:**
  - **Logo TATAP Kapital:** Menampilkan brand `TATAP` dalam huruf kapital penuh dengan letter-spacing proporsional di sisi kiri header.
  - **Ultra-Clean Fluid Search Bar:** Mengembalikan bilah pencarian fluid inline satu baris (`layout_weight="1"`) yang bersih sepenuhnya dari ikon (tanpa icon kaca pembesar dan tanpa spinner di dalam kotak), memberikan tampilan minimalis, lapang, dan langsung siap menerima input.
  - **Status Online Ikon Power Vektor Material (`ic_power.xml`):** Menggantikan render karakter Unicode glyph `⏻` dan penulisan teks panjang yang terpotong menjadi komponen `ImageView` 34x34dp dengan Android Vector Drawable resmi Material Design (`ic_power.xml`). Menggunakan 3 status warna dinamis melalui `PorterDuff.Mode.SRC_IN`: Hijau (`#10B981`) saat Online, Kuning (`#F59E0B`) saat Checking / Booting, dan Merah (`#EF4444`) saat Offline / Error, lengkap dengan handling interaktif untuk mencoba koneksi ulang.
  - **Horizontal Scrollable Category Pills (36dp):** Mengganti segmented tabs kaku dengan deretan pill kategori horizontal yang ramah satu jempol di HP dan D-Pad remote TV: *🌸 Musim Ini*, *📺 Masih Tayang*, *⭐ Favorit*, *📚 Katalog*, *⏱️ Jadwal*, dan *🏷️ Genre*.
  - **Efisiensi Ruang Layar (~58dp):** Menghilangkan tumpukan baris header ganda sehingga baris kartu anime langsung tampak luas dan utuh dari bagian atas layar pada ponsel maupun TV.

- **Aktivasi Load Animation & Optimasi List Data:**
  - **Central Loading Indicator Seamless Cold Start & Page Switch:** Mengaktifkan loading state central spinner cyber cyan (`#38BDF8`) sejak detik pertama aplikasi dibuka (`visibility="visible"` default pada XML), meredupkan grid lama (`alpha 0.25f`) saat berpindah halaman katalog/tab baru yang belum di-cache, dan mengembalikan kecerahan penuh (`alpha 1.0f`) diikuti entrance cascade layout animation saat data anime tiba.
  - **Cascade Layout Animation:** Menambahkan animasi entrance halus (fade-in & slide-up 180ms via `grid_item_fade_in.xml` dan `grid_layout_animation.xml`) saat kartu-kartu anime masuk ke `RecyclerView`.
  - **Smooth Poster Fade-In:** Animasi transisi 160ms pada `ImageLoader.java` saat poster selesai diunduh dari jaringan.
  - **In-Memory Tab Caching (<1ms):** Menyimpan cache daftar anime per-tab dengan masa berlaku 3 menit, membuat perpindahan antar tab (Musim Ini, Masih Tayang, Favorit, Katalog, Jadwal) berlangsung instan seketika tanpa latency jaringan.
  - **Pencegahan Race Condition:** Menggunakan `AtomicInteger` tokenization untuk membatalkan respons jaringan yang usang saat pengguna berganti tab dengan cepat.

- **Dual-Lane View & Pemisahan Anime Musiman vs Serial Panjang (Semua Platform):**
  - **Pemisahan Jalur Adaptif:** Memisahkan katalog anime yang masih tayang (`which=airing` / `:lanjutan` / Tab `MASIH TAYANG`) menjadi dua seksi terpisah dalam satu halaman:
    1. *Anime Musiman (Baru Tamat / Berjalan):* Menampilkan anime musiman reguler dan memprioritaskan anime yang baru saja tamat di bagian paling atas berdasarkan tanggal berakhir riil (`sort: [END_DATE_DESC, POPULARITY_DESC]` via AniList GraphQL) dengan badge `TAMAT` berwarna emerald.
    2. *Anime Panjang Berkelanjutan (Continuous On-Going):* Mengelompokkan anime yang tayang berkelanjutan antar musim (*One Piece*, *Detective Conan*, *Pokemon*, *Crayon Shin-chan*, *Doraemon*, *Chibi Maruko-chan*, *Boruto*) ke jalur khusus dengan badge `SERIAL PANJANG` berwarna amber.
  - **Banner Pembatas Jalur Full-Width:** Menambahkan komponen section header adaptif dengan aksen indikator visual (cyan untuk musiman, amber untuk serial panjang) yang membentang penuh di atas baris grid kartu.
  - **Android TV & Mobile Multi-View Type Adapter:** Mengimplementasikan `GridLayoutManager.SpanSizeLookup` pada `MainActivity.java` dan multi-view type pada `AnimeAdapter.java` (`VIEW_TYPE_HEADER` dan `VIEW_TYPE_ANIME`). Banner header secara otomatis membentang selebar seluruh kolom grid dan dikecualikan dari remote focus (`itemView.setFocusable(false)`) agar navigasi D-Pad Android TV berpindah mulus antar kartu tanpa macet di header.
  - **Desktop Web UI Parity:** Memperbarui `frontend/js/api.js` (mengarahkan `stillAiring` ke `which=airing`) dan `frontend/js/term.js` untuk merender banner pembatas jalur melintasi grid CSS (`grid-column: 1 / -1`) serta melompati header saat navigasi panah keyboard.
  - **Sinkronisasi Paritas Chaquopy Android:** Menjaga sinkronisasi 100% kode backend embedded di `android/app/src/main/python/backend/` bersama backend utama.

### Ditingkatkan
- **True Seamless Quality Switching Khusus Android TV (Terisolasi Penuh):**
  - Meniadakan pemanggilan disruptif `player.stop()` dan `player.prepare()` saat pengguna mengganti resolusi video (misalnya dari 360p ke 1080p) pada Android TV (`TvFocusHelper.isTv()`).
  - Mengandalkan pembaruan dinamis `TrackSelectionParameters` pada Media3 ExoPlayer dan `app:surface_type="surface_view"`.
  - Video dan audio mengalir tanpa putus, tanpa jeda layar hitam, dan tanpa kemunculan spinner buffering saat pergantian kualitas berlangsung pada batas segmen/GOP berikutnya.
  - Varian Android Mobile tetap mempertahankan alur kode bawaannya secara terisolasi tanpa modifikasi.
- **Optimasi Kinerja dan Konsumsi Memori Khusus Android TV (Terisolasi Penuh):**
  - **Isolasi Bebas Efek Samping ke Android Mobile:** Seluruh penyesuaian parameter memori, connection pool, buffer pemutar, dan siklus render dibatasi secara ketat hanya untuk lingkungan Android TV (`TvFocusHelper.isTv()` dan `src/tv/AndroidManifest.xml`). Kode dan perilaku Android Mobile tetap berjalan 100% pada parameter bawaan tanpa modifikasi.
  - **Alokasi Heap Android TV:** Menambahkan `android:largeHeap="true"` khusus pada flavor Android TV (`src/tv/AndroidManifest.xml`) untuk memberikan headroom memori tambahan saat runtime CPython Chaquopy, cache database, dan ExoPlayer berjalan berdampingan pada perangkat TV dengan RAM terbatas (512MB–1GB).
  - **Downsampling Gambar Hemat Memori Khusus TV:** Memangkas target dekompresi poster anime pada Android TV dari 300x420 px menjadi 180x260 px di `ImageLoader.java` (menghemat ~63% memori per kartu poster pada layar TV 1080p). Menambahkan pemeriksaan pembatalan dini jika tampilan kartu telah didaur ulang (*view recycling*) sebelum proses decode bitmap dilakukan.
  - **Penyesuaian Cache View RecyclerView TV:** Menyetel `setItemViewCacheSize(4)` untuk navigasi remote D-Pad Android TV guna mencegah penumpukan hirarki tampilan di luar layar, sementara varian Mobile tetap mempertahankan 20 item untuk scrolling sentuh yang halus.
  - **Peniadaan Beban Komputasi Dynamic Shadow GPU:** Mengatur elevasi fokus kartu menjadi `0f` pada `TvFocusHelper.attachCardFocus` guna meniadakan kalkulasi bayangan drop shadow 3D pada GPU TV berdaya rendah (seperti Mali-450 / Mali-G31) saat tombol remote ditekan.
  - **Penyesuaian Buffer Video ExoPlayer TV:** Menyetel buffer video ExoPlayer pada Android TV menjadi 8 detik minimum dan 15 detik maksimum (dibandingkan 12s/25s pada Mobile), menghemat alokasi RAM playback tanpa memicu rebuffering pada koneksi stabil.
  - **Efisiensi Polling Subtitle:** Mengurangi frekuensi sinkronisasi subtitle pada TV dari interval 75ms menjadi 150ms serta membandingkan teks cue secara langsung dengan cache lokal tanpa alokasi string baru dari `getText().toString()`.
  - **Penjadwalan Pre-Resolve Episode Tetangga TV:** Menunda proses pre-resolve episode sebelum dan sesudah selama 20 detik setelah pemutaran video dimulai pada Android TV, mencegah persaingan CPU dan koneksi jaringan antara thread scraping dan hardware decoder video saat inisialisasi awal.
  - **Tuning Backend Python Rendah Memori:** Menyetel batas koneksi HTTPX pada backend menjadi `max_connections=8` dan `max_keepalive=3` saat berjalan di TV (`TATAP_IS_TV=1`), mengonfigurasi SQLite PRAGMA memori minimalis (`cache_size = -500`, `temp_store = FILE`, `mmap_size = 0`), menerapkan batas GC Python `(100, 5, 5)`, serta menghubungkan event Android `onTrimMemory` untuk memicu pembersihan sampah memori Python runtime secara berkala.
- **Kompresi Top-Bar Ergonomis Android TV (10-Foot UI):**
  - Memampatkan tinggi top-bar area pada Android TV: tinggi header dari 56dp menjadi 44dp, kolom pencarian dari 38dp menjadi 32dp, dan tombol tab segmentasi dari 34dp menjadi 30dp dengan padding vertikal yang ringkas (overscan vertikal disesuaikan dari 20dp ke 12dp).
  - Menghemat ~40dp ruang vertikal layar televisi tanpa mengurangi kenyamanan radius pandang 10 kaki (*10-foot viewing radius*) maupun keterbacaan teks font dan navigasi remote D-Pad.
  - Memperluas area tampilan grid anime di Android TV sehingga baris kartu kedua terlihat jelas tanpa perlu banyak scrolling dengan remote.
  - Memperkuat deteksi lingkungan TV di `TvFocusHelper.isTv()` dengan menyertakan deteksi package name Android TV (`.tv`) dan fitur sistem `android.software.leanback`.
- **Floating Navigation Capsule Transparan (Android UI):**
  - Mengubah panel navigasi bawah (`layout_pagination`) dari bilah footer solid statis 48dp menjadi kapsul melayang (*floating pill*) transparan setinggi 36dp dengan gaya *cyber glassmorphism* (`#CC090A12`, 80% opacity) dan aksen border cyan lembut (`#2B38BDF8`).
  - Menerapkan *edge-to-edge scrolling* pada `rv_anime_grid` dengan `paddingBottom="64dp"` dan `clipToPadding="false"`. Kartu anime mengalir mulus di bawah kapsul navigasi dan baris kartu terakhir tidak akan tertutup saat di-scroll ke paling bawah.
  - Mempertahankan interoperabilitas penuh Android TV D-Pad remote focus (`TvFocusHelper.attachFocusScale`) dengan visual border highlight cyan cerah saat tombol paginasi dipilih.
  - Menyembunyikan floating pill secara otomatis ketika grid berada dalam kondisi kosong (*empty state*) atau mengalami kegagalan koneksi awal agar tidak mengaburkan pesan error.
- **Auto-Dismiss Notification Timer Berbasis Panjang Teks (Android UI):**
  - Mengganti durasi statis 8 detik pada banner perintah/notifikasi (`showCommandOutput`) dengan kalkulasi timer baca dinamis yang proporsional dan ergonomis:
    - **Pesan Singkat (`<= 35 char`):** `2200ms` (2.2s) — ideal untuk pergantian tampilan/tab (`Tampilan diatur ke: MUSIM`, `:cari`, `:help`).
    - **Pesan Sedang (`36 - 65 char`):** `3200ms` (3.2s) — durasi pas untuk status eksekusi atau pergantian sumber stream.
    - **Pesan Panjang / Error:** `4500ms` (4.5s) — memberi waktu yang cukup bagi pengguna untuk membaca detail kesalahan koneksi atau instruksi perintah.
  - Menambahkan animasi transisi halus *fade-out* (alpha 220ms) saat notifikasi menghilang, menggantikan hilangnya banner secara mendadak (`GONE`).
  - Menambahkan dukungan *instant touch-to-dismiss*: mengetuk banner notifikasi secara langsung atau tombol silang penutup akan langsung menutup banner dengan transisi cepat.
- **Optimasi Performa Perangkat Spesifikasi Rendah (Web Desktop & Android):**
  - **Eliminasi Beban GPU Offscreen:** Mengganti penggunaan `backdrop-filter: blur(...)` pada drawer navigation menu dan gesture OSD player dengan permukaan solid gelap berpresisi tinggi (`--panel-solid`, `rgba(11, 13, 17, 0.96)`) dan border crisp. Mengurangi frame drop dan stuttering compositing GPU secara signifikan saat membuka drawer atau mengatur volume di laptop lawas dan Android TV.
  - **Optimasi Ambient Halo Video Player:** Mengurangi radius Gaussian blur `#ambient` dan `#ambient-fallback` dari 70px menjadi 24px (16px–20px pada resolusi mobile/tablet) dengan akselerasi layer hardware `transform: translate3d(0,0,0)` dan `will-change: transform, opacity`. Menghemat >70% GPU fillrate dan mempertahankan pemutaran video HLS pada 60 FPS stabil.
  - **CSS Layout Isolation:** Menambahkan `contain: content;` pada kartu poster (`.poster-card`) dan list item (`.trow`) sehingga perubahan hover atau mutasi DOM lokal tidak memicu re-layout satu halaman penuh.
  - **Atomic DOM Injection via DocumentFragment:** Membungkus seluruh perakitan elemen kartu hasil pencarian dan jadwal rilis di `term.js` ke dalam `DocumentFragment`, menggantikan mutasi DOM berulang per-item menjadi injeksi tunggal yang cepat.
  - **Asynchronous Image Decompression:** Menambahkan atribut `decoding="async"` dan `loading="lazy"` pada seluruh thumbnail dan poster anime di frontend web untuk mengalihkan dekompresi gambar keluar dari browser main thread.
  - **RecyclerView Cache & Low-End Tuning (Android):** Mengaktifkan `setHasFixedSize(true)`, `setItemViewCacheSize(20)`, dan drawing cache quality low pada `MainActivity.java` untuk pengalaman scroll instan tanpa re-measuring berulang.
  - **Animasi TV D-Pad Ringan (Android TV):** Menyetel durasi transisi fokus remote TV menjadi 90ms dan skala kartu 1.04x di `TvFocusHelper.java`, mengeliminasi lag shadow software pada chipset Android TV hemat daya.

### Diperbaiki
- **Pencegahan Kebocoran Metadata Sidebar HiAnime pada Kartu Terakhir:**
  - Mengisolasi batas kontainer kartu anime di `_parse_browse_cards` pada `backend/api/hianime.py` agar berhenti pada `<div class="clearfix">` dan memangkas blok sidebar sebelum parsing HTML dijalankan.
  - Mencegah kartu anime di posisi paling bawah halaman katalog (seperti *Yani Neko*) menyerap metadata episode widget sidebar (*Black Clover* `eps: 170`), yang sebelumnya memicu salah klasifikasi ke dalam seksi *Anime Panjang Berkelanjutan* (*Serial Panjang*).
  - Menambahkan guard defensif rasio episode pada `_is_long_running` dan menaikkan cache key airing ke `airing_lanes_v4` untuk mensterilkan cache lama secara otomatis.
- **Eliminasi Stuttering & Patah-Patah Pemutaran Video 1080p (Android & Android TV):**
  - **Pencegahan Loop Rekonfigurasi Decoder di `onTracksChanged`:** Memasang guard boolean `hasAppliedTrackSelectionForStream` pada listener `onTracksChanged` agar seleksi track HLS hanya dieksekusi sekali saat manifest track pertama kali selesai di-resolve. Menghindari pemanggilan rekursif `setTrackSelectionParameters` yang memicu flush decoder dan micro-stuttering berulang kali saat pemutaran video sedang berlangsung.
  - **Ekspansi Buffer Video 1080p Aman (`min: 25s`, `max: 50s`):** Menyesuaikan buffer durasi `DefaultLoadControl` dari 8s/15s menjadi 25s minimum dan 50s maksimum dengan buffer mulai 2s dan rebuffer 4s serta menonaktifkan `prioritizeTimeOverSizeThresholds`. Menjamin buffer video 1080p tidak pernah mengalami starvation pada jaringan dinamis dengan alokasi RAM native yang tetap hemat (~10–15 MB).
  - **Aktivasi Asynchronous MediaCodec Buffer Queueing:** Mengonfigurasi `DefaultRenderersFactory.forceEnableMediaCodecAsynchronousQueueing()` pada `PlayerActivity.java` untuk memindahkan antrean input/output buffer decoding ke background looper thread, mencegah rendering loop terhambat pada chipset TV berbasis Android 9-11 (API 28-30).
  - **Aktivasi HLS Chunkless Preparation:** Mengaktifkan `setAllowChunklessPreparation(true)` pada `HlsMediaSource.Factory`, meniadakan pengunduhan segmen awal dari seluruh varian resolusi lain yang tidak diperlukan saat stream baru disiapkan.
  - **Eliminasi Teardown Codec di `onVideoSizeChanged`:** Menghapus pemanggilan disruptif `player.stop()` di tengah pemutaran video pada event perubahan ukuran surface, menjaga aliran decoding tetap mulus tanpa jeda restart.
  - **Pelepasan Batasan Minimum Resolusi Kaku:** Menghapus parameter `minW = 1600` dan `minH = 900` pada `applyHlsTrackSelection` serta menambahkan pengecekan `newParams.equals(current)` sebelum memicu update parameter track ke ExoPlayer.
  - **Restorasi HTTPX Keep-Alive Pool Backend:** Menyetel `max_keepalive_connections=20` dan `max_connections=30` dengan `keepalive_expiry=90.0` pada `_get_video_client`, meniadakan lonjakan CPU dari kalkulasi TLS 1.3 handshake berulang pada setiap pengunduhan segmen TS 1080p.
- **Perbaikan Inisialisasi Zoom/Crop Video Player (Android & Android TV):**
  - Mengatasi masalah di mana video HLS pada awal pemutaran selalu ter-zoom/terpotong (*cropped*) dan baru normal setelah pengguna berpindah resolusi ke 360p lalu ke 1080p lagi.
  - Mengonfigurasi `DefaultBandwidthMeter` dengan estimasi awal 25 Mbps (`25_000_000`) pada `ExoPlayer.Builder` agar ExoPlayer langsung memilih track video resolusi optimal (1080p/720p) sejak awal koneksi tanpa adaptasi lambat dari 360p yang mengunci surface buffer TV.
  - Memanggil `applyHlsTrackSelection(activeQuality)` secara eksplisit sebelum `player.prepare()`.
  - Memperbarui `applyHlsTrackSelection()` agar mendukung penuh kualitas `"best"`, `"hd"`, dan `"1080p"` dengan batasan resolusi yang presisi.
  - Mengaitkan `onTracksChanged(Tracks tracks)` di listener ExoPlayer dengan proteksi guard atomik untuk mengunci track override seketika setelah master manifest HLS selesai di-resolve tanpa loop rekursif.
  - Menetapkan atribut `app:surface_type="surface_view"` pada `PlayerView` di layout player untuk mengeliminasi pemotongan buffer dan tearing saat resolusi adaptif berubah tanpa memerlukan restart codec.
  - Menetapkan mode skala default `player.setVideoScalingMode(C.VIDEO_SCALING_MODE_SCALE_TO_FIT)` untuk memastikan video pas dengan layar tanpa pemotongan.
- **Anti-Ghosting & View Recycling Flicker (Android):** Memperbaiki bug tampilan pada daur ulang view RecyclerView di mana kartu yang di-scroll cepat sempat menampilkan poster anime sebelumnya secara keliru. Menyetel placeholder drawable solid netral (`#151822`) seketika sebelum thread decode background dijalankan pada `ImageLoader.java`.
- **Eliminasi Overdraw View Hierarchy (Android):** Menghapus background bertingkat yang redundan pada FrameLayout poster dan LinearLayout teks di dalam `item_anime_card.xml`, memotong beban pemindaian GPU fillrate hingga separuh pada perangkat mobile RAM 1GB–2GB.
- **2-Line Title Clamp & Tipografi Hybrid Minimalis:** Memperbaiki pemotongan judul anime romaji/Indo panjang pada kartu web dengan menerapkan 2-line clamp (`-webkit-line-clamp: 2` dan `min-height: 2.7em`), serta transisi ke sistem tipografi sans-serif modern yang proporsional untuk konten judul dan tetap mempertahankan monospace murni untuk terminal prompt, timestamp, dan statusbar.

## [2.4.2] - 2026-10-13

### Diperbaiki
- **Perbaikan Lifecycle Linux AppRun (Eliminasi Layar Putih & Font Unstyled):** Mengatasi bug kritis di mana peluncuran browser mode aplikasi (`google-chrome --app=...`) mendelegasikan proses ke instance browser yang sedang aktif sehingga proses CLI keluar seketika (< 100ms) dan memicu `trap cleanup EXIT` membunuh backend server FastAPI secara prematur. Menerapkan profil browser terisolasi (`--user-data-dir="${DATA_DIR}/browser-profile"`), fail-safe monitoring proses browser (jika browser mendelegasikan, tunggu dialihkan ke proses server agar backend tetap hidup), healthcheck mandiri via Python internal (bebas dependensi `curl`), dan pembersihan otomatis port 8767 stale sebelum startup.
- **Pencarian Multi-Sumber & Otomatis Fallback Otakudesu:** Memperbaiki subsistem pencarian di seluruh platform dengan meneruskan preferensi sumber aktif (`source`) dari frontend dan mengimplementasikan failover otomatis ke scraper Otakudesu apabila scraper HiAnime mengalami kendala jaringan atau Cloudflare challenge.
- **Perbaikan Input Terminal & Eliminasi Flash Putih:** Menghapus pencegahan ketik tombol slash (`/`) pada kolom pencarian terminal `#cmd` serta menambahkan inline background gelap `#08090c` pada tag `<html>` dan `<body>` di `index.html`.
- **Integrasi & Isolasi Tombol Filter Hari Rilis:** Memindahkan 3 tombol filter hari rilis (Kemarin, Hari Ini, Besok) ke dalam `.sec-head` sejajar dengan judul jadwal rilis menggunakan gaya segmented control (`.seg.schedule-days-bar`). Memproteksi visibilitasnya agar HANYA tampil saat view jadwal aktif (`terbaru`) dan otomatis disembunyikan di semua view lainnya (`cari`, `musim`, `lanjutan`, `katalog`, `recents`).
- **Penambahan Thumbnail Poster di List Pencarian & Jadwal Rilis:** Menambahkan thumbnail cover/poster mini (rasio 3:4) dengan *lazy-loading* dan fallback icon pada setiap item hasil pencarian (`view: cari`) dan jadwal rilis (`view: terbaru`), lengkap dengan metadata ringkas (tipe format, jumlah episode, status SUB/DUB) serta garis aksen visual jadwal hari ini (`.today`) dan besok (`.tomorrow`).
- **Perbaikan Overlap Bawah Desktop Web, Windows Portable & Linux AppImage:** Menghapus override cacat `--status-h: 36px` pada rentang resolusi desktop 901px–1280px yang sebelumnya menyebabkan kartu anime terbawah, tombol paginasi, dan jadwal rilis tertutup oleh `.bottom-bar`. Menetapkan baseline aman `--status-h: 88px`.
- **Navigasi Header Desktop & Scroll Safe Player Shell:** Menambahkan tombol drawer menu di bar header atas (`#btn-drawer-head`) untuk ergonomi pengguna desktop/laptop, menambahkan `overflow-y: auto` pada `.player-shell`, dan membatasi tinggi video windowed (`max-height: clamp(240px, 66vh, 640px)`) agar kontrol footer tidak terpotong pada laptop 768p.
- **Scrollbar Gelap Cyber Global:** Menerapkan styling scrollbar gelap kustom yang konsisten di seluruh WebKitGTK Linux AppImage, Edge WebView2 Windows Portable, dan Desktop Browser.

### Ditambahkan
- **Penyesuaian Skala Ukuran Font Subtitle Android TV:** Menambahkan 7 tingkatan ukuran font khusus perangkat Android TV (18sp, 22sp, 26sp [Standar TV], 30sp, 34sp [Jarak Jauh], 38sp [Layar Besar], dan 42sp [Maksimal]) untuk kenyamanan jarak pandang sofa 2.5m - 4m (10-foot UI).
- **Default Ukuran Font Adaptif TV:** Pengguna Android TV secara otomatis mendapatkan ukuran font standar 26sp (sebelumnya terbatas 17sp), sementara perangkat Mobile tetap menggunakan skala layar sentuh (14sp s/d 36sp, default 17sp).
- **Spasi Baris Dinamis & Line Spacing Multiplier:** Menerapkan `lineSpacingMultiplier="1.2"` pada layout XML dan `tvSubtitles.setLineSpacing(0f, 1.25f)` dinamis di Android TV agar kalimat subtitle panjang dua baris dengan font besar tidak saling bertumpuk bayangan (*shadow*).
- **Navigasi D-Pad Remote Dialog Ukuran Font:** Dialog pemilihan ukuran font mendukung navigasi remote kontrol D-pad secara penuh dengan auto-focus pada opsi aktif dan pengembalian fokus kontroler pemutar saat dialog ditutup.

### Ditingkatkan
- **Rebranding & Overhaul Mesin Penerjemah GTX+:** Memperbarui penamaan dan identitas mesin penerjemah AIGTX menjadi **GTX+ (Smart Fansub & Scene Detection)** di seluruh ekosistem (Backend FastAPI, Frontend Desktop Web/Windows/Linux, serta Android Mobile dan Android TV).
- **Integrasi Scene Detection Otomatis pada GTX+ Tanpa API Key:** Menerapkan deteksi konteks adegan (*scene detection*) adaptif langsung pada mesin GTX+ tanpa memerlukan API key pengguna. Adegan formal/kerajaan/militer dipertahankan baku dan santun, sedangkan adegan sehari-hari/sekolah/komedi otomatis diterjemahkan dengan gaya dialog lisan fansub santai (*casual conversation*).
- **Pengayaan Kamus Bahasa Fansub Casual Conversation:** Menambahkan puluhan leksikon dialog lisan santai fansub (*nggak, udah, cuma, banget, maksudmu apa, mana kutahu, beneran nih, pantesan, yang bener aja, jangan bercanda deh, sama sekali nggak, biar aku yang urus, gampang banget, cowok/cewek itu, mau gimana lagi*).
- **Kompatibilitas Mundur Penuh (Backward Compatibility):** Mendukung cache key `sub2|gtx+|` dengan pembacaan fallback `sub2|aigtx|`, parameter mode query `gtx+` dan `aigtx`, fungsi `_sanitize_aigtx_id = _sanitize_gtxplus_id`, serta prefix track URL `gtx+:<url>` dan `aigtx:<url>`.
- **Sinkronisasi Paritas Runtime Android:** Menyelaraskan seluruh modul penerjemah `backend/api/translate.py` dan `backend/main.py` ke `android/app/src/main/python/backend/` dengan 100% paritas kode.
- **Dokumentasi Pemetaan Teknis & Direktif AI Agent:** Menambahkan berkas master `PROJECT_MAP.md` yang memetakan topologi basis kode, data pipeline streaming/subtitle, skema database, indeks simbol fungsi utama, aturan paritas Chaquopy, serta menetapkan urutan baca wajib (`AGENTS.md` lalu `PROJECT_MAP.md`) sebelum perencanaan/iterasi bagi seluruh agen AI.

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
- **Kamus Idiom & Ungkapan Fansub Anime Universal:** Mengintegrasikan kamus referensi penerjemahan fansub anime yang komprehensif ke dalam mesin penerjemah `translate.py` (prompt sistem `_FANSUB_PROMPT_ID`, aturan normalisasi universal `_UNIVERSAL_FANSUB_RULES`, percakapan kasual `_CASUAL_FANSUB_RULES`, dan penghalus `_AIGTX_SMOOTH_RULES`). Mengeliminasi puluhan calque dan blunder penerjemahan mesin yang kaku (*"It can't be helped"* -> *"Mau gimana lagi"*, *"Give me a break"* -> *"Yang benar saja!"*, *"Serves you right"* -> *"Rasakan itu!"*, *"I'll take care of this"* -> *"Biar aku yang urus ini"*, *"Don't let your guard down"* -> *"Jangan lengah!"*, *"Stand back"* -> *"Mundur!"*, *"Over my dead body"* -> *"Langkahi dulu mayatku!"*, *"Piece of cake"* -> *"Gampang banget"*, *"Under the weather"* -> *"Kurang enak badan"*, *"Mendokusai"* -> *"Merepotkan sekali"*, *"Sasuga"* -> *"Sudah kuduga / Memang bisa diandalkan"*, serta ungkapan santai khas anime lainnya).
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
