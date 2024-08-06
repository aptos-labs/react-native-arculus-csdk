import CSDK

final class WalletGetGGUID: CSDKAPICall<String> {
    override func request() async throws -> [Data] {
        var len: size_t = 0
        
        guard let bytes = WalletGetGGUIDRequest(wallet, &len) else {
            throw CSDKAPICallError(.requestCreationFailed("wallet get GGUID"))
        }
        
        return [Data(bytes: bytes, count: len)]
    }
    
    override func response(bytes: [UInt8]) async throws -> ResponseType {
        var len: size_t = 0
        
        guard let result = WalletGetGGUIDResponse(wallet, bytes, bytes.count, &len) else {
            throw CSDKAPICallError(.responseParsingFailed("wallet get GGUID"))
        }
        
        let data = Data(bytes: result, count: len)
        
        return dataToHexString(data)
    }
}
