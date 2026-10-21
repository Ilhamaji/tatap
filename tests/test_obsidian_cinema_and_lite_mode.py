"""Test suite untuk verifikasi Redesign UI 'Obsidian Cinema' dan Low-Spec / Performance Mode (:lite).

Memastikan:
1. Skema warna 'Obsidian Cinema' berbasis CSS Variables (Amber #F59E0B, Canvas #090A0D, Surface #111318).
2. Zero external fonts (0KB network tax) & Zero backdrop-filter blur.
3. Font monospace dengan tabular-nums pada indikator teknis dan badge.
4. Command Bar terminal command mode saat mengetik awalan ':'.
5. Card containment content-visibility: auto dan aspect-ratio 2/3 pada poster.
6. Player HUD scrims, timeline seekbar, dan tombol AniSkip high-contrast #F3F4F6.
7. Ambient stage canvas resolution 16x9 dan guards throttling.
8. Fitur Low-Spec / Performance Mode (:lite):
   - Auto-detection hardwareConcurrency <= 4 dan deviceMemory <= 2.
   - Command parser :lite di term.js dan penyimpanan di localStorage.
   - CSS rules body.lite-mode (zero shadow, no transitions, ambient hidden).
   - Indikator monospace LITE di bar atas.
"""

from pathlib import Path
import pytest
import subprocess

REPO_ROOT = Path(__file__).resolve().parent.parent
STYLE_CSS = REPO_ROOT / "frontend" / "css" / "style.css"
INDEX_HTML = REPO_ROOT / "frontend" / "index.html"
APP_JS = REPO_ROOT / "frontend" / "js" / "app.js"
TERM_JS = REPO_ROOT / "frontend" / "js" / "term.js"


def test_obsidian_cinema_tokens_and_zero_fonts_tax():
    """Memastikan token warna Obsidian Cinema dan font stack mandiri."""
    css = STYLE_CSS.read_text(encoding="utf-8")
    html = INDEX_HTML.read_text(encoding="utf-8")

    # Tokens Obsidian Cinema
    assert "--bg-canvas:#090A0D;" in css or "--bg-canvas: #090A0D;" in css
    assert "--bg-surface:#111318;" in css or "--bg-surface: #111318;" in css
    assert "--bg-elevated:#171A21;" in css or "--bg-elevated: #171A21;" in css
    assert "--border-focus:#F59E0B;" in css or "--border-focus: #F59E0B;" in css
    assert "--accent-primary:#F59E0B;" in css or "--accent-primary: #F59E0B;" in css
    assert "--text-primary:#F3F4F6;" in css or "--text-primary: #F3F4F6;" in css

    # Backward-compatible tokens
    assert "--bg:#000000;" in css or "--bg: #000000;" in css
    assert "--accent:#19d0d0;" in css or "--accent: #19d0d0;" in css

    # 0KB external font tax
    assert "fonts.googleapis.com" not in html
    assert "fonts.gstatic.com" not in html
    assert "@import" not in css
    assert "backdrop-filter" not in css


def test_tabular_nums_and_monospace_indicators():
    """Memastikan tabular-nums diterapkan pada seluruh elemen indikator teknis."""
    css = STYLE_CSS.read_text(encoding="utf-8")

    assert "tabular-nums" in css
    assert "font-variant-numeric: tabular-nums" in css or "font-variant-numeric:tabular-nums" in css
    assert "--font-mono" in css


def test_command_bar_terminal_mode():
    """Memastikan mode terminal command aktif pada prefix ':'."""
    css = STYLE_CSS.read_text(encoding="utf-8")
    term_js = TERM_JS.read_text(encoding="utf-8")

    assert ".terminal-mode" in css
    assert ".terminal-cmd" in css
    assert 'inp.classList.add("terminal-cmd")' in term_js
    assert 'wrap.classList.add("terminal-mode")' in term_js


def test_poster_grid_and_card_containment():
    """Memastikan CSS grid dan optimasi kartu anime untuk perangkat low-end."""
    css = STYLE_CSS.read_text(encoding="utf-8")
    term_js = TERM_JS.read_text(encoding="utf-8")

    # Grid & Containment
    assert "content-visibility:auto" in css or "content-visibility: auto" in css
    assert "contain-intrinsic-size:0 290px" in css or "contain-intrinsic-size: 0 290px" in css
    assert "contain:content" in css or "contain: content" in css
    assert "aspect-ratio:2/3" in css or "aspect-ratio: 2/3" in css

    # Dual class binding
    assert "poster-card anime-card" in term_js


def test_player_hud_and_aniskip_contrast():
    """Memastikan tombol AniSkip bergaya sinema kontras tinggi dan canvas ambient 16x9."""
    html = INDEX_HTML.read_text(encoding="utf-8")
    css = STYLE_CSS.read_text(encoding="utf-8")
    app_js = APP_JS.read_text(encoding="utf-8")

    # Canvas 16x9
    assert 'id="ambient" width="16" height="9"' in html
    assert "tmp.width=16;tmp.height=9;" in app_js

    # AniSkip #F3F4F6 high contrast
    assert "#F3F4F6" in css
    assert "#090A0D" in css
    assert "border-radius:6px" in css or "border-radius: 6px" in css


def test_low_spec_lite_mode_system():
    """Memastikan fitur Low-Spec / Performance Mode (:lite) terintegrasi lengkap."""
    html = INDEX_HTML.read_text(encoding="utf-8")
    css = STYLE_CSS.read_text(encoding="utf-8")
    app_js = APP_JS.read_text(encoding="utf-8")
    term_js = TERM_JS.read_text(encoding="utf-8")

    # 1. Badge di bar atas
    assert 'id="badge-lite-mode"' in html
    assert "LITE" in html
    assert ".badge-lite-mode" in css

    # 2. JS Auto-detection & Command
    assert "hardwareConcurrency" in app_js
    assert "deviceMemory" in app_js
    assert "tatap_lite_mode" in app_js
    assert "toggleLiteMode" in app_js
    assert 'case "lite":' in term_js

    # 3. Ambient stage dimatikan total saat lite-mode
    assert 'document.body.classList.contains("lite-mode")' in app_js
    assert "body.lite-mode #ambient" in css

    # 4. Transitions & Shadows dinonaktifkan
    assert "body.lite-mode .poster-card" in css
    assert "transition:none!important" in css or "transition: none !important" in css
    assert "box-shadow:none!important" in css or "box-shadow: none !important" in css
