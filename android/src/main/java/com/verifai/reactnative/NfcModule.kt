package com.verifai.reactnative

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.verifai.core.pub.CoreConfiguration
import com.verifai.core.pub.exceptions.CanceledException
import com.verifai.nfc.pub.NfcConfiguration
import com.verifai.nfc.pub.VerifaiNfc
import com.verifai.nfc.pub.listeners.LocalNfcResultListener
import com.verifai.nfc.pub.listeners.NfcResultListener
import com.verifai.nfc.pub.result.LocalCombinedResult
import com.verifai.nfc.pub.result.NfcResult
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromJsonElement
import kotlinx.serialization.json.encodeToJsonElement
import kotlinx.serialization.json.jsonObject

private const val KEY_CORE = "core"
private const val KEY_NFC = "nfc"

/**
 * Wrapper class for the nfc module
 */
@ReactModule(name = NfcModule.NAME)
class NfcModule(reactContext: ReactApplicationContext?) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return NAME
    }

    private val json = Json { encodeDefaults = true }

    @ReactMethod
    fun setLicense(license: String, promise: Promise) {
        try {
            VerifaiNfc.setLicense(currentActivity!!, license)
            promise.resolve(null)
        } catch (e: Throwable) {
            promise.reject(Error.License, e)
        }
    }

    @ReactMethod
    fun configure(args: ReadableMap, promise: Promise) {
        try {
            var coreConfig = CoreConfiguration()
            args.getMap(KEY_CORE)?.toJsonObject()?.let {
                coreConfig = json.decodeFromJsonElement(it)
            }

            var nfcConfig = NfcConfiguration()
            args.getMap(KEY_NFC)?.toJsonObject()?.let {
                nfcConfig = json.decodeFromJsonElement(it)
            }

            VerifaiNfc.configure(coreConfig, nfcConfig)
            promise.resolve(null)
        } catch (e: Throwable) {
            promise.reject(Error.Configuration, e)
        }
    }

    @ReactMethod
    fun start(internalReference: String? = null, promise: Promise) {
        try {
            VerifaiNfc.start(currentActivity!!, object : NfcResultListener {
                override fun onSuccess(result: NfcResult) {
                    try {
                        promise.resolve(json.encodeToJsonElement(result).jsonObject.toRNMap())
                    } catch (e: Throwable) {
                        promise.reject(Error.ResultConversion, e)
                    }
                }

                override fun onError(e: Throwable) {
                    if (e is CanceledException) {
                        promise.reject(Error.Canceled, e)
                    } else {
                        promise.reject(Error.Sdk, e)
                    }
                }
            }, internalReference)
        } catch (e: Throwable) {
            promise.reject(Error.Unhandled, e)
        }
    }

    @ReactMethod
    fun startLocal(promise: Promise) {
        try {
            VerifaiNfc.startLocal(currentActivity!!, object : LocalNfcResultListener {
                override fun onSuccess(result: LocalCombinedResult) {
                    try {
                        promise.resolve(json.encodeToJsonElement(result).jsonObject.toRNMap())
                    } catch (e: Throwable) {
                        promise.reject(Error.ResultConversion, e)
                    }
                }

                override fun onError(e: Throwable) {
                    if (e is CanceledException) {
                        promise.reject(Error.Canceled, e)
                    } else {
                        promise.reject(Error.Sdk, e)
                    }
                }
            })
        } catch (e: Throwable) {
            promise.reject(Error.Unhandled, e)
        }
    }

    companion object {
        const val NAME = "NFC"
    }
}
