import os
import sys
import pytest
from fastapi.responses import JSONResponse

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "backend"))
import main  # noqa: E402

@pytest.mark.asyncio
async def test_browse_cross_filter_params():
    # Test browse with sort, year, month, type
    res = await main.browse_ep(sort="score", year="2024", month="10", type="tv", page=1)
    assert isinstance(res, dict)
    assert res.get("success") is True
    data = res.get("data", {})
    assert "items" in data
    assert "page" in data
    assert data["page"] == 1
    # params dictionary harus menangkap resolusi sy/ey dan sm/em
    params = data.get("params", {})
    assert params.get("sort") == "score"
    assert params.get("sy") == "2024"
    assert params.get("ey") == "2024"
    assert params.get("sm") == "10"
    assert params.get("em") == "10"
    assert params.get("type") == "tv"

@pytest.mark.asyncio
async def test_browse_year_range_parsing():
    # Test range year (2015-2019)
    res = await main.browse_ep(year="2015-2019", page=1)
    assert isinstance(res, dict)
    assert res.get("success") is True
    params = res["data"].get("params", {})
    assert params.get("sy") == "2015"
    assert params.get("ey") == "2019"

    # Test classic year (<2000)
    res_classic = await main.browse_ep(year="<2000", page=1)
    assert isinstance(res_classic, dict)
    assert res_classic.get("success") is True
    params_c = res_classic["data"].get("params", {})
    assert params_c.get("ey") == "1999"

@pytest.mark.asyncio
async def test_browse_hentai_genre_blacklist():
    res = await main.browse_ep(genre="hentai", page=1)
    assert isinstance(res, dict)
    assert res.get("success") is True
    assert res["data"]["items"] == []
