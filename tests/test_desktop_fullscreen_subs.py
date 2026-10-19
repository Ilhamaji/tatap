"""Test suite untuk verifikasi tombol CC tersemat dan panel HUD pengatur subtitle fullscreen di desktop."""
import os
import subprocess
import pytest

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
INDEX_HTML = os.path.join(REPO_ROOT, "frontend", "index.html")
STYLE_CSS = os.path.join(REPO_ROOT, "frontend", "css", "style.css")
APP_JS = os.path.join(REPO_ROOT, "frontend", "js", "app.js")


def test_html_embedded_cc_button_and_panel():
    """Memastikan tombol CC dan panel HUD pengatur subtitle terpasang di dalam container stage player."""
    with open(INDEX_HTML, "r", encoding="utf-8") as f:
        html = f.read()

    # Tombol CC tersemat langsung di dalam pemutar (.ambient-stage)
    assert 'id="pm-fs-subs-btn"' in html, "Tombol #pm-fs-subs-btn wajib ada di index.html"
    assert 'id="pm-fs-subs-badge"' in html, "Badge bahasa aktif #pm-fs-subs-badge wajib ada"
    
    # Panel HUD modal styling subtitle
    assert 'id="pm-fs-subs-panel"' in html, "Panel #pm-fs-subs-panel wajib ada di index.html"
    assert 'id="pm-fs-subs-select"' in html, "Dropdown track subtitle #pm-fs-subs-select wajib ada di panel HUD"
    assert 'id="pm-fs-offset-m05"' in html, "Tombol sync offset -0.5s wajib ada"
    assert 'id="pm-fs-offset-p05"' in html, "Tombol sync offset +0.5s wajib ada"
    assert 'id="pm-fs-offset-val"' in html, "Label offset #pm-fs-offset-val wajib ada"

    # Kelompok kontrol visual styling
    assert 'id="pm-fs-size-group"' in html, "Grup ukuran font #pm-fs-size-group wajib ada"
    for sz in ("s", "m", "l", "xl"):
        assert f'data-fs-size="{sz}"' in html, f"Opsi ukuran {sz} wajib ada"

    assert 'id="pm-fs-color-group"' in html, "Grup warna font #pm-fs-color-group wajib ada"
    for col in ("white", "yellow", "cyan", "green"):
        assert f'data-fs-color="{col}"' in html, f"Opsi warna {col} wajib ada"

    assert 'id="pm-fs-border-group"' in html, "Grup outline font #pm-fs-border-group wajib ada"
    for bdr in ("thick", "thin", "glow", "none"):
        assert f'data-fs-border="{bdr}"' in html, f"Opsi border {bdr} wajib ada"

    assert 'id="pm-fs-bg-group"' in html, "Grup background subtitle #pm-fs-bg-group wajib ada"
    for bg in ("none", "thin", "dark", "opaque"):
        assert f'data-fs-bg="{bg}"' in html, f"Opsi background {bg} wajib ada"

    assert 'id="pm-fs-pos-group"' in html, "Grup posisi vertikal #pm-fs-pos-group wajib ada"
    for pos in ("low", "mid", "high"):
        assert f'data-fs-pos="{pos}"' in html, f"Opsi posisi vertikal {pos} wajib ada"


def test_css_variables_and_rules():
    """Memastikan CSS custom variables dan aturan styling HUD terdefinisi dengan benar."""
    with open(STYLE_CSS, "r", encoding="utf-8") as f:
        css = f.read()

    # CSS Variables pada .subs-overlay
    assert "--sub-color" in css, "CSS variable --sub-color wajib ada"
    assert "--sub-border" in css, "CSS variable --sub-border wajib ada"
    assert "--sub-bg" in css, "CSS variable --sub-bg wajib ada"
    assert "--sub-bottom" in css, "CSS variable --sub-bottom wajib ada"

    # Styling tombol CC dan panel HUD
    assert ".pm-fs-subs-btn" in css, "Class .pm-fs-subs-btn wajib ada di style.css"
    assert ".pm-fs-subs-panel" in css, "Class .pm-fs-subs-panel wajib ada di style.css"
    assert ".swatch-btn" in css, "Class .swatch-btn untuk palet warna wajib ada"
    assert ".fs-pill-group" in css, "Class .fs-pill-group untuk segmented button wajib ada"
    assert ".fs-sync-stepper" in css, "Class .fs-sync-stepper untuk sync buttons wajib ada"


def test_app_js_syntax_and_logic():
    """Memastikan sintaksis JS valid dan implementasi fungsi stlyer lengkap."""
    # Sintaksis valid menggunakan node --check
    res = subprocess.run(["node", "--check", APP_JS], capture_output=True, text=True)
    assert res.returncode == 0, f"Sintaksis app.js gagal: {res.stderr}"

    with open(APP_JS, "r", encoding="utf-8") as f:
        js = f.read()

    # Peta styling dan fungsi kontrol
    assert "SUB_COLOR_MAP" in js, "SUB_COLOR_MAP wajib ada di app.js"
    assert "SUB_BORDER_MAP" in js, "SUB_BORDER_MAP wajib ada di app.js"
    assert "SUB_BG_MAP" in js, "SUB_BG_MAP wajib ada di app.js"
    assert "SUB_POS_MAP" in js, "SUB_POS_MAP wajib ada di app.js"

    # Helper & handler styling
    for fn in (
        "applySubStyles",
        "setSubColor",
        "setSubBorder",
        "setSubBg",
        "setSubPos",
        "setSubSize",
        "setSubOffset",
        "toggleFsSubsPanel",
        "closeFsSubsPanel",
        "isFsSubsPanelOpen",
        "syncFsSubsSelect",
        "updateFsSubsBadge",
    ):
        assert fn in js, f"Fungsi {fn} wajib diimplementasikan di app.js"

    # Pencegahan event bubbling agar interaksi pada panel tidak memicu play/pause atau fullscreen toggle
    assert "e.stopPropagation()" in js, "e.stopPropagation() wajib digunakan pada kontrol panel HUD"

    # Sinkronisasi real-time delay cue offset pada paintCue
    assert "cur.subOffset" in js, "cur.subOffset wajib dipertimbangkan dalam pencocokan paintCue"
