package com.aptoslabs.arculus.csdk

import android.nfc.tech.IsoDep
import com.sun.jna.Pointer

class CSDKAPI(private val tag: IsoDep) : AutoCloseable {
  private val wallet: Pointer = CSDK.WalletInit()

  override fun close() {
    CSDK.WalletFree(wallet)
  }

  suspend fun walletGetFirmwareVersion(): String {
    return WalletGetFirmwareVersion(wallet).execute(tag)
  }

  suspend fun walletGetGGUID(): String {
    return WalletGetGGUID(wallet).execute(tag)
  }

  suspend fun walletGetPublicKeyFromPath(path: String, curve: Short): Map<String, String> {
    return WalletGetPublicKeyFromPath(wallet, path, curve).execute(tag)
  }

  suspend fun walletInitRecoverWallet(nbrOfWords: Int) {
    return WalletInitRecoverWallet(wallet, nbrOfWords).execute(tag)
  }

  suspend fun walletInitSession() {
    return WalletInitSession(wallet).execute(tag)
  }

  suspend fun walletResetWallet() {
    return WalletResetWallet(wallet).execute(tag)
  }

  suspend fun walletSeedCreateWallet(nbrOfWords: Int): String {
    return WalletSeedCreateWallet(wallet, nbrOfWords).execute(tag)
  }

  suspend fun walletSeedFinishRecoverWallet(seed: ByteArray) {
    return WalletSeedFinishRecoverWallet(wallet, seed).execute(tag)
  }

  suspend fun walletSeedFromMnemonicSentence(mnemonicSentence: String): ByteArray {
    return WalletSeedFromMnemonicSentence(wallet, mnemonicSentence).execute()
  }

  private suspend fun walletSelectWalletV1() {
    val aid = WalletSelectWallet(
      wallet,
      WalletSelectWallet.ApplicationAID.V1
    ).execute(tag)

    if (!aid.contentEquals(WalletSelectWallet.ApplicationAID.V1.aid)) {
      throw ExpectedAIDNotMetException(WalletSelectWallet.ApplicationAID.V1)
    }
  }

  private suspend fun walletSelectWalletV2() {
    walletInitSession()
  }

  suspend fun walletSelectWallet() {
    val aid = WalletSelectWallet(
      wallet,
      WalletSelectWallet.ApplicationAID.V2
    ).execute(tag)

    when {
      aid.contentEquals(WalletSelectWallet.ApplicationAID.V1.aid) -> walletSelectWalletV1()
      aid.contentEquals(WalletSelectWallet.ApplicationAID.V2.aid) -> walletSelectWalletV2()
      else -> throw InvalidAIDException()
    }
  }

  suspend fun walletSignHash(path: String, curve: Short, algorithm: Byte, hash: String): String {
    return WalletSignHash(wallet, path, curve, algorithm, hash).execute(tag)
  }

  suspend fun walletStoreDataPIN(pin: String) {
    return WalletStoreDataPIN(wallet, pin).execute(tag)
  }

  suspend fun walletVerifyPIN(pin: String) {
    return WalletVerifyPIN(wallet, pin).execute(tag)
  }
}
