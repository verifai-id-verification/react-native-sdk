package com.verifai.reactnative;

import com.verifai.nfc.result.VerifaiNfcResult;

public class VerifaiNfcResultSingleton {
    private static VerifaiNfcResultSingleton instance;

    private VerifaiNfcResultSingleton() {
    }

    public static synchronized VerifaiNfcResultSingleton getInstance() {
        if (instance == null) {
            instance = new VerifaiNfcResultSingleton();
        }
        return instance;
    }

    private VerifaiNfcResult _result = null;

    public VerifaiNfcResult getResult() {
        return _result;
    }

    public void setResult(VerifaiNfcResult result) {
        _result = result;
    }
}
