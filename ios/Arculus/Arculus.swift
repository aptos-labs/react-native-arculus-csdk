import CoreNFC

class Arculus {
    private var nfcSessionManager: NFCSessionManager
    
    init(nfcSessionManager: NFCSessionManager) {
        self.nfcSessionManager = nfcSessionManager
    }
    
    private func execute<ResultType>(sendCommands: @escaping (CSDKAPI) async throws -> ResultType) async throws -> ResultType {
        let tag = try await nfcSessionManager.getTag()
        
        do {
            let api = CSDKAPI(tag: tag)
            
            let value = try await sendCommands(api)
            
            nfcSessionManager.done()
            
            return value
        } catch {
            nfcSessionManager.fail(errorMessage: error.localizedDescription)
            
            throw error
        }
    }
    
    func changePIN(oldPIN: String, newPIN: String) async throws {
        try await execute {
            try await $0.walletSelectWallet()
            try await $0.walletVerifyPIN(pin: oldPIN)
            try await $0.walletStoreDataPIN(pin: newPIN)
        }
    }
    
    func createWallet(pin: String, nbrOfWords: Int) async throws -> String {
        try await execute {
            try await $0.walletSelectWallet()
            try await $0.walletResetWallet()
            try await $0.walletStoreDataPIN(pin: pin)
            
            let mnemonicSentence = try await $0.walletSeedCreateWallet(nbrOfWords: nbrOfWords)
            
            let seed = try await $0.seedFromMnemonicSentence(mnemonicSentence: mnemonicSentence)
            
            try await $0.walletInitRecoverWallet(nbrOfWords: nbrOfWords)
            try await $0.walletSeedFinishRecoverWallet(seed: seed)
            
            return mnemonicSentence
        }
    }
    
    func getFirmwareVersion() async throws -> String {
        try await execute {
            try await $0.walletSelectWallet()
            
            return try await $0.walletGetFirmwareVersion()
        }
    }
    
    func getGGUID() async throws -> String {
        try await execute {
            try await $0.walletSelectWallet()
            
            return try await $0.walletGetGGUID()
        }
    }
    
    func getInfo(path: String, curve: UInt16) async throws -> [ String: String ] {
        try await execute {
            try await $0.walletSelectWallet()
            
            let gguid = try await $0.walletGetGGUID()
            
            var info = try await $0.walletGetPublicKeyFromPath(path: path, curve: curve)
            
            info["gguid"] = gguid
            
            return info
        }
    }
    
    func getPublicKeyFromPath(path: String, curve: UInt16) async throws -> [ String: String ] {
        try await execute {
            try await $0.walletSelectWallet()
            
            return try await $0.walletGetPublicKeyFromPath(path: path, curve: curve)
        }
    }
    
    func resetWallet() async throws {
        try await execute {
            try await $0.walletSelectWallet()
            try await $0.walletResetWallet()
        }
    }
    
    func restoreWallet(pin: String, mnemonicSentence: String) async throws {
        try await execute {
            let nbrOfWords = mnemonicSentence.split(separator: " ").count
            
            let seed = try await $0.seedFromMnemonicSentence(mnemonicSentence: mnemonicSentence)
            
            try await $0.walletSelectWallet()
            try await $0.walletResetWallet()
            try await $0.walletStoreDataPIN(pin: pin)
            try await $0.walletInitRecoverWallet(nbrOfWords: nbrOfWords)
            try await $0.walletSeedFinishRecoverWallet(seed: seed)
        }
    }
    
    func signHash(pin: String, path: String, curve: UInt16, algorithm: UInt8, hash: String) async throws -> String {
        try await execute {
            try await $0.walletSelectWallet()
            try await $0.walletVerifyPIN(pin: pin)
            
            return try await $0.walletSignHash(path: path, curve: curve, algorithm: algorithm, hash: hash)
        }
    }
    
    func verifyPIN(pin: String) async throws {
        try await execute {
            try await $0.walletSelectWallet()
            try await $0.walletVerifyPIN(pin: pin)
        }
    }
}
