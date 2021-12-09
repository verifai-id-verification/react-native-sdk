package com.verifai.corereactnative;

import android.app.Activity;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;
import com.verifai.core.Verifai;
import com.verifai.core.listeners.VerifaiResultListener;
import com.verifai.core.result.VerifaiResult;

@ReactModule(name = VerifaiCoreModule.NAME)
public class VerifaiCoreModule extends ReactContextBaseJavaModule {
    public static final String NAME = "VerifaiCore";
    public static final String TAG = "V-CORE";

    public VerifaiCoreModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @ReactMethod
    public void start(String licence) {
        Activity activity = getCurrentActivity();
        if (activity == null) {
            Log.e(TAG, "No activity running");
            return;
        }
        Log.d(TAG, "licence:" + licence);
        Verifai.setLicence(activity, licence);
        VerifaiResultListener resultListener = new VerifaiResultListener() {
            @Override
            public void onSuccess(@NonNull VerifaiResult verifaiResult) {
                // Handle the result.
                // Please consult the general docs for more information regarding the
                // result object and its contents.
            }

            @Override
            public void onCanceled() {
                // What to do when the user cancels the SDK route.
                // This will mostly be triggered because of the user pressing the back
                // button or locking the phone in certain states.
                // The user can restart Verifai from the start. No errors occurred.
            }

            @Override
            public void onError(Throwable throwable) {
                Log.d("error", throwable.getMessage());
            }
        };
        Verifai.startScan(activity, resultListener);
    }
}
