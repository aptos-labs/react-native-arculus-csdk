import CSDK

final class WalletSeedCreateWallet: CSDKAPICall<String> {
    private let nbrOfWords: Int
    
    init(wallet: OpaquePointer, nbrOfWords: Int) {
        self.nbrOfWords = nbrOfWords
        
        super.init(wallet: wallet)
    }
    
    override func request() async throws -> [Data] {
        var len: size_t = 0
        
        guard let bytes = WalletSeedCreateWalletRequest(wallet, &len, nbrOfWords) else {
            throw CSDKAPICallError(.requestCreationFailed("seed create wallet"))
        }
        
        return [Data(bytes: bytes, count: len)]
    }
    
    override func response(bytes: [UInt8]) async throws -> ResponseType {
        var mnemonicSentenceLength: size_t = 0
        
        guard let response = WalletSeedCreateWalletResponse(wallet, bytes, bytes.count, &mnemonicSentenceLength) else {
            throw CSDKAPICallError(.responseParsingFailed("seed create wallet"))
        }
        
        let data = Data(bytes: response, count: mnemonicSentenceLength)
        
        guard let phrase = String(data: data, encoding: .utf8) else {
            throw CSDKAPICallError(.responseParsingFailed("seed create wallet"))
        }
        
        return phrase.trimmingCharacters(in: .controlCharacters)
    }
}
