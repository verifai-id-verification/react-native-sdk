package com.verifai.reactnative;

import android.app.Activity;
import android.graphics.Bitmap;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.module.annotations.ReactModule;
import com.verifai.core.result.VerifaiResult;
import com.verifai.liveness.VerifaiLiveness;
import com.verifai.liveness.VerifaiLivenessCheckListener;
import com.verifai.liveness.checks.CloseEyes;
import com.verifai.liveness.checks.FaceMatching;
import com.verifai.liveness.checks.Speech;
import com.verifai.liveness.checks.Tilt;
import com.verifai.liveness.checks.VerifaiLivenessCheck;
import com.verifai.liveness.result.VerifaiFaceMatchingCheckResult;
import com.verifai.liveness.result.VerifaiLivenessCheckResult;
import com.verifai.liveness.result.VerifaiLivenessCheckResults;
import com.verifai.nfc.result.VerifaiNfcResult;

import java.util.ArrayList;
import java.util.Objects;

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

    // This has to match the TypeScript enum in react native js part
    enum LivenessCheck {
        CloseEyes,
        Tilt,
        Speech,
        FaceMatching,
    }

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

    private ReadableMap convertLivenessResult(VerifaiLivenessCheckResults result) {
        WritableMap map = new WritableNativeMap();
        map.putBoolean("automaticChecksPassed", result.getAutomaticChecksPassed());
        map.putDouble("successRatio", result.getSuccessRatio());

        ArrayList<VerifaiLivenessCheckResult> resultList = result.getResultList();
        WritableArray list = new WritableNativeArray();
        for (int i = 0; i < resultList.size(); ++i) {
            WritableMap resMap = new WritableNativeMap();
            VerifaiLivenessCheckResult currentResult = resultList.get(i);
            resMap.putString("status", currentResult.getStatus().name());
            VerifaiLivenessCheck check = currentResult.getCheck();
            WritableMap checkMap = new WritableNativeMap();
            checkMap.putString("instruction", check.getInstruction());
            if (check instanceof CloseEyes) {
                checkMap.putString("name", "CloseEyes");
                checkMap.putDouble("numberOfSeconds", ((CloseEyes) check).getNumberOfSeconds());
            } else if (check instanceof Tilt) {
                checkMap.putString("name", "Tilt");
                checkMap.putDouble("faceAngleRequirement", ((Tilt) check).getFaceAngleRequirement());
            } else if (check instanceof Speech) {
                checkMap.putString("name", "Speech");
                checkMap.putString("speechRequirement", ((Speech) check).getSpeechRequirement());
            } else if (check instanceof FaceMatching) {
                checkMap.putString("name", "FaceMatching");
                // FaceMatching has image that cannot be converted for now
            }

            if (currentResult instanceof VerifaiFaceMatchingCheckResult) {
                VerifaiFaceMatchingCheckResult faceMatchResult = (VerifaiFaceMatchingCheckResult) currentResult;
                if (faceMatchResult.getConfidence() != null) {
                    resMap.putDouble("confidence", faceMatchResult.getConfidence());
                } else resMap.putNull("confidence");
                if (faceMatchResult.getMatch() != null) {
                    resMap.putBoolean("match", faceMatchResult.getMatch());
                } else resMap.putNull("match");
            }

            resMap.putMap("check", checkMap);
            list.pushMap(resMap);
        }
        map.putArray("resultList", list);
        return map;
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @ReactMethod
    public void start(ReadableArray args) {
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

        ArrayList<VerifaiLivenessCheck> checks = new ArrayList<>();
//        checks.add(new Tilt(activity, -25));
        for (int i = 0; i < args.size(); i++) {
            ReadableType type = args.getType(i);
            if (type != ReadableType.Map) {
                _onError.invoke("Argument should be an object");
                return;
            }

            ReadableMap argMap = args.getMap(i);
            if (argMap.hasKey("check")) {
                if (argMap.getType("check") == ReadableType.Number) {
                    LivenessCheck check = LivenessCheck.values()[argMap.getInt("check")];
                    switch (check) {
                        case CloseEyes:
                            if (argMap.hasKey("numberOfSeconds")) {
                                if (argMap.getType("numberOfSeconds") == ReadableType.Number) {
                                    checks.add(new CloseEyes(activity, argMap.getDouble("numberOfSeconds")));
                                } else {
                                    _onError.invoke("Argument 'numberOfSeconds' should be a number");
                                    return;
                                }
                            } else {
                                _onError.invoke("'Close eyes' should have 'numberOfSeconds' argument");
                                return;
                            }
                            break;
                        case Tilt:
                            if (argMap.hasKey("faceAngleRequirement")) {
                                if (argMap.getType("faceAngleRequirement") == ReadableType.Number) {
                                    checks.add(new Tilt(activity, argMap.getInt("faceAngleRequirement")));
                                } else {
                                    _onError.invoke("Argument 'faceAngleRequirement' should be a number");
                                    return;
                                }
                            } else {
                                _onError.invoke("'Tilt' should have 'faceAngleRequirement' argument");
                                return;
                            }
                            break;
                        case Speech:
                            if (argMap.hasKey("speechRequirement")) {
                                if (argMap.getType("speechRequirement") == ReadableType.String) {
                                    checks.add(new Speech(activity, Objects.requireNonNull(argMap.getString("speechRequirement"))));
                                } else {
                                    _onError.invoke("Argument 'speechRequirement' should be a string");
                                    return;
                                }
                            } else {
                                _onError.invoke("'Speech' should have 'speechRequirement' argument");
                                return;
                            }
                            break;
                        case FaceMatching:
                            if (argMap.hasKey("imageType")) {
                                if (argMap.getType("imageType") == ReadableType.String) {
                                    String imageType = argMap.getString("imageType");
                                    Bitmap image;
                                    if (imageType.equals("nfc")) {
                                        VerifaiNfcResult nfcResult = VerifaiNfcResultSingleton.getInstance().getResult();
                                        if (nfcResult != null) {
                                            image = nfcResult.getPhoto();
                                            if (image != null) {
                                                checks.add(new FaceMatching(activity, image));
                                            } else {
                                                _onError.invoke("NFC result has no image");
                                                continue; // Skip
                                            }
                                        } else {
                                            _onError.invoke("Result from nfc module is null");
                                            return;
                                        }
                                    } else if (imageType.equals("doc")) {
                                        VerifaiResult coreResult = VerifaiResultSingleton.getInstance().getResult();
                                        if (coreResult != null) {
                                            image = coreResult.getFrontImage();
                                            if (image != null) {
                                                checks.add(new FaceMatching(activity, image));
                                            } else {
                                                _onError.invoke("Result has no front image");
                                                continue; // Skip
                                            }
                                        } else {
                                            _onError.invoke("Result from core module is null");
                                            return;
                                        }
                                    } else {
                                        _onError.invoke("Argument 'imageTYpe' should be either 'nfc' or 'doc'");
                                        return;
                                    }
                                } else {
                                    _onError.invoke("Argument 'speechRequirement' should be a string");
                                    return;
                                }
                            } else {
                                _onError.invoke("'Face matching' should have 'imageType' argument");
                                return;
                            }
                            break;
                        default:
                            _onError.invoke("Unexpected value: " + check.toString());
                            return;
                    }
                } else {
                    _onError.invoke("'check' argument should be of type enum (number)");
                    return;
                }
            }
        }

        VerifaiLivenessCheckListener resultListener = new VerifaiLivenessCheckListener() {
            @Override
            public void onResult(@NonNull VerifaiLivenessCheckResults results) {
                try {
                    _onSuccess.invoke(convertLivenessResult(results));
                } catch (Exception e) {
                    onError(e);
                }
            }

            @Override
            public void onError(Throwable throwable) {
                _onError.invoke(throwable.getMessage());
            }
        };
        VerifaiLiveness.start(activity, checks, resultListener);
    }
}
