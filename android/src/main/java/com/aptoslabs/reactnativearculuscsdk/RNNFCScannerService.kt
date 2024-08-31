package com.aptoslabs.reactnativearculuscsdk

import android.app.Activity
import android.app.PendingIntent
import android.content.Intent
import android.content.IntentFilter
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import com.aptoslabs.arculus.NFCConnectionProvider
import com.facebook.react.bridge.ActivityEventListener
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactApplicationContext
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

class RNNFCScannerService(
  private val reactContext: ReactApplicationContext,
  private val eventEmitter: RNEventEmitter
) :
  NFCConnectionProvider,
  ActivityEventListener,
  LifecycleEventListener {
  class NoCompatibleTagsFoundException : Exception("No compatible tags found")

  private val nfcAdapter = NfcAdapter.getDefaultAdapter(reactContext)

  private var isAppInForeground: Boolean = false
  private var tagRequest: Continuation<IsoDep>? = null

  init {
    reactContext.addActivityEventListener(this)
    reactContext.addLifecycleEventListener(this)
  }

  // region NFCConnectionProvider

  override suspend fun <ResultType> connect(callback: suspend (IsoDep) -> ResultType): ResultType {
    val tag = suspendCoroutine {
      tagRequest = it
      if (isAppInForeground) {
        startScanning()
      }
    }

    tag.use {
      try {
        it.connect()
        it.timeout = 15000
        eventEmitter.sendEvent("ConnectionOpened", null)
        return callback(it)
      } finally {
        eventEmitter.sendEvent("ConnectionClosed", null)
      }
    }
  }

  // endregion

  // region LifecycleEventListener

  override fun onHostResume() {
    isAppInForeground = true
    if (tagRequest != null) {
      startScanning()
    }
  }


  override fun onHostPause() {
    isAppInForeground = false
    if (tagRequest != null) {
      cancelScanning()
    }
  }

  override fun onHostDestroy() {
  }

  // endregion

  // region ActivityEventListener

  override fun onNewIntent(intent: Intent) {
    if (intent.action == NfcAdapter.ACTION_TECH_DISCOVERED || intent.action == NfcAdapter.ACTION_TAG_DISCOVERED) {
      onActionTagDiscovered(intent)
    }
  }

  override fun onActivityResult(
    activity: Activity,
    requestCode: Int,
    resultCode: Int,
    data: Intent?
  ) {
    // no-op
  }

  // endregion

  // region Tag scanning

  private fun startScanning() {
    val activity = reactContext.currentActivity ?: return

    val requestCode = 0
    val intent = Intent(activity, activity::class.java).apply {
      addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
    }
    val flags = if (VERSION.SDK_INT >= VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
    val pendingIntent = PendingIntent.getActivity(activity, requestCode, intent, flags)

    val intentFilters = arrayOf(IntentFilter(NfcAdapter.ACTION_TECH_DISCOVERED))
    val techListsArray = arrayOf(arrayOf(IsoDep::class.java.name))
    nfcAdapter?.enableForegroundDispatch(activity, pendingIntent, intentFilters, techListsArray)
    eventEmitter.sendEvent("ScanningStarted", null)
  }

  private fun cancelScanning() {
    val activity = reactContext.currentActivity ?: return
    nfcAdapter?.disableForegroundDispatch(activity)
    eventEmitter.sendEvent("ScanningStopped", null)
  }

  private fun onActionTagDiscovered(intent: Intent) {
    // The tag request should never be null at this point
    if (tagRequest == null) {
      return
    }

    val tag = if (VERSION.SDK_INT >= VERSION_CODES.TIRAMISU) {
      intent.getParcelableExtra(NfcAdapter.EXTRA_TAG, Tag::class.java)
    } else {
      @Suppress("DEPRECATION")
      intent.getParcelableExtra(NfcAdapter.EXTRA_TAG)
    }

    if (tag != null) {
      tagRequest?.resume(IsoDep.get(tag))
    } else {
      tagRequest?.resumeWithException(NoCompatibleTagsFoundException())
    }
    tagRequest = null
    if (isAppInForeground) {
      cancelScanning()
    }
  }

  // endregion
}
