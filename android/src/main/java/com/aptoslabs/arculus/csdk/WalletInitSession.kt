package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer

class WalletInitSession(wallet: Pointer) : CSDKAPICall<Unit>(wallet) {
  override suspend fun request(): Array<ByteArray?> {
    val len = SizeTByReference()

    val pointer = CSDK.WalletInitSessionRequest(wallet, len)

    if (pointer == Pointer.NULL) throw CSDKAPICallRequestCreationException()

    return arrayOf(pointer.getByteArray(0, len.toIntChecked()))
  }

  override suspend fun response(bytes: ByteArray) {
    val rc = CSDK.WalletInitSessionResponse(wallet, bytes, bytes.size)

    validateWalletResponse(rc)
  }
}
