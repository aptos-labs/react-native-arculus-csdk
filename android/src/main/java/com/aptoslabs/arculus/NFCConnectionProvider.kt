package com.aptoslabs.arculus

import android.nfc.tech.IsoDep

interface NFCConnectionProvider {
  suspend fun <ResultType> connect(callback: suspend (IsoDep) -> ResultType): ResultType
}

