import CoreNFC
import CSDK

enum WalletSignHashError: Error, LocalizedError {
    case invalidPath
    
    var errorDescription: String? {
        switch self {
        case .invalidPath: return "Invalid path, could not be converted to ascii"
        }
    }
}

final class WalletSignHash: CSDKAPIChainCall<String> {
    private var path: ByteVector
    private var curve: UInt16
    private var algorithm: UInt8
    private var hash: ByteVector
    
    init(wallet: OpaquePointer, path: String, curve: UInt16, algorithm: UInt8, hash: String) throws {
        let pathData = [UInt8](path.utf8)
        let hashData = [UInt8](try hexStringToData(hash))
        
        self.path = WalletSignHash.createByteVector(from: pathData)
        self.curve = curve
        self.algorithm = algorithm
        self.hash = WalletSignHash.createByteVector(from: hashData)
        
        super.init(wallet: wallet)
    }
    
    deinit {
        path.addr.deallocate()
        hash.addr.deallocate()
    }
    
    private static func createByteVector(from data: [UInt8]) -> ByteVector {
        let byteVector = ByteVector(count: UInt32(data.count), addr: UnsafeMutablePointer<UInt8>.allocate(capacity: data.count))
        
        byteVector.addr.initialize(from: data, count: data.count)
        
        return byteVector
    }
    
    override func request() async throws -> [Data] {
        let apdus = UnsafeMutablePointer<UnsafeMutablePointer<APDUSequence>?>.allocate(capacity: 1)
        
        defer { apdus.deallocate() }
        
        let rc = WalletSignRequest(wallet, &path, curve, algorithm, &hash, apdus)
        
        try CSDKAPIChainCallError.validateWalletResponseCode(rc: rc)
        
        guard let apduSequence = apdus.pointee?.pointee, let apdu = apduSequence.apdu else {
            throw CSDKAPIChainCallError(.requestCreationFailed("wallet sign hash"))
        }
        
        return try Array<Data>(repeating: Data(), count: Int(apduSequence.count)).enumerated().map { (index, _) in
            let byteVector = apdu[index]
            
            guard let addr = byteVector.addr else {
                throw CSDKAPIChainCallError(.requestCreationFailed("wallet sign hash"))
            }
            
            return Data(bytes: addr, count: Int(byteVector.count))
        }
    }
    
    override func response(bytes: [UInt8]) async throws -> ResponseType {
        var len: size_t = 0
        
        guard let result = WalletSignHashResponse(wallet, bytes, bytes.count, &len) else {
            throw CSDKAPIChainCallError(.responseParsingFailed("wallet sign hash"))
        }
        
        return dataToHexString(Data(bytes: result, count: len))
    }
}
