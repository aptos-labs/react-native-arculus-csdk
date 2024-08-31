import React

class RNArculus {
    private let nfcSessionManager: RNNFCSessionManager
    private let arculus: Arculus
    
    init(eventEmitter: RCTEventEmitter) {
        nfcSessionManager = RNNFCSessionManager(eventEmitter: eventEmitter)
        arculus = Arculus(nfcSessionManager: nfcSessionManager)
    }
    
    func handle<Result>(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock, execute: @escaping (Arculus) async throws -> Result) {
        Task {
            do {
                let value = try await execute(arculus)
                
                resolve(value)
            } catch {
                reject("RN_ARCULUS_CSDK_ERROR", error.localizedDescription, error)
            }
        }
    }
    
    func setNFCTagReaderAlertMessage(message: String) {
        nfcSessionManager.setSessionAlertMessage(message: message)
    }
}
