import CoreNFC
import CSDK

class CSDKAPI {
    var tag: NFCISO7816Tag
    var wallet: OpaquePointer
    
    init(tag: NFCISO7816Tag) {
        self.tag = tag
        self.wallet = WalletInit()
    }
    
    deinit {
        WalletFree(wallet)
    }
    
    func walletGetFirmwareVersion() async throws -> WalletGetFirmwareVersion.ResponseType {
        try await WalletGetFirmwareVersion(wallet: wallet).execute(tag: tag)
    }
    
    func walletGetGGUID() async throws -> WalletGetGGUID.ResponseType {
        try await WalletGetGGUID(wallet: wallet).execute(tag: tag)
    }
    
    func walletGetPublicKeyFromPath(path: String, curve: UInt16) async throws -> WalletGetPublicKeyFromPath.ResponseType {
        try await WalletGetPublicKeyFromPath(wallet: wallet, path: path, curve: curve).execute(tag: tag)
    }
    
    func walletInitRecoverWallet(nbrOfWords: Int) async throws -> WalletInitRecoverWallet.ResponseType {
        try await WalletInitRecoverWallet(wallet: wallet, nbrOfWords: nbrOfWords).execute(tag: tag)
    }
    
    func walletInitSession() async throws -> WalletInitSession.ResponseType {
        try await WalletInitSession(wallet: wallet).execute(tag: tag)
    }
    
    func walletResetWallet() async throws -> WalletResetWallet.ResponseType {
        try await WalletResetWallet(wallet: wallet).execute(tag: tag)
    }
    
    func walletSeedCreateWallet(nbrOfWords: Int) async throws -> WalletSeedCreateWallet.ResponseType {
        try await WalletSeedCreateWallet(wallet: wallet, nbrOfWords: nbrOfWords).execute(tag: tag)
    }
    
    func walletSeedFinishRecoverWallet(seed: [UInt8]) async throws -> WalletSeedFinishRecoverWallet.ResponseType {
        try await WalletSeedFinishRecoverWallet(wallet: wallet, seed: seed).execute(tag: tag)
    }
    
    private func walletSelectWalletV1() async throws -> Void {
        let aid = try await WalletSelectWallet(wallet: wallet, applicationAID: ApplicationAID.v1).execute(tag: tag)
        
        guard aid == ApplicationAID.v1.aid else {
            throw WalletSelectWalletError.expectedAIDNotMet(ApplicationAID.v1)
        }
    }
    
    private func walletSelectWalletV2() async throws -> Void {
        try await walletInitSession()
    }
    
    func walletSelectWallet() async throws -> Void {
        let aid = try await WalletSelectWallet(wallet: wallet, applicationAID: ApplicationAID.v2).execute(tag: tag)
        
        switch aid {
        case ApplicationAID.v1.aid:
            try await walletSelectWalletV1()
        case ApplicationAID.v2.aid:
            try await walletSelectWalletV2()
        default:
            throw WalletSelectWalletError.invalidAID
        }
    }
    
    func walletSignHash(path: String, curve: UInt16, algorithm: UInt8, hash: String) async throws -> WalletSignHash.ResponseType {
        try await WalletSignHash(wallet: wallet, path: path, curve: curve, algorithm: algorithm, hash: hash).execute(tag: tag)
    }
    
    func walletStoreDataPIN(pin: String) async throws -> WalletStoreDataPIN.ResponseType {
        try await WalletStoreDataPIN(wallet: wallet, pin: pin).execute(tag: tag)
    }
    
    func walletVerifyPIN(pin: String) async throws -> WalletVerifyPIN.ResponseType {
        try await WalletVerifyPIN(wallet: wallet, pin: pin).execute(tag: tag)
    }
    
    func seedFromMnemonicSentence(mnemonicSentence: String) async throws -> WalletSeedFromMnemonicSentence.ResponseType {
        try await WalletSeedFromMnemonicSentence(wallet: wallet, mnemonicSentence: mnemonicSentence).execute()
    }
}

