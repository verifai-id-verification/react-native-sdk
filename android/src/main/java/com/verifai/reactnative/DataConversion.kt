package com.verifai.reactnative

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReadableType
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.buildJsonObject

fun JsonObject.toRNMap(): ReadableMap {
    return Arguments.createMap().also { map ->
        entries.forEach { (key, value) ->
            map.addJsonElement(key, value)
        }
    }
}

fun JsonArray.toRNArray(): ReadableArray {
    return Arguments.createArray().also { array ->
        map { array.addJsonElement(it) }
    }
}

fun WritableMap.addJsonElement(key: String, element: JsonElement) {
    when (element) {
        is JsonObject -> putMap(key, element.toRNMap())
        is JsonArray -> putArray(key, element.toRNArray())
        is JsonNull -> putNull(key)
        is JsonPrimitive -> {
            when {
                element.isString -> putString(key, element.content)
                element.booleanOrNull != null -> putBoolean(key, element.boolean)
                else -> putDouble(key, element.content.toDouble())
            }
        }
    }
}

fun WritableArray.addJsonElement(element: JsonElement) {
    when (element) {
        is JsonObject -> pushMap(element.toRNMap())
        is JsonArray -> pushArray(element.toRNArray())
        is JsonNull -> pushNull()
        is JsonPrimitive -> {
            when {
                element.isString -> pushString(element.content)
                element.booleanOrNull != null -> pushBoolean(element.boolean)
                else -> pushDouble(element.content.toDouble())
            }
        }
    }
}

fun ReadableMap.toJsonObject(convertDoubleToInt: Boolean = false): JsonObject {
    return buildJsonObject {
        entryIterator.forEach { (key, _) ->
            when (getType(key)) {
                ReadableType.Null -> put(key, JsonNull)
                ReadableType.Boolean -> put(key, JsonPrimitive(getBoolean(key)))
                ReadableType.Number -> {
                    if (convertDoubleToInt && (getDouble(key) % 1 == 0.0)) {
                        put(key, JsonPrimitive(getInt(key)))
                    } else {
                        put(key, JsonPrimitive(getDouble(key)))
                    }
                }
                ReadableType.String -> put(key, JsonPrimitive(getString(key)))
                ReadableType.Map -> put(key, getMap(key)!!.toJsonObject(convertDoubleToInt))
                ReadableType.Array -> put(key, getArray(key)!!.toJsonArray(convertDoubleToInt))
            }
        }
    }
}

fun ReadableArray.toJsonArray(convertDoubleToInt: Boolean = false): JsonArray {
    return buildJsonArray {
        repeat(size()) { i ->
            when (getType(i)) {
                ReadableType.Null -> add(JsonNull)
                ReadableType.Boolean -> add(JsonPrimitive(getBoolean(i)))
                ReadableType.Number -> {
                    if (convertDoubleToInt && (getDouble(i) % 1 == 0.0)) {
                        add(JsonPrimitive(getInt(i)))
                    } else {
                        add(JsonPrimitive(getDouble(i)))
                    }
                }
                ReadableType.String -> add(JsonPrimitive(getString(i)))
                ReadableType.Map -> add(getMap(i).toJsonObject(convertDoubleToInt))
                ReadableType.Array -> add(getArray(i).toJsonArray(convertDoubleToInt))
            }
        }
    }
}
