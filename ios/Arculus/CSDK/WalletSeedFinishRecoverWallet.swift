import CSDK

final class WalletSeedFinishRecoverWallet: CSDKAPICall<Void> {
    private var seed: [UInt8]
    
    init(wallet: OpaquePointer, seed: [UInt8]) {
        self.seed = seed
        
        super.init(wallet: wallet)
    }
    
    override func request() async throws -> [Data] {
        var len: size_t = 0
        
        guard let bytes = WalletSeedFinishRecoverWalletRequest(wallet, seed, seed.count, &len) else {
            throw CSDKAPICallError(.requestCreationFailed("wallet seed finish recover"))
        }
        
        return [Data(bytes: bytes, count: len)]
    }
    
    override func response(bytes: [UInt8]) async throws -> ResponseType {
        let result = WalletSeedFinishRecoverWalletResponse(wallet, bytes, bytes.count)
        
        try CSDKAPICallError.validateWalletResponseCode(rc: result)
    }
}
