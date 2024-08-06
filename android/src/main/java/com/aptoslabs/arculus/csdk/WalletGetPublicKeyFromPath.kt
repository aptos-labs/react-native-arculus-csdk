package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer

class WalletGetPublicKeyFromPath(
  wallet: Pointer,
  private val path: String,
  private val curve: Short
) :
  CSDKAPICall<Map<String, String>>(wallet) {
  override suspend fun request(): Array<ByteArray> {
    val bipPath = path.encodeToByteArray()

    val len = SizeTByReference()

    val pointer = CSDK.WalletGetPublicKeyFromPathRequest(wallet, bipPath, path.length, curve, len)

    if (pointer == Pointer.NULL) throw CSDKAPICallRequestCreationException()

    return arrayOf(pointer.getByteArray(0, len.toIntChecked()))
  }

  override suspend fun response(bytes: ByteArray): Map<String, String> {
    val pointer = CSDK.WalletGetPublicKeyFromPathResponse(wallet, bytes, bytes.size)

    if (pointer == Pointer.NULL) throw CSDKAPICallResponseParsingException()

    val len = SizeTByReference()

    val chainCode = CSDK.ExtendedKey_getChainCode(pointer, len).getByteArray(0, len.toIntChecked())
    val publicKey = CSDK.ExtendedKey_getPubKey(pointer, len).getByteArray(0, len.toIntChecked())

    return mapOf(
      "chainCode" to byteArrayToHexString(chainCode),
      "publicKey" to byteArrayToHexString(publicKey)
    )
  }
}
