package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer

class InvalidAIDException : Exception("Invalid application AID")

class ExpectedAIDNotMetException(expectedAID: WalletSelectWallet.ApplicationAID) :
  Exception("Expected ${expectedAID.aid} application AID not met")

class WalletSelectWallet(
  wallet: Pointer,
  private val applicationAID: ApplicationAID
) : CSDKAPICall<ByteArray>(wallet) {
  enum class ApplicationAID(val aid: ByteArray) {
    V1(byteArrayOf(0x4a, 0x4e, 0x45, 0x54, 0x5f, 0x4c, 0x5f, 0x01, 0x01, 0x57)),
    V2(byteArrayOf(0x41, 0x52, 0x43, 0x55, 0x4C, 0x55, 0x53, 0x01, 0x01, 0x57))
  }

  override suspend fun request(): Array<ByteArray> {
    val len = SizeTByReference()

    val pointer = CSDK.WalletSelectWalletRequest(wallet, applicationAID.aid, len)

    if (pointer == Pointer.NULL) throw CSDKAPICallRequestCreationException()

    return arrayOf(pointer.getByteArray(0, len.toIntChecked()))
  }

  override suspend fun response(bytes: ByteArray): ByteArray {
    val len = SizeTByReference()

    val result = CSDK.WalletSelectWalletResponse(
      wallet,
      bytes,
      bytes.size
    )

    val sAID = CSDK.WalletGetApplicationAID(result, len)

    return sAID.getByteArray(0, len.toIntChecked())
  }
}
