import CSDK

final class WalletResetWallet: CSDKAPICall<Void> {
    override func request() async throws -> [Data] {
        var len: size_t = 0
        
        guard let bytes = WalletResetWalletRequest(wallet, &len) else {
            throw CSDKAPICallError(.requestCreationFailed("reset wallet"))
        }
        
        return [Data(bytes: bytes, count: len)]
    }
    
    override func response(bytes: [UInt8]) async throws -> ResponseType {
        let result = WalletResetWalletResponse(wallet, bytes, bytes.count)
        
        try CSDKAPICallError.validateWalletResponseCode(rc: result)
    }
}
