package com.verifai.reactnative.liveness;

import android.app.Activity;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.google.gson.Gson;
import com.verifai.liveness.VerifaiLiveness;
import com.verifai.liveness.VerifaiLivenessCheckListener;
import com.verifai.liveness.checks.CloseEyes;
import com.verifai.liveness.checks.FaceMatching;
import com.verifai.liveness.checks.Speech;
import com.verifai.liveness.checks.Tilt;
import com.verifai.liveness.checks.VerifaiLivenessCheck;
import com.verifai.liveness.result.VerifaiLivenessCheckResults;
import com.verifai.reactnative.ConvertDataUtilities;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

/**
 * Wrapper class for the liveness module
 * Callbacks have to be set one by one because:
 * https://reactnative.dev/docs/native-modules-android#callbacks
 * Maybe this can be done differently when TurboModules are out
 */
@ReactModule(name = LivenessModule.NAME)
public class LivenessModule extends ReactContextBaseJavaModule {
    public static final String NAME = "Liveness";
    public static final String TAG = "V-LIVE";

    public LivenessModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    private Callback _onSuccess = null;

    @ReactMethod
    public void setOnSuccess(Callback onSuccess) {
        _onSuccess = onSuccess;
    }

    private Callback _onError = null;

    @ReactMethod
    public void setOnError(Callback onError) {
        _onError = onError;
    }

    private final ConvertDataUtilities utils = new ConvertDataUtilities();

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @ReactMethod
    public void start() {
        Activity activity = getCurrentActivity();
        if (activity == null) {
            Log.e(TAG, "No activity running");
            return;
        }
        if (_onSuccess == null) {
            Log.e(TAG, "No onSuccess callback has been set");
            return;
        }
        if (_onError == null) {
            Log.e(TAG, "No onError callback has been set");
            return;
        }

        VerifaiLivenessCheckListener resultListener = new VerifaiLivenessCheckListener() {
            @Override
            public void onResult(@NonNull VerifaiLivenessCheckResults results) {
                try {
                    Gson gson = new Gson();
                    String jsonResult = gson.toJson(results);
                    WritableMap returnMap = utils.convertJsonToMap(new JSONObject(jsonResult));
                    _onSuccess.invoke(returnMap);
                } catch (JSONException e) {
                    onError(new Exception("Data conversion failed"));
                }
            }

            @Override
            public void onError(Throwable throwable) {
                _onError.invoke(throwable.getMessage());
            }
        };
        ArrayList<VerifaiLivenessCheck> checks = new ArrayList<>();
//        if (result != null) {
//            checks.add(new FaceMatching(this, Objects.requireNonNull(result.getFrontImage())));
//        }
        checks.add(new Tilt(activity, -25));
        checks.add(new CloseEyes(activity, 2));
        VerifaiLiveness.start(activity, checks, resultListener);
    }
}
