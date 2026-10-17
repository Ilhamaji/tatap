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
    assert "vibrateDirect(vibeDurationMs, intensity);" in player_source

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
    assert "peak >= 16500" in player_source
    assert "deltaRms >= 1400" in player_source


def test_anti_bgm_transient_onset_detector(player_source):
    """Test adaptive transient onset detector, energy derivative, and AniSkip isolation."""
    # Check running baseline and attack derivative fields
    assert "runningRms" in player_source
    assert "prevRms" in player_source
    assert "deltaRms" in player_source
    assert "surgeRatio" in player_source
    assert "isAttackOnset" in player_source
    assert "isColossal" in player_source

    # Check AniSkip integration
    assert "isInOpEd" in player_source
    assert "isInOpEd = (inIntro || inOutro);" in player_source
    assert "if (!isHapticEnabled || !isVideoPlaying || isInOpEd || TvFocusHelper.isTv(PlayerActivity.this)) return;" in player_source

    # Check HAL HapticGenerator is disabled during playback to prevent BGM leakage
    assert "HapticGeneratorHelper.setEnabled((HapticGenerator) hapticGenerator, false);" in player_source


def test_dsp_simulation_scene_vs_bgm():
    """Simulate DSP logic: ensure sustained BGM is rejected while scene impacts trigger cleanly."""
    running_rms = 1500.0
    prev_rms = 1500.0
    last_trigger = -1000

    def process_buffer(now_ms, peak, rms, in_op_ed=False):
        nonlocal running_rms, prev_rms, last_trigger
        if in_op_ed:
            running_rms = 3500.0
            prev_rms = 3500.0
            return False
        if now_ms - last_trigger < 250:
            prev_rms = rms
            return False

        delta_rms = rms - prev_rms
        prev_rms = rms

        effective_baseline = max(1200.0, running_rms)
        surge_ratio = rms / effective_baseline

        is_attack_onset = (delta_rms >= 1400 and peak >= 16500) or (surge_ratio >= 1.55 and peak >= 17000 and rms >= 2600)
        is_colossal = (peak >= 24000 and (rms - running_rms) >= 1200 and delta_rms >= 800)

        is_impact = (is_attack_onset or is_colossal)

        if not is_impact:
            running_rms = 0.88 * running_rms + 0.12 * rms
            return False
        else:
            last_trigger = now_ms
            running_rms = max(running_rms, rms * 0.75)
            return True

    # 1. Test Dialogue (should not trigger)
    assert not process_buffer(0, peak=10000, rms=1600)
    assert not process_buffer(20, peak=12000, rms=1800)

    # 2. Test Sudden Scene Impact (Punch / Sword Clash) from dialogue baseline
    # Peak jumps to 20000, RMS jumps to 3600 (delta = 1800, surge = 2.0x)
    assert process_buffer(100, peak=20000, rms=3600)

    # 3. Test Lingering Rumble after punch (should not trigger duplicate vibrations)
    assert not process_buffer(120, peak=16000, rms=2800)

    # 4. Test Continuous Loud Battle Music (BGM playing during fight scene)
    # Running RMS adapts to 4500. Music beats fluctuate smoothly (4200 -> 4700 -> 4300)
    for t in range(500, 1200, 20):
        is_beat = (t % 400 == 0)
        p = 20000 if is_beat else 16000
        r = 4700 if is_beat else 4200
        assert not process_buffer(t, p, r), f"False trigger on rhythm at t={t}"

    # 5. Test Punch / Explosion occurring DURING the loud battle BGM!
    # prev_rms was 4200, explosion lands on top of BGM: peak 26000, rms 6200 (delta = 2000!)
    assert process_buffer(1300, peak=26000, rms=6200)

    # 6. Test AniSkip OP/ED Theme (always false)
    assert not process_buffer(2000, peak=28000, rms=8000, in_op_ed=True)


