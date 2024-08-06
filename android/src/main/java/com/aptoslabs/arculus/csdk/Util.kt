package com.aptoslabs.arculus.csdk

fun byteArrayToHexString(data: ByteArray): String {
  return "0x" + data.joinToString("") { "%02x".format(it) }
}

abstract class InvalidHexStringException(message: String) : IllegalArgumentException(message)
class InvalidHexCharacterException(characters: String) :
  InvalidHexStringException("The input string contains invalid characters: $characters")

class OddHexLengthException :
  InvalidHexStringException("The input string must have an even number of characters")

fun hexStringToByteArray(hexString: String): ByteArray {
  val hasPrefix = hexString.startsWith("0x", ignoreCase = true)
  val hex = if (hasPrefix) hexString.substring(2) else hexString

  if (hex.length % 2 != 0) throw OddHexLengthException()

  return ByteArray(hex.length / 2) {
    val index = it * 2
    val byteString = hex.substring(index, index + 2)

    try {
      byteString.toInt(16).toByte()
    } catch (e: NumberFormatException) {
      throw InvalidHexCharacterException(byteString)
    }
  }
}
