import CoreNFC
import CSDK

enum CSDKError: Int32, Error, LocalizedError {
    case nullPointer = -100
    case nullAppleObj = -101
    case nullCalloc = -102
    case wrongResponseLength = -103
    case wrongResponseData = -104
    case wrongStatusWord = -105
    case wrongDataLength = -106
    case wrongParamLength = -107
    case wrongPIN = -108
    case invalidParam = -109
    case encryptionNotInit = -110
    case extOrChainNotSupported = -111
    case apiChainNotSupported = -112
    case unknownError = -113
    case apduExceedsChainLength = -114
    case extApduSupportRequired = -115
    case apduTooBig = -116
    case walletNotSelected = -117
    
    var errorDescription: String? {
        switch self {
        case .nullPointer: return "Null pointer encountered"
        case .nullAppleObj: return "Wallet session object is NULL"
        case .nullCalloc: return "Unable to allocate memory"
        case .wrongResponseLength: return "Card response length is incorrect/unexpected"
        case .wrongResponseData: return "Card response not valid"
        case .wrongStatusWord: return "Card response status not expected"
        case .wrongDataLength: return "Data length of payload is invalid"
        case .wrongParamLength: return "Parameter size validation failed"
        case .wrongPIN: return "Wrong PIN"
        case .invalidParam: return "Invalid Parameter"
        case .encryptionNotInit: return "NFC Session encryption was not initialized"
        case .extOrChainNotSupported: return "Card doesn't support extended APDUs or chaining"
        case .apiChainNotSupported: return "API is deprecated and requires Chaining"
        case .unknownError: return "An unknown error has occurred"
        case .apduExceedsChainLength: return "APDU too big to do chaining"
        case .extApduSupportRequired: return "Extended APDU not supported but required"
        case .apduTooBig: return "APDU too big"
        case .walletNotSelected: return "Wallet not selected"
        }
    }
    
    init(rc: Int32) {
        self = CSDKError(rawValue: rc) ?? CSDKError.unknownError
    }
}

class CSDKAPICallError: Error, LocalizedError {
    enum CSDKAPICallErrorType {
        case apduCreationFailed
        case requestCreationFailed(String)
        case responseParsingFailed(String)
        case walletResponseError(Int32)
    }
    
    var callErrorType: CSDKAPICallErrorType?
    
    init(_ errorType: CSDKAPICallErrorType) {
        self.callErrorType = errorType
    }
    
    init() {
        self.callErrorType = nil
    }
    
    var errorDescription: String? {
        switch callErrorType {
        case .apduCreationFailed:
            return "Failed to create APDU from data"
        case let .requestCreationFailed(command):
            return "Failed to create \(command) request"
        case let .responseParsingFailed(command):
            return "Failed to parse \(command) response"
        case let .walletResponseError(rc):
            var len: size_t = 0
            var message: UnsafePointer<CChar>?
            
            let response = WalletErrorMessage(rc, &message, &len)
            
            guard response == CSDK_OK, let message = message else {
                return CSDKError(rc: rc).localizedDescription
            }
            
            let description = String(cString: message)
            
            guard description != "Unknown error code" else {
                return CSDKError(rc: rc).localizedDescription
            }
            
            return description
        default: return "Unknown error"
        }
    }
    
    static func validateWalletResponseCode(rc: Int32) throws {
        guard rc == CSDK_OK else {
            throw CSDKAPICallError(.walletResponseError(rc))
        }
    }
}


class CSDKAPICall<T>: CSDKAPICommand<T> {
    final override func execute() async throws -> ResponseType {
        fatalError("execute() must not be called - use execute(tag:) instead")
    }
    
    func request() async throws -> [Data] {
        fatalError("request must be overridden")
    }
    
    func response(bytes: [UInt8]) async throws -> ResponseType {
        fatalError("response must be overridden")
    }
    
    func sendCommand(_ data: Data?, tag: NFCISO7816Tag) async throws -> [UInt8] {
        guard let data = data else {
            preconditionFailure("cannot send empty request")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            guard let apdu = NFCISO7816APDU(data: data) else {
                return continuation.resume(throwing: CSDKAPICallError(.apduCreationFailed))
            }
            
            tag.sendCommand(apdu: apdu) { response, sw1, sw2, error in
                if let error = error {
                    return continuation.resume(throwing: error)
                }
                
                let data = response + Data([sw1, sw2])
                
                continuation.resume(returning: Array(data))
            }
        }
    }
    
    func execute(tag: NFCISO7816Tag) async throws -> ResponseType {
        let data = try await request()
        
        assert(data.count == 1, "request should return exactly one data item in the array")
        
        let bytes = try await sendCommand(data.first, tag: tag)
        
        return try await response(bytes: bytes)
    }
}
