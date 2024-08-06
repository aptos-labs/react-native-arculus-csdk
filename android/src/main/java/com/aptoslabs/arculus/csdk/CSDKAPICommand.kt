package com.aptoslabs.arculus.csdk

import com.sun.jna.Pointer

abstract class CSDKAPICommand<ResponseType>(protected val wallet: Pointer) {
  abstract suspend fun execute(): ResponseType
}

