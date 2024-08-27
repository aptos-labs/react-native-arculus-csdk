package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer

class WalletResetWallet(wallet: Pointer) : CSDKAPICall<Unit>(wallet) {
  override suspend fun request(): Array<ByteArray?> {
    val len = SizeTByReference()

    val pointer = CSDK.WalletResetWalletRequest(wallet, len)

    if (pointer == Pointer.NULL) throw CSDKAPICallRequestCreationException()

    return arrayOf(pointer.getByteArray(0, len.toIntChecked()))
  }

  override suspend fun response(bytes: ByteArray) {
    val rc = CSDK.WalletResetWalletResponse(wallet, bytes, bytes.size)

    validateWalletResponse(rc)
  }
}
