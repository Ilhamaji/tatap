import os
import sys
import re
import pytest

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if ROOT_DIR not in sys.path:
    sys.path.insert(0, ROOT_DIR)

from backend.api import anilist as al


def test_clean_synopsis_text():
    raw_desc = (
        "Di sebuah dunia sihir &amp; pertarungan.<br><br>"
        "Seorang pemuda bernama &quot;Asta&quot; lahir tanpa sihir sama sekali. "
        "Ia bertekad menjadi Kaisar Sihir demi membuktikan kekuatannya! "
        "Pertarungan sengit tiada henti menguji tekad dan keberanian kelompok Banteng Hitam.<br>"
        "Apakah impian mustahil ini dapat tercapai?<br><br>"
        "(Source: Crunchyroll, edited)\n\n[Written by MAL Rewrite]"
    )
    cleaned = al.clean_synopsis_text(raw_desc)
    # Tag HTML terhapus
    assert "<br>" not in cleaned
    assert "</p>" not in cleaned
    # Entitas ter-decode
    assert '"Asta"' in cleaned
    assert "&amp;" not in cleaned
    # Atribusi terhapus
    assert "(Source:" not in cleaned
    assert "[Written by MAL Rewrite]" not in cleaned
    # Tidak dipotong artifisial
    assert len(cleaned) > 150
    assert "Apakah impian mustahil ini dapat tercapai?" in cleaned


def test_android_layout_detail_metadata():
    layout_path = os.path.join(ROOT_DIR, "android/app/src/main/res/layout/activity_detail.xml")
    assert os.path.exists(layout_path)
    with open(layout_path, "r", encoding="utf-8") as f:
        xml = f.read()

    assert 'android:id="@+id/tv_detail_score"' in xml
    assert 'android:id="@+id/tv_detail_status"' in xml
    assert 'android:id="@+id/tv_detail_info_line"' in xml
    assert 'android:id="@+id/hsv_detail_genres"' in xml
    assert 'android:id="@+id/ll_detail_genres"' in xml
    assert 'android:id="@+id/layout_detail_synopsis"' in xml
    assert 'android:id="@+id/tv_detail_synopsis"' in xml
    assert 'android:id="@+id/btn_toggle_synopsis"' in xml

    # Pastikan layout landscape / Android TV juga memiliki metadata lengkap
    layout_land_path = os.path.join(ROOT_DIR, "android/app/src/main/res/layout-land/activity_detail.xml")
    assert os.path.exists(layout_land_path)
    with open(layout_land_path, "r", encoding="utf-8") as f:
        land_xml = f.read()

    assert 'android:id="@+id/tv_detail_score"' in land_xml
    assert 'android:id="@+id/tv_detail_status"' in land_xml
    assert 'android:id="@+id/tv_detail_info_line"' in land_xml
    assert 'android:id="@+id/hsv_detail_genres"' in land_xml
    assert 'android:id="@+id/layout_detail_synopsis"' in land_xml
    assert 'android:id="@+id/rv_episodes"' in land_xml


def test_android_detail_activity_and_adapter_metadata():
    detail_java_path = os.path.join(ROOT_DIR, "android/app/src/main/java/id/tatap/app/DetailActivity.java")
    assert os.path.exists(detail_java_path)
    with open(detail_java_path, "r", encoding="utf-8") as f:
        detail_code = f.read()

    assert "tvScore = findViewById(R.id.tv_detail_score);" in detail_code
    assert "tvStatus = findViewById(R.id.tv_detail_status);" in detail_code
    assert "setupMetadata(" in detail_code
    assert "TvFocusHelper.isTv(this)" in detail_code

    adapter_java_path = os.path.join(ROOT_DIR, "android/app/src/main/java/id/tatap/app/AnimeAdapter.java")
    assert os.path.exists(adapter_java_path)
    with open(adapter_java_path, "r", encoding="utf-8") as f:
        adapter_code = f.read()

    assert 'intent.putExtra("score", score);' in adapter_code
    assert 'intent.putExtra("genres", genresStr);' in adapter_code
    assert 'intent.putExtra("studio", studio);' in adapter_code


def test_web_desktop_metadata_and_synopsis():
    html_path = os.path.join(ROOT_DIR, "frontend/index.html")
    with open(html_path, "r", encoding="utf-8") as f:
        html = f.read()
    assert 'id="tm-detail-meta"' in html
    assert 'id="tm-score"' in html
    assert 'id="tm-status"' in html
    assert 'id="tm-genres"' in html
    assert 'id="tm-synopsis-box"' in html
    assert 'id="tm-synopsis-toggle"' in html

    css_path = os.path.join(ROOT_DIR, "frontend/css/style.css")
    with open(css_path, "r", encoding="utf-8") as f:
        css = f.read()
    assert ".detail-meta-box" in css
    assert ".badge-score" in css
    assert ".badge-status" in css
    assert ".tm-synopsis-box" in css
    assert ".tm-synopsis-text.clamped" in css

    js_path = os.path.join(ROOT_DIR, "frontend/js/app.js")
    with open(js_path, "r", encoding="utf-8") as f:
        js = f.read()
    assert "function renderDetailMeta(" in js
    assert "tm-detail-meta" in js
    assert "tm-synopsis-toggle" in js


def test_backend_anime_detail_endpoint_security():
    main_path = os.path.join(ROOT_DIR, "backend/main.py")
    with open(main_path, "r", encoding="utf-8") as f:
        code = f.read()

    assert "@app.get(\"/api/anime/{slug}/detail\")" in code
    assert "hentai" in code.lower()
    # Pastikan chaquopy parity ada
    chaquopy_main = os.path.join(ROOT_DIR, "android/app/src/main/python/backend/main.py")
    with open(chaquopy_main, "r", encoding="utf-8") as f:
        chaquopy_code = f.read()
    assert "@app.get(\"/api/anime/{slug}/detail\")" in chaquopy_code


def test_web_desktop_sheet_dom_structure():
    """Memastikan struktur DOM #title-modal dan .sheet tidak mengalami tag mismatch/unclosed head."""
    from bs4 import BeautifulSoup
    html_path = os.path.join(ROOT_DIR, "frontend/index.html")
    with open(html_path, "r", encoding="utf-8") as f:
        html = f.read()
    soup = BeautifulSoup(html, "html.parser")

    title_modal = soup.find(id="title-modal")
    assert title_modal is not None

    # Sheet harus child langsung dari title-modal
    sheet = title_modal.find(class_="sheet")
    assert sheet is not None
    assert sheet.parent == title_modal

    # sheet-head harus ditutup dengan benar, direct children sheet:
    # sheet-head, tm-detail-meta, tm-seasons, sheet-controls, tm-ep-ranges, tm-eps
    sheet_children = [c.get("id") or (c.get("class")[0] if c.get("class") else c.name) for c in sheet.find_all(recursive=False)]
    assert "sheet-head" in sheet_children
    assert "tm-detail-meta" in sheet_children
    assert "tm-seasons" in sheet_children
    assert "sheet-controls" in sheet_children
    assert "tm-ep-ranges" in sheet_children
    assert "tm-eps" in sheet_children

    # Pastikan .sheet-head TIDAK menelan tm-eps atau tm-detail-meta
    sheet_head = sheet.find(class_="sheet-head")
    head_children = [c.get("id") or (c.get("class")[0] if c.get("class") else c.name) for c in sheet_head.find_all(recursive=False)]
    assert "tm-eps" not in head_children
    assert "tm-detail-meta" not in head_children
    assert "sheet-controls" not in head_children

    # Pastikan player-modal bukan child dari title-modal (tag balance)
    player_modal = soup.find(id="player-modal")
    assert player_modal is not None
    assert player_modal.parent != title_modal

