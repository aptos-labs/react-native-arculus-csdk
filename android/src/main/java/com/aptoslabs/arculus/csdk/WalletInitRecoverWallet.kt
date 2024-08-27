package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer

class WalletInitRecoverWallet(wallet: Pointer, private val nbrOfWords: Int) :
  CSDKAPICall<Unit>(wallet) {
  override suspend fun request(): Array<ByteArray?> {
    val len = SizeTByReference()

    val pointer = CSDK.WalletInitRecoverWalletRequest(wallet, nbrOfWords, len)

    if (pointer == Pointer.NULL) throw CSDKAPICallRequestCreationException()

    return arrayOf(pointer.getByteArray(0, len.toIntChecked()))
  }

  override suspend fun response(bytes: ByteArray) {
    val rc = CSDK.WalletInitRecoverWalletResponse(wallet, bytes, bytes.size)

    validateWalletResponse(rc)
  }
}
