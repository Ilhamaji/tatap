import os
import re
import pytest

PLAYER_ACTIVITY_PATH = os.path.join(
    os.path.dirname(__file__),
    "..",
    "android",
    "app",
    "src",
    "main",
    "java",
    "id",
    "tatap",
    "app",
    "PlayerActivity.java"
)

@pytest.fixture
def player_source():
    assert os.path.exists(PLAYER_ACTIVITY_PATH), f"PlayerActivity.java not found at {PLAYER_ACTIVITY_PATH}"
    with open(PLAYER_ACTIVITY_PATH, "r", encoding="utf-8") as f:
        return f.read()

def test_haptic_imports(player_source):
    """Test required Android haptic and audiofx imports are present."""
    assert "import android.media.audiofx.HapticGenerator;" in player_source
    assert "import android.view.HapticFeedbackConstants;" in player_source
    assert "import androidx.media3.exoplayer.analytics.AnalyticsListener;" in player_source

def test_haptic_state_fields(player_source):
    """Test haptic fields exist in PlayerActivity."""
    assert re.search(r"private\s+boolean\s+isHapticEnabled\s*=\s*true;", player_source)
    assert re.search(r"private\s+Object\s+hapticGenerator;", player_source)
    assert re.search(r"private\s+int\s+lastHapticBrightnessStep\s*=\s*-1;", player_source)

def test_haptic_tv_isolation(player_source):
    """Test that TV mode disables haptics completely."""
    # In onCreate: isHapticEnabled = !TvFocusHelper.isTv(this) && ...
    assert "!TvFocusHelper.isTv(this) && sp.getBoolean(\"pref_haptic\", true)" in player_source
    # In performHapticTick, performHapticClick, performHapticHeavyClick, setupHapticGenerator
    assert "if (!isHapticEnabled || TvFocusHelper.isTv(this)) return;" in player_source
    assert "if (TvFocusHelper.isTv(this)) return;" in player_source

def test_haptic_modern_methods(player_source):
    """Test modern subtle haptic feedback implementation."""
    assert "private void performHapticTick()" in player_source
    assert "private void performHapticClick()" in player_source
    assert "private void performHapticHeavyClick()" in player_source

    # Check tick uses SEGMENT_TICK or CLOCK_TICK or EFFECT_TICK
    assert "HapticFeedbackConstants.SEGMENT_TICK" in player_source
    assert "HapticFeedbackConstants.CLOCK_TICK" in player_source
    assert "VibrationEffect.EFFECT_TICK" in player_source

    # Check click uses KEYBOARD_TAP or EFFECT_CLICK
    assert "HapticFeedbackConstants.KEYBOARD_TAP" in player_source
    assert "VibrationEffect.EFFECT_CLICK" in player_source

    # Check heavy click uses DRAG_START or LONG_PRESS or EFFECT_HEAVY_CLICK
    assert "HapticFeedbackConstants.DRAG_START" in player_source
    assert "VibrationEffect.EFFECT_HEAVY_CLICK" in player_source

def test_haptic_generator_helper_and_lifecycle(player_source):
    """Test HapticGeneratorHelper inner class and lifecycle management."""
    assert "class HapticGeneratorHelper" in player_source
    assert "setupHapticGenerator" in player_source
    assert "updateHapticGeneratorState" in player_source
    assert "releaseHapticGenerator" in player_source

    # ExoPlayer analytics hook
    assert "onAudioSessionIdChanged" in player_source
    assert "setupHapticGenerator(audioSessionId)" in player_source

    # Playback hooks
    assert "updateHapticGeneratorState();" in player_source
    assert "releaseHapticGenerator();" in player_source

def test_haptic_preference_in_settings_dialog(player_source):
    """Test user preference toggle in player settings dialog."""
    assert "Umpan Balik Haptik / Getaran Adegan" in player_source
    assert 'sp.edit().putBoolean("pref_haptic", newHaptic).apply();' in player_source
    # Wrapped in !TvFocusHelper.isTv(this)
    assert "!TvFocusHelper.isTv(this)" in player_source

def test_gesture_interactions_trigger_subtle_haptics(player_source):
    """Test gesture interactions call subtle haptics instead of crude vibrations."""
    # Volume adjust tick
    assert "performHapticTick();" in player_source
    # Double tap click
    assert "performHapticClick();" in player_source
    # Lock screen heavy click
    assert "performHapticHeavyClick();" in player_source
    # Skip Op/Ed click
    assert "doSkipOpEd()" in player_source
    # Episode switch click
    assert "switchEpisode(int targetEp)" in player_source
