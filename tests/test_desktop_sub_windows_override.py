"""Test suite untuk verifikasi pengalihan kontrol subtitle fullscreen dari Windows Closed Captions ke CC Styler Tatap."""
import os
import subprocess
import pytest

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STYLE_CSS = os.path.join(REPO_ROOT, "frontend", "css", "style.css")
APP_JS = os.path.join(REPO_ROOT, "frontend", "js", "app.js")


def test_hide_native_media_controls_cc_in_css():
    """Memastikan tombol dan menu native Closed Captions browser disembunyikan agar tidak memicu Windows Captions."""
    with open(STYLE_CSS, "r", encoding="utf-8") as f:
        css = f.read()

    assert "video::-webkit-media-controls-closed-captions-container" in css
    assert "video::-webkit-media-controls-closed-captions-track-list" in css
    assert "video::-webkit-media-controls-toggle-closed-captions-button" in css
    assert "display: none !important;" in css or "display:none !important;" in css

    # Fallback styling video::cue dengan variabel Tatap
    assert "color:var(--sub-color" in css or "color: var(--sub-color" in css
    assert "background:var(--sub-bg" in css or "background: var(--sub-bg" in css
    assert "text-shadow:var(--sub-border" in css or "text-shadow: var(--sub-border" in css


def test_desktop_fullscreen_promotion_logic():
    """Memastikan promosi fullscreen dari elemen video langsung ke stage container."""
    res = subprocess.run(["node", "--check", APP_JS], capture_output=True, text=True)
    assert res.returncode == 0, f"Sintaksis app.js gagal: {res.stderr}"

    with open(APP_JS, "r", encoding="utf-8") as f:
        js = f.read()

    # Fungsi deteksi lingkungan desktop vs mobile
    assert "isDesktopEnv" in js, "Fungsi isDesktopEnv wajib ada di app.js"

    # Handler promosi fullscreen
    assert "onFullscreenChange" in js, "Fungsi onFullscreenChange wajib ada di app.js"
    assert "fsEl===v&&stage" in js or "fsEl === v && stage" in js, "Pengecekan elemen video dipromosikan ke stage"

    # Penguncian native track ke hidden di desktop
    assert "shouldShowNative=isVidFs&&!isDesktopEnv();" in js or "shouldShowNative = isVidFs && !isDesktopEnv()" in js

    # Overlay Tatap #pm-subs-overlay tetap aktif di desktop
    assert "isVideoFullscreen()&&!isDesktopEnv()" in js or "isVideoFullscreen() && !isDesktopEnv()" in js
