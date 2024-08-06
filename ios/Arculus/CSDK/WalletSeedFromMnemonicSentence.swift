import CSDK

enum WalletSeedFromMnemonicSentenceError: Error, LocalizedError {
    case invalidMnemonicSentence
    case parseFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidMnemonicSentence: return "Invalid mnemonic sentence"
        case .parseFailed: return "Could not parse mnemonic sentence"
        }
    }
}

class WalletSeedFromMnemonicSentence: CSDKAPICommand<[UInt8]> {
    private let mnemonicSentence: String
    
    init(wallet: OpaquePointer, mnemonicSentence: String) {
        self.mnemonicSentence = mnemonicSentence
        
        super.init(wallet: wallet)
    }
    
    override func execute() async throws -> ResponseType {
        guard let mnemonicData = mnemonicSentence.data(using: .utf8) else {
            throw WalletSeedFromMnemonicSentenceError.invalidMnemonicSentence
        }
        
        let mnemonicPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: mnemonicData.count)
        
        mnemonicData.copyBytes(to: mnemonicPointer, count: mnemonicData.count)
        
        defer { mnemonicPointer.deallocate() }
        
        var len: size_t = 0
        
        guard let bytes = CSDK.WalletSeedFromMnemonicSentence(wallet, mnemonicPointer, mnemonicData.count, nil, 0, &len) else {
            throw WalletSeedFromMnemonicSentenceError.invalidMnemonicSentence
        }
        
        return [UInt8](Data(bytes: bytes, count: len))
    }
}
