import CSDK

enum ApplicationAID {
    case v1
    case v2
    
    public var aid: [UInt8] {
        switch self {
        case .v1: return [0x4a, 0x4e, 0x45, 0x54, 0x5f, 0x4c, 0x5f, 0x01, 0x01, 0x57]
        case .v2: return [0x41, 0x52, 0x43, 0x55, 0x4C, 0x55, 0x53, 0x01, 0x01, 0x57]
        }
    }
}

enum WalletSelectWalletError: Error, LocalizedError {
    case invalidAID
    case expectedAIDNotMet(ApplicationAID)
    
    var errorDescription: String? {
        switch self{
        case .invalidAID:
            return "Invalid application AID"
        case let .expectedAIDNotMet(applicationAID):
            return "Expected \(applicationAID) application AID not met"
        }
    }
}

final class WalletSelectWallet: CSDKAPICall<[UInt8]> {
    private var applicationAID: ApplicationAID
    
    init(wallet: OpaquePointer, applicationAID: ApplicationAID) {
        self.applicationAID = applicationAID
        
        super.init(wallet: wallet)
    }
    
    override func request() async throws -> [Data] {
        var len: size_t = 0
        
        guard let bytes = WalletSelectWalletRequest(wallet, applicationAID.aid, &len) else {
            throw CSDKAPICallError(.requestCreationFailed("wallet select"))
        }
        
        return [Data(bytes: bytes, count: len)]
    }
    
    override func response(bytes: [UInt8]) async throws -> ResponseType {
        guard let result = WalletSelectWalletResponse(wallet, bytes, bytes.count) else {
            throw CSDKAPICallError(.responseParsingFailed("wallet select"))
        }
        
        let data = Data(bytes: result.pointee.ApplicationAID, count: size_t(result.pointee.ApplicationAIDLength))
        
        let aid = [UInt8](data)
        
        return aid
    }
}
