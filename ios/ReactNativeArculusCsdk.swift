@objc(ReactNativeArculusCsdk)
class ReactNativeArculusCsdk: NSObject {
    private var nfcSessionManager = NFCSessionManager()

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

    @objc(createAptosWalletSeed:withResolver:withRejecter:)
    func createAptosWalletSeed(pin: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let createAptosWalletSeedCommand = CreateAptosWalletSeedCommand(pin: pin)

        nfcSessionManager.startSession(command: createAptosWalletSeedCommand, resolve: resolve, reject: reject)
    }

    @objc(signAptosHash:withHash:withResolver:withRejecter:)
    func signAptosHash(pin: String, hash: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let signAptosHashCommand = SignAptosHashCommand(pin: pin, hash: hash)

        nfcSessionManager.startSession(command: signAptosHashCommand, resolve: resolve, reject: reject)
    }
}
