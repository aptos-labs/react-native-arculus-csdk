package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer

class WalletVerifyPIN(wallet: Pointer, private val pin: String) : CSDKAPICall<Unit>(wallet) {
  private class WalletVerifyPINException(tries: Int) :
    Exception("Wrong PIN. $tries tries remaining.")

  override suspend fun request(): Array<ByteArray> {
    val pinBytes = pin.encodeToByteArray()

    val len = SizeTByReference()

    val pointer = CSDK.WalletVerifyPINRequest(wallet, pinBytes, pinBytes.size, len)

    if (pointer == Pointer.NULL) throw CSDKAPICallRequestCreationException()

    return arrayOf(pointer.getByteArray(0, len.toIntChecked()))
  }

  override suspend fun response(bytes: ByteArray) {
    val nbrOfTries = SizeTByReference()

    val rc = CSDK.WalletVerifyPINResponse(wallet, bytes, bytes.size, nbrOfTries)

    val tries = nbrOfTries.toIntChecked()

    if (tries in 0..2) throw WalletVerifyPINException(tries)

    validateWalletResponse(rc)
  }
}
