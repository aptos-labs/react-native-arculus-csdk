import React

@objc(ReactNativeArculusCsdk)
class ReactNativeArculusCsdk: RCTEventEmitter {
    private lazy var rnArculus: RNArculus = {
        return RNArculus(eventEmitter: self)
    }()
    
    @objc(changePIN:withNewPIN:withResolver:withRejecter:)
    func changePIN(
        oldPIN: String,
        newPIN: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        rnArculus.handle(resolve: resolve, reject: reject) {
            try await $0.changePIN(oldPIN: oldPIN, newPIN: newPIN)
        }
    }
    
    @objc(createWallet:withNumberOfWords:withResolver:withRejecter:)
    func createWallet(
        pin: String,
        nbrOfWords: NSNumber,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        rnArculus.handle(resolve: resolve, reject: reject) {
            try await $0.createWallet(pin: pin, nbrOfWords: nbrOfWords.intValue)
        }
    }
    
    @objc(getFirmwareVersion:withRejecter:)
    func getFirmwareVersion(
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        rnArculus.handle(resolve: resolve, reject: reject) {
            try await $0.getFirmwareVersion()
        }
    }
    
    @objc(getGGUID:withRejecter:)
    func getGGUID(
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        rnArculus.handle(resolve: resolve, reject: reject) {
            try await $0.getGGUID()
        }
    }
    
    @objc(getInfo:withCurve:withResolver:withRejecter:)
    func getInfo(
        path: String,
        curve: NSNumber,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        rnArculus.handle(resolve: resolve, reject: reject) {
            try await $0.getInfo(path: path, curve: curve.uint16Value)
        }
    }
    
    @objc(getPublicKeyFromPath:withCurve:withResolver:withRejecter:)
    func getPublicKeyFromPath(
        path: String,
        curve: NSNumber,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        rnArculus.handle(resolve: resolve, reject: reject) {
            try await $0.getPublicKeyFromPath(path: path, curve: curve.uint16Value)
        }
    }
    
    @objc(resetWallet:withRejecter:)
    func resetWallet(
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        rnArculus.handle(resolve: resolve, reject: reject) {
            try await $0.resetWallet()
        }
    }
    
    @objc(restoreWallet:withMnemonicSentence:withResolver:withRejecter:)
    func restoreWallet(
        pin: String,
        mnemonicSentence: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        rnArculus.handle(resolve: resolve, reject: reject) {
            try await $0.restoreWallet(pin: pin, mnemonicSentence: mnemonicSentence)
        }
    }
    
    @objc(setNFCTagReaderAlertMessage:)
    func setNFCTagReaderAlertMessage(message: String) {
        rnArculus.setNFCTagReaderAlertMessage(message: message)
    }
    
    @objc(signHash:withPath:withCurve:withAlgorithm:withHash:withResolver:withRejecter:)
    func signHash(
        pin: String,
        path: String,
        curve: NSNumber,
        algorithm: NSNumber,
        hash: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        rnArculus.handle(resolve: resolve, reject: reject) {
            try await $0.signHash(pin: pin, path: path, curve: curve.uint16Value, algorithm: algorithm.uint8Value, hash: hash)
        }
    }
    
    @objc(verifyPIN:withResolver:withRejecter:)
    func verifyPIN(
        pin: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        rnArculus.handle(resolve: resolve, reject: reject) {
            try await $0.verifyPIN(pin: pin)
        }
    }
    
    private var hasListeners = false
    
    override func startObserving() {
        hasListeners = true
    }
    
    override func stopObserving() {
        hasListeners = false
    }
    
    override func sendEvent(withName name: String!, body: Any!) {
        if(hasListeners) {
            super.sendEvent(withName: name, body: body)
        }
    }
    
    override func supportedEvents() -> [String]! {
        return ["ConnectionClosed", "ConnectionOpened", "ScanningStarted"]
    }
    
    override class func requiresMainQueueSetup() -> Bool {
        return true
    }
}
