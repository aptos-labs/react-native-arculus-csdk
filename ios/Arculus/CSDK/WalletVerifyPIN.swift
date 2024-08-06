import CSDK

final class WalletVerifyPIN: CSDKAPICall<Void> {
    enum VerifyPINError: Error, LocalizedError {
        case wrongPIN(Int)
        
        var errorDescription: String? {
            switch self {
            case let .wrongPIN(tries): return "Wrong PIN. \(tries) tries remaining."
            }
        }
    }
    
    private let pin: String
    
    init(wallet: OpaquePointer, pin: String) {
        self.pin = pin
        
        super.init(wallet: wallet)
    }
    
    override func request() async throws -> [Data] {
        var len: size_t = 0
        
        guard let bytes = WalletVerifyPINRequest(wallet, pin, pin.count, &len) else {
            throw CSDKAPICallError(.requestCreationFailed("verify PIN"))
        }
        
        return [Data(bytes: bytes, count: len)]
    }
    
    override func response(bytes: [UInt8]) async throws {
        var nbrOfTries: size_t = 0
        
        let code = WalletVerifyPINResponse(wallet, bytes, bytes.count, &nbrOfTries)
        
        if 0...2 ~= nbrOfTries {
            throw VerifyPINError.wrongPIN(nbrOfTries)
        }
        
        try CSDKAPICallError.validateWalletResponseCode(rc: code)
    }
}
