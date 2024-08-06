import CSDK

final class WalletStoreDataPIN: CSDKAPICall<Void> {
    private let pin: String
    
    init(wallet: OpaquePointer, pin: String) {
        self.pin = pin
        
        super.init(wallet: wallet)
    }
    
    override func request() async throws -> [Data] {
        var len: size_t = 0
        
        guard let bytes = WalletStoreDataPINRequest(wallet, pin, pin.count, &len) else {
            throw CSDKAPICallError(.requestCreationFailed("store PIN"))
        }
        
        return [Data(bytes: bytes, count: len)]
    }
    
    override func response(bytes: [UInt8]) async throws -> ResponseType {
        let result = WalletStoreDataPINResponse(wallet, bytes, bytes.count)
        
        try CSDKAPICallError.validateWalletResponseCode(rc: result)
    }
}
