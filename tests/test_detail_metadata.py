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
