package id.tatap.app;

import android.app.UiModeManager;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.graphics.Color;
import android.os.Build;
import android.view.View;

import com.google.android.material.card.MaterialCardView;

public class TvFocusHelper {
    private static final int COLOR_FOCUSED_STROKE = Color.parseColor("#38BDF8");
    private static final int COLOR_NORMAL_STROKE = Color.parseColor("#1C202C");

    public static boolean isTv(Context context) {
        if (context == null) return false;
        UiModeManager uiModeManager = (UiModeManager) context.getSystemService(Context.UI_MODE_SERVICE);
        if (uiModeManager != null && uiModeManager.getCurrentModeType() == Configuration.UI_MODE_TYPE_TELEVISION) {
            return true;
        }
        // Fallback cek: tidak memiliki layar sentuh
        PackageManager pm = context.getPackageManager();
        return !pm.hasSystemFeature(PackageManager.FEATURE_TOUCHSCREEN);
    }

    public static void attachFocusScale(final View view, final float targetScale, final float elevationDp) {
        if (view == null) return;
        view.setFocusable(true);
        view.setFocusableInTouchMode(false); // Di TV, remote fokus tidak membutuhkan touch mode

        final float density = view.getResources().getDisplayMetrics().density;
        final float elevationPx = elevationDp * density;

        view.setOnFocusChangeListener((v, hasFocus) -> {
            float scale = hasFocus ? targetScale : 1.0f;
            v.animate()
                    .scaleX(scale)
                    .scaleY(scale)
                    .setDuration(130)
                    .start();

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                v.setElevation(hasFocus ? elevationPx : 0f);
                v.setTranslationZ(hasFocus ? elevationPx / 2f : 0f);
            }

            // Jika view adalah MaterialCardView, sorot border secara dinamis
            if (v instanceof MaterialCardView) {
                MaterialCardView card = (MaterialCardView) v;
                card.setStrokeColor(hasFocus ? COLOR_FOCUSED_STROKE : COLOR_NORMAL_STROKE);
                card.setStrokeWidth(hasFocus ? (int) (2.5f * density) : (int) (1f * density));
            }
        });
    }

    public static void attachCardFocus(final MaterialCardView card) {
        attachFocusScale(card, 1.06f, 10f);
    }
}
