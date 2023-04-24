package com.verifai.reactnative;

import com.verifai.core.result.VerifaiResult;

public class VerifaiResultSingleton {

    private static VerifaiResultSingleton  instance;

    private VerifaiResultSingleton() { }

    public static synchronized VerifaiResultSingleton getInstance() {
        if (instance == null) {
            instance = new VerifaiResultSingleton();
        }
        return instance;
    }

    private VerifaiResult _result = null;
    public VerifaiResult getResult() { return _result; }
    public void setResult(VerifaiResult result) { _result = result; }
}
