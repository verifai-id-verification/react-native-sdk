package com.verifai.reactnative

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.verifai.liveness.pub.LivenessCheckListener
import com.verifai.liveness.pub.LivenessConfiguration
import com.verifai.liveness.pub.VerifaiLiveness
import com.verifai.liveness.pub.checks.LivenessCheck
import com.verifai.liveness.pub.result.LivenessCheckResults
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromJsonElement
import kotlinx.serialization.json.encodeToJsonElement
import kotlinx.serialization.json.jsonObject

/**
 * Wrapper class for the liveness module
 */
@ReactModule(name = LivenessModule.NAME)
class LivenessModule(reactContext: ReactApplicationContext?) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return NAME
    }

    private val json = Json {
        encodeDefaults = true
    }

    @ReactMethod
    fun configure(args: ReadableMap, promise: Promise) {
        try {
            val configuration: LivenessConfiguration = json.decodeFromJsonElement(args.toJsonObject())
            VerifaiLiveness.configure(configuration)
            promise.resolve(null)
        } catch (e: Throwable) {
            promise.reject(e)
        }
    }

    @ReactMethod
    fun start(args: ReadableArray, promise: Promise) {
        try {
            val livenessChecks: List<LivenessCheck> = json.decodeFromJsonElement(args.toJsonArray(true))
            val resultListener = object : LivenessCheckListener {
                override fun onResult(results: LivenessCheckResults) {
                    try {
                        promise.resolve(json.encodeToJsonElement(results).jsonObject.toRNMap())
                    } catch (e: Throwable) {
                        promise.reject(Error.ResultConversion, e)
                    }
                }

                override fun onError(e: Throwable) {
                    promise.reject(Error.Liveness, e)
                }
            }
            VerifaiLiveness.start(currentActivity!!, resultListener, livenessChecks)
        } catch (e: Throwable) {
            promise.reject(Error.Unhandled, e)
        }
    }

    companion object {
        const val NAME = "Liveness"
    }
}
