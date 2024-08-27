package com.aptoslabs.arculus.csdk

import android.nfc.tech.IsoDep
import com.sun.jna.Pointer

class ChainCallFailedEarlyException(step: Int, total: Int) :
  Exception("Chain call failed early - $step/$total")

class ChainCallFinishedEarlyException(step: Int, total: Int) :
  Exception("Chain call finished early - $step/$total")

class CommandExecutionFailedException(message: String) : Exception(message)

abstract class CSDKAPIChainCall<ResponseType>(wallet: Pointer) : CSDKAPICall<ResponseType>(wallet) {
  private fun sendCommand(data: Array<ByteArray?>, tag: IsoDep): ByteArray {
    data.forEachIndexed { index, apdu ->
      val bytes = sendCommand(apdu, tag)

      if (index == data.size - 1) {
        return bytes
      }

      if (data.size != 2) {
        throw ChainCallFinishedEarlyException(index, data.size)
      }

      val sw1 = bytes[bytes.size - 2]
      val sw2 = bytes[bytes.size - 1]

      if (sw1 != 0x90.toByte() || sw2 != 0x00.toByte()) {
        throw ChainCallFailedEarlyException(index, data.size)
      }
    }

    throw CommandExecutionFailedException("Failed to execute the command sequence.")
  }

  override suspend fun execute(tag: IsoDep): ResponseType {
    val data = request()

    val bytes = sendCommand(data, tag)

    return response(bytes)
  }
}
