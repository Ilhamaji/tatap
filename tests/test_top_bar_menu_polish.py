"""
Test Suite: Top Bar Menu Polish & Graphic Design Principles (Desktop & Web)
Verifies:
1. Brand Logo Mark SVG symbol (#icon-brand-mark) and interactive #head-brand element.
2. Mathematical 3-column CSS Grid architecture (1fr auto 1fr) for true optical centering.
3. Optical center alignment of .nav-tabs-bar (justify-self: center).
4. Symmetrical visual counterweight: Quick search launcher pill (#btn-head-search) with '/' keycap.
5. Interactive event listeners in JavaScript for brand home navigation and quick search focus.
6. Zero Backdrop Blur compliance for low-end device performance.
"""

from pathlib import Path
import re
import pytest

ROOT_DIR = Path(__file__).resolve().parent.parent
INDEX_HTML = ROOT_DIR / "frontend" / "index.html"
STYLE_CSS = ROOT_DIR / "frontend" / "css" / "style.css"
APP_JS = ROOT_DIR / "frontend" / "js" / "app.js"
TERM_JS = ROOT_DIR / "frontend" / "js" / "term.js"


def test_brand_logo_mark_svg_and_interactive_element():
    """Verify brand mark vector symbol and interactive #head-brand container."""
    html_content = INDEX_HTML.read_text(encoding="utf-8")
    css_content = STYLE_CSS.read_text(encoding="utf-8")

    # SVG Symbol
    assert 'id="icon-brand-mark"' in html_content
    # Interactive head brand
    assert 'id="head-brand"' in html_content
    assert 'class="brand-logo-mark"' in html_content
    assert 'href="#icon-brand-mark"' in html_content
    assert 'class="brand-name"' in html_content
    assert 'class="brand-ver"' in html_content

    # CSS styling
    assert ".brand-logo-mark" in css_content
    assert ".head-brand" in css_content
    assert "cursor:pointer" in css_content or "cursor: pointer" in css_content


def test_three_column_grid_and_optical_centering():
    """Verify .tui-head uses a 3-column grid to mathematically center tabs."""
    css_content = STYLE_CSS.read_text(encoding="utf-8")

    # 3-column grid structure
    assert "grid-template-columns:1fr auto 1fr" in css_content or "grid-template-columns: 1fr auto 1fr" in css_content
    # Center alignment for tabs
    assert "justify-self:center" in css_content or "justify-self: center" in css_content
    # 56px modular scale height
    assert "height:56px" in css_content or "height: 56px" in css_content


def test_quick_search_pill_counterweight():
    """Verify quick search launcher pill (#btn-head-search) balances visual weight on right."""
    html_content = INDEX_HTML.read_text(encoding="utf-8")
    css_content = STYLE_CSS.read_text(encoding="utf-8")

    assert 'id="btn-head-search"' in html_content
    assert 'class="head-search-pill"' in html_content
    assert 'class="head-search-kbd"' in html_content
    assert '>/<k' in html_content or '>/<' in html_content

    assert ".head-search-pill" in css_content
    assert ".head-search-kbd" in css_content


def test_javascript_event_listeners_wired():
    """Verify event handlers for head-brand and btn-head-search in app.js."""
    app_js = APP_JS.read_text(encoding="utf-8")
    term_js = TERM_JS.read_text(encoding="utf-8")

    # Brand click handler
    assert "head-brand" in app_js
    assert 'setView("musim")' in app_js or "setView('musim')" in app_js

    # Quick search click handler
    assert "btn-head-search" in app_js
    assert "pulse-highlight" in app_js

    # Forward slash keyboard shortcut in term.js
    assert 'e.key==="/"' in term_js or 'e.key === "/"' in term_js


def test_zero_backdrop_blur_on_header():
    """Verify header does not introduce backdrop-filter: blur for low-end device performance."""
    css_content = STYLE_CSS.read_text(encoding="utf-8")
    # Isolate header rules
    header_start = css_content.find(".tui-head{")
    header_end = css_content.find("/* ---- DRAWER", header_start)
    header_section = css_content[header_start:header_end]

    assert "backdrop-filter" not in header_section
