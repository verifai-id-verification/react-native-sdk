package com.verifai.reactnative

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.verifai.core.pub.CoreConfiguration
import com.verifai.core.pub.Verifai
import com.verifai.core.pub.exceptions.CanceledException
import com.verifai.core.pub.listeners.LocalResultListener
import com.verifai.core.pub.listeners.ResultListener
import com.verifai.core.pub.result.CoreResult
import com.verifai.core.pub.result.LocalCoreResult
import com.verifai.core.pub.validators.DocumentCountryAllowlistValidator
import com.verifai.core.pub.validators.DocumentCountryAllowlistValidatorSerializer
import com.verifai.core.pub.validators.DocumentCountryBlocklistValidator
import com.verifai.core.pub.validators.DocumentCountryBlocklistValidatorSerializer
import com.verifai.core.pub.validators.DocumentHasMrzValidator
import com.verifai.core.pub.validators.DocumentHasMrzValidatorSerializer
import com.verifai.core.pub.validators.DocumentTypesValidator
import com.verifai.core.pub.validators.DocumentTypesValidatorSerializer
import com.verifai.core.pub.validators.MrzAvailableValidator
import com.verifai.core.pub.validators.MrzAvailableValidatorSerializer
import com.verifai.core.pub.validators.NfcKeyWhenAvailableValidator
import com.verifai.core.pub.validators.NfcKeyWhenAvailableValidatorSerializer
import com.verifai.core.pub.validators.ValidatorInterface
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromJsonElement
import kotlinx.serialization.json.encodeToJsonElement
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.modules.SerializersModule
import kotlinx.serialization.modules.polymorphic

/**
 * Wrapper class for the core module
 */
@ReactModule(name = CoreModule.NAME)
class CoreModule(reactContext: ReactApplicationContext?) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return NAME
    }

    private val mySerializersModule = SerializersModule {
        polymorphic(ValidatorInterface::class) {
            subclass(
                DocumentCountryAllowlistValidator::class,
                DocumentCountryAllowlistValidatorSerializer
            )
            subclass(
                DocumentCountryBlocklistValidator::class,
                DocumentCountryBlocklistValidatorSerializer
            )
            subclass(DocumentHasMrzValidator::class, DocumentHasMrzValidatorSerializer)
            subclass(DocumentTypesValidator::class, DocumentTypesValidatorSerializer)
            subclass(MrzAvailableValidator::class, MrzAvailableValidatorSerializer)
            subclass(NfcKeyWhenAvailableValidator::class, NfcKeyWhenAvailableValidatorSerializer)
        }
    }

    private val json = Json {
        encodeDefaults = true
        serializersModule = mySerializersModule
    }

    @ReactMethod
    fun setLicense(license: String, promise: Promise) {
        try {
            Verifai.setLicense(currentActivity!!, license)
            promise.resolve(null)
        } catch (e: Throwable) {
            promise.reject(Error.License, e)
        }
    }

    @ReactMethod
    fun configure(args: ReadableMap, promise: Promise) {
        try {
            val configuration: CoreConfiguration = json.decodeFromJsonElement(args.toJsonObject())
            Verifai.configure(configuration)
            promise.resolve(null)
        } catch (e: Throwable) {
            promise.reject(Error.Configuration, e)
        }
    }

    @ReactMethod
    fun start(internalReference: String? = null, promise: Promise) {
        try {
            Verifai.start(currentActivity!!, object : ResultListener {
                override fun onSuccess(result: CoreResult) {
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
            Verifai.startLocal(currentActivity!!, object : LocalResultListener {
                override fun onSuccess(result: LocalCoreResult) {
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
        const val NAME = "Core"
    }
}
