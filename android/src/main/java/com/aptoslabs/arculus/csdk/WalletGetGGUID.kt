package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer

class WalletGetGGUID(wallet: Pointer) : CSDKAPICall<String>(wallet) {
  override suspend fun request(): Array<ByteArray?> {
    val len = SizeTByReference()

    val pointer = CSDK.WalletGetGGUIDRequest(wallet, len)

    if (pointer == Pointer.NULL) throw CSDKAPICallRequestCreationException()

    return arrayOf(pointer.getByteArray(0, len.toIntChecked()))
  }

  override suspend fun response(bytes: ByteArray): String {
    val len = SizeTByReference()

    val pointer = CSDK.WalletGetGGUIDResponse(wallet, bytes, bytes.size, len)

    if (pointer == Pointer.NULL) throw CSDKAPICallResponseParsingException()

    val gguidBytes = pointer.getByteArray(0, len.toIntChecked())

    return byteArrayToHexString(gguidBytes)
  }
}
