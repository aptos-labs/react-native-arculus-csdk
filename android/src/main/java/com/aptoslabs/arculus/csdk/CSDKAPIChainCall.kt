package com.aptoslabs.arculus.csdk

import android.nfc.tech.IsoDep
import com.sun.jna.Pointer

class InvalidAPDUSequenceException(message: String) : Exception(message)

class InvalidStatusWordException(sw1: Byte, sw2: Byte) :
  Exception("Invalid status word: SW1=$sw1, SW2=$sw2")

class CommandExecutionFailedException(message: String) : Exception(message)

abstract class CSDKAPIChainCall<ResponseType>(wallet: Pointer) : CSDKAPICall<ResponseType>(wallet) {
  private fun sendCommand(data: Array<ByteArray>, tag: IsoDep): ByteArray {
    data.forEachIndexed { index, apdu ->
      val bytes = sendCommand(apdu, tag)

      if (index == data.size - 1) {
        return bytes
      }

      // Check if the sequence size is valid
      if (data.size != 2) {
        throw InvalidAPDUSequenceException("APDU sequence must contain exactly 2 commands, but found ${data.size}")
      }

      val sw1 = bytes[bytes.size - 2]
      val sw2 = bytes[bytes.size - 1]

      // Validate the status word
      if (sw1 != 0x90.toByte() || sw2 != 0x00.toByte()) {
        throw InvalidStatusWordException(sw1, sw2)
      }
    }

    // If no valid response is returned, throw an execution failure exception
    throw CommandExecutionFailedException("Failed to execute the command sequence.")
  }

  override suspend fun execute(tag: IsoDep): ResponseType {
    val data = request()

    val bytes = sendCommand(data, tag)
    
    return response(bytes)
  }
}
