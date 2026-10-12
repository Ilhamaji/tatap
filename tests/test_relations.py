"""Unit test untuk anime relations API (/api/anime/{slug}/relations)."""
import asyncio
import os
import sys
import pytest

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "backend"))

import main  # noqa: E402
import api.anilist as al  # noqa: E402


@pytest.mark.asyncio
async def test_anime_relations_endpoint(monkeypatch):
    """Pastikan endpoint relations mengembalikan relasi PREQUEL, SEQUEL dengan label yang benar."""

    def fake_relations(search):
        return [
            {
                "id": 113415,
                "relation": "PREQUEL",
                "format": "TV",
                "title": "JUJUTSU KAISEN",
                "title_romaji": "Jujutsu Kaisen",
                "year": 2020,
                "status": "FINISHED",
                "poster": "https://example.com/poster1.jpg"
            },
            {
                "id": 172463,
                "relation": "SEQUEL",
                "format": "TV",
                "title": "JUJUTSU KAISEN Season 3",
                "title_romaji": "Jujutsu Kaisen Season 3",
                "year": 2026,
                "status": "FINISHED",
                "poster": "https://example.com/poster3.jpg"
            }
        ]

    async def fake_match_slug(loop, title, alt_title=""):
        if "Season 3" in title:
            return "jujutsu-kaisen-season-3-999"
        return "jujutsu-kaisen-100"

    async def fake_get_cache(key, ttl=None):
        return None

    monkeypatch.setattr(al, "anime_relations", fake_relations)
    monkeypatch.setattr(main, "_match_slug_one", fake_match_slug)
    monkeypatch.setattr(main, "get_browse_cache", fake_get_cache)

    res = await main.anime_relations_endpoint("test-jjk-season-2-12345", "Jujutsu Kaisen 2nd Season")
    assert res["success"] is True
    data = res["data"]
    assert data["current_slug"] == "test-jjk-season-2-12345"
    relations = data["relations"]
    assert len(relations) == 2

    # PREQUEL di urutan terdepan
    assert relations[0]["relation"] == "PREQUEL"
    assert relations[0]["label"] == "Season 1"
    assert relations[0]["slug"] == "jujutsu-kaisen-100"

    # SEQUEL di urutan berikutnya
    assert relations[1]["relation"] == "SEQUEL"
    assert relations[1]["label"] == "Season 3"
    assert relations[1]["slug"] == "jujutsu-kaisen-season-3-999"
