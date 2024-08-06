import CoreNFC
import CSDK

class CSDKAPIChainCallError: CSDKAPICallError {
    enum CSDKAPIChainCallErrorType {
        case chainCallFailedEarly(Int, Int)
        case chainCallFinishedEarly(Int, Int)
        case emptyChainCall
    }

    var chainCallErrorType: CSDKAPIChainCallErrorType?

    init(_ errorType: CSDKAPIChainCallErrorType) {
        self.chainCallErrorType = errorType

        super.init()
    }

    override init(_ errorType: CSDKAPICallErrorType) {
        self.chainCallErrorType = nil

        super.init(errorType)
    }

    override var errorDescription: String? {
        guard let chainCallErrorType = chainCallErrorType else {
            return super.errorDescription
        }

        switch chainCallErrorType {
        case let .chainCallFailedEarly(step, total): return "Chain call failed early - \(step)/\(total)"
        case let .chainCallFinishedEarly(step, total): return "Chain call finish early - \(step)/\(total)"
        case .emptyChainCall: return "Empty chain call"
        }
    }
}

class CSDKAPIChainCall<T>: CSDKAPICall<T> {
    func sendCommand(_ data: [Data], tag: NFCISO7816Tag) async throws -> [UInt8] {
        for (index, apdu) in data.enumerated() {
            let bytes = try await sendCommand(apdu, tag: tag)

            if index == data.count - 1 {
                return bytes
            }

            guard data.count == 2 else {
                throw CSDKAPIChainCallError(.chainCallFinishedEarly(index, data.count))
            }

            let sw1 = bytes[0]
            let sw2 = bytes[1]

            guard sw1 == 0x90, sw2 == 0x00 else {
                throw CSDKAPIChainCallError(.chainCallFailedEarly(index, data.count))
            }
        }


        throw CSDKAPIChainCallError(.emptyChainCall)
    }

    override func execute(tag: NFCISO7816Tag) async throws -> ResponseType {
        let data = try await request()

        let bytes = try await sendCommand(data, tag: tag)

        return try await response(bytes: bytes)
    }
}
