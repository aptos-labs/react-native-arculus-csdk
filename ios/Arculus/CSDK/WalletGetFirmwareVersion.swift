import CSDK

final class WalletGetFirmwareVersion: CSDKAPICall<String> {
    override func request() async throws -> [Data] {
        var len: size_t = 0
        
        guard let bytes = WalletGetFirmwareVersionRequest(wallet, &len) else {
            throw CSDKAPICallError(.requestCreationFailed("wallet get firmware version"))
        }
        
        return [Data(bytes: bytes, count: len)]
    }
    
    override func response(bytes: [UInt8]) async throws -> ResponseType {
        var len: size_t = 0
        
        guard let result = WalletGetFirmwareVersionResponse(wallet, bytes, bytes.count, &len) else {
            throw CSDKAPICallError(.responseParsingFailed("wallet get firmware version"))
        }
        
        let data = Data(bytes: result, count: len)
        
        let version = data.map { "\($0)" }.joined(separator: ".")
        
        return version
    }
}
