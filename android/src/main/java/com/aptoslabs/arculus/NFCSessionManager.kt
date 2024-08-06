package com.aptoslabs.arculus

import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES

abstract class NFCSessionManager(context: Context) {
  private val nfcAdapter = NfcAdapter.getDefaultAdapter(context)

  protected var isoDep: IsoDep? = null

  abstract suspend fun beginSession(): IsoDep

  open fun invalidateSession() {
    isoDep?.let {
      try {
        it.close()
      } finally {
        isoDep = null
      }
    }
  }

  protected fun handleIntent(intent: Intent): IsoDep? {
    val action = intent.action ?: return null

    if (NfcAdapter.ACTION_TECH_DISCOVERED != action && NfcAdapter.ACTION_TAG_DISCOVERED != action) return null

    val tag = if (VERSION.SDK_INT >= VERSION_CODES.TIRAMISU) {
      intent.getParcelableExtra(NfcAdapter.EXTRA_TAG, Tag::class.java)
    } else {
      @Suppress("DEPRECATION")
      intent.getParcelableExtra(NfcAdapter.EXTRA_TAG)
    } ?: throw Exception("No NFC tag available")

    this.isoDep = IsoDep.get(tag).apply { connect() }

    return this.isoDep ?: throw Exception("IsoDep technology not supported")
  }

  protected fun enableForegroundDispatch(activity: Activity) {
    val requestCode = 0

    val intent = Intent(activity, activity::class.java).apply {
      addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
    }

    val flags = if (VERSION.SDK_INT >= VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0

    val pendingIntent = PendingIntent.getActivity(activity, requestCode, intent, flags)

    val intentFilters = arrayOf(IntentFilter(NfcAdapter.ACTION_TECH_DISCOVERED))

    val techListsArray = arrayOf(arrayOf(IsoDep::class.java.name))

    nfcAdapter?.enableForegroundDispatch(activity, pendingIntent, intentFilters, techListsArray)
  }

  protected fun disableForegroundDispatch(activity: Activity) {
    nfcAdapter?.disableForegroundDispatch(activity)
  }
}

