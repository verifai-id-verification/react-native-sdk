package com.verifai.reactnative;

import android.util.Base64;

import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;

import java.security.cert.CertificateEncodingException;
import java.security.cert.CertificateParsingException;
import java.security.cert.X509Certificate;
import java.util.List;

public class ConvertTypesToRNMap {
    public static ReadableMap convertX509toMap(X509Certificate cert) throws CertificateEncodingException, CertificateParsingException {
        WritableMap map = new WritableNativeMap();
        map.putInt("version", cert.getVersion());
        map.putInt("serialNumber", cert.getSerialNumber().intValue());
        map.putString("serialNumber", cert.getSigAlgOID());
        map.putString("serialNumber", cert.getSigAlgName());
        map.putString("signatureAlgorithmParams", Base64.encodeToString(cert.getSigAlgParams(), Base64.DEFAULT));
        map.putString("issuerName", cert.getIssuerX500Principal().getName());
        map.putString("notBefore", cert.getNotBefore().toString());
        map.putString("notAfter", cert.getNotAfter().toString());
        map.putString("subjectName", cert.getSubjectX500Principal().getName());
        map.putString("tbsCertificate", Base64.encodeToString(cert.getTBSCertificate(), Base64.DEFAULT));
        map.putString("signature", Base64.encodeToString(cert.getSignature(), Base64.DEFAULT));
        boolean[] issuerIdList = cert.getIssuerUniqueID();
        if (issuerIdList != null) {
            WritableArray issuerIdArray = new WritableNativeArray();
            for (boolean b : issuerIdList) {
                issuerIdArray.pushBoolean(b);
            }
            map.putArray("issuerUniqueID", issuerIdArray);
        }
        boolean[] subjectIdList = cert.getSubjectUniqueID();
        if (subjectIdList != null) {
            WritableArray subjectIdArray = new WritableNativeArray();
            for (boolean b : subjectIdList) {
                subjectIdArray.pushBoolean(b);
            }
            map.putArray("subjectUniqueID", subjectIdArray);
        }
        boolean[] keyUsageList = cert.getKeyUsage();
        if (keyUsageList != null) {
            WritableArray keyUsageArray = new WritableNativeArray();
            for (boolean b : keyUsageList) {
                keyUsageArray.pushBoolean(b);
            }
            map.putArray("keyUsage", keyUsageArray);
        }
        List<String> extendedKeyUsageList = cert.getExtendedKeyUsage();
        if (extendedKeyUsageList != null) {
            WritableArray extendedKeyUsageArray = new WritableNativeArray();
            for (String s : extendedKeyUsageList) {
                extendedKeyUsageArray.pushString(s);
            }
            map.putArray("extendedKeyUsage", extendedKeyUsageArray);
        }
        return map;
    }
}
