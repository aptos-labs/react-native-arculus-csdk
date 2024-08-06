package com.aptoslabs.reactnativearculuscsdk

import com.aptoslabs.arculus.Arculus
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class RNArculus(reactContext: ReactApplicationContext) {
  private val nfcSessionManager = RNNFCSessionManager(reactContext)
  private val arculus = Arculus(nfcSessionManager)

  fun <Result> handle(promise: Promise, execute: suspend Arculus.() -> Result) {
    CoroutineScope(Dispatchers.IO).launch {
      try {
        promise.resolve(arculus.execute())
      } catch (e: Exception) {
        promise.reject("RN_ARCULUS_CSDK_ERROR", e.localizedMessage, e)
      }
    }
  }
}
