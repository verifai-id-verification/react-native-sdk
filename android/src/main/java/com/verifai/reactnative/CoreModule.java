package com.verifai.reactnative;

import android.app.Activity;
import android.graphics.Bitmap;
import android.util.Base64;
import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.verifai.core.Verifai;
import com.verifai.core.VerifaiConfiguration;
import com.verifai.core.VerifaiInstructionScreenConfiguration;
import com.verifai.core.VerifaiInstructionScreenId;
import com.verifai.core.VerifaiInstructionType;
import com.verifai.core.VerifaiSingleInstructionScreen;
import com.verifai.core.filters.VerifaiDocumentBlackListFilter;
import com.verifai.core.filters.VerifaiDocumentFilter;
import com.verifai.core.filters.VerifaiDocumentTypeWhiteListFilter;
import com.verifai.core.filters.VerifaiDocumentWhiteListFilter;
import com.verifai.core.internal.DocumentType;
import com.verifai.core.listeners.VerifaiResultListener;
import com.verifai.core.validators.VerifaiDocumentCountryBlackListValidator;
import com.verifai.core.result.VerifaiResult;
import com.facebook.react.bridge.Callback;
import com.verifai.core.validators.VerifaiDocumentCountryWhiteListValidator;
import com.verifai.core.validators.VerifaiDocumentHasMrzValidator;
import com.verifai.core.validators.VerifaiDocumentIsDrivingLicenceValidator;
import com.verifai.core.validators.VerifaiDocumentIsTravelDocumentValidator;
import com.verifai.core.validators.VerifaiDocumentTypesValidator;
import com.verifai.core.validators.VerifaiMrzAvailableValidator;
import com.verifai.core.validators.VerifaiMrzCorrectValidator;
import com.verifai.core.validators.VerifaiNFCKeyWhenAvailableValidator;
import com.verifai.core.validators.VerifaiNfcKeyRequiredValidator;
import com.verifai.core.validators.VerifaiValidatorInterface;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Objects;

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

    // This has to match the TypeScript enum in react native js part
    enum ValidatorType {
        DocumentCountryAllowList,
        DocumentCountryBlockList,
        DocumentHasMrz,
        DocumentTypes,
        MrzAvailable,
        NFCKeyWhenAvailable
    }

    enum DocumentFilterType {
        DocumentTypeAllowList,
        DocumentAllowList,
        DocumentBlockList,
    }

    enum DocumentType {
        IdCard,
        DriversLicence,
        Passport,
        Refugee,
        EmergencyPassport,
        ResidencePermitTypeI,
        ResidencePermitTypeII,
        Visa,
        Unknown
    }

    private ArrayList<com.verifai.core.internal.DocumentType> createDocumentTypeList(ReadableArray documentTypes) {
        ArrayList<com.verifai.core.internal.DocumentType> documentTypesList = new ArrayList<>();
        if (documentTypes != null) {
            for (int j = 0; j < documentTypes.size(); ++j) {
                switch (DocumentType.values()[documentTypes.getInt(j)]) {
                    case IdCard:
                        documentTypesList.add(com.verifai.core.internal.DocumentType.IDENTITY_CARD);
                        break;
                    case DriversLicence:
                        documentTypesList.add(com.verifai.core.internal.DocumentType.DRIVING_LICENCE);
                        break;
                    case Passport:
                        documentTypesList.add(com.verifai.core.internal.DocumentType.PASSPORT);
                        break;
                    case Refugee:
                        documentTypesList.add(com.verifai.core.internal.DocumentType.REFUGEE_TRAVEL_DOCUMENT);
                        break;
                    case EmergencyPassport:
                        documentTypesList.add(com.verifai.core.internal.DocumentType.EMERGENCY_PASSPORT);
                        break;
                    case ResidencePermitTypeI:
                        documentTypesList.add(com.verifai.core.internal.DocumentType.RESIDENCE_PERMIT_I);
                        break;
                    case ResidencePermitTypeII:
                        documentTypesList.add(com.verifai.core.internal.DocumentType.RESIDENCE_PERMIT_II);
                        break;
                    case Visa:
                        documentTypesList.add(com.verifai.core.internal.DocumentType.VISA);
                        break;
                }
            }
        }
        return documentTypesList;
    }

    @ReactMethod
    public void configure(ReadableMap rnConfig) {
        try {
            boolean requireDocumentCopy = true;
            if (rnConfig.hasKey("requireDocumentCopy")) {
                requireDocumentCopy = rnConfig.getBoolean("requireDocumentCopy");
            }
            boolean enablePostCropping = true;
            if (rnConfig.hasKey("enablePostCropping")) {
                enablePostCropping = rnConfig.getBoolean("enablePostCropping");
            }
            boolean enableManual = true;
            if (rnConfig.hasKey("enableManual")) {
                enableManual = rnConfig.getBoolean("enableManual");
            }
            boolean requireMrzContents = false;
            if (rnConfig.hasKey("requireMRZContents")) {
                requireMrzContents = rnConfig.getBoolean("requireMRZContents");
            }
            boolean requireNfcWhenAvailable = false;
            if (rnConfig.hasKey("requireNFCWhenAvailable")) {
                requireNfcWhenAvailable = rnConfig.getBoolean("requireNFCWhenAvailable");
            }
            boolean readMrzContents = true;
            if (rnConfig.hasKey("readMRZContents")) {
                readMrzContents = rnConfig.getBoolean("readMRZContents");
            }
            boolean documentFiltersAutoCreateValidators = true;
            if (rnConfig.hasKey("documentFiltersAutoCreateValidators")) {
                documentFiltersAutoCreateValidators = rnConfig.getBoolean("documentFiltersAutoCreateValidators");
            }
            boolean isScanHelpEnabled = true;
            if (rnConfig.hasKey("scanHelpConfiguration")) {
                ReadableMap scanHelpMap = rnConfig.getMap("scanHelpConfiguration");
                if (scanHelpMap != null) {
                    if (scanHelpMap.hasKey("isScanHelpEnabled")) {
                        isScanHelpEnabled = scanHelpMap.getBoolean("isScanHelpEnabled");
                    }
                }
            }
            boolean requireCroppedImage = true;
            if (rnConfig.hasKey("requireCroppedImage")) {
                requireCroppedImage = rnConfig.getBoolean("requireCroppedImage");
            }
            boolean enableVisualInspection = false;
            if (rnConfig.hasKey("enableVisualInspection")) {
                enableVisualInspection = rnConfig.getBoolean("enableVisualInspection");
            }

            ArrayList<VerifaiValidatorInterface> validators = new ArrayList<>();
            if (rnConfig.hasKey("validators")) {
                ReadableArray extraValidatorsArray = rnConfig.getArray("validators");
                if (extraValidatorsArray != null) {
                    for (int i = 0; i < extraValidatorsArray.size(); ++i) {
                        ReadableMap extraValidatorMap = extraValidatorsArray.getMap(i);
                        if (extraValidatorMap.hasKey("type")) {
                            int validatorType = extraValidatorMap.getInt("type");
                            switch (ValidatorType.values()[validatorType]) {
                                case DocumentCountryBlockList: {
                                    ReadableArray countryList = extraValidatorMap.getArray("countryList");
                                    ArrayList<String> countryStringList = new ArrayList<>();
                                    if (countryList != null) {
                                        for (int j = 0; j < countryList.size(); ++j) {
                                            countryStringList.add(countryList.getString(j));
                                        }
                                    }
                                    validators.add(new VerifaiDocumentCountryBlackListValidator(null, countryStringList));
                                    break;
                                }
                                case DocumentCountryAllowList: {
                                    ReadableArray countryList = extraValidatorMap.getArray("countryList");
                                    ArrayList<String> countryStringList = new ArrayList<>();
                                    if (countryList != null) {
                                        for (int j = 0; j < countryList.size(); ++j) {
                                            countryStringList.add(countryList.getString(j));
                                        }
                                    }
                                    validators.add(new VerifaiDocumentCountryWhiteListValidator(null, countryStringList));
                                    break;
                                }
                                case DocumentHasMrz:
                                    validators.add(new VerifaiDocumentHasMrzValidator());
                                    break;
                                case DocumentTypes: {
                                    ReadableArray documentTypes = extraValidatorMap.getArray("validDocumentTypes");
                                    ArrayList<com.verifai.core.internal.DocumentType> documentTypesList = createDocumentTypeList(documentTypes);
                                    validators.add(new VerifaiDocumentTypesValidator(null, null, documentTypesList));
                                    break;
                                }
                                case MrzAvailable:
                                    validators.add(new VerifaiMrzAvailableValidator(null));
                                    break;
                                case NFCKeyWhenAvailable:
                                    validators.add(new VerifaiNFCKeyWhenAvailableValidator());
                                    break;
                            }
                        }
                    }
                }
            }

            ArrayList<VerifaiDocumentFilter> documentFilters = new ArrayList<>();
            if (rnConfig.hasKey("documentFilters")) {
                ReadableArray documentFiltersArray = rnConfig.getArray("documentFilters");
                if (documentFiltersArray != null) {
                    for (int i = 0; i < documentFiltersArray.size(); ++i) {
                        ReadableMap documentFilterMap = documentFiltersArray.getMap(i);
                        int filterType = documentFilterMap.getInt("type");
                        switch (DocumentFilterType.values()[filterType]) {
                            case DocumentBlockList: {
                                ReadableArray countryList = documentFilterMap.getArray("countryList");
                                ArrayList<String> countryStringList = new ArrayList<>();
                                if (countryList != null) {
                                    for (int j = 0; j < countryList.size(); ++j) {
                                        countryStringList.add(countryList.getString(j));
                                    }
                                }
                                documentFilters.add(new VerifaiDocumentBlackListFilter(countryStringList));
                                break;
                            }
                            case DocumentAllowList: {
                                ReadableArray countryList = documentFilterMap.getArray("countryList");
                                ArrayList<String> countryStringList = new ArrayList<>();
                                if (countryList != null) {
                                    for (int j = 0; j < countryList.size(); ++j) {
                                        countryStringList.add(countryList.getString(j));
                                    }
                                }
                                documentFilters.add(new VerifaiDocumentWhiteListFilter(countryStringList));
                                break;
                            }
                            case DocumentTypeAllowList: {
                                ReadableArray documentTypes = documentFilterMap.getArray("documentTypes");
                                ArrayList<com.verifai.core.internal.DocumentType> documentTypesList = createDocumentTypeList(documentTypes);
                                documentFilters.add(new VerifaiDocumentTypeWhiteListFilter(documentTypesList));
                                break;
                            }
                        }
                    }
                }
            }

            VerifaiInstructionScreenConfiguration instructionScreenConfig = new VerifaiInstructionScreenConfiguration();
            if (rnConfig.hasKey("instructionScreenConfiguration")) {
                ReadableMap screenConfig = rnConfig.getMap("instructionScreenConfiguration");
                if (screenConfig != null) {
                    boolean showInstructionScreens = true;
                    if (screenConfig.hasKey("showInstructionScreens")) {
                        showInstructionScreens = screenConfig.getBoolean("showInstructionScreens");
                    }
//                    if (screenConfig.hasKey("instructionScreens")) {
//                        ReadableArray instructionScreensList = screenConfig.getArray("instructionScreens");
//                        if (instructionScreensList != null) {
//                            HashMap<VerifaiInstructionScreenId, VerifaiSingleInstructionScreen> instructionSceenMap = new HashMap<>();
//                            for (int i = 0; i < instructionScreensList.size(); ++i) {
//                                ReadableMap screenMap = instructionScreensList.getMap(i);
//                                int screenId = screenMap.getInt("screen");
//                                int type = screenMap.getInt("type");
//                                ReadableArray argList = screenMap.getArray("args");
//                                ArrayList<Object> argArray = new ArrayList<>();
//                                if (argList != null) {
//                                    argArray = argList.toArrayList();
//                                }
//                                VerifaiSingleInstructionScreen singleScreen =
//                                        new VerifaiSingleInstructionScreen(VerifaiInstructionType.values()[type], argArray.toArray(new Object[0]));
//                                instructionSceenMap.put(VerifaiInstructionScreenId.values()[screenId], singleScreen);
//                            }
//                            instructionScreenConfig.setInstructionScreens(instructionSceenMap);
//                        }
//                    }
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
                    5.0, // REDUNDANT was used in automatic flow
                    true, // DEPRECATED: show_instruction_screens
                    validators, // extraValidators
                    documentFilters, // document_filters
                    documentFiltersAutoCreateValidators,
                    isScanHelpEnabled, // if set to true, a hint box will appear when the users seems to have trouble scanning
                    requireCroppedImage, // if set true the photo result will be cropped,
                    instructionScreenConfig,
                    enableVisualInspection  // If set to false, no VIZ processing
            );
            Verifai.configure(configuration);
        } catch (Throwable e) {
            if (_onError != null) {
                _onError.invoke(e.getMessage());
            }
        }
    }

    @ReactMethod
    public void setLicence(String licence) {
        Activity activity = getCurrentActivity();
        if (activity == null) {
            Log.e(TAG, "No activity running");
            return;
        }
        Verifai.setLicence(activity, licence);
    }

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
        if (_onCancelled == null) {
            Log.e(TAG, "No onCancelled callback has been set");
            return;
        }
        if (_onError == null) {
            Log.e(TAG, "No onError callback has been set");
            return;
        }

        VerifaiResultListener resultListener = new VerifaiResultListener() {
            @Override
            public void onSuccess(@NonNull VerifaiResult verifaiResult) {
                try {
                    Gson gson = new Gson();
                    JsonElement element = gson.toJsonTree(verifaiResult);
                    JsonObject object = element.getAsJsonObject();
                    if (object.has("backImage")) {
                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
                        Objects.requireNonNull(verifaiResult.getBackImage()).compress(Bitmap.CompressFormat.PNG, 100, stream);
                        byte[] byteArray = stream.toByteArray();
                        JsonObject image = object.getAsJsonObject("backImage");
                        image.addProperty("data", Base64.encodeToString(byteArray, Base64.DEFAULT));
                    }
                    if (object.has("frontImage")) {
                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
                        Objects.requireNonNull(verifaiResult.getFrontImage()).compress(Bitmap.CompressFormat.PNG, 100, stream);
                        byte[] byteArray = stream.toByteArray();
                        JsonObject image = object.getAsJsonObject("frontImage");
                        image.addProperty("data", Base64.encodeToString(byteArray, Base64.DEFAULT));
                    }
                    WritableMap returnMap = utils.convertJsonToMap(new JSONObject(element.toString()));

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
