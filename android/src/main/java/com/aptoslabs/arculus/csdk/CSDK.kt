package com.aptoslabs.arculus.csdk

import com.sun.jna.Memory
import com.sun.jna.Native
import com.sun.jna.NativeLibrary
import com.sun.jna.Pointer
import com.sun.jna.Structure
import com.sun.jna.ptr.PointerByReference

@Suppress("KotlinJniMissingFunction", "FunctionName", "unused")
object CSDK {
  private val LIBRARY: NativeLibrary = NativeLibrary.getInstance("csdk")

  @Structure.FieldOrder("count", "addr")
  class ByteVector(pointer: Pointer?) : Structure(pointer) {
    @JvmField
    var count: Int = 0

    @JvmField
    var addr: Pointer? = null

    init {
      read()
    }

    constructor(bytes: ByteArray) : this(null) {
      val m = Memory(bytes.size.toLong())
      m.write(0, bytes, 0, bytes.size)
      allocateMemory()
      addr = m
      count = bytes.size
      write()
    }

    override fun getFieldOrder(): List<String> {
      return listOf("count", "addr")
    }
  }

  @Structure.FieldOrder("count", "apdu", "extended_apdu")
  class APDUSequence(pointer: Pointer?) : Structure(pointer) {
    @JvmField
    var count: Int = 0

    @JvmField
    var apdu: Pointer? = null // Pointer to array of ByteVector C structs

    @JvmField
    var extended_apdu: Boolean = false

    init {
      useMemory(pointer)
      read()
    }

    override fun getFieldOrder(): List<String> {
      return listOf("count", "apdu", "extended_apdu")
    }

    fun GetChain(): Array<ByteArray?> {
      val byteVectorSize = Native.getNativeSize(ByteVector::class.java)
      return Array(count) { index ->
        val byteVectorPointer = apdu?.share((index * byteVectorSize).toLong())
        val byteVector = ByteVector(byteVectorPointer)
        val byteArray = byteVector.addr?.getByteArray(0, byteVector.count)
        byteArray
      }
    }
  }

  fun GetByteVectorFromPointer(ptr: Pointer): ByteVector {
    return ByteVector(ptr)
  }

  fun CreateByteVector(bytes: ByteArray): Pointer {
    val m = Memory(bytes.size.toLong())
    m.write(0, bytes, 0, bytes.size)
    val byteVector = ByteVector(bytes)
    return byteVector.pointer
  }

  fun GetAPDUSequenceFromResult(result: PointerByReference): APDUSequence {
    val resultPtr = result.value
    return APDUSequence(resultPtr)
  }

  fun CheckPartialAPDUChainResult(nfcResult: ByteArray): Boolean {
    return if (nfcResult.size == 2) {
      nfcResult[0] == 0x90.toByte() && nfcResult[1] == 0x00.toByte()
    } else {
      false
    }
  }

  const val CARD_CURVE_DEFAULT: Short = 0
  const val CARD_CURVE_SECP256K1: Short = 0x0100
  const val CARD_CURVE_ED25519: Short = 0x0201
  const val CARD_CURVE_NISTP256: Short = 0x0301
  const val CARD_CURVE_ED25519_CARDANO: Short = 0x0401
  const val CARD_CURVE_SR25519: Short = 0x0501

  const val CARD_ALGO_DEFAULT: Byte = 0
  const val CARD_ALGO_ECDSA: Byte = 1
  const val CARD_ALGO_EDDSA: Byte = 2
  const val CARD_ALGO_EC_SCHNORR: Byte = 3
  const val CARD_ALGO_RISTRETTO: Byte = 4
  const val CARD_ALGO_CARDANO: Byte = 5

  const val CARD_VERSION_UNKNOWN: Int = -1
  const val CSDK_OK: Int = 0
  const val CSDK_ERR_WRONG_PIN: Int = -108

  init {
    Native.register(
      CSDK::class.java,
      LIBRARY
    )
  }

  external fun WalletInit(): Pointer
  external fun WalletFree(wallet: Pointer): Int

  external fun WalletGetApplicationAID(
    selectResponse: Pointer,
    bytesCount: SizeTByReference
  ): Pointer

  /**
   * Personalization stage
   */
  external fun WalletCreateWalletRequest(
    wallet: Pointer,
    bytesCount: SizeTByReference,
    nbrOfWords: Int
  ): Pointer

  external fun WalletSeedFromMnemonicSentence(
    wallet: Pointer,
    words: ByteArray,
    wordsLength: Int,
    passphrase: ByteArray,
    passphraseLength: Int,
    seedLength: SizeTByReference
  ): Pointer

  external fun WalletSeedCreateWalletRequest(
    wallet: Pointer,
    bytesCount: SizeTByReference,
    nbrOfWords: Int
  ): Pointer

  external fun WalletCreateWalletResponse(
    wallet: Pointer,
    response: ByteArray,
    length: Int,
    mnemonicSentenceLength: SizeTByReference
  ): Pointer

  external fun WalletInitRecoverWalletRequest(
    wallet: Pointer,
    nbrOfWords: Int,
    bytesCount: SizeTByReference
  ): Pointer

  external fun WalletInitRecoverWalletResponse(
    wallet: Pointer,
    response: ByteArray,
    length: Int
  ): Int

  external fun WalletFinishRecoverWalletRequest(
    wallet: Pointer,
    words: ByteArray,
    wordsLength: Int,
    passphrase: ByteArray,
    passphraseLength: Int,
    bytesCount: SizeTByReference
  ): Pointer

  external fun WalletSeedFinishRecoverWalletRequest(
    wallet: Pointer,
    seed: ByteArray,
    seedLength: Int,
    bytesCount: SizeTByReference
  ): Pointer

  external fun WalletFinishRecoverWalletResponse(
    wallet: Pointer,
    response: ByteArray,
    length: Int
  ): Int

  /**
   * Session encryption commands
   */
  external fun WalletInitSessionRequest(wallet: Pointer, len: SizeTByReference): Pointer
  external fun WalletInitSessionResponse(
    wallet: Pointer,
    response: ByteArray,
    ResponseLength: Int
  ): Int

  /**
   * Use Wallet
   */
  external fun WalletGetGGUIDRequest(wallet: Pointer, len: SizeTByReference): Pointer
  external fun WalletGetGGUIDResponse(
    wallet: Pointer,
    response: ByteArray,
    ResponseLength: Int,
    GGUIDLength: SizeTByReference
  ): Pointer

  external fun WalletGetFirmwareVersionRequest(wallet: Pointer, len: SizeTByReference): Pointer
  external fun WalletGetFirmwareVersionResponse(
    wallet: Pointer,
    response: ByteArray,
    ResponseLength: Int,
    VersionLength: SizeTByReference
  ): Pointer

  external fun WalletResetWalletRequest(wallet: Pointer, bytesCount: SizeTByReference): Pointer
  external fun WalletResetWalletResponse(wallet: Pointer, response: ByteArray, length: Int): Int

  external fun WalletSelectWalletRequest(
    wallet: Pointer,
    aid: ByteArray,
    bytesCount: SizeTByReference
  ): Pointer

  external fun WalletSelectWalletResponse(
    wallet: Pointer,
    response: ByteArray,
    length: Int
  ): Pointer

  external fun WalletGetPublicKeyFromPathRequest(
    wallet: Pointer,
    bipPath: ByteArray,
    bipPathLength: Int,
    curve: Short,
    commandLe: SizeTByReference
  ): Pointer

  external fun WalletGetPublicKeyFromPathResponse(
    wallet: Pointer,
    response: ByteArray,
    ResponseLength: Int
  ): Pointer

  external fun WalletVerifyPINRequest(
    wallet: Pointer,
    pin: ByteArray,
    pinLen: Int,
    bytesCount: SizeTByReference
  ): Pointer

  external fun WalletVerifyPINResponse(
    wallet: Pointer,
    response: ByteArray,
    length: Int,
    nbrOfTries: SizeTByReference
  ): Int

  external fun WalletStoreDataPINRequest(
    wallet: Pointer,
    pin: ByteArray,
    pinLen: Int,
    bytesCount: SizeTByReference
  ): Pointer

  external fun WalletStoreDataPINResponse(wallet: Pointer, response: ByteArray, length: Int): Int

  external fun WalletSignHashRequest(
    wallet: Pointer,
    bipPath: ByteArray,
    bipPathLength: Int,
    curve: Short,
    algorithm: Byte,
    hash: ByteArray,
    hashLength: Int,
    commandLe: SizeTByReference
  ): Pointer

  external fun WalletSignHashResponse(
    wallet: Pointer,
    response: ByteArray,
    length: Int,
    signedDataLe: SizeTByReference
  ): Pointer

  external fun WalletSignRequest(
    wallet: Pointer,
    bipPath: Pointer,
    curve: Short,
    algorithm: Byte,
    hash: Pointer,
    result: PointerByReference
  ): Int

  external fun WalletErrorMessage(
    rc: Int,
    message: PointerByReference,
    len: SizeTByReference
  ): Int

  // TODO: Rename for public API
  external fun ExtendedKey_getPubKey(extendedKey: Pointer, bytesCount: SizeTByReference): Pointer
  external fun ExtendedKey_getChainCode(extendedKey: Pointer, bytesCount: SizeTByReference): Pointer
}
