package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer

class WalletSeedFromMnemonicSentence(wallet: Pointer, private val mnemonicSentence: String) :
  CSDKAPICommand<ByteArray>(wallet) {
  override suspend fun execute(): ByteArray {
    val mnemonicSentenceBytes = mnemonicSentence.toByteArray(Charsets.UTF_8)

    val len = SizeTByReference()

    val pointer = CSDK.WalletSeedFromMnemonicSentence(
      wallet,
      mnemonicSentenceBytes,
      mnemonicSentence.length,
      ByteArray(0),
      0,
      len
    )

    if (pointer == Pointer.NULL) throw CSDKAPICallRequestCreationException()

    return pointer.getByteArray(0, len.toIntChecked())
  }
}
