package com.aptoslabs.reactnativearculuscsdk

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class ReactNativeArculusCsdkModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
  companion object {
    const val NAME = "ReactNativeArculusCsdk"
  }

  override fun getName(): String {
    return NAME
  }

  private val rnArculus = RNArculus(reactContext)

  @ReactMethod
  fun changePIN(oldPIN: String, newPIN: String, promise: Promise) {
    rnArculus.handle(promise) {
      changePIN(oldPIN, newPIN)

      null
    }
  }

  @ReactMethod
  fun createWallet(pin: String, nbrOfWords: Int, promise: Promise) {
    rnArculus.handle(promise) {
      createWallet(pin, nbrOfWords)
    }
  }

  @ReactMethod
  fun getFirmwareVersion(promise: Promise) {
    rnArculus.handle(promise) {
      getFirmwareVersion()
    }
  }

  @ReactMethod
  fun getGGUID(promise: Promise) {
    rnArculus.handle(promise) {
      getGGUID()
    }
  }

  @ReactMethod
  fun getInfo(path: String, curve: Int, promise: Promise) {
    rnArculus.handleMap(promise) {
      getInfo(path, curve.toShort())
    }
  }

  @ReactMethod
  fun getPublicKeyFromPath(path: String, curve: Int, promise: Promise) {
    rnArculus.handleMap(promise) {
      getPublicKeyFromPath(path, curve.toShort())
    }
  }

  @ReactMethod
  fun resetWallet(promise: Promise) {
    rnArculus.handle(promise) {
      resetWallet()

      null
    }
  }

  @ReactMethod
  fun restoreWallet(pin: String, mnemonicSentence: String, promise: Promise) {
    rnArculus.handle(promise) {
      restoreWallet(pin, mnemonicSentence)

      null
    }
  }

  @ReactMethod
  fun signHash(
    pin: String,
    path: String,
    curve: Int,
    algorm: Int,
    hash: String,
    promise: Promise
  ) {
    rnArculus.handle(promise) {
      signHash(pin, path, curve.toShort(), algorm.toByte(), hash)
    }
  }

  @ReactMethod
  fun verifyPIN(pin: String, promise: Promise) {
    rnArculus.handle(promise) {
      verifyPIN(pin)

      null
    }
  }
}
