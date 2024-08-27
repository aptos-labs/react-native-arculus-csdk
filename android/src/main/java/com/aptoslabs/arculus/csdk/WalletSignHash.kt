package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer
import com.sun.jna.ptr.PointerByReference

class WalletSignHash(
  wallet: Pointer,
  private val path: String,
  private val curve: Short,
  private val algorithm: Byte,
  private val hash: String
) : CSDKAPIChainCall<String>(wallet) {
  override suspend fun request(): Array<ByteArray?> {
    val pathBytes = path.toByteArray()
    val pathPointer = CSDK.CreateByteVector(pathBytes)

    val hashBytes = hexStringToByteArray(hash)
    val hashPointer = CSDK.CreateByteVector(hashBytes)

    val apdu = PointerByReference()

    val rc = CSDK.WalletSignRequest(
      wallet,
      pathPointer,
      curve,
      algorithm,
      hashPointer,
      apdu
    )

    validateWalletResponse(rc)

    val apduSequence = CSDK.GetAPDUSequenceFromResult(apdu)

    return apduSequence.GetChain()
  }

  override suspend fun response(bytes: ByteArray): String {
    val len = SizeTByReference()

    val pointer = CSDK.WalletSignHashResponse(wallet, bytes, bytes.size, len)

    val gguidBytes = pointer.getByteArray(0, len.toIntChecked())

    return byteArrayToHexString(gguidBytes)
  }
}
