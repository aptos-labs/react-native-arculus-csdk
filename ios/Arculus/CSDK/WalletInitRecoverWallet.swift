import CSDK

final class WalletInitRecoverWallet: CSDKAPICall<Void> {
    private var nbrOfWords: Int
    
    init(wallet: OpaquePointer, nbrOfWords: Int) {
        self.nbrOfWords = nbrOfWords
        
        super.init(wallet: wallet)
    }
    
    override func request() async throws -> [Data] {
        var len: size_t = 0
        
        guard let bytes = WalletInitRecoverWalletRequest(wallet, nbrOfWords, &len) else {
            throw CSDKAPICallError(.requestCreationFailed("wallet init recover wallet"))
        }
        
        return [Data(bytes: bytes, count: len)]
    }
    
    override func response(bytes: [UInt8]) async throws -> ResponseType {
        let result = WalletInitRecoverWalletResponse(wallet, bytes, bytes.count)
        
        try CSDKAPICallError.validateWalletResponseCode(rc: result)
    }
}
