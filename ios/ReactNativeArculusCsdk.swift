@objc(ReactNativeArculusCsdk)
class ReactNativeArculusCsdk: NSObject {
    private var nfcSessionManager = NFCSessionManager()
    
    @objc(createWalletSeed:withWordCount:withPath:withCurve:withResolver:withRejecter:)
    func createWalletSeed(
        pin: String,
        wordCount: NSNumber,
        path: String,
        curve: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        let createWalletSeedCommand = CreateWalletSeedCommand(pin: pin, wordCount: wordCount.intValue, path: path, curve: curve)
        
        nfcSessionManager.startSession(command: createWalletSeedCommand, resolve: resolve, reject: reject)
    }
    
    @objc(getPubKeyByPath:withCurve:withResolver:withRejecter:)
    func getPubKeyByPath(path: String, curve: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let getPubKeyByPathCommand = GetPubKeyByPathCommand(path: path, curve: curve)
        
        nfcSessionManager.startSession(command: getPubKeyByPathCommand, resolve: resolve, reject: reject)
    }
    
    @objc(signHashByPath:withPath:withCurve:withAlgorithm:withHash:withResolver:withRejecter:)
    func signHashByPath(
        pin: String,
        path: String,
        curve: String,
        algorithm: String,
        hash: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        let signHashByPathCommand = SignHashByPathCommand(pin: pin, path: path, curve: curve, algorithm: algorithm, hash: hash)
        
        nfcSessionManager.startSession(command: signHashByPathCommand, resolve: resolve, reject: reject)
    }
    
    //
    
    @objc(getGGUID:withRejecter:)
    func getGGUID(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let getGGUIDCommand = GetGGUIDCommand()
        
        nfcSessionManager.startSession(command: getGGUIDCommand, resolve: resolve, reject: reject)
    }
    
    @objc(getVersion:withRejecter:)
    func getVersion(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let getVersionCommand = GetVersionCommand()
        
        nfcSessionManager.startSession(command: getVersionCommand, resolve: resolve, reject: reject)
    }
    
    @objc(verifyPIN:withResolver:withRejecter:)
    func verifyPIN(pin: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let verifyPINCommand = VerifyPINCommand(pin: pin)
        
        nfcSessionManager.startSession(command: verifyPINCommand, resolve: resolve, reject: reject)
    }
    
    @objc(storePIN:withResolver:withRejecter:)
    func storePIN(pin: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let storePINCommand = StorePINCommand(pin: pin)
        
        nfcSessionManager.startSession(command: storePINCommand, resolve: resolve, reject: reject)
    }
    
    @objc(updatePIN:withNewPin:withResolver:withRejecter:)
    func updatePIN(oldPin: String, newPin: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let updatePINCommand = UpdatePINCommand(oldPin: oldPin, newPin: newPin)
        
        nfcSessionManager.startSession(command: updatePINCommand, resolve: resolve, reject: reject)
    }
}
