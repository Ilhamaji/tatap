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
    """Test modern subtle haptic feedback and direct vibrator engine implementation."""
    assert "private void performHapticTick()" in player_source
    assert "private void performHapticClick()" in player_source
    assert "private void performHapticHeavyClick()" in player_source
    assert "private void vibrateDirect(long ms, int amplitude)" in player_source
    assert "getVibratorService()" in player_source

    # Check tick uses SEGMENT_TICK, CLOCK_TICK, or KEYBOARD_TAP and vibrateDirect
    assert "HapticFeedbackConstants.SEGMENT_TICK" in player_source
    assert "HapticFeedbackConstants.CLOCK_TICK" in player_source
    assert "HapticFeedbackConstants.FLAG_IGNORE_VIEW_SETTING" in player_source
    assert "vibrateDirect(15, 70);" in player_source

    # Check click uses KEYBOARD_TAP and vibrateDirect
    assert "HapticFeedbackConstants.KEYBOARD_TAP" in player_source
    assert "vibrateDirect(25, 140);" in player_source

    # Check heavy click uses DRAG_START or LONG_PRESS and vibrateDirect
    assert "HapticFeedbackConstants.DRAG_START" in player_source
    assert "vibrateDirect(45, 230);" in player_source

def test_scene_haptic_audio_processor(player_source):
    """Test SceneHapticAudioSink and TeeAudioProcessor for universal anime scene vibration."""
    assert "class SceneHapticAudioSink implements TeeAudioProcessor.AudioBufferSink" in player_source
    assert "TeeAudioProcessor(new SceneHapticAudioSink())" in player_source
    assert "handleBuffer(ByteBuffer buffer)" in player_source
    assert "vibrateDirect(35, intensity);" in player_source

def test_scene_haptic_thread_safety(player_source):
    """Test that SceneHapticAudioSink does not touch player instance on audio thread."""
    sink_match = re.search(r"class SceneHapticAudioSink\s+implements[^{]+\{(.*?)\n    \}", player_source, re.DOTALL)
    assert sink_match is not None, "SceneHapticAudioSink class not found!"
    sink_body = sink_match.group(1)
    assert "player." not in sink_body, "SceneHapticAudioSink must not access player on audio thread!"
    assert "isVideoPlaying" in sink_body, "SceneHapticAudioSink should check thread-safe volatile isVideoPlaying"

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

def test_erm_motor_adaptation_and_media_attributes(player_source):
    """Test ERM motor pulse adaptation and USAGE_MEDIA attributes for Samsung One UI."""
    assert "hasAmplitudeControl()" in player_source
    assert "effectiveMs" in player_source
    assert "AudioAttributes.USAGE_MEDIA" in player_source
    assert "cachedVibrator" in player_source
    # Calibrated scene haptic threshold for AAC anime streams
    assert "peak > 17500" in player_source
    assert "rms > 3800" in player_source
