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
import com.facebook.react.bridge.Callback;

/**
 * Wrapper class for the core module
 * Callbacks have to be set one by one because:
 * https://reactnative.dev/docs/native-modules-android#callbacks
 * Maybe this can be done differently when TurboModules are out
 */
@ReactModule(name = VerifaiCoreModule.NAME)
public class VerifaiCoreModule extends ReactContextBaseJavaModule {
    public static final String NAME = "VerifaiCore";
    public static final String TAG = "V-CORE";

    public VerifaiCoreModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    private Callback _onSuccess = null;
    @ReactMethod
    public void setOnSuccess(Callback onSuccess) { _onSuccess = onSuccess; }

    private Callback _onCancelled = null;
    @ReactMethod
    public void setOnCancelled(Callback onCancelled) { _onCancelled = onCancelled; }

    private Callback _onError = null;
    @ReactMethod
    public void setOnError(Callback onError) { _onError = onError; }

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
        if (_onSuccess == null) {
            Log.e(TAG, "No onSuccess callback has been set");
            return;
        }
        if (_onCancelled == null) {
            Log.e(TAG, "No onCancelled callback has been set");
            return;
        }
        if (_onError == null) {
            Log.e(TAG, "No onError callback has been set");
            return;
        }

        Verifai.setLicence(activity, licence);
        VerifaiResultListener resultListener = new VerifaiResultListener() {
            @Override
            public void onSuccess(@NonNull VerifaiResult verifaiResult) {
                _onSuccess.invoke("success");
            }

            @Override
            public void onCanceled() {
                _onCancelled.invoke();
            }

            @Override
            public void onError(Throwable throwable) {
                _onError.invoke(throwable.getMessage());
            }
        };
        Verifai.startScan(activity, resultListener);
    }
}
