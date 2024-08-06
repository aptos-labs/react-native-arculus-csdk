import CSDK

final class WalletGetPublicKeyFromPath: CSDKAPICall<[ String: String ]> {
    private var path: String
    private var curve: UInt16
    
    init(wallet: OpaquePointer, path: String, curve: UInt16) {
        self.path = path
        self.curve = curve
        
        super.init(wallet: wallet)
    }
    
    override func request() async throws -> [Data] {
        let bipPath = UnsafeMutablePointer<UInt8>.allocate(capacity: path.count)
        
        bipPath.initialize(from: path, count: path.count)
        
        defer { bipPath.deallocate() }
        
        var len: size_t = 0
        
        guard let bytes = WalletGetPublicKeyFromPathRequest(wallet, bipPath, path.count, curve, &len) else {
            throw CSDKAPICallError(.requestCreationFailed("wallet get public key from path"))
        }
        
        return [Data(bytes: bytes, count: len)]
    }
    
    override func response(bytes: [UInt8]) async throws -> ResponseType {
        guard let result = WalletGetPublicKeyFromPathResponse(wallet, bytes, bytes.count) else {
            throw CSDKAPICallError(.responseParsingFailed("wallet get public key from path"))
        }
        
        let chainCodeKey = Data(bytes: &result.pointee.chainCodeKey, count: result.pointee.chainCodeLe)
        let publicKey = Data(bytes: &result.pointee.publicKey, count: result.pointee.pubKeyLe)
        
        return ["chainCodeKey": dataToHexString(chainCodeKey), "publicKey": dataToHexString(publicKey)]
    }
}
