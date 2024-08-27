import CoreNFC

class ArculusCSDK {
    private var nfcSessionManager = NFCSessionManager()
    
    private func execute<ResultType>(sendCommands: @escaping (_ tag: NFCISO7816Tag) async throws -> ResultType) async throws -> ResultType {
        do {
            let tag = try await nfcSessionManager.beginSession()
            
            let value = try await sendCommands(tag)
            
            nfcSessionManager.invalidateSession()
            
            return value
        } catch {
            nfcSessionManager.invalidateSession(errorMessage: error.localizedDescription)
            
            throw error
        }
    }
    
    func changePIN(oldPIN: String, newPIN: String) async throws {
        try await execute { tag in
            let api = CSDKAPI(tag: tag)
            
            try await api.walletSelectWallet()
            try await api.walletVerifyPIN(pin: oldPIN)
            try await api.walletStoreDataPIN(pin: newPIN)
        }
    }
    
    func createWallet(pin: String, nbrOfWords: Int) async throws -> String {
        try await execute { tag in
            let api = CSDKAPI(tag: tag)
            
            try await api.walletSelectWallet()
            try await api.walletResetWallet()
            try await api.walletStoreDataPIN(pin: pin)
            
            let mnemonicSentence = try await api.walletSeedCreateWallet(nbrOfWords: nbrOfWords)
            
            let seed = try await api.seedFromMnemonicSentence(mnemonicSentence: mnemonicSentence)
            
            try await api.walletInitRecoverWallet(nbrOfWords: nbrOfWords)
            try await api.walletSeedFinishRecoverWallet(seed: seed)
            
            return mnemonicSentence
        }
    }
    
    func getFirmwareVersion() async throws -> String {
        try await execute { tag in
            let api = CSDKAPI(tag: tag)
            
            try await api.walletSelectWallet()
            
            return try await api.walletGetFirmwareVersion()
        }
    }
    
    func getGGUID() async throws -> String {
        try await execute { tag in
            let api = CSDKAPI(tag: tag)
            
            try await api.walletSelectWallet()
            
            return try await api.walletGetGGUID()
        }
    }
    
    func getInfo(path: String, curve: UInt16) async throws -> [ String: String ] {
        try await execute { tag in
            let api = CSDKAPI(tag: tag)
            
            try await api.walletSelectWallet()
            
            let gguid = try await api.walletGetGGUID()
            
            var info = try await api.walletGetPublicKeyFromPath(path: path, curve: curve)
            
            info["gguid"] = gguid
            
            return info
        }
    }
    
    func getPublicKeyFromPath(path: String, curve: UInt16) async throws -> [ String: String ] {
        try await execute { tag in
            let api = CSDKAPI(tag: tag)
            
            try await api.walletSelectWallet()
            
            return try await api.walletGetPublicKeyFromPath(path: path, curve: curve)
        }
    }
    
    func resetWallet() async throws {
        try await execute { tag in
            let api = CSDKAPI(tag: tag)
            
            try await api.walletSelectWallet()
            try await api.walletResetWallet()
        }
    }
    
    func restoreWallet(pin: String, mnemonicSentence: String) async throws {
        try await execute { tag in
            let api = CSDKAPI(tag: tag)
            
            let nbrOfWords = mnemonicSentence.split(separator: " ").count
            
            let seed = try await api.seedFromMnemonicSentence(mnemonicSentence: mnemonicSentence)
            
            try await api.walletSelectWallet()
            try await api.walletResetWallet()
            try await api.walletStoreDataPIN(pin: pin)
            try await api.walletInitRecoverWallet(nbrOfWords: nbrOfWords)
            try await api.walletSeedFinishRecoverWallet(seed: seed)
        }
    }
    
    func signHash(pin: String, path: String, curve: UInt16, algorithm: UInt8, hash: String) async throws -> String {
        try await execute { tag in
            let api = CSDKAPI(tag: tag)
            
            try await api.walletSelectWallet()
            try await api.walletVerifyPIN(pin: pin)
            
            return try await api.walletSignHash(path: path, curve: curve, algorithm: algorithm, hash: hash)
        }
    }
    
    func verifyPIN(pin: String) async throws {
        try await execute { tag in
            let api = CSDKAPI(tag: tag)
            
            try await api.walletSelectWallet()
            try await api.walletVerifyPIN(pin: pin)
        }
    }
}
