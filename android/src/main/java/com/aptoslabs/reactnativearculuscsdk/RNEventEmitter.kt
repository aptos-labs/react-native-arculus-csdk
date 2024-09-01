package com.aptoslabs.reactnativearculuscsdk

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule

class RNEventEmitter(private val reactContext: ReactApplicationContext) {
  private var listenerCount = 0

  fun addListener(eventName: String) {
    listenerCount += 1
  }

  fun removeListeners(count: Int) {
    listenerCount -= count
  }

  fun sendEvent(eventName: String, params: WritableMap?) {
    if (listenerCount > 0) {
      reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
        .emit(eventName, params)
    }
  }
}
