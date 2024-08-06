package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer

class WalletStoreDataPIN(wallet: Pointer, private val pin: String) : CSDKAPICall<Unit>(wallet) {
  override suspend fun request(): Array<ByteArray> {
    val pinBytes = pin.encodeToByteArray()

    val len = SizeTByReference()

    val pointer = CSDK.WalletStoreDataPINRequest(wallet, pinBytes, pinBytes.size, len)

    if (pointer == Pointer.NULL) throw CSDKAPICallRequestCreationException()

    return arrayOf(pointer.getByteArray(0, len.toIntChecked()))
  }

  override suspend fun response(bytes: ByteArray) {

    val rc = CSDK.WalletStoreDataPINResponse(wallet, bytes, bytes.size)

    validateWalletResponse(rc)
  }
}
