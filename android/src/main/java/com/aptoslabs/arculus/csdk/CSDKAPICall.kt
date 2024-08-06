package com.aptoslabs.arculus.csdk

import android.nfc.tech.IsoDep
import com.sun.jna.Pointer
import com.sun.jna.ptr.PointerByReference

class CSDKAPICallRequestCreationException : Exception("Failed to create request")
class CSDKAPICallResponseParsingException : Exception("Failed to parse response")

class CSDKError(rc: Int) : Exception(getErrorMessage(rc)) {
  companion object {
    private const val CSDK_ERR_NULL_POINTER = -100
    private const val CSDK_ERR_NULL_APPLETOBJ = -101
    private const val CSDK_ERR_NULL_CALLOC = -102
    private const val CSDK_ERR_WRONG_RESPONSE_LENGTH = -103
    private const val CSDK_ERR_WRONG_RESPONSE_DATA = -104
    private const val CSDK_ERR_WRONG_STATUS_WORD = -105
    private const val CSDK_ERR_WRONG_DATA_LENGTH = -106
    private const val CSDK_ERR_WRONG_PARAM_LENGTH = -107
    private const val CSDK_ERR_WRONG_PIN = -108
    private const val CSDK_ERR_INVALID_PARAM = -109
    private const val CSDK_ERR_ENCRYPTION_NOT_INIT = -110
    private const val CSDK_ERR_EXT_OR_CHAIN_NOT_SUPORTED = -111
    private const val CSDK_ERR_API_CHAIN_NOT_SUPORTED = -112
    private const val CSDK_ERR_UNKNOWN_ERROR = -113
    private const val CSDK_ERR_APDU_EXCEEDS_CHAIN_LENGTH = -114
    private const val CSDK_ERR_EXTAPDU_SUPPORT_REQUIRED = -115
    private const val CSDK_ERR_APDU_TOO_BIG = -116
    private const val CSDK_ERR_WALLET_NOT_SELECTED = -117

    private fun getErrorMessage(rc: Int): String {
      val message = PointerByReference()
      val len = SizeTByReference()

      if (CSDK.WalletErrorMessage(
          rc,
          message,
          len
        ) == CSDK.CSDK_OK && message.value != Pointer.NULL
      ) {
        val description = message.value.getString(0)

        if (description != "Unknown error code") {
          return description
        }
      }

      return when (rc) {
        CSDK_ERR_NULL_POINTER -> "Null pointer encountered"
        CSDK_ERR_NULL_APPLETOBJ -> "Wallet session object is NULL"
        CSDK_ERR_NULL_CALLOC -> "Unable to allocate memory"
        CSDK_ERR_WRONG_RESPONSE_LENGTH -> "Card response length is incorrect/unexpected"
        CSDK_ERR_WRONG_RESPONSE_DATA -> "Card response not valid"
        CSDK_ERR_WRONG_STATUS_WORD -> "Card response status not expected"
        CSDK_ERR_WRONG_DATA_LENGTH -> "Data length of payload is invalid"
        CSDK_ERR_WRONG_PARAM_LENGTH -> "Parameter size validation failed"
        CSDK_ERR_WRONG_PIN -> "Wrong PIN"
        CSDK_ERR_INVALID_PARAM -> "Invalid Parameter"
        CSDK_ERR_ENCRYPTION_NOT_INIT -> "NFC Session encryption was not initialized"
        CSDK_ERR_EXT_OR_CHAIN_NOT_SUPORTED -> "Card doesn't support extended APDUs or chaining"
        CSDK_ERR_API_CHAIN_NOT_SUPORTED -> "API is deprecated and requires Chaining"
        CSDK_ERR_UNKNOWN_ERROR -> "An unknown error has occurred"
        CSDK_ERR_APDU_EXCEEDS_CHAIN_LENGTH -> "APDU too big to do chaining"
        CSDK_ERR_EXTAPDU_SUPPORT_REQUIRED -> "Extended APDU not supported but required"
        CSDK_ERR_APDU_TOO_BIG -> "APDU too big"
        CSDK_ERR_WALLET_NOT_SELECTED -> "Wallet not selected"
        else -> "Unknown error code: $rc"
      }
    }
  }
}


abstract class CSDKAPICall<ResponseType>(wallet: Pointer) : CSDKAPICommand<ResponseType>(wallet) {
  override suspend fun execute(): ResponseType {
    throw Error("execute() must not be called - use execute(tag:) instead")
  }

  open suspend fun request(): Array<ByteArray> {
    throw NotImplementedError("request must be overridden")
  }

  open suspend fun response(bytes: ByteArray): ResponseType {
    throw NotImplementedError("response must be overridden")
  }

  protected fun sendCommand(data: ByteArray?, tag: IsoDep): ByteArray {
    requireNotNull(data) { "cannot send empty request" }

    return tag.transceive(data)
  }

  open suspend fun execute(tag: IsoDep): ResponseType {
    val data = request()

    require(data.size == 1) { "request should return exactly one data item in the array" }

    val bytes = sendCommand(data.first(), tag)

    return response(bytes)
  }

  protected fun validateWalletResponse(rc: Int) {
    if (rc != CSDK.CSDK_OK) {
      throw CSDKError(rc)
    }
  }
}
