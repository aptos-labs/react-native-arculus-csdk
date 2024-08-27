class RNArculusCSDK: ArculusCSDK {
    private let resolve: RCTPromiseResolveBlock
    private let reject: RCTPromiseRejectBlock
    
    init(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.resolve = resolve
        self.reject = reject
        
        super.init()
    }
    
    private func handle<Result>(execute: @escaping () async throws -> Result) {
        Task {
            do {
                let value = try await execute()
                
                resolve(value)
            } catch {
                reject("RN_ARCULUS_CSDK_ERROR", error.localizedDescription, error)
            }
        }
    }
    
    func changePIN(oldPIN: String, newPIN: String) {
        handle {
            try await super.changePIN(oldPIN: oldPIN, newPIN: newPIN)
        }
    }
    
    func createWallet(pin: String, nbrOfWords: Int) {
        handle {
            try await super.createWallet(pin: pin, nbrOfWords: nbrOfWords)
        }
    }
    
    func getFirmwareVersion() {
        handle {
            try await super.getFirmwareVersion()
        }
    }
    
    func getGGUID() {
        handle {
            try await super.getGGUID()
        }
    }
    
    func getInfo(path: String, curve: UInt16) {
        handle {
            try await super.getInfo(path: path, curve: curve)
        }
    }
    
    func getPublicKeyFromPath(path: String, curve: UInt16) {
        handle {
            try await super.getPublicKeyFromPath(path: path, curve: curve)
        }
    }
    
    func resetWallet() {
        handle {
            try await super.resetWallet()
        }
    }
    
    func restoreWallet(pin: String, mnemonicSentence: String) {
        handle {
            try await super.restoreWallet(pin: pin, mnemonicSentence: mnemonicSentence)
        }
    }
    
    func signHash(pin: String, path: String, curve: UInt16, algorithm: UInt8, hash: String) {
        handle {
            try await super.signHash(pin: pin, path: path, curve: curve, algorithm: algorithm, hash: hash)
        }
    }
    
    func verifyPIN(pin: String) {
        handle {
            try await super.verifyPIN(pin: pin)
        }
    }
}
