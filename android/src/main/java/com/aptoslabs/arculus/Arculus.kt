package com.aptoslabs.arculus

import com.aptoslabs.arculus.csdk.CSDKAPI

class Arculus(private val nfcConnectionProvider: NFCConnectionProvider) {
  private suspend fun <ResultType> execute(sendCommands: suspend CSDKAPI.() -> ResultType): ResultType {
    return nfcConnectionProvider.connect { tag ->
      CSDKAPI(tag).use { api ->
        api.sendCommands()
      }
    }
  }

  suspend fun changePIN(oldPIN: String, newPIN: String) {
    return execute {
      walletSelectWallet()
      walletVerifyPIN(oldPIN)
      walletStoreDataPIN(newPIN)
    }
  }

  suspend fun createWallet(pin: String, nbrOfWords: Int): String {
    return execute {
      walletSelectWallet()
      walletResetWallet()
      walletStoreDataPIN(pin)

      val mnemonicSentence = walletSeedCreateWallet(nbrOfWords)

      val seed = walletSeedFromMnemonicSentence(mnemonicSentence)

      walletInitRecoverWallet(nbrOfWords)
      walletSeedFinishRecoverWallet(seed)

      mnemonicSentence
    }
  }

  suspend fun getFirmwareVersion(): String {
    return execute {
      walletSelectWallet()
      walletGetFirmwareVersion()
    }
  }

  suspend fun getGGUID(): String {
    return execute {
      walletSelectWallet()
      walletGetGGUID()
    }
  }

  suspend fun getPublicKeyFromPath(path: String, curve: Short): Map<String, String> {
    return execute {
      walletSelectWallet()
      walletGetPublicKeyFromPath(path, curve)
    }
  }

  suspend fun getInfo(path: String, curve: Short): Map<String, String> {
    return execute {
      walletSelectWallet()

      val gguid = walletGetGGUID()

      val publicKey = walletGetPublicKeyFromPath(path, curve)

      publicKey.plus(Pair("gguid", gguid))
    }
  }

  suspend fun resetWallet() {
    return execute {
      walletSelectWallet()
      walletResetWallet()
    }
  }

  suspend fun restoreWallet(pin: String, mnemonicSentence: String) {
    return execute {
      val nbrOfWords = mnemonicSentence.split(" ").size

      val seed = walletSeedFromMnemonicSentence(mnemonicSentence)

      walletSelectWallet()
      walletResetWallet()
      walletStoreDataPIN(pin)
      walletInitRecoverWallet(nbrOfWords)
      walletSeedFinishRecoverWallet(seed)
    }
  }

  suspend fun signHash(
    pin: String,
    path: String,
    curve: Short,
    algorithm: Byte,
    hash: String
  ): String {
    return execute {
      walletSelectWallet()
      walletVerifyPIN(pin)

      walletSignHash(path, curve, algorithm, hash)
    }
  }

  suspend fun verifyPIN(pin: String) {
    execute {
      walletSelectWallet()
      walletVerifyPIN(pin)
    }
  }
}
