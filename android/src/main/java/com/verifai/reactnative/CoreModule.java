package com.verifai.reactnative;

import static java.util.Collections.emptyList;

import android.app.Activity;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.UnexpectedNativeTypeException;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.google.gson.Gson;
import com.verifai.core.Verifai;
import com.verifai.core.VerifaiConfiguration;
import com.verifai.core.VerifaiInstructionScreenConfiguration;
import com.verifai.core.VerifaiInstructionScreenId;
import com.verifai.core.VerifaiInstructionType;
import com.verifai.core.VerifaiSingleInstructionScreen;
import com.verifai.core.listeners.VerifaiResultListener;
import com.verifai.core.result.VerifaiResult;
import com.facebook.react.bridge.Callback;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Wrapper class for the core module
 * Callbacks have to be set one by one because:
 * https://reactnative.dev/docs/native-modules-android#callbacks
 * Maybe this can be done differently when TurboModules are out
 */
@ReactModule(name = CoreModule.NAME)
public class CoreModule extends ReactContextBaseJavaModule {
    public static final String NAME = "Core";
    public static final String TAG = "V-CORE";

    public CoreModule(ReactApplicationContext reactContext) {
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

    @ReactMethod
    public void configure(ReadableMap rnConfig) {
        try {
            boolean requireDocumentCopy = true;
            if (rnConfig.hasKey("require_document_copy")) {
                requireDocumentCopy = rnConfig.getBoolean("require_document_copy");
            }
            boolean enablePostCropping = true;
            if (rnConfig.hasKey("enable_post_cropping")) {
                enablePostCropping = rnConfig.getBoolean("enable_post_cropping");
            }
            boolean enableManual = true;
            if (rnConfig.hasKey("enable_manual")) {
                enableManual = rnConfig.getBoolean("enable_manual");
            }
            boolean requireMrzContents = false;
            if (rnConfig.hasKey("require_mrz_contents")) {
                requireMrzContents = rnConfig.getBoolean("require_mrz_contents");
            }
            boolean requireNfcWhenAvailable = false;
            if (rnConfig.hasKey("require_nfc_when_available")) {
                requireNfcWhenAvailable = rnConfig.getBoolean("require_nfc_when_available");
            }
            boolean readMrzContents = true;
            if (rnConfig.hasKey("read_mrz_contents")) {
                readMrzContents = rnConfig.getBoolean("read_mrz_contents");
            }
            double scanDuration = 5.0;
            if (rnConfig.hasKey("scanDuration")) {
                scanDuration = rnConfig.getDouble("scanDuration");
            }
            boolean documentFiltersAutoCreateValidators = true;
            if (rnConfig.hasKey("document_filters_auto_create_validators")) {
                documentFiltersAutoCreateValidators = rnConfig.getBoolean("document_filters_auto_create_validators");
            }
            boolean isScanHelpEnabled = true;
            if (rnConfig.hasKey("is_scan_help_enabled")) {
                isScanHelpEnabled = rnConfig.getBoolean("is_scan_help_enabled");
            }
            boolean requireCroppedImage = true;
            if (rnConfig.hasKey("require_cropped_image")) {
                requireCroppedImage = rnConfig.getBoolean("require_cropped_image");
            }
            boolean enableVisualInspection = false;
            if (rnConfig.hasKey("enableVisualInspection")) {
                enableVisualInspection = rnConfig.getBoolean("enableVisualInspection");
            }

            VerifaiInstructionScreenConfiguration instructionScreenConfig = new VerifaiInstructionScreenConfiguration();
            if (rnConfig.hasKey("instructionScreenConfiguration")) {
                ReadableMap screenConfig = rnConfig.getMap("instructionScreenConfiguration");
                if (screenConfig != null) {
                    boolean showInstructionScreens = true;
                    if (screenConfig.hasKey("showInstructionScreens")) {
                        showInstructionScreens = screenConfig.getBoolean("showInstructionScreens");
                    }
                    if (screenConfig.hasKey("instructionScreens")) {
                        ReadableArray instructionScreensList = screenConfig.getArray("instructionScreens");
                        if (instructionScreensList != null) {
                            HashMap<VerifaiInstructionScreenId, VerifaiSingleInstructionScreen> instructionSceenMap = new HashMap<>();
                            for (int i = 0; i < instructionScreensList.size(); ++i) {
                                ReadableMap screenMap = instructionScreensList.getMap(i);
                                int screenId = screenMap.getInt("screenId");
                                int type = screenMap.getInt("type");
                                ReadableArray argList = screenMap.getArray("args");
                                ArrayList<Object> argArray = new ArrayList<>();
                                if (argList != null) {
                                    argArray = argList.toArrayList();
                                }
                                VerifaiSingleInstructionScreen singleScreen =
                                        new VerifaiSingleInstructionScreen(VerifaiInstructionType.values()[type], argArray.toArray(new Object[0]));
                                instructionSceenMap.put(VerifaiInstructionScreenId.values()[screenId], singleScreen);
                            }
                            instructionScreenConfig.setInstructionScreens(instructionSceenMap);
                        }
                    }
                    instructionScreenConfig.setShowInstructionScreens(showInstructionScreens);
                }
            }
            VerifaiConfiguration configuration = new VerifaiConfiguration(
                    requireDocumentCopy, // if set to false it switches off all AI mode screens and picture correction screens. Also skips taking a picture of the non-MRZ side.
                    enablePostCropping, // set to false the C1 and C2 states are disabled and it should show C3
                    enableManual,  // If set to false the routes that lead to the F screens return a negative result to the developer
                    requireMrzContents, // if set to true, it disables all documents without MRZ and adds the MrzValidator.
                    requireNfcWhenAvailable,  // if set to true, the NfcKeyWhenAvailableValidator is added and if there are several results in J1 that contain different chips, it should be shown. If all the same it can be skipped.
                    readMrzContents, // if set true the whole MRZ will be read, if false it only reads the prefix
                    scanDuration,
                    true, // DEPRECATED: show_instruction_screens
                    emptyList(), // extraValidators
                    emptyList(), // document_filters
                    documentFiltersAutoCreateValidators,
                    isScanHelpEnabled, // if set to true, a hint box will appear when the users seems to have trouble scanning
                    requireCroppedImage, // if set true the photo result will be cropped,
                    instructionScreenConfig,
                    enableVisualInspection  // If set to false, no VIZ processing
            );
            Verifai.configure(configuration);
        } catch (UnexpectedNativeTypeException e) {
            if (_onError != null) {
                _onError.invoke(e.getMessage());
            }
        }
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
                try {
                    Gson gson = new Gson();
                    String jsonResult = gson.toJson(verifaiResult);
                    WritableMap returnMap = utils.convertJsonToMap(new JSONObject(jsonResult));

                    VerifaiResultSingleton.getInstance().setResult(verifaiResult);
                    _onSuccess.invoke(returnMap);
                } catch (JSONException e) {
                    onError(new Exception("Data conversion failed"));
                }
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

        VerifaiResultSingleton.getInstance().setResult(null); // Reset possible previous result
        Verifai.startScan(activity, resultListener);
    }
}
