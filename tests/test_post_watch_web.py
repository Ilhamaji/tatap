import os
import subprocess
import pytest

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def test_post_watch_frontend_syntax():
    """Memverifikasi app.js lolos pemeriksaan sintaksis Node.js."""
    app_js_path = os.path.join(BASE_DIR, "frontend", "js", "app.js")
    assert os.path.exists(app_js_path), "frontend/js/app.js harus ada"
    res = subprocess.run(["node", "--check", app_js_path], capture_output=True, text=True)
    assert res.returncode == 0, f"Syntax error di app.js: {res.stderr}"


def test_post_watch_html_and_css():
    """Memverifikasi elemen DOM dan class styling untuk post-watch & last-watch marker."""
    html_path = os.path.join(BASE_DIR, "frontend", "index.html")
    with open(html_path, "r", encoding="utf-8") as f:
        html = f.read()

    assert 'id="rm-btn-cancel"' in html, "index.html harus memuat tombol #rm-btn-cancel"
    assert "Batal" in html, "index.html harus memuat label Batal pada tombol modal resume"

    css_path = os.path.join(BASE_DIR, "frontend", "css", "style.css")
    with open(css_path, "r", encoding="utf-8") as f:
        css = f.read()

    assert ".btn-resume-cancel" in css, "style.css harus memuat styling .btn-resume-cancel"
    assert ".ep.last-watch" in css, "style.css harus memuat styling .ep.last-watch dengan border dan glow cyan"
    assert ".ep-badge-last" in css, "style.css harus memuat styling badge .ep-badge-last"


def test_post_watch_js_logic():
    """Memverifikasi implementasi transisi post-watch, last-watch marker, dan dismissResumeModal di app.js."""
    app_js_path = os.path.join(BASE_DIR, "frontend", "js", "app.js")
    with open(app_js_path, "r", encoding="utf-8") as f:
        js = f.read()

    # 1. Helper tracking episode ditonton
    assert "function recordEpisodeWatched(" in js, "app.js harus mendefinisikan recordEpisodeWatched()"
    assert "tatap_watched_" in js, "app.js harus menyimpan riwayat episode ke localStorage"
    assert "tatap_last_ep_" in js, "app.js harus melacak episode terakhir ditonton per anime di localStorage"

    # 2. Event listener ended: menutup player dan mengembalikan pengguna ke episode list
    assert 'v.addEventListener("ended"' in js, "app.js harus memiliki listener event ended pada elemen video"
    assert "closePlayer()" in js, "app.js harus menutup pemutar saat episode selesai"
    assert "openTitle(" in js, "app.js harus memanggil openTitle() saat episode selesai untuk menampilkan list episode"
    assert "recordEpisodeWatched(endedSlug, endedEp)" in js, "app.js harus mencatat episode yang baru saja selesai ditonton"

    # 3. Dismiss resume modal: kembali ke daftar episode anime
    assert "function dismissResumeModal()" in js, "app.js harus mendefinisikan dismissResumeModal()"
    assert "openTitle(savedSlug, savedTitle" in js, "dismissResumeModal harus membuka kembali modal anime jika sebelumnya tertutup"

    # 4. Render ep grid: penanda episode terakhir aktif
    assert "ep.last-watch" in js or "last-watch" in js, "renderEpGrid harus menyematkan class last-watch"
    assert "ep-badge-last" in js, "renderEpGrid harus merender badge TERAKHIR"
    assert "scrollIntoView" in js, "renderEpGrid harus mendukung auto-scroll ke episode terakhir yang ditonton"


def test_android_native_untouched_post_watch():
    """Memastikan perubahan post-watch strictly terisolasi di Web & Desktop tanpa menyentuh kode native Android."""
    res = subprocess.run(["git", "status", "--porcelain", "android/"], cwd=BASE_DIR, capture_output=True, text=True)
    assert res.stdout.strip() == "", f"Kode native Android tidak boleh berubah: {res.stdout}"
