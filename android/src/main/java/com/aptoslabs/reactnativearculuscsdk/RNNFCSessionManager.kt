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
    return suspendCoroutine {
      continuation = it

      sendEvent("ScanningStarted", null)
    }
  }

  override fun close() {
    continuation = null

    super.close()

    sendEvent("ConnectionClosed", null)
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
      if (continuation == null) return

      val isoDep = handleTagDetection(intent) ?: return

      sendEvent("ConnectionOpened", null)

      continuation?.resume(isoDep)
    } catch (e: Exception) {
      continuation?.resumeWithException(e)
    }
  }

  override fun onHostDestroy() {
    close()
  }

  override fun onHostPause() {
    reactContext.currentActivity?.let { disableForegroundDispatch(it) }
  }

  override fun onHostResume() {
    reactContext.currentActivity?.let { enableForegroundDispatch(it) }
  }
}

