package com.aptoslabs.reactnativearculuscsdk

import android.app.Activity
import android.content.Intent
import android.nfc.tech.IsoDep
import com.aptoslabs.arculus.NFCSessionManager
import com.facebook.react.bridge.ActivityEventListener
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine


class RNNFCSessionManager(private val reactContext: ReactApplicationContext) :
  NFCSessionManager(reactContext),
  ActivityEventListener,
  LifecycleEventListener,
  AutoCloseable {
  private var continuation: Continuation<IsoDep>? = null

  init {
    reactContext.addActivityEventListener(this)
    reactContext.addLifecycleEventListener(this)
  }

  private fun sendEvent(eventName: String, params: WritableMap?) {
    reactContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(eventName, params)
  }

  override suspend fun getTag(): IsoDep {
    return suspendCoroutine { it ->
      continuation = it

      sendEvent("ArculusCardStartScanning", null)
    }
  }

  override fun close() {
    continuation = null

    super.close()

    sendEvent("ArculusCardConnectionClosed", null)
  }

  override fun onActivityResult(
    activity: Activity,
    requestCode: Int,
    resultCode: Int,
    data: Intent?
  ) {
  }

  override fun onNewIntent(intent: Intent) {
    try {
      val isoDep = handleTagDetection(intent) ?: return

      sendEvent("ArculusCardConnected", null)

      continuation?.resume(isoDep)
    } catch (e: Exception) {
      continuation?.resumeWithException(e)
    }
  }

  override fun onHostDestroy() {
    close()
  }

  override fun onHostPause() {
    reactContext.currentActivity?.let { cancelScanning(it) }
  }

  override fun onHostResume() {
    reactContext.currentActivity?.let { startScanning(it) }
  }
}

