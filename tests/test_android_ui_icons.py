"""
tests/test_android_ui_icons.py - Test suite to prevent regressions on Android UI icons,
ensuring zero emoji stuffing, zero raw symbols, and valid vector/mipmap assets.
"""

import os
import re
import xml.etree.ElementTree as ET
from PIL import Image

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES_DIR = os.path.join(ROOT_DIR, "android", "app", "src", "main", "res")
JAVA_DIR = os.path.join(ROOT_DIR, "android", "app", "src", "main", "java")
TV_RES_DIR = os.path.join(ROOT_DIR, "android", "app", "src", "tv", "res")

def test_zero_emojis_and_raw_symbols_in_android():
    """
    Asserts that no emojis or raw characters (✕, ⋮, ⭐, etc.) remain in Android XML or Java code.
    """
    emoji_pattern = re.compile(r'[\U00010000-\U0010ffff]', flags=re.UNICODE)
    forbidden_symbols = ['⭐', '⏱', '✕', '⋮', '⏩', '⏭', '★', '✨']
    
    violations = []
    
    for base_dir in [RES_DIR, JAVA_DIR]:
        for root, dirs, files in os.walk(base_dir):
            for f in files:
                if f.endswith(('.java', '.xml')):
                    path = os.path.join(root, f)
                    with open(path, 'r', encoding='utf-8', errors='ignore') as fp:
                        for idx, line in enumerate(fp, 1):
                            found_e = emoji_pattern.findall(line)
                            found_s = [s for s in forbidden_symbols if s in line]
                            if found_e or found_s:
                                violations.append((path, idx, found_e + found_s, line.strip()))
                                
    assert len(violations) == 0, f"Found {len(violations)} forbidden emoji/symbol occurrences: {violations}"

def test_vector_drawables_exist_and_valid():
    """
    Asserts that all 13 purpose-built vector drawables exist and parse as valid XML.
    """
    vectors = [
        "ic_tab_season.xml",
        "ic_tab_airing.xml",
        "ic_tab_favorite.xml",
        "ic_tab_catalog.xml",
        "ic_tab_schedule.xml",
        "ic_tab_genre.xml",
        "ic_filter.xml",
        "ic_search.xml",
        "ic_more_vert.xml",
        "ic_close.xml",
        "ic_star_outline.xml",
        "ic_star_filled.xml",
        "ic_skip_next.xml"
    ]
    
    drawable_dir = os.path.join(RES_DIR, "drawable")
    android_ns = "{http://schemas.android.com/apk/res/android}"
    for v in vectors:
        file_path = os.path.join(drawable_dir, v)
        assert os.path.exists(file_path), f"Vector drawable {v} missing at {file_path}"
        tree = ET.parse(file_path)
        root = tree.getroot()
        assert root.tag == "vector", f"{v} root element is {root.tag}, expected vector"
        width = root.attrib.get(f"{android_ns}width")
        height = root.attrib.get(f"{android_ns}height")
        assert width in ["14dp", "15dp", "16dp"], f"{v} width {width} not in expected proportional range [14dp-16dp]"
        assert height in ["14dp", "15dp", "16dp"], f"{v} height {height} not in expected proportional range [14dp-16dp]"

def test_adaptive_icons_and_mipmaps():
    """
    Asserts that Adaptive Icons (API 26+) and legacy mipmaps exist with valid dimensions.
    """
    v26_dir = os.path.join(RES_DIR, "mipmap-anydpi-v26")
    assert os.path.exists(os.path.join(v26_dir, "ic_launcher.xml"))
    assert os.path.exists(os.path.join(v26_dir, "ic_launcher_round.xml"))
    
    densities = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    
    for folder, size in densities.items():
        sq_path = os.path.join(RES_DIR, folder, "ic_launcher.png")
        rnd_path = os.path.join(RES_DIR, folder, "ic_launcher_round.png")
        assert os.path.exists(sq_path)
        assert os.path.exists(rnd_path)
        
        with Image.open(sq_path) as im:
            assert im.size == (size, size), f"Expected {size}x{size}, got {im.size}"
        with Image.open(rnd_path) as im:
            assert im.size == (size, size), f"Expected {size}x{size}, got {im.size}"
            
    # TV banners
    banner_320 = os.path.join(TV_RES_DIR, "drawable", "tv_banner.png")
    banner_640 = os.path.join(TV_RES_DIR, "drawable-xhdpi", "tv_banner.png")
    assert os.path.exists(banner_320)
    assert os.path.exists(banner_640)
    
    with Image.open(banner_320) as im:
        assert im.size == (320, 180)
    with Image.open(banner_640) as im:
        assert im.size == (640, 360)
