import os
import sys
import json
import pytest
from fastapi.responses import JSONResponse

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "backend"))
import main  # noqa: E402

@pytest.mark.asyncio
async def test_search_hianime_and_validation():
    # Validation empty q returns JSONResponse
    res_empty = await main.search(q="")
    assert isinstance(res_empty, JSONResponse)
    data_empty = json.loads(res_empty.body.decode())
    assert data_empty["success"] is False
    assert data_empty["error"] == "missing q"

    # Blacklist hentai returns ok dict with empty results
    res_hentai = await main.search(q="hentai")
    assert isinstance(res_hentai, dict)
    assert res_hentai["success"] is True
    assert res_hentai["data"]["results"] == []

@pytest.mark.asyncio
async def test_search_source_param_handling():
    # Pastikan pemanggilan dengan parameter string atau default aman
    res = await main.search(q="naruto", source="otakudesu", limit=3)
    assert isinstance(res, dict)
    assert res["success"] is True
    assert "results" in res["data"]
