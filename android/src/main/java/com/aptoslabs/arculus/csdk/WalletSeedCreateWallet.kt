package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer

class WalletSeedCreateWallet(wallet: Pointer, private val nbrOfWords: Int) :
  CSDKAPICall<String>(wallet) {
  override suspend fun request(): Array<ByteArray> {
    val len = SizeTByReference()

    val pointer = CSDK.WalletSeedCreateWalletRequest(wallet, len, nbrOfWords)

    if (pointer == Pointer.NULL) throw CSDKAPICallRequestCreationException()

    return arrayOf(pointer.getByteArray(0, len.toIntChecked()))
  }

  override suspend fun response(bytes: ByteArray): String {
    val mnemonicSentenceLength = SizeTByReference()

    val pointer = CSDK.WalletCreateWalletResponse(wallet, bytes, bytes.size, mnemonicSentenceLength)

    val data = pointer.getByteArray(0, mnemonicSentenceLength.toIntChecked())

    return data.toString(Charsets.UTF_8).trimEnd('\u0000')
  }
}
