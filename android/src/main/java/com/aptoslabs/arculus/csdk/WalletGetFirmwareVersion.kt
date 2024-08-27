package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer

class WalletGetFirmwareVersion(wallet: Pointer) : CSDKAPICall<String>(wallet) {
  override suspend fun request(): Array<ByteArray?> {
    val len = SizeTByReference()

    val pointer = CSDK.WalletGetFirmwareVersionRequest(wallet, len)

    if (pointer == Pointer.NULL) throw CSDKAPICallRequestCreationException()

    return arrayOf(pointer.getByteArray(0, len.toIntChecked()))
  }

  override suspend fun response(bytes: ByteArray): String {
    val len = SizeTByReference()

    val pointer = CSDK.WalletGetFirmwareVersionResponse(wallet, bytes, bytes.size, len)

    if (pointer == Pointer.NULL) throw CSDKAPICallResponseParsingException()

    val gguidBytes = pointer.getByteArray(0, len.toIntChecked())

    return gguidBytes.joinToString(".")
  }
}
