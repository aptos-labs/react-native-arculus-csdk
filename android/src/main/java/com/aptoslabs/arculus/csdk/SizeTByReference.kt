package com.aptoslabs.arculus.csdk

import com.sun.jna.Native
import com.sun.jna.ptr.ByReference
import java.math.BigInteger

class SizeTByReference : ByReference {

  constructor() : this(BigInteger.ZERO)

  constructor(value: BigInteger) : super(Native.SIZE_T_SIZE) {
    setValue(value)
  }

  fun getValue(): BigInteger {
    return if (Native.SIZE_T_SIZE == 8) {
      BigInteger.valueOf(pointer.getLong(0))
    } else {
      BigInteger.valueOf(pointer.getInt(0).toLong())
    }
  }

  fun setValue(value: BigInteger) {
    if (Native.SIZE_T_SIZE == 8) {
      pointer.setLong(0, value.toLong())
    } else {
      pointer.setInt(0, value.toInt())
    }
  }

  fun toIntChecked(): Int {
    val value = getValue().toLong()
    require(value in Int.MIN_VALUE..Int.MAX_VALUE) { "Value out of range for Int: $value" }
    return value.toInt()
  }
}
