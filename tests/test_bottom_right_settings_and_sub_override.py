"""
Unit tests for Bottom-Right Controls Dock, Quick Settings Menu (Titik 3), and Windows Closed Captions Override.
"""
from pathlib import Path

ROOT = Path(__file__).parent.parent


def test_index_html_has_dock_and_quick_settings_menu():
    html_path = ROOT / "frontend" / "index.html"
    assert html_path.exists(), "frontend/index.html harus ada"
    content = html_path.read_text(encoding="utf-8")

    # Icon more-vert
    assert '<symbol id="icon-more-vert"' in content, "Simbol SVG icon-more-vert harus terdefinisi di <defs>"

    # Controls dock
    assert 'id="pm-controls-dock"' in content, "Elemen #pm-controls-dock harus ada"
    assert 'id="pm-fs-subs-btn"' in content, "Tombol #pm-fs-subs-btn harus ada"
    assert 'id="pm-quick-settings-btn"' in content, "Tombol #pm-quick-settings-btn (Titik 3) harus ada"

    # Quick Settings Menu
    assert 'id="pm-quick-settings-menu"' in content, "Elemen #pm-quick-settings-menu harus ada"
    assert 'id="pm-qs-item-subs"' in content, "Item Subtitle & CC Styler harus ada di quick settings"
    assert 'id="pm-qs-group-speed"' in content, "Item Kecepatan Putar harus ada di quick settings"
    assert 'id="pm-qs-speed-chips"' in content, "Chip pilihan kecepatan harus ada"
    assert 'id="pm-qs-group-quality"' in content, "Grup pilihan resolusi harus ada"
    assert 'id="pm-qs-item-pip"' in content, "Item PiP harus ada"
    assert 'id="pm-qs-item-fs"' in content, "Item Fullscreen harus ada"


def test_css_positions_dock_and_panels_at_bottom_right():
    css_path = ROOT / "frontend" / "css/style.css"
    assert css_path.exists(), "frontend/css/style.css harus ada"
    content = css_path.read_text(encoding="utf-8")

    # Dock di kanan bawah
    assert ".pm-controls-dock" in content
    assert "bottom: 58px;" in content
    assert "bottom: 76px;" in content

    # Quick settings menu & subs panel dari bawah
    assert ".pm-quick-settings-menu" in content
    assert "bottom: 98px;" in content
    assert "bottom: 122px;" in content


def test_js_prevents_track_insertion_on_desktop_and_handles_quick_settings():
    js_path = ROOT / "frontend" / "js/app.js"
    assert js_path.exists(), "frontend/js/app.js harus ada"
    content = js_path.read_text(encoding="utf-8")

    # Desktop track prevention
    assert "if(isDesktopEnv()){" in content
    assert "syncNativeTextTrack" in content
    assert "nofullscreen nodownload noremoteplayback" in content

    # Quick settings methods
    assert "isQuickSettingsMenuOpen" in content
    assert "toggleQuickSettingsMenu" in content
    assert "closeQuickSettingsMenu" in content
    assert "syncQuickSettingsState" in content
