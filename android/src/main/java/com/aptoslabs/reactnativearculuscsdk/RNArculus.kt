package com.aptoslabs.reactnativearculuscsdk

import com.aptoslabs.arculus.Arculus
import com.aptoslabs.arculus.NFCConnectionProvider
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.WritableMap
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

fun <K, V> toWritableMap(map: Map<K, V>): WritableMap {
  val result = Arguments.createMap()

  map.forEach { (key, value) ->
    if (key is String) {
      when (value) {
        is String -> result.putString(key, value)
        is Int -> result.putInt(key, value)
        is Double -> result.putDouble(key, value)
        is Boolean -> result.putBoolean(key, value)
        is Map<*, *> -> result.putMap(key, toWritableMap(value))
        else -> throw IllegalArgumentException("Unsupported type of key $key")
      }
    } else {
      throw IllegalArgumentException("WritableMap only supports String keys")
    }
  }

  return result
}

class RNArculus(nfcConnectionProvider: NFCConnectionProvider) {
  private val arculus = Arculus(nfcConnectionProvider)

  fun <Result> handle(promise: Promise, execute: suspend Arculus.() -> Result) {
    CoroutineScope(Dispatchers.IO).launch {
      try {
        promise.resolve(arculus.execute())
      } catch (e: Exception) {
        promise.reject("RN_ARCULUS_CSDK_ERROR", e.localizedMessage, e)
      }
    }
  }

  fun <K, V> handleMap(promise: Promise, execute: suspend Arculus.() -> Map<K, V>) {
    handle(promise) {
      toWritableMap(execute())
    }
  }
}
