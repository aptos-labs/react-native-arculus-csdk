import CSDK

final class WalletInitSession: CSDKAPICall<Void> {
    override func request() async throws -> [Data] {
        var len: size_t = 0
        
        guard let bytes = WalletInitSessionRequest(wallet, &len) else {
            throw CSDKAPICallError(.requestCreationFailed("init session"))
        }
        
        return [Data(bytes: bytes, count: len)]
    }
    
    override func response(bytes: [UInt8]) async throws -> ResponseType {
        let result = WalletInitSessionResponse(wallet, bytes, bytes.count)
        
        try CSDKAPICallError.validateWalletResponseCode(rc: result)
    }
}
