package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer

class WalletSeedFinishRecoverWallet(wallet: Pointer, private val seed: ByteArray) :
  CSDKAPICall<Unit>(wallet) {
  override suspend fun request(): Array<ByteArray> {
    val len = SizeTByReference()

    val pointer = CSDK.WalletSeedFinishRecoverWalletRequest(wallet, seed, seed.size, len)

    if (pointer == Pointer.NULL) throw CSDKAPICallRequestCreationException()

    return arrayOf(pointer.getByteArray(0, len.toIntChecked()))
  }

  override suspend fun response(bytes: ByteArray) {
    val rc = CSDK.WalletFinishRecoverWalletResponse(wallet, bytes, bytes.size)

    validateWalletResponse(rc)
  }
}
