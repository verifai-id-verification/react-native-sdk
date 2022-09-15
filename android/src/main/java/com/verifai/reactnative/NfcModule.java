package com.verifai.reactnative;

import android.app.Activity;
import android.graphics.Bitmap;
import android.util.Base64;
import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.module.annotations.ReactModule;
import com.google.gson.Gson;
import com.verifai.core.result.DocumentSpecificData;
import com.verifai.core.result.VerifaiResult;
import com.verifai.nfc.VerifaiNfc;
import com.verifai.nfc.VerifaiNfcResultListener;
import com.verifai.nfc.result.EdlData;
import com.verifai.nfc.result.VerifaiNfcResult;

import org.jetbrains.annotations.NotNull;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;

/**
 * Wrapper class for the nfc module
 * Callbacks have to be set one by one because:
 * https://reactnative.dev/docs/native-modules-android#callbacks
 * Maybe this can be done differently when TurboModules are out
 */
@ReactModule(name = NfcModule.NAME)
public class NfcModule extends ReactContextBaseJavaModule {
    public static final String NAME = "NFC";
    public static final String TAG = "V-NFC";

    public NfcModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    private Callback _onSuccess = null;

    @ReactMethod
    public void setOnSuccess(Callback onSuccess) {
        _onSuccess = onSuccess;
    }

    private Callback _onCancelled = null;

    @ReactMethod
    public void setOnCancelled(Callback onCancelled) {
        _onCancelled = onCancelled;
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

    private ReadableMap convertNfcResult(VerifaiNfcResult result) {
        Gson gson = new Gson();
        WritableMap map = new WritableNativeMap();

        map.putBoolean("originality", result.originality());
        map.putBoolean("authenticity", result.authenticity());
        map.putBoolean("confidentiality", result.confidentiality());

        map.putBoolean("mrzMatch", result.getMrzMatch());
        map.putBoolean("comSodMatch", result.getComSodMatch());
        map.putString("bacStatus", result.getBacStatus().name());
        map.putString("paceStatus", result.getPaceStatus().name());
        map.putString("activeAuthenticationStatus", result.getActiveAuthenticationStatus().name());

        map.putBoolean("documentCertificateValid", result.getDocumentCertificateValid());
        map.putString("signingCertificateMatchesWithParent", result.getSigningCertificateMatchesWithParent().name());

        map.putBoolean("scanCompleted", result.getScanCompleted());

        map.putString("chipAuthenticationStatus", result.getChipAuthenticationStatus().name());
        map.putBoolean("documentSignatureCorrect", result.getDocumentSignatureCorrect());

        Bitmap photo = result.getPhoto();
        if (photo != null) {
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            photo.compress(Bitmap.CompressFormat.PNG, 100, stream);
            byte[] byteArray = stream.toByteArray();
            map.putString("photo", Base64.encodeToString(byteArray, Base64.DEFAULT));
        }

        try {
            String jsonMrz = gson.toJson(result.getMrzData());
            WritableMap mrzMap = utils.convertJsonToMap(new JSONObject(jsonMrz));
            map.putMap("mrzData", mrzMap);
        } catch (JSONException ignored) {
        }

        // dataGroups: HashMap<Int, NfcDocument.LdsFile>? = null
        try {
            if (result.getDocumentCertificate() != null) {
                map.putMap("documentCertificate", ConvertTypesToRNMap.convertX509toMap(result.getDocumentCertificate()));
            }
        } catch (Exception ignored) {
        }

        try {
            DocumentSpecificData docData = result.getDocumentSpecificData();
            if (docData instanceof EdlData) {
                EdlData edlData = (EdlData) docData;
                String jsonEdl = gson.toJson(edlData);
                WritableMap edlMap = utils.convertJsonToMap(new JSONObject(jsonEdl));
                map.putMap("documentSpecificData", edlMap);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        map.putString("type", result.getType());

        // sodHashes: HashMap<Int, ByteArray>? = null
        // sodData: ByteArray? = null
        if (result.getFeaturePoints() != null) {
            map.putInt("featurePoints", result.getFeaturePoints());
        } else map.putNull("featurePoints");
        // mimeBytes: ByteArray? = null
        if (result.getAaDigestAlgorithm() != null) {
            map.putString("aaDigestAlgorithm", result.getAaDigestAlgorithm());
        } else map.putNull("aaDigestAlgorithm");
        if (result.getChipAuthenticationOid() != null) {
            map.putString("chipAuthenticationOid", result.getChipAuthenticationOid());
        } else map.putNull("chipAuthenticationOid");
        if (result.getChipAuthenticationAgreementAlgorithm() != null) {
            map.putString("chipAuthenticationAgreementAlgorithm", result.getChipAuthenticationAgreementAlgorithm());
        } else map.putNull("chipAuthenticationAgreementAlgorithm");
        if (result.getChipAuthenticationPublicKeyAlgorithm() != null) {
            map.putString("chipAuthenticationAgreementAlgorithm", result.getChipAuthenticationPublicKeyAlgorithm());
        } else map.putNull("chipAuthenticationAgreementAlgorithm");

        try {
            if (result.getSigningCertificate() != null) {
                map.putMap("signingCertificate", ConvertTypesToRNMap.convertX509toMap(result.getSigningCertificate()));
            }
        } catch (Exception ignored) {
        }

        return map;
    }

    @ReactMethod
    public void start(ReadableMap args) {
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

        VerifaiNfcResultListener nfcResultListener = new VerifaiNfcResultListener() {
            @Override
            public void onResult(@NotNull VerifaiNfcResult result) {
                ReadableMap nfcResultMap = convertNfcResult(result);
                VerifaiNfcResultSingleton.getInstance().setResult(result);
                _onSuccess.invoke(nfcResultMap);
            }

            @Override
            public void onCanceled() {
                _onCancelled.invoke();
            }

            @Override
            public void onError(@NotNull Throwable throwable) {
                _onError.invoke(throwable.getMessage());
            }
        };
        VerifaiResult result = VerifaiResultSingleton.getInstance().getResult();
        if (result == null) {
            _onError.invoke("No result from core module");
            return;
        }

        try {
            boolean retrieveImage = true;
            if (args.hasKey("retrieveImage")) {
                retrieveImage = args.getBoolean("retrieveImage");
            }

            boolean showInstructionScreens = true;
            if (args.hasKey("instructionScreenConfiguration")) {
                ReadableMap instructionScreenConfig = args.getMap("instructionScreenConfiguration");
                if (instructionScreenConfig != null) {
                    if (instructionScreenConfig.hasKey("showInstructionScreens")) {
                        showInstructionScreens = instructionScreenConfig.getBoolean("showInstructionScreens");
                    }
                }
            }

            VerifaiNfcResultSingleton.getInstance().setResult(null); // Reset possible previous result
            VerifaiNfc.start(activity, result, retrieveImage, nfcResultListener, showInstructionScreens);
        } catch (Throwable e) {
            _onError.invoke(e.getMessage());
        }
    }
}
